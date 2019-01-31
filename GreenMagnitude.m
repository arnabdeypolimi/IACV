function [ magnitude ] = GreenMagnitude( pixel )

    hueRange = 35.0/360.0;
    greenHueVal = 120.0/360.0;
    saturationLimit = 20.0/100.0;
    valueLimit = 20.0/100.0;

    hsv_pixel = rgb2hsv(double([pixel(1) pixel(2) pixel(3)])/255);
    
    if ( hsv_pixel(1) < greenHueVal + hueRange && hsv_pixel(1) > greenHueVal - hueRange ) && hsv_pixel(2) > saturationLimit && hsv_pixel(3) > valueLimit 

        hContribution = -(9*abs(hsv_pixel(1)-1/3))^5+1;
        sContribution = hsv_pixel(2)-saturationLimit;
        vContribution = hsv_pixel(3)-valueLimit;
        
        weights = [0.6 0.2 0.2];
        
        magnitude = weights *[hContribution sContribution vContribution]';
    else
        magnitude = 0;
    end


end

