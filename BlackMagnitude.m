function [ magnitude ] = BlackMagnitude( pixel, colorFormat )

    color = pixel;

    if strcmp(colorFormat,'rgb')
        color = rgb2hsv(pixel);
        a = 0.65;
        b = 4; % parabolic exponent

        x = color(3); %brightness

        magnitude = subplus(-((x/a)^b)+1);
    end
    
    if strcmp(colorFormat,'bw')
        a = 0.55; % 0.5
        b = 5; % parabolic exponent 4

        x = color; %bw

        magnitude = subplus(-((x/a)^b)+1);
    end

end

