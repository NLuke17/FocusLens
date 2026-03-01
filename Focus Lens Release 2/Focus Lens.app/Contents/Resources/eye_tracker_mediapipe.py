#!/usr/bin/env python3
"""
High-accuracy gaze tracker using MediaPipe Face Mesh + iris landmarks.
Much more accurate than dlib and easier to install!

Requirements:
    pip install opencv-python mediapipe numpy

Usage:
    python3 eye_tracker_mediapipe.py
    
Output format (JSON per line):
    {"gaze_x": 0.5, "gaze_y": 0.5, "face_detected": true, "iris_detected": true}
"""

import sys
import json
import cv2
import numpy as np
import time

try:
    import mediapipe as mp
except ImportError:
    print(json.dumps({"error": "mediapipe not installed. Run: pip install mediapipe"}), flush=True)
    sys.exit(1)

class MediaPipeGazeTracker:
    def __init__(self):
        # Initialize MediaPipe Face Mesh with iris tracking
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            max_num_faces=1,
            refine_landmarks=True,  # Enable iris landmarks!
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        # Iris landmark indices (MediaPipe provides 5 landmarks per iris)
        # Left iris: 468-472, Right iris: 473-477
        self.LEFT_IRIS = [469]   # Center of left iris
        self.RIGHT_IRIS = [474]  # Center of right iris
        
        # Eye corner landmarks (for normalizing iris position)
        self.LEFT_EYE_INNER = 133
        self.LEFT_EYE_OUTER = 33
        self.RIGHT_EYE_INNER = 362
        self.RIGHT_EYE_OUTER = 263
        
        # Face landmarks for head position
        self.NOSE_TIP = 1
        
        # Smoothing (exponential moving average)
        self.smoothed_gaze = None
        self.alpha = 0.4  # Smoothing factor (0.3-0.5 recommended)
        
        # Outlier rejection
        self.gaze_history = []
        self.history_size = 5
        self.outlier_threshold = 0.25
    
    def get_landmark_coords(self, landmarks, indices, w, h):
        """Extract landmark coordinates and convert to pixel space"""
        if isinstance(indices, list):
            coords = np.array([(landmarks[i].x * w, landmarks[i].y * h) for i in indices])
            return coords
        else:
            return np.array([landmarks[indices].x * w, landmarks[indices].y * h])
    
    def estimate_gaze(self, frame, results):
        """
        Estimate gaze using MediaPipe's precise iris tracking.
        Returns normalized coordinates (0-1).
        """
        if not results.multi_face_landmarks:
            return None
        
        landmarks = results.multi_face_landmarks[0].landmark
        h, w = frame.shape[:2]
        
        # Get iris centers
        left_iris = self.get_landmark_coords(landmarks, self.LEFT_IRIS, w, h)[0]
        right_iris = self.get_landmark_coords(landmarks, self.RIGHT_IRIS, w, h)[0]
        
        # Get eye corners for normalization
        left_inner = self.get_landmark_coords(landmarks, self.LEFT_EYE_INNER, w, h)
        left_outer = self.get_landmark_coords(landmarks, self.LEFT_EYE_OUTER, w, h)
        right_inner = self.get_landmark_coords(landmarks, self.RIGHT_EYE_INNER, w, h)
        right_outer = self.get_landmark_coords(landmarks, self.RIGHT_EYE_OUTER, w, h)
        
        # Calculate eye centers and widths
        left_eye_center = (left_inner + left_outer) / 2
        right_eye_center = (right_inner + right_outer) / 2
        left_eye_width = np.linalg.norm(left_outer - left_inner)
        right_eye_width = np.linalg.norm(right_outer - right_inner)
        
        # Normalize iris position relative to eye width
        left_offset_x = (left_iris[0] - left_eye_center[0]) / (left_eye_width / 2)
        left_offset_y = (left_iris[1] - left_eye_center[1]) / (left_eye_width / 2)
        right_offset_x = (right_iris[0] - right_eye_center[0]) / (right_eye_width / 2)
        right_offset_y = (right_iris[1] - right_eye_center[1]) / (right_eye_width / 2)
        
        # Average both eyes for gaze direction
        gaze_offset_x = (left_offset_x + right_offset_x) / 2
        gaze_offset_y = (left_offset_y + right_offset_y) / 2
        
        # Get face position (nose tip as reference)
        nose = self.get_landmark_coords(landmarks, self.NOSE_TIP, w, h)
        face_x = nose[0] / w
        face_y = nose[1] / h
        
        # Combine face position with iris offset
        # Higher gain for better screen coverage
        gain_x = 2.2  # Horizontal sensitivity
        gain_y = 2.0  # Vertical sensitivity
        
        final_x = face_x + gaze_offset_x * gain_x * 0.25
        final_y = face_y + gaze_offset_y * gain_y * 0.25
        
        # Clamp to 0-1
        final_x = max(0, min(1, final_x))
        final_y = max(0, min(1, final_y))
        
        return (final_x, final_y)
    
    def reject_outlier(self, gaze):
        """Reject gaze points that are too different from recent history"""
        if len(self.gaze_history) < 3:
            self.gaze_history.append(gaze)
            return gaze
        
        # Calculate average of recent points
        avg_x = sum(g[0] for g in self.gaze_history) / len(self.gaze_history)
        avg_y = sum(g[1] for g in self.gaze_history) / len(self.gaze_history)
        
        # Calculate distance from average
        distance = np.sqrt((gaze[0] - avg_x)**2 + (gaze[1] - avg_y)**2)
        
        # If too far from average, use last valid point
        if distance > self.outlier_threshold:
            return self.gaze_history[-1]
        
        # Update history
        self.gaze_history.append(gaze)
        if len(self.gaze_history) > self.history_size:
            self.gaze_history.pop(0)
        
        return gaze
    
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
        # Convert BGR to RGB for MediaPipe
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Process with MediaPipe
        results = self.face_mesh.process(rgb_frame)
        
        if not results.multi_face_landmarks:
            return {"face_detected": False, "iris_detected": False, "gaze_x": 0.5, "gaze_y": 0.5}
        
        # Estimate gaze
        gaze = self.estimate_gaze(frame, results)
        
        if gaze is None:
            return {"face_detected": True, "iris_detected": False, "gaze_x": 0.5, "gaze_y": 0.5}
        
        # Reject outliers
        gaze = self.reject_outlier(gaze)
        
        # Smooth gaze
        gaze = self.smooth_gaze(gaze)
        
        return {
            "face_detected": True,
            "iris_detected": True,
            "gaze_x": float(gaze[0]),
            "gaze_y": float(gaze[1]),
            "confidence": 1.0
        }

def main():
    # Initialize tracker
    tracker = MediaPipeGazeTracker()
    
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
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(json.dumps({"error": str(e)}), flush=True)
        sys.exit(1)
