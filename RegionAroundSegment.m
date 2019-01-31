function [ region ] = RegionAroundSegment( p1, p2, width )
% REGIONAROUNDSEGMENT: this function computes the four vertices sorrounding
% a line identified by the points p1 and p2 with a distance from it equal
% to width
% P1: first line point
% P2: second line point
% width: distance from the line

    R1 = [cos(pi/4) -sin(pi/4); sin(pi/4) cos(pi/4)];
    R2 = [cos(-pi/4) -sin(-pi/4); sin(-pi/4) cos(-pi/4)];

    p1p2 = (p2-p1)/norm(p2-p1);
    p2p1 = (p1-p2)/norm(p1-p2);
    
    Q1 = R2*width*p2p1+p1;
    Q2 = R1*width*p2p1+p1;

    Q3 = R2*width*p1p2+p2;
    Q4 = R1*width*p1p2+p2;

    region = [Q1';Q2';Q3';Q4'];

end