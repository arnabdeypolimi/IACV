function [ magnitude ] = WhiteMagnitude( pixel , colorFormat)

    color = pixel;

    if strcmp(colorFormat,'rgb')
        color = rgb2hsv(pixel);
        a = 5;
        b = 4; % even number, paraboloid exponent
        c = 0.4;

        x = color(3); %brightness
        y = color(2); %saturation

        magnitude = subplus(-1/a * ( ((x-1)/c)^b + (y/c)^b ) + 1);
    end
    
    if strcmp(colorFormat,'bw')
        a = 0.4; % 0.5
        b = 5; % parabolic exponent 4

        x = color; %bw

        magnitude = subplus(-(((-x+1)/a)^b)+1);
    end
    
end