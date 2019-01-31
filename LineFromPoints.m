function [ line ] = LineFromPoints( point1, point2 )

    if size(point1,1) == 2
            point1 = vertcat(point1,1);
    end

    if size(point2,1) == 2
            point2 = vertcat(point2,1);
    end

    line = cross(point1, point2);
    line = line/line(3);

end

