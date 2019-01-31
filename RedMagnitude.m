function [ magnitude ] = RedMagnitude( pixel )

    redRange = 20.0/360.0; %can't exceed 90
    saturationLimit = 60.0/100.0; % 60
    valueLimit = 50.0/100.0; % 50

    hsv_pixel = rgb2hsv(double([pixel(1) pixel(2) pixel(3)])/255);

    if ( hsv_pixel(1) < redRange || hsv_pixel(1) > 1-redRange ) && hsv_pixel(2) > saturationLimit && hsv_pixel(3) > valueLimit 

        hContribution = ((cos(2*pi*hsv_pixel(1))-cos(2*pi*redRange))/(1-cos(2*pi*redRange)))^5;
        sContribution = hsv_pixel(2)-saturationLimit;
        vContribution = hsv_pixel(3)-valueLimit;
        
        weights = [0.6 0.2 0.2];
        
        magnitude = weights *[hContribution sContribution vContribution]';
    else
        magnitude = 0;
    end
    
end

