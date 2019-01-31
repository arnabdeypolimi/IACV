function [ Kd ] = DenormalizeCalibrationMatrix( Kn, dimensions )
%DENORMALIZECALIBRATIONMATRIX: this function takes as input a camera
%calibration matrix K and the dimensions of a reference system frame, it
%outputs the denormalized calibration matrix

    normFactor = max(dimensions);
    
    Kd = Kn;
    
    Kd(1,1) = Kd(1,1)*normFactor;
    Kd(2,2) = Kd(2,2)*normFactor;
    
    Kd(:,3) = ActualImageCoordinates(Kd(:,3)',dimensions)';
    
end

