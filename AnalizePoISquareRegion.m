function [ isElected ] = AnalizePoISquareRegion( PoI, slope, squareSize, image )

    % the PoI is the center of the square
    % the SLOPE is expected to be expressed in radians
    % the SIZE is the edge lenght of the square
    % the IMAGE is a RGB image

    blackMag = zeros(4,1);
    whiteMag = zeros(4,1);
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

        for j=1:area
           val1 = val1 + WhiteMagnitude(image(col(j), row(j),:),'rgb');
           val2 = val2 + BlackMagnitude(image(col(j), row(j),:),'rgb');
        end

        whiteMag(i) = val1/area;
        blackMag(i) = val2/area;
    end
        %blackMag
        %whiteMag

    whiteThreshold = 0.45;
    blackThreshold = 0.15;
    % COLOR SPACE?

    isConfiguration1 = blackMag(1) >= blackThreshold && whiteMag(2) >= whiteThreshold && blackMag(3) >= blackThreshold && whiteMag(4) >= whiteThreshold;
    isConfiguration2 = whiteMag(1) >= whiteThreshold && blackMag(2) >= blackThreshold && whiteMag(3) >= whiteThreshold && blackMag(4) >= blackThreshold;

    isElected = isConfiguration1 || isConfiguration2;

    if isElected
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

