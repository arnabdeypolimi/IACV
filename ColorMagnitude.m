function [ magnitude ] = ColorMagnitude( targetColor, pixel )
  % the PIXEL paramater is intended as rgb space color
  % the TARGETCOLOR paramater is intended as rgb space color

    debug = 0;
  
    tmpPix = double([pixel(1) pixel(2) pixel(3)]);
    color = rgb2hsv(tmpPix/255.0);
    targetColorHSV = rgb2hsv(targetColor/255.0);
    
    hx = color(1);
    hv = targetColorHSV(1);
    
    h = mod(hx+(0.5-hv),1);
    
  % h component impact
    a = 0.2; % width factor 0.12
    b = 6; % parabolic exponent
    hWeight = subplus(1-((h-0.5)/a)^b);
    
    s = color(2);
    v = color(3);
    
  % sv components impact
    a = 0.8; % width factor 0.72
    b = 4; % parabolic exponent
    svWeight= subplus(1-(((s-1)/a)^b-((v-1)/a)^b));
    
    magnitude = hWeight * 1; %svWeight

    if debug == 1
        fprintf('\nhue: %f sat: %f val: %f target: %f mag: %f colorRGB: [%d %d %d]',color(1),color(2),color(3),targetColorHSV(1),magnitude , pixel(1),pixel(2),pixel(3));
    end
end