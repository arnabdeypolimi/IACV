function [ out_vett ] = FilterNearPointsWithWeights( in_vett, weights )
%FILTERNEARPOINTSWITHWIGHTS supposed an ordered in_vett vector deletes rows
%too close
%   IN_VETT: input vector to be filtered
%   WEIGHTS: vector containing weights distinguishing close points

    tmp_vett = zeros(size(in_vett));
    tmp_weight = zeros(size(in_vett));
    rows = size(in_vett,1);    
    
    i = 1;
    j = 1;
    
    tmp_index = 1;
   
    while j < rows
        
        j = j + 1;
        
        current = in_vett(i,:);
        currentWeight = weights(i);
        
        next = in_vett(j,:);
        nextWeight = weights(j);
        
        tmp_vett(tmp_index,:) = current;
        if norm(current-next) < 3
            if weights(i) >= weights(j)
                tmp_vett(tmp_index,:) = current;
                tmp_weight(tmp_index) = currentWeight;
            else
                tmp_vett(tmp_index,:) = next;
                tmp_weight(tmp_index) = nextWeight;
                i = j;
            end
        else
            i = j;
            tmp_index = tmp_index + 1;
            tmp_vett(tmp_index,:) = next;
            tmp_weight(tmp_index) = nextWeight;
        end
    end
    
    tmp_vett = tmp_vett(1:tmp_index,:);
    tmp_weight = tmp_weight(1:tmp_index);
    
    [ ~ , indices] = sort(tmp_weight,'descend');
    
    out_vett = [tmp_vett(indices(1),:) ; tmp_vett(indices(2),:) ; tmp_vett(indices(3),:)];
    
end

