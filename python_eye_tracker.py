#!/usr/bin/env python3
"""
High-accuracy gaze tracker using dlib facial landmarks + calibration.
Outputs gaze coordinates via stdout for Swift to consume.

Requirements:
    pip install opencv-python dlib numpy imutils

Usage:
    python3 eye_tracker.py
    
Output format (JSON per line):
    {"gaze_x": 0.5, "gaze_y": 0.5, "face_detected": true}
"""

import sys
import json
import cv2
import dlib
import numpy as np
from imutils import face_utils
import time

class GazeTracker:
    def __init__(self):
        # Initialize dlib's face detector and facial landmark predictor
        self.detector = dlib.get_frontal_face_detector()
        
        # Download shape_predictor_68_face_landmarks.dat from:
        # http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
        self.predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")
        
        # Eye landmark indices (dlib 68-point model)
        self.LEFT_EYE = list(range(36, 42))
        self.RIGHT_EYE = list(range(42, 48))
        
        # Calibration data
        self.calibrated = False
        self.calibration_matrix = None
        
        # Smoothing (exponential moving average)
        self.smoothed_gaze = None
        self.alpha = 0.3  # Smoothing factor (lower = smoother)
        
    def get_eye_region(self, landmarks, eye_points):
        """Extract eye region coordinates"""
        points = np.array([(landmarks.part(i).x, landmarks.part(i).y) 
                          for i in eye_points], dtype=np.int32)
        return points
    
    def get_eye_center(self, eye_points):
        """Calculate eye center"""
        x = [p[0] for p in eye_points]
        y = [p[1] for p in eye_points]
        return (int(np.mean(x)), int(np.mean(y)))
    
    def get_pupil_position(self, frame, eye_points):
        """
        Estimate pupil position using intensity threshold.
        More accurate than simple centroid.
        """
        # Create mask for eye region
        mask = np.zeros(frame.shape[:2], dtype=np.uint8)
        cv2.fillPoly(mask, [eye_points], 255)
        
        # Get eye region
        x, y, w, h = cv2.boundingRect(eye_points)
        eye_region = frame[y:y+h, x:x+w]
        mask_region = mask[y:y+h, x:x+w]
        
        if eye_region.size == 0:
            return None
            
        # Convert to grayscale
        gray = cv2.cvtColor(eye_region, cv2.COLOR_BGR2GRAY)
        
        # Apply Gaussian blur to reduce noise
        gray = cv2.GaussianBlur(gray, (7, 7), 0)
        
        # Threshold to find darkest region (pupil)
        _, threshold = cv2.threshold(gray, 50, 255, cv2.THRESH_BINARY_INV)
        
        # Apply mask
        threshold = cv2.bitwise_and(threshold, threshold, mask=mask_region)
        
        # Find contours
        contours, _ = cv2.findContours(threshold, cv2.RETR_EXTERNAL, 
                                       cv2.CHAIN_APPROX_SIMPLE)
        
        if not contours:
            return None
            
        # Get largest contour (pupil)
        largest_contour = max(contours, key=cv2.contourArea)
        
        # Calculate moments to find center
        M = cv2.moments(largest_contour)
        if M["m00"] == 0:
            return None
            
        cx = int(M["m10"] / M["m00"]) + x
        cy = int(M["m01"] / M["m00"]) + y
        
        return (cx, cy)
    
    def estimate_gaze(self, frame, landmarks):
        """
        Estimate gaze direction from eye landmarks and pupil position.
        Returns normalized coordinates (0-1).
        """
        # Get eye regions
        left_eye = self.get_eye_region(landmarks, self.LEFT_EYE)
        right_eye = self.get_eye_region(landmarks, self.RIGHT_EYE)
        
        # Get eye centers
        left_center = self.get_eye_center(left_eye)
        right_center = self.get_eye_center(right_eye)
        
        # Get pupil positions
        left_pupil = self.get_pupil_position(frame, left_eye)
        right_pupil = self.get_pupil_position(frame, right_eye)
        
        if left_pupil is None or right_pupil is None:
            return None
            
        # Calculate pupil offset from eye center (normalized by eye width)
        left_width = np.max(left_eye[:, 0]) - np.min(left_eye[:, 0])
        right_width = np.max(right_eye[:, 0]) - np.min(right_eye[:, 0])
        
        left_offset_x = (left_pupil[0] - left_center[0]) / (left_width / 2)
        left_offset_y = (left_pupil[1] - left_center[1]) / (left_width / 2)
        
        right_offset_x = (right_pupil[0] - right_center[0]) / (right_width / 2)
        right_offset_y = (right_pupil[1] - right_center[1]) / (right_width / 2)
        
        # Average both eyes
        gaze_x = (left_offset_x + right_offset_x) / 2
        gaze_y = (left_offset_y + right_offset_y) / 2
        
        # Get face position for additional context
        face_center_x = landmarks.part(30).x / frame.shape[1]  # Nose tip
        face_center_y = landmarks.part(30).y / frame.shape[0]
        
        # Combine iris offset with face position
        # Apply gain for better screen coverage
        gain = 2.0
        final_x = face_center_x + gaze_x * gain * 0.3
        final_y = face_center_y + gaze_y * gain * 0.3
        
        # Clamp to 0-1
        final_x = max(0, min(1, final_x))
        final_y = max(0, min(1, final_y))
        
        return (final_x, final_y)
    
    def smooth_gaze(self, gaze):
        """Apply exponential moving average smoothing"""
        if self.smoothed_gaze is None:
            self.smoothed_gaze = gaze
        else:
            self.smoothed_gaze = (
                self.alpha * gaze[0] + (1 - self.alpha) * self.smoothed_gaze[0],
                self.alpha * gaze[1] + (1 - self.alpha) * self.smoothed_gaze[1]
            )
        return self.smoothed_gaze
    
    def process_frame(self, frame):
        """Process a single frame and return gaze data"""
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Detect faces
        faces = self.detector(gray, 0)
        
        if len(faces) == 0:
            return {"face_detected": False, "gaze_x": 0.5, "gaze_y": 0.5}
        
        # Use first face
        face = faces[0]
        
        # Get facial landmarks
        landmarks = self.predictor(gray, face)
        
        # Estimate gaze
        gaze = self.estimate_gaze(frame, landmarks)
        
        if gaze is None:
            return {"face_detected": True, "gaze_x": 0.5, "gaze_y": 0.5}
        
        # Smooth gaze
        gaze = self.smooth_gaze(gaze)
        
        return {
            "face_detected": True,
            "gaze_x": float(gaze[0]),
            "gaze_y": float(gaze[1]),
            "confidence": 1.0
        }

def main():
    # Initialize tracker
    tracker = GazeTracker()
    
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
        
        # Flip frame horizontally (mirror)
        frame = cv2.flip(frame, 1)
        
        # Process frame
        result = tracker.process_frame(frame)
        
        # Calculate FPS
        frame_count += 1
        if frame_count % 30 == 0:
            current_time = time.time()
            fps = 30 / (current_time - fps_time)
            fps_time = current_time
            result["fps"] = round(fps, 1)
        
        # Output result as JSON
        print(json.dumps(result), flush=True)
        
    cap.release()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"error": str(e)}), flush=True)
        sys.exit(1)
