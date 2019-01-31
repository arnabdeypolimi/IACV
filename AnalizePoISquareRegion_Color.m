function [ isElected ] = AnalizePoISquareRegion_Color(color1, color2, PoI, slope, squareSize, image, thresholds )

    % the COLOR1 param is intended as an rgb format color
    % the COLOR2 param is intended as an rgb format color
    % the PoI param is the center of the square
    % the SLOPE param is expected to be expressed in radians
    % the SIZE param is the edge lenght of the square
    % the IMAGE param is a RGB image

    color1Mag = zeros(4,1);
    color2Mag = zeros(4,1);
    points = zeros(4,2);

    h = size(image,1);
    w = size(image,2);


    for i=1:4

        points(1,:) = squareSize * [ cos(slope+(i-1)*pi/2-pi/4) , sin(slope+(i-1)*pi/2-pi/4)] + PoI;
        points(2,:) = squareSize * sqrt(2) * [ cos(slope+(i-1)*pi/2) , sin(slope+(i-1)*pi/2)] + PoI; 
        points(3,:) = squareSize * [ cos(slope+(i-1)*pi/2+pi/4) , sin(slope+(i-1)*pi/2+pi/4)] + PoI; 
        points(4,:) = PoI;

        val1 = 0;
        val2 = 0;

        RoI = poly2mask(points(:,1), points(:,2), h, w);
        [col, row] = find(RoI == 1);

        area = size(col,1);
        %fprintf('\ni: %d',i);
        for j=1:area
            currPixel = image(col(j), row(j),:);
           val1 = val1 + ColorMagnitude(color1,currPixel);
           val2 = val2 + ColorMagnitude(color2,currPixel);
           %fprintf('\n c:[%d,%d,%d]',currPixel(1),currPixel(2),currPixel(3));
           %fprintf('\nval1: %f',ColorMagnitude(color1,currPixel));
           %fprintf('\nval2: %f',ColorMagnitude(color2,currPixel));
        end

        %fprintf('\nmag1: %f',val1/area*1.3);
        %fprintf('\nmag2: %f',val2/area*1.3);
        color1Mag(i) = val1/area*1.3;
        color2Mag(i) = val2/area*1.3;
    end
    
    color1Threshold = thresholds(1);
    color2Threshold = thresholds(2);
    
    isConfiguration1 = color1Mag(1) >= color1Threshold && color2Mag(2) >= color2Threshold && color1Mag(3) >= color1Threshold && color2Mag(4) >= color2Threshold;
    isConfiguration2 = color2Mag(1) >= color2Threshold && color1Mag(2) >= color1Threshold && color2Mag(3) >= color2Threshold && color1Mag(4) >= color1Threshold;

    isElected = isConfiguration1 || isConfiguration2;

    if 0==1
       fprintf('\n{');
        for i=1:4

        points(1,:) = squareSize * [ cos(slope+(i-1)*pi/2-pi/4) , sin(slope+(i-1)*pi/2-pi/4)] + PoI;
        points(2,:) = squareSize * sqrt(2) * [ cos(slope+(i-1)*pi/2) , sin(slope+(i-1)*pi/2)] + PoI; 
        points(3,:) = squareSize * [ cos(slope+(i-1)*pi/2+pi/4) , sin(slope+(i-1)*pi/2+pi/4)] + PoI; 
        points(4,:) = PoI;

        fprintf('{{%f,%f},{%f,%f},{%f,%f},{%f,%f}},\n',points(1,1),points(1,2),points(2,1),points(2,2),points(3,1),points(3,2),points(4,1),points(4,2));
        end
        fprintf('},');
    end

end

