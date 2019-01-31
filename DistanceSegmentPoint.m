function [ dist ] = DistanceSegmentPoint( segP1, segP2, P )

    mat = [segP2-segP1, P-segP1];
    dist = abs(det(mat))/abs(segP2-segP1);

end

