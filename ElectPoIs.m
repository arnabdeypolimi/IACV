function [ electedPoI ] = ElectPoIs( PoI, image )
%ELECTPOIS Summary of this function goes here
%   Detailed explanation goes here

    count_PoI = size(PoI,1);
    elected = zeros(count_PoI,1);
    
    colorToElect = [0 70 255];
    
    for i=1:count_PoI
        if isEligiblePoint(PoI(i,:), image, 2, 0.6, colorToElect)
            elected(i) = 1;
        end
    end

    count_elected = length(find(elected == 1));
    electedPoI = zeros(count_elected,2);
    
    index = 1;
    for i=1:count_PoI
        if elected(i)
           electedPoI(index,:) = PoI(i,:);
           index = index + 1;
        end
    end
    
end

