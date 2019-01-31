debug = 1;
%54 x 93 cm

% the camera frame is loaded and converted in in b/w
% the bw_frame contrast can be adjusted changing the values [0 1]
rgb_frame = imread('pics/4.jpg');
bw_frame = imadjust(single(rgb2gray(rgb_frame))/255,[0 1],[]);
frame = double(single(rgb2gray(rgb_frame)));

% the frame need to be smoothed a bit to delete some noise in the image,
% however the dimension of the gaussian kernel must be small otherwise it
% could delete or modify important features of the image
height = size(rgb_frame, 1);
width = size(rgb_frame, 2);
k_factor = 0.01;
k_size = 4;
k_halved_size = round(k_size/2);
sigma_gauss = k_size/6;
h = fspecial('gaussian' , k_size , sigma_gauss);

frame=conv2(frame , h , 'same');

m = size(frame,1);
n = size(frame,2);
 
% the image is masked keeping the details outside the taple plane from
% influence the brush detection
RoI = poly2mask(x, y, m, n);
crop = RoI .* frame;

% the edges of the masked image are identified
edges = edge(crop ,'prewitt');

% the hough transform is used on the edges dected to fit lines that could
% be belong to the brush
[H,T,R] = hough(edges);
P  = houghpeaks(H,8,'threshold',ceil(0.15*max(H(:))));
lines = houghlines(edges,T,R,P,'FillGap',28,'MinLength',70);

% the following code displays the lines identified by the hough transform
figure(2), imshow(rgb_frame,[]), hold on

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end

% the following portion of code is responsible for the fitering of the
% lines identified in order to isolate the one that has a red area around
% one of its vertices
pHalfeSize = 5*2;
threshold = 25;

penIndex = 0;

% for each line we compute the redness of both vertices the one exceeding
% the red threshold is elected storing the index where that line is in the
% lines vector
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    
    redF1 = patchRedFactor(rgb_frame(subplus(xy(1,2)-pHalfeSize):xy(1,2)+pHalfeSize, subplus(xy(1,1)-pHalfeSize):xy(1,1)+pHalfeSize, :));
    redF2 = patchRedFactor(rgb_frame(subplus(xy(2,2)-pHalfeSize):xy(2,2)+pHalfeSize, subplus(xy(2,1)-pHalfeSize):xy(2,1)+pHalfeSize, :));
    % fprintf('%f %f ',redF1, redF2);
    
    if redF1 > threshold 
        plot(xy(1,1),xy(1,2),'o','LineWidth',4,'Color','blue');
        penIndex = k;
    end
    if redF2 > threshold 
        plot(xy(2,1),xy(2,2),'o','LineWidth',4,'Color','blue');
        penIndex = k;
    end
end

% if the index is not set the brush hasn't been detected, anyway this is a
% preliminar detection, later in the DetectBrushTipsAndMarks algorithm we
% will detect more accurately it
if penIndex == 0
    error('pen not found');
end

penVertexes = [lines(penIndex).point1;lines(penIndex).point2];

% now we create another mask around the identified brush, inside this area
% we will appy a subpixel filter in order to detect more precisely the
% brush slope and its tips

% maxDistanceFromBrush is the maxium distance from the brush line defining
% the masking area
maxDistanceFromBrush = 10;

% the mask is computed using RegionAroundSegment specifing two line
% vertices and a distance
regionPoints = RegionAroundSegment(penVertexes(1,:)',penVertexes(2,:)',maxDistanceFromBrush);
penRegion = poly2mask(regionPoints(:,1), regionPoints(:,2), m, n);

% the slope of the brush is calculated
theta = T(penIndex);
penSlope = atan((penVertexes(1,2)-penVertexes(2,2))/(penVertexes(1,1)-penVertexes(2,1)));

% the DetectBrushTipsAndMarks algorithm is able to analyze the masked area
% on a subpixel level, this guarantees a more precise localization of the
% brush. The function returns the red and the green tips of the brush,
% moreover it fids the marks placed on the brush body to help 3D
% localization
[ redTip, brushMarks, greenTip] = DetectBrushTipsAndMarks( bw_frame, rgb_frame, penRegion, penSlope );

% for simplicity the calibration matrix from the folder 18 computed by the
% CameraCalibration algorithm is declared here
%K = [[746.1211 0 513.3663];[0 746.1211 399.4005]; [0 0 1.0000]];


% these two distances represents the distance between marks, the former,
% while the latter is the lenght of the brush body
markToMarkDistance = 4.625; % cm
redToGreenTipDistance = 20; % cm

% in order to limit numerical errors we normalize coordinates as usual.
brushMarksN = NormalizeInScreenCoordinates(brushMarks,size(bw_frame));

% using the VanishingPointFromThreeCollinearPoints algorithm we can place
% the vanishing point associated with the direction of the brush
brushVPN = VanishingPointFromThreeCollinearPoints(brushMarksN,[markToMarkDistance markToMarkDistance*2]');

% we transform back to actual image coordinates and then we plot the
% vanishing point
brushVP = ActualImageCoordinates(brushVPN,size(bw_frame));

%figure(2), plot([redTip(1) brushVP(1)]',[redTip(2) brushVP(2)]','LineWidth',2,'Color','red');
%figure(2), plot(brushVP(1),brushVP(2),'o','LineWidth',4,'Color','green');

% thanks to the LocateCollinearPoints_VP_RealDistance algorithm and the
% just computed vanishing point we can calculate the 3D coordinates of the
% two brush tips
[redTip3D, greenTip3D] = LocateCollinearPoints_VP_RealDistance(redTip, greenTip, brushVP, K, redToGreenTipDistance,[width height]);

figure(scene3D), plot3([redTip3D(1) greenTip3D(1)], [redTip3D(2) greenTip3D(2)], [redTip3D(3) greenTip3D(3)],'Color','magenta');

%figure(5), imshow(bw_frame,[]),hold on, plot(brushPatternCorner(:,1),brushPatternCorner(:,2),'o','LineWidth',4,'Color','magenta');

clear brush* bw_frame crop debug edges folder frame greenTip
clear h H height k k_factor k_halved_size k_size lines m markToMarkDistance
clear maxDistanceFromBrush n P pen* pHalfeSize R redF1 redF2 redTip redToGreenTipDistance
clear regionPoints rgb_frame Roi sigma_gauss T theta threshold width xy
