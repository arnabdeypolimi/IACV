function [ eligible ] = isEligiblePoint( PoI, image, area, threshold, targetColor)
% POI: coordinates of the point of interest
% IMAGE: image reference to be analised
% AREA: dimension of the patch
% THRESHOLD: amount of color needed to be recognised
% TARGETCOLOR: color of the eligible PoI
    debug = 0;

    areaHalved = area/2;

    patch = image(subplus(PoI(1)-areaHalved):PoI(1)+areaHalved, subplus(PoI(2)-areaHalved):PoI(2)+areaHalved, :);

    width = size(patch,1);
    height = size(patch,2);

    colorAmount = 0;
    
    for i=1:width
        for j=1:height
            pixel = patch(i,j,:);
            colorAmount = colorAmount + ColorMagnitude(targetColor, pixel);
        end
    end

    if debug == 1
       fprintf('%f ',colorAmount); 
    end
    
    if colorAmount/(width*height) >= threshold
        eligible = 1;
    else
        eligible = 0;
    end
    
end