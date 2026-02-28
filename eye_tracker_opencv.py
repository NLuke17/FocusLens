#!/usr/bin/env python3
"""
Simple eye tracker using OpenCV only (no MediaPipe needed).
Uses Haar Cascade for face/eye detection.

Requirements:
    pip install opencv-python numpy

Usage:
    python3 eye_tracker_opencv.py
    
Output format (JSON per line):
    {"gaze_x": 0.5, "gaze_y": 0.5, "face_detected": true}
"""

import sys
import json
import cv2
import numpy as np
import time

class OpenCVGazeTracker:
    def __init__(self):
        # Load Haar Cascade classifiers (built into OpenCV)
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        self.eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')
        
        # Smoothing
        self.smoothed_gaze = None
        self.alpha = 0.35  # Smoothing factor
        
        # Outlier rejection
        self.gaze_history = []
        self.history_size = 5
        self.outlier_threshold = 0.3
    
    def detect_pupil(self, eye_region):
        """Detect pupil center in eye region"""
        # Convert to grayscale
        gray = cv2.cvtColor(eye_region, cv2.COLOR_BGR2GRAY)
        
        # Apply Gaussian blur
        blur = cv2.GaussianBlur(gray, (7, 7), 0)
        
        # Threshold to find darkest region (pupil)
        _, threshold = cv2.threshold(blur, 30, 255, cv2.THRESH_BINARY_INV)
        
        # Find contours
        contours, _ = cv2.findContours(threshold, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if not contours:
            return None
        
        # Get largest contour (pupil)
        largest = max(contours, key=cv2.contourArea)
        
        # Get center
        M = cv2.moments(largest)
        if M["m00"] == 0:
            return None
        
        cx = int(M["m10"] / M["m00"])
        cy = int(M["m01"] / M["m00"])
        
        return (cx, cy)
    
    def estimate_gaze(self, frame, face):
        """Estimate gaze from face region"""
        x, y, w, h = face
        
        # Extract face region
        face_region = frame[y:y+h, x:x+w]
        
        # Detect eyes in face region
        eyes = self.eye_cascade.detectMultiScale(
            cv2.cvtColor(face_region, cv2.COLOR_BGR2GRAY),
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(20, 20)
        )
        
        if len(eyes) < 2:
            # No eyes detected, use face position
            frame_h, frame_w = frame.shape[:2]
            gaze_x = (x + w / 2) / frame_w
            gaze_y = (y + h / 2) / frame_h
            return (gaze_x, gaze_y)
        
        # Sort eyes by x position (left, right)
        eyes = sorted(eyes, key=lambda e: e[0])
        
        # Get pupil positions
        pupil_offsets = []
        for (ex, ey, ew, eh) in eyes[:2]:  # Use first 2 eyes
            eye_region = face_region[ey:ey+eh, ex:ex+ew]
            if eye_region.size == 0:
                continue
            
            pupil = self.detect_pupil(eye_region)
            if pupil:
                # Normalize pupil position within eye
                offset_x = (pupil[0] - ew / 2) / (ew / 2)
                offset_y = (pupil[1] - eh / 2) / (eh / 2)
                pupil_offsets.append((offset_x, offset_y))
        
        # Calculate gaze
        frame_h, frame_w = frame.shape[:2]
        
        if len(pupil_offsets) >= 1:
            # Average pupil offsets
            avg_offset_x = sum(p[0] for p in pupil_offsets) / len(pupil_offsets)
            avg_offset_y = sum(p[1] for p in pupil_offsets) / len(pupil_offsets)
            
            # Face center as base
            face_center_x = (x + w / 2) / frame_w
            face_center_y = (y + h / 2) / frame_h
            
            # Apply gain
            gain_x = 2.5
            gain_y = 2.2
            
            gaze_x = face_center_x + avg_offset_x * gain_x * 0.2
            gaze_y = face_center_y + avg_offset_y * gain_y * 0.2
        else:
            # Fallback to face center
            gaze_x = (x + w / 2) / frame_w
            gaze_y = (y + h / 2) / frame_h
        
        # Clamp to 0-1
        gaze_x = max(0, min(1, gaze_x))
        gaze_y = max(0, min(1, gaze_y))
        
        return (gaze_x, gaze_y)
    
    def reject_outlier(self, gaze):
        """Reject gaze points that are too different from recent history"""
        if len(self.gaze_history) < 3:
            self.gaze_history.append(gaze)
            return gaze
        
        # Calculate average
        avg_x = sum(g[0] for g in self.gaze_history) / len(self.gaze_history)
        avg_y = sum(g[1] for g in self.gaze_history) / len(self.gaze_history)
        
        # Calculate distance
        distance = np.sqrt((gaze[0] - avg_x)**2 + (gaze[1] - avg_y)**2)
        
        # If too far, use last valid
        if distance > self.outlier_threshold:
            return self.gaze_history[-1]
        
        # Update history
        self.gaze_history.append(gaze)
        if len(self.gaze_history) > self.history_size:
            self.gaze_history.pop(0)
        
        return gaze
    
    def smooth_gaze(self, gaze):
        """Apply exponential moving average"""
        if self.smoothed_gaze is None:
            self.smoothed_gaze = gaze
        else:
            self.smoothed_gaze = (
                self.alpha * gaze[0] + (1 - self.alpha) * self.smoothed_gaze[0],
                self.alpha * gaze[1] + (1 - self.alpha) * self.smoothed_gaze[1]
            )
        return self.smoothed_gaze
    
    def process_frame(self, frame):
        """Process a single frame"""
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Detect faces
        faces = self.face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.2,
            minNeighbors=5,
            minSize=(60, 60)
        )
        
        if len(faces) == 0:
            return {"face_detected": False, "gaze_x": 0.5, "gaze_y": 0.5}
        
        # Use first (largest) face
        face = max(faces, key=lambda f: f[2] * f[3])
        
        # Estimate gaze
        gaze = self.estimate_gaze(frame, face)
        
        # Reject outliers
        gaze = self.reject_outlier(gaze)
        
        # Smooth
        gaze = self.smooth_gaze(gaze)
        
        return {
            "face_detected": True,
            "gaze_x": float(gaze[0]),
            "gaze_y": float(gaze[1]),
            "confidence": 1.0
        }

def main():
    # Initialize tracker
    tracker = OpenCVGazeTracker()
    
    # Open webcam
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 30)
    
    if not cap.isOpened():
        print(json.dumps({"error": "Cannot open camera"}), flush=True)
        return
    
    # Send ready signal
    print(json.dumps({"status": "ready"}), flush=True)
    
    # Process frames
    frame_count = 0
    fps_time = time.time()
    
    while True:
        ret, frame = cap.read()
        if not ret:
            continue
        
        # Flip horizontally
        frame = cv2.flip(frame, 1)
        
        # Process
        result = tracker.process_frame(frame)
        
        # Calculate FPS
        frame_count += 1
        if frame_count % 30 == 0:
            current_time = time.time()
            fps = 30 / (current_time - fps_time)
            fps_time = current_time
            result["fps"] = round(fps, 1)
        
        # Output
        print(json.dumps(result), flush=True)
    
    cap.release()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(json.dumps({"error": str(e)}), flush=True)
        sys.exit(1)
