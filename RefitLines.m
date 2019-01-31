function [ lines ] = RefitLines( couples, params )

    if size(couples, 2)~= 4
        error('Error in the format of points couples');
    end
    
    if size(params, 2)~= 2
        error('Error in the format of line parameters');
    end
    
    if size(couples,1) ~= size(params,1)
        error('Error of uncompliant function parameters');
    end
    
    unique_params = unique(params, 'rows');
    unique_lines_count = size(unique_params,1);
    
    lines = zeros(unique_lines_count, 3);
    
    for i=1:unique_lines_count
        indices = find(bsxfun(@and,params(:,1) == unique_params(i,1) ,params(:,2) == unique_params(i,2)));
        points_to_fit = [couples(indices, 1:2); couples(indices, 3:4)];
        line = FitLineFromPoints(points_to_fit);
        lines(i,:) = line;
        %lines(i,:) = LineFromPoints(p1',p2');
    end


end

