function [ vanishingPoint ] = VPFromTwoPointsOfTwoParallelLines( p1L1 , p2L1, p1L2 , p2L2)

    if size(p1L1,1) == 2
        p1L1 = vertcat(p1L1,1);
    end

    if size(p2L1,1) == 2
        p2L1 = vertcat(p2L1,1);
    end

    if size(p1L2,1) == 2
        p1L2 = vertcat(p1L2,1);
    end

    if size(p2L2,1) == 2
        p2L2 = vertcat(p2L2,1);
    end

    [p1L1  p2L1 p1L2  p2L2]

    line1 = cross(p1L1, p2L1);
    line2 = cross(p1L2, p2L2);

    line1 = line1/line1(3);
    line2 = line2/line2(3);

    vpNotNorm= cross(line1, line2);

    if vpNotNorm(3) ~= 0
        vanishingPoint = vpNotNorm / vpNotNorm(3);
    else
        vanishingPoint = vpNotNorm;
    end

end

