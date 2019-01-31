function [ points3D ] = LocalizeRectPointsFromPointImagesVpsAndActualSize( corners, table_size, K, image_size)
%LOCALIZERECTPOINTSFROMPOINTIMAGESVPSANDACTUALSIZE Summary of this function goes here
%   The first couple of points is the one of lenght specified at the first
%   index of table_size vector
%
%     V1
%
%   A-----D
%   |     | 
%   |     |    V2
%   |     |
%   B-----C
% 
%   corners = [A B C D]

    A = corners(1,:);
    B = corners(2,:);
    C = corners(3,:);
    D = corners(4,:);

    V1 = TwoLinesIntersectionPoint(LineFromPoints(A', B'),LineFromPoints(D',C'))';
    V2 = TwoLinesIntersectionPoint(LineFromPoints(A', D'),LineFromPoints(B',C'))';

    [A3D, B3D] = LocateCollinearPoints_VP_RealDistance(A, B, V1(1:2), K, table_size(1),image_size);
    [~ , D3D] = LocateCollinearPoints_VP_RealDistance(A, D, V2(1:2), K, table_size(2),image_size);

    C3D = D3D + (B3D-A3D);
    
    points3D = [A3D; B3D; C3D; D3D];
    
end

