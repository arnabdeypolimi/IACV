function [ subpixdata ] = SubpixelAlgorithm( patch )
% AREA: squared patch of the BW image to filter

    midPixelIndex = ceil(size(patch,1)/2);
    bwTargetValue = patch(midPixelIndex,midPixelIndex);

    gradient = [0 0]';
    
    gauss = fspecial('gaussian',[size(patch,1) size(patch,1)], 1.3);
    
    for i=1:size(patch,1)
        for j=1:size(patch,2)
            currValue = patch(i,j);
            dir = [j-midPixelIndex i-midPixelIndex]';
            normDir = dir / norm(dir);
            power = currValue - bwTargetValue;
            gradient = gradient + power * gauss(i,j) * normDir;
        end
    end
    
    [point1, point2] = SubpixelLinePoints(gradient, patch(midPixelIndex,midPixelIndex));
    slope = atan(gradient(2)/gradient(1));
    
    subpixdata = struct('slope', slope, 'point1', point1,'point2', point2);
end


% È STATO TOTALMENTE REIMPLEMENTATO NEL FILE SUBPIXELFILTER