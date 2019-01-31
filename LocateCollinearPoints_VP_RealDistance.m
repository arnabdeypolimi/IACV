function [ A3D, C3D ] = LocateCollinearPoints_VP_RealDistance( A, C, VP, K , AC3DDistance,image_size)
% LOCATECOLLINEARPOINTS: this function, based on triangle properties, can
% compute the 3D coordinates of two points whose images are A and C lying on
% the direction identified by the vanishing point VP. Moreover it uses the matrix K
% which is the camera calibration matrix and the real distance between the
% 3D points
%   A,C = are the images of the two collinear poins the last
%   VP = is the vanishing point associated with the AC direction
%   K = calbration matrix
%   AC3DDISTANCE = the real 3D distance between the two points
%   image_size = the size of the image used to relocate the coordinates in
%                the correct reference system

    f = K(1,1); % focal lenght
    %f = 50;
    
    A = image_size/2 - A;
    C = image_size/2 - C;
    VP = image_size/2 - VP;
    
    P = K(1:2,3)'; % principal point

    VP3D = [ P(1)-VP(1) P(2)-VP(2) -f];
    
    AO = sqrt(distance(A,P)^2 + f^2);
    CO = sqrt(distance(C,P)^2 + f^2);
    alpha = acos(f/AO);
    beta = acos(f/CO) - alpha;

    line3Ddir = K * VP3D' / norm(K * VP3D');
    
    rayOC = -[ P(1)-C(1) P(2)-C(2) -f ];
    dirOC = rayOC / norm(rayOC);
    
    rayOA = -[ P(1)-A(1) P(2)-A(2) -f ];
    dirOA = rayOA / norm(rayOA);
    
    gamma = acos(line3Ddir*dirOC);

    A3Ddist = AC3DDistance * sin(gamma)/sin(beta);
    C3Ddist = sqrt(A3Ddist^2+AC3DDistance^2);

    A3D = dirOA * A3Ddist;
    C3D = dirOC * C3Ddist;

end