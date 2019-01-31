function [ penPosition, distance, orientation ] = locateBrush ( image , K, tableCorners)

    pHalfeSize = 5;
    threshold = 25;

    penIndex = 0;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];

        redF1 = patchRedFactor(rgb_frame(subplus(xy(1,2)-pHalfeSize):xy(1,2)+pHalfeSize, subplus(xy(1,1)-pHalfeSize):xy(1,1)+pHalfeSize, :));
        redF2 = patchRedFactor(rgb_frame(subplus(xy(2,2)-pHalfeSize):xy(2,2)+pHalfeSize, subplus(xy(2,1)-pHalfeSize):xy(2,1)+pHalfeSize, :));
        %fprintf('%f %f ',redF1, redF2);

        if redF1 > threshold 
            plot(xy(1,1),xy(1,2),'o','LineWidth',4,'Color','blue');
            penIndex = k;
        end
        if redF2 > threshold 
            plot(xy(2,1),xy(2,2),'o','LineWidth',4,'Color','blue');
            penIndex = k;
        end
    end

end

