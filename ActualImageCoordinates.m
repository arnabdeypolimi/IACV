function [ coord ] = ActualImageCoordinates( norm, dimensions )
    
    normFactor = max(dimensions);
    lenghts = ones(1,size(1,size(norm,2)))*normFactor;

    if size(size(norm),2) == 2
        coord = norm;
        points = size(norm, 1);

        for i=1:points
            %coord(i,1:2) = coord(i,1:2).*lenghts+lenghts/2;
            coord(i,1:2) = coord(i,1:2).*lenghts;
        end
    else
        error('Vectors dimension not compliant');
    end
end