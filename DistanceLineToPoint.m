function [ dist ] = DistanceLineToPoint( line, P )

a = line(1);
b = line(2);

xp = P(1);
yp = P(2);

line_perp = [b -a (-b*xp+a*yp)];

R = cross(line_perp/line_perp(3), line/line(3));
R = R / R(3);
R = R(1:2);

dist = distance(R, P);

end

