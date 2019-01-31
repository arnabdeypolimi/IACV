function [ points ] = OrientedSquareRoI( origin , slope, size)

% the ORIGIN is the center of the square
% the SLOPE is expected to be expressed in radians
% the SIZE is the edge lenght of the square


roh = size * sqrt(2)/2;
points = ones(4,2);

for i=1:4
    deltaX = roh*cos(slope+(i-1)*pi/2);
    deltaY = roh*sin(slope+(i-1)*pi/2);
    points(i,:) = [ origin(1)+deltaX , origin(2)+deltaY];
end


end

