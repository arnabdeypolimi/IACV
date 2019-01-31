function [ factor ] = patchRedFactor( patch )
% PATCHREDFACTOR: this function computer the amount of redness of in the
% patch image passed as parameter

    height = size(patch, 1);
    width = size(patch, 2);

    reds = 0;
    redCount = 0;
    
    redRange = 20.0/360.0; %can't exceed 90
    saturationLimit = 60.0/100.0; % 60
    valueLimit = 50.0/100.0; % 50
    
    pixelContribution = 1.5;
    
    for y=1:width
        for x=1:height
            hsv_pixel = rgb2hsv(double(patch(x,y,:))/255);
            hsv_pixel = [hsv_pixel(1,1,1) hsv_pixel(1,1,2) hsv_pixel(1,1,3)];
            if ( hsv_pixel(1) < redRange || hsv_pixel(1) > 1-redRange ) && hsv_pixel(2) > saturationLimit && hsv_pixel(3) > valueLimit 
                pow = 5;
                
                hContribution = ((cos(2*pi*hsv_pixel(1))-cos(2*pi*redRange))/(1-cos(2*pi*redRange)))^pow;
                sContribution = hsv_pixel(2)-saturationLimit;
                vContribution = hsv_pixel(3)-valueLimit;
                
                weights = [0.6 0.2 0.2];
                
                reds = reds + pixelContribution * (weights *[hContribution sContribution vContribution]');
                redCount = redCount +1;
            end
        end
    end

    if redCount > 0
        factor = 100.0*reds/redCount;
    else
        factor = 0;
    end

end

