function [ redTip, marks, greenTip ] = DetectBrushTipsAndMarks( area, rgbArea, mask, slope )
%DETECT3DBRUSH Summary of this function goes here
%   AREA: image pixels representing the area containing the brush
%   MASK: bit mask specifing which pixels have to be analyzed by the subpix
%   algorithm
%   VERTEX2D: coordinates in the AREA image corresponding to the brush tip
%   SLOPE: value representing the slanting of the brush expressed in
%   dregrees

    debug = 1;
    
    houghFigure = 12;
    rectRegionFigure = 11;
    subpixFigure = 10;
    colorAnalysisFigure = 13;

% CONTRASTS image
    area = imadjust(area,[0.15 0.85],[]);
    
% puts the values of slope and orthoslope within the [-pi/2, pi/2] range
    if slope > pi/2
        slope = slope - pi;
    end
    if slope < -pi/2
        slope = slope + pi;
    end
        
    if slope < 0
        orthoslope = slope + pi/2;
    else
        orthoslope = slope - pi/2;
    end

% Applies SUBPIXEL Filter
    filter_size = 3;
    houghMaxRho = round(norm(size(area))*1.4);
    houghMaxTheta = 270;
    houghMaxRhoSensed = round(norm(size(area)));
    houghMaxThetaSensed = 270;

    param = [houghMaxRho, houghMaxTheta, houghMaxRhoSensed, houghMaxThetaSensed];

    [imSubData, houghMatrix,pool] = SubpixelFilterMasked(area, mask, filter_size, param);
    
    if debug==1
        figure(houghFigure), imshow(houghMatrix,[]),hold on;
        figure(subpixFigure),imshow(rgbArea), hold on;
        for i=1:size(area,1)
            for j=1:size(area,2)
                ff = imSubData(i,j).pow;
                t = 0.07;
                if ff > t
                    p1 = imSubData(i,j).point1;
                    p2 = imSubData(i,j).point2;
                    x = [p1(1) p2(1)];
                    y = [p1(2) p2(2)];
                    plot(x,y,'LineWidth',0.2,'Color','green');
                end
            end
        end
    end
    
% IDENTIFIES more precisely the BRUSH ANGLE
% moreover it gets a segment crossing entirely the image so that scanning
% it end-to-end we can be sure to cross the red/green tip sooner or later
    [brushLineVertices, brushHoughpts] = SubpixelLinesWithSlope(houghMatrix, 1, param, size(area),pool,radtodeg(slope));
    
    tip1 = round(brushLineVertices(1).point1);
    tip2 = round(brushLineVertices(1).point2);
    
    if debug == 1
        figure(houghFigure), plot(brushHoughpts(2),brushHoughpts(1),'+','LineWidth',4,'Color','red');
        figure(subpixFigure), plot(tip1(1),tip1(2),'o','LineWidth',4,'Color','yellow');
        figure(subpixFigure), plot(tip2(1),tip2(2),'o','LineWidth',4,'Color','yellow');
        p1 = brushLineVertices(1).point1;
        p2 = brushLineVertices(1).point2;
        figure(subpixFigure), plot([p1(1) p2(1)],[p1(2) p2(2)],'LineWidth',0.2,'Color','red');
    end
    
    
% FIND brush red and green TIPs 
    colorAnalysis = zeros(size(area));
    pt = tip1;
    if tip2(1)-tip1(1) < tip2(2)-tip1(2)
        distance = tip2(2)-tip1(2);
    else
        distance = tip2(1)-tip1(1);
    end
    
    deltapt = (tip2-tip1)/(distance);
    maxRed = 0;
    maxGreen = 0;
    redTip = [0 0];
    greenTip = [0 0];
    i = 0;
    
    while i < abs(distance)
        intpt = floor(pt);
        tmpRed = RedMagnitude(rgbArea(intpt(2),intpt(1),:));
        tmpGreen = GreenMagnitude(rgbArea(intpt(2),intpt(1),:));
        colorAnalysis(intpt(2),intpt(1)) = tmpGreen;
        
        if tmpRed > maxRed
            redTip = intpt;
            maxRed = tmpRed;
        end
        
        if tmpGreen > maxGreen
            greenTip = intpt;
            maxGreen = tmpGreen;
        end
        pt = pt + deltapt;
        i = i + 1;
    end
    
    if debug == 1
        figure(colorAnalysisFigure), imshow(colorAnalysis,[]), hold on;
        figure(subpixFigure), plot(greenTip(1),greenTip(2),'o','LineWidth',4,'Color','red');
        figure(subpixFigure), plot(redTip(1),redTip(2),'o','LineWidth',4,'Color','green');
    end
    
    
    %Rectangular REGION scanning brush line
    w = 16;
    h = 2;
    mainpoint = [w w];
    p1 = mainpoint + [ w/2*cos(orthoslope) + h/2*cos(orthoslope) , w/2*sin(orthoslope) - h/2*sin(orthoslope)];
    p2 = mainpoint + [ w/2*cos(orthoslope) - h/2*cos(orthoslope) , w/2*sin(orthoslope) + h/2*sin(orthoslope)];
    p3 = mainpoint + [ - w/2*cos(orthoslope) - h/2*cos(orthoslope) , - w/2*sin(orthoslope) + h/2*sin(orthoslope)];
    p4 = mainpoint + [ - w/2*cos(orthoslope) + h/2*cos(orthoslope) , - w/2*sin(orthoslope) - h/2*sin(orthoslope)];
    
    px = [p1(1) p2(1) p3(1) p4(1) p1(1)];
    py = [p1(2) p2(2) p3(2) p4(2) p1(2)];
    scanMask = poly2mask(px, py, w*2+1,w*2+1);
    
    if debug == 1
        figure(rectRegionFigure), imshow(scanMask,[]);
    end
    
    [y, x] = find(scanMask == 1);
    y = y - mainpoint(2);
    x = x - mainpoint(1);
   
    % SCAN brush line to look for orthogonal MARKS
    if abs(greenTip(1) - redTip(1)) < abs(greenTip(2) - redTip(2))
        distance = abs(greenTip(2) - redTip(2));
    else
        distance = abs(greenTip(1) - redTip(1));
    end
    
    deltapt = (greenTip-redTip)/distance;
        
    maskPoints = size(x,1);
    subpixthreshold = 0.0;
   
    marksOkPixelCount = zeros(distance,1);
    marks = zeros(distance,2);
    marksCount = 0;
    
    adjust = 15/180*pi;
    
    brushCrop = 0.05;
    
    i = abs(distance)*brushCrop;
    pt = redTip + i*deltapt;
    
    while i < abs(distance)*(1-brushCrop)
        orthoMag = 0;
        intpt = round(pt);
        okCount = 0;
                
        for j=1:maskPoints
            actual_pt = intpt + [x(j) y(j)];
            if actual_pt(1) > 0 && actual_pt(1) < size(imSubData,2) && actual_pt(2) > 0 && actual_pt(2) < size(imSubData,1)
                subpixElem = imSubData(actual_pt(2),actual_pt(1));
                elemSlope = subpixElem.slope;
                if elemSlope > slope-adjust && elemSlope < slope+adjust
                    orthoMag = orthoMag + subpixElem.pow;
                    okCount = okCount + 1;
                end
            end
        end
        
        if orthoMag > subpixthreshold
            marksCount = marksCount + 1;
            marks(marksCount,:) = intpt;
            marksOkPixelCount(marksCount) = okCount;
            %fprintf('\n%f',orthoMag);
        end
        
        pt = pt + deltapt;
        i = i + 1;
    end
    
    marks = marks(1:marksCount,:);
    
   % FILTER selected points
   
    marks = FilterNearPointsWithWeights(marks,marksOkPixelCount);

    marksDists = [norm(marks(1,:)-redTip) norm(marks(2,:)-redTip) norm(marks(3,:)-redTip)];
    
    [~, marksOrder] = sort(marksDists, 'ascend');
    
    marks = [marks(marksOrder(1),:) ; marks(marksOrder(2),:) ; marks(marksOrder(3),:)];
    
    if debug == 1
        figure(subpixFigure),plot(marks(:,1),marks(:,2),'+','LineWidth',8,'Color','yellow');
    end
    
    maxMarks = 3;
    if size(marks,1) ~= maxMarks
        error('Too many orthogonal marks recognized');
    end

end

