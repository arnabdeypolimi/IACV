% CALIBRATION CODE

close all;
clear
clc;

tic
vps = zeros(6,2);

% flag to control the visualization of the vanishing points while they are
% computed
showCalibrationImages = 1;

% VPs computation in a set of 3 different oriented and placed pictures of
% the table.
for i=1:3

    frame = imread(['pics/',num2str(i) ,'.JPG']);
    bw_frame = single(rgb2gray(frame));

    [corners, vps_tmp]= ExtractFromImageRectVerticesAndVPs(bw_frame, 0.03);
    if showCalibrationImages == 1
        figure(i), imshow(frame,[]); hold on;
        
        figure(i), plot(corners(:,1), corners(:,2), '+g','MarkerSize', 5);
        figure(i), plot([corners(:,1); corners(1,1)], [corners(:,2);corners(1,2)], 'LineStyle', ':','LineWidth',2,'Color','red');

        figure(i), plot(vps_tmp(:,1),vps_tmp(:,2),'+r','MarkerSize', 10);
    end
    
    vps((i-1)*2+1,:) = vps_tmp(1,:);
    vps((i-1)*2+2,:) = vps_tmp(2,:);
end

height = size(frame, 1);
width = size(frame, 2);

% Calibration

% riarranges the vanishing points coordinates
xh = [vps(1,1),vps(3,1),vps(5,1)]';
yh = [vps(1,2),vps(3,2),vps(5,2)]';
xv = [vps(2,1),vps(4,1),vps(6,1)]';
yv = [vps(2,2),vps(4,2),vps(6,2)]';

if showCalibrationImages == 1
    
    % displays all the couples of vanishing points for each image and plots
    % a line connecting them.
    
    for i=1:3
        figure(i), plot([xh(i) xv(i)],[yh(i) yv(i)], 'LineStyle', '-', 'Color','g');
        fprintf('[%f, %f]\n',xh(i), xv(i));
        fprintf('[%f, %f]\n',yh(i), yv(i));
        xm = (xh(i)+xv(i))/2;
        ym = (yh(i)+yv(i))/2;
        figure(i),plot(xm,ym,'db','MarkerSize', 10);
    end
end

% Normalize coordinates

% each row of the vectors H and V contains the vanishing points from the
% same image, then these the coordinates of H and V are normalized using
% the biggest of the screen dimensions
H = NormalizeInScreenCoordinates([xh yh], [width, height]);
V = NormalizeInScreenCoordinates([xv yv], [width, height]);

% the calibration matrix is computed and immediately its components are
% denormalized back
K = CalibrationWithThreeCoupleOrthoVP(H(:,1), H(:,2), V(:,1), V(:,2));
K = DenormalizeCalibrationMatrix(K,[width, height]);
K

% this variable contains the time elapsed since the calibration algorithm
% has been fired
timeToCalibrate = toc;

% displays the principal point on each image use for the calibration
if showCalibrationImages == 1
    for i=1:3
        figure(i), plot(K(2,3), K(1,3),'oy','MarkerSize', 5);
    end
end

% 3D Reconstruction

% the last image used in the calibration algorithm represents the final
% camera orientation
last_frame_vps = vps_tmp;
last_frame_img = bw_frame;
last_frame_corners = corners;
last_frame_edges = [LineFromPoints(corners(1,:)',corners(2,:)')';
                    LineFromPoints(corners(2,:)',corners(3,:)')';
                    LineFromPoints(corners(3,:)',corners(4,:)')';
                    LineFromPoints(corners(4,:)',corners(1,:)')'];

% the vector table_size contains the physical dimension of the table, the
% first dimension specified is the longest one
table_size = [93 54];

figure(4), imshow(last_frame_img, []); hold on;
figure(4), plot(last_frame_corners(:,1), last_frame_corners(:,2), '+g','MarkerSize', 5);
figure(4), plot([last_frame_corners(:,1); last_frame_corners(1,1)], [last_frame_corners(:,2);last_frame_corners(1,2)], 'LineStyle', ':','LineWidth',2,'Color','red');

% at this point the user input is required to specify which of the segments
% delimiting the table is the longest, it's required in order to match
% correctly the actual table size with the table image
% it is sufficient to click near the segment
[x, y] = getpts();

tic

% to understand which is the nearest segment the respective distances are
% computed 
selected_point = [x y];
distances = zeros(4,1);

for i=1:4
    distances(i) = DistanceLineToPoint(last_frame_edges(i,:), selected_point);
end

% the index of the minimum distance from the user-provided point is
% computed
nearest_line_index = find(distances==min(distances));

reordered_corners = zeros(4, 2);
reordered_edges = zeros(4,3);
CCcorners = zeros(4,2);

% the table edge segments are riarranged in order to put first the one
% identified by user input
for i=0:3
    reordered_edges(i+1,:) = last_frame_edges(mod(nearest_line_index(1)+i-1,4)+1,:);
    reordered_corners(i+1,:) = last_frame_corners(mod(nearest_line_index(1)+i-1,4)+1,:);
    CCcorners(i+1,:) = reordered_corners(i+1,:); 
end

% the 3D coordinates of the table are computed
[corners3D ] = LocalizeRectPointsFromPointImagesVpsAndActualSize(CCcorners, table_size, K, [width height]);

% this variable contains the amount of time elapsed since the beginning of
% the 3D reconstruction algorithm
timeToLocalizeTable = toc;

scene3D = figure(5);

figure(scene3D), hold on, plot3( [corners3D(:,1)' corners3D(1,1)'], [corners3D(:,2)' corners3D(1,2)'], [corners3D(:,3)' corners3D(1,3)'] );

% for i=1:4
%     figure(scene3D), plot3([corners3D(i,1) [0 0 0]], [corners3D(i,2) [0 0 0]], [corners3D(i,3) [0 0 0]], 'LineStyle',':','Color', 'blue');
% end

disp(['Calibration time: ',num2str(timeToCalibrate)]);
disp(['Localization time: ',num2str(timeToLocalizeTable)]);

clear bw_frame corners distances frame H height i
clear last_frame_edges last_frame_img last_frame_vps
clear nearest_line_index reordered_* selected_point showCalibrationImages
clear timeToCalibrate timeToLocalizeTable V vps vps_tmp width x* y*

x = last_frame_corners(:,1)';
y = last_frame_corners(:,2)';

clear last_frame_corners ans