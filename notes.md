# IACV Project

## Issues
 - In CameraCalibration.m:
    - Vanishing points in the first part of the code don't look accurate: this probably implies that the camera calibration matrix is not correct either.
    - The 3D reconstruction of the table is not a rectangle.
 - In FindPen.m:
    - The recognized pen is not perpendicular to the plane of the table, as it is in the pictures, but almost lying on it.
