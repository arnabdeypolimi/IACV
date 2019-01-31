function [ VP ] = VanishingPointFromThreeCollinearPoints( points_2D, distances )
%VANISHINGPOINT Summary of this function goes here
%   POINTS_2D: contains the 2D coordinates of the images of the 3D points
%   (3D)[ A B C ] -> [ a b c ](2D)
%   DISTANCES: contains the distances of 3D points wrt the first one [AB AC]

    if size(points_2D,1) ~=3 || size(points_2D,2) ~=2
        error('wrong #points_2D');
    end
    
    if size(distances,1) ~=2 || size(distances,2) ~=1
        error('wrong #distances');
    end
    
    aP = points_2D(1,:);
    bP = points_2D(2,:);
    cP = points_2D(3,:);
    
    dirLine2D = (cP-aP)/norm(cP-aP);
    
    AB = distances(1);
    AC = distances(2);
    BC = abs(AC-AB);
    
    a = norm(aP - aP);
    b = norm(bP - aP);
    c = norm(cP - aP);
    
    L = (a-c)/(b-c);
    
    d = (a*AC-L*b*BC)/(AC-L*BC);
    
    VP = aP + d*dirLine2D;

end

