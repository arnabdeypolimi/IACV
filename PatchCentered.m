function [ xCoord, yCoord ] = PatchCentered( point, patchSize, dims )

    x = point(1);
    y = point(2);

    xMin = 1;
    xMax = dims(1);
    
    yMin = 1;
    yMax = dims(2);
    
    if subplus(x-patchSize) > 0
        xMin = subplus(x-patchSize);
    end
    
    if subplus(y-patchSize) > 0
        yMin = subplus(y-patchSize);
    end
    
    if x+patchSize < dims(1)
        xMax = x+patchSize;
    end
    
    if y+patchSize < dims(2)
        yMax = y+patchSize;
    end
    
    xCoord = xMin:xMax;
    yCoord = yMin:yMax;
end

