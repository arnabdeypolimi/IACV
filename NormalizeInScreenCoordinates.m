function [ norm ] = NormalizeInScreenCoordinates( coord, dimensions )
% NORMALIZEINSCREENCOORDINATES: this function takes as input parameters
% a set of coordinates and the dimensions of the reference system frame,
% and it outputs the nomalized set of coordinates

%computes the maximum reference-system-frame dimension
    normFactor = max(dimensions);
    lenghts = ones(1,size(1,size(coord,2)))*normFactor;

    if size(size(coord),2) == 2
        norm = coord;
        points = size(coord, 1);
% for each point computes its normalized coordinates
        for i=1:points
            %norm(i,1:2) = (norm(i,1:2)-lenghts/2)./lenghts;
            norm(i,1:2) = norm(i,1:2)./lenghts;
        end
    else
        error('Vectors dimension not compliant');
    end

end