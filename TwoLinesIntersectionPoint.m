function [ point ] = TwoLinesIntersectionPoint( line1, line2 )

    if size(line1,1) == 2
            line1 = [line1, 1];
    end

    if size(line2,1) == 2
            line2 = [line2, 1];
    end

    point = cross(line1, line2);
    point = point/point(3);
end
