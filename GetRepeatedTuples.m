function [ repeatedTuples ] = GetRepeatedTuples( tuples )
%GETREPEATEDTUPLES Summary of this function goes here
%   Detailed explanation goes here

tuples_count = size(tuples,1);
checked = zeros(tuples_count,1);
for i=1:tuples_count
    if checked(i) == 0
        for j=i+1:tuples_count
            if checked(j) == 0
                if AreTuplesEquals(tuples(i,:), tuples(j,:))
                    checked(i) = 1;
                    if ~exist('repeatedTuples', 'var')
                    	repeatedTuples = tuples(i,:);
                    else
                        repeatedTuples = [repeatedTuples ; tuples(i,:)];
                    end
                end
            end
        end
    end
    
end

