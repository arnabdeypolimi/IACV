function [ vertices, VPs ] = ExtractFromImageRectVerticesAndVPs( image, blur_factor )
% ExtractFromImageRectVerticesAndVPs this function given an image and a blur
% factor is able to detect a rectangular shape, computes the four verteces
% and the two vanishing points associated with 
% IMAGE: is the image that has to be analized
% BLUR_FACTOR: is the blur factor to apply to the image in order to remove
% useless details

% the debug flag if set to 1 enables portions of code that display or write
% on the textual console infos about the execution of the code
    debug = 1;
    edgesAlgorithm = 2; % 1 LongestSegment else RefitLines
    houghMaxDistanceLines = 30; % 5(poor)->30(ok) [20 is default]

    height = size(image, 1);
    width = size(image, 2);
    
% definition of the parameters for the gaussian kernel for the denoising
% filter

    k_factor = blur_factor;
    k_size = round(max(size(image))*k_factor);
    k_halved_size = round(k_size/2);
    sigma_gauss = k_size/6;
    h = fspecial('gaussian' , k_size , sigma_gauss);

% the filter is applied to the input image
    gauss_image=conv2(image , h , 'same');

% edge extraction 
    edges = edge(gauss_image ,'prewitt');
    
% cuts out the denoising filter framing effect
    edges(1:k_halved_size, 1:end) = 0;
    edges(end-k_halved_size:end, 1:end) = 0;
    edges(1:end, 1:k_halved_size) = 0;
    edges(1:end, end-k_halved_size:end) = 0;
    
% the hough transform is applied to the image obtained from the edge
% extraction. We need to fit 4 lines that will represents our table edges
    [H,T,R] = hough(edges);
    P  = houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(edges,T,R,P,'FillGap',houghMaxDistanceLines,'MinLength',7); 
    lines_count = size(lines,2);
    
    if debug == 1
        % plots on the edges image the line fitted by the hough transform
        imshow(edges), hold on
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
            
            % plots line vertices
            plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        end
    end
    
% loads in the vector points the vertices of the lines fitted by the HT e
% then in the vector params the parameters describing the lines. The
% coordinates of the verteces are previously nomalized in order to minimize
% numeric errors during the varius computation where they are involved
    points1 = zeros(lines_count, 2);
    points2 = zeros(lines_count, 2);
    for i=1:lines_count
        points1(i,:) = [lines(i).point1(1) ; lines(i).point1(2)];
        points2(i,:) = [lines(i).point2(1) ; lines(i).point2(2)];
    end
 
    points1 = NormalizeInScreenCoordinates(points1, [width, height]);
    points2 = NormalizeInScreenCoordinates(points2, [width, height]);
    points = [points1  points2];
    
    params = [lines(:).rho ; lines(:).theta]';

    
    if edgesAlgorithm == 1
        % for each direction we select the one that should be the best one 
        % which means the one that fits most point so the longest one
        rect_edges_lines = SelectLongestSegmentsForDirections(points, params);
    else
        % for each direction we take all the points of the segments
        % identified to get a better fitted line. (useless, the method
        % above works fine)
        rect_edges_lines = RefitLines(points, params);
    end
    
    if any(size(rect_edges_lines) ~= [4, 3])
        error('Error finding rect edges');
    end
    
% now working in NORMALIZED SCREEN COORDINATES
    
% we compute the 6 intersection points between the 4 lines obtained before,
% these six points are 4 rectangle vertices and 2 vanishing points
    comb = [1,2; 1,3; 1,4; 2,3; 2,4; 3,4];
    candidates = zeros(6,2);
    for i=1:6
        line1 = rect_edges_lines(comb(i,1),:);
        line2 = rect_edges_lines(comb(i,2),:);
        tmp_candidate =TwoLinesIntersectionPoint(line1',line2');
        candidates(i,:) = tmp_candidate(1:2);
    end
    
    collinear_points = CollinearPointsFromSet(candidates);
 
% identifies the set of collinear points that cross in the internal point
% wrt the rectangle
    coupleFound = 0;
    colliner_sets = 4;
    if size(collinear_points,1) == colliner_sets
        i=1;
        while i <= colliner_sets-1 && coupleFound == 0
            count = 1;
            j=i+1;
            while j <=colliner_sets && coupleFound == 0
                if collinear_points(i, 3) == collinear_points(j,3) && collinear_points(i, 4) == collinear_points(j,4)
                    count= count+1;
                end
                if count == 2
                    coupleFound = 1;
                    same_mid_point = [i j];
                    internal_point = collinear_points(i,3:4);
                 end
                j=j+1;
            end
            
            i=i+1;
        end
    else
        error('Error computing collinear points from candidates');
    end
    
% identifies the set of collinear points crossing in the external point wrt
% the rectangle
    selected_tuples_indices = setdiff(1:4,same_mid_point);
    selected_points = [collinear_points(selected_tuples_indices,[1 2]); collinear_points(selected_tuples_indices,[5 6])];
    external_point = GetRepeatedTuples(selected_points);

    
% finds the vanishing points
    VPs = zeros(2,2);
    count = 1;
    for i=1:size(selected_points,1)
        if ~AreTuplesEquals(selected_points(i,:),external_point)
            VPs(count,:) = selected_points(i,:);
            count = count+1;
        end
    end
    
% copies the other vertices which are the rectangle vertices
    vertices = zeros(4,2);
    vertices(1,:) = internal_point;
    vertices(3,:) = external_point;
    count = 2;
    i=1;

    while i<=6
        noVP = ~AreTuplesEquals(candidates(i,:), VPs(1,:)) && ~AreTuplesEquals(candidates(i,:), VPs(2,:));
        noExtInt = ~AreTuplesEquals(candidates(i,:), internal_point) && ~AreTuplesEquals(candidates(i,:), external_point);
        if noVP && noExtInt
            vertices(count,:) = candidates(i,:);
            count = count+2;
        end
        i = i+1;
    end

% the following couple of lines bring back the coordinates of the six
% points previously analyzed in the image coordinate system
    vertices = ActualImageCoordinates(vertices, [width, height]);
    VPs = ActualImageCoordinates(VPs, [width, height]);
end