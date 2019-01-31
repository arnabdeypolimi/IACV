function [ line ] = FitLineFromPoints( points )

    line = polyfit(points(:,1), points(:,2), 1);
    line = [line(1) -1 line(2)]/line(2);

end

