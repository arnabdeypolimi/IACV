# IACV Project

## Issues
 - In CameraCalibration.m:
    - Principal point is offset with respect to the centre of the images;
      unless the images are cropped or the sensor was not centered W.R.T.
      the focal point, this is a hint that the calibration matrix is not
      accurate.
    - The 3D reconstruction of the table is not a rectangle.
 - In FindPen.m:
    - The recognized pen is not perpendicular to the plane of the table, as it is in the pictures, but almost lying on it.
