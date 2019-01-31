function [ lines ] = SelectLongestSegmentsForDirections( couples, params )
% SELECTLONGESTSEGMENTSFORDIRECTIONS
% COUPLES: line verteces
% PARAMS: line parameters
% rows in matrix couples are grouped by direction
% there is corrispondence between couples and params, the same row index
% the same actual line.

    if size(couples, 2)~= 4
        error('Error in the format of points couples');
    end
    
    if size(params, 2)~= 2
        error('Error in the format of line parameters');
    end
    
    if size(couples,1) ~= size(params,1)
        error('Error of uncompliant function parameters');
    end
    
    theta_pos = 6;
    total_lines_count = size(couples,1);
    
    unique_params = unique(params, 'rows');
    unique_lines_count = size(unique_params,1);
    
    line_ref_param = params(1,:);
    line_ref_points = couples(1,:);
    lines_saved_count = 0;
    lines_selected = zeros(unique_lines_count,6);
    
% selects the longest line for each direction detected
    for i=2:total_lines_count
        current_line_param = params(i,:);
        current_line_points = couples(i,:);
        if line_ref_param(1) == current_line_param(1) && line_ref_param(2) == current_line_param(2)
            if pdist2(line_ref_points(1:2), line_ref_points(3:4)) < pdist2(current_line_points(1:2), current_line_points(3:4))
                line_ref_param = current_line_param;
                line_ref_points = current_line_points;
            end
        else
           lines_saved_count = lines_saved_count + 1;
           lines_selected(lines_saved_count,:) = [line_ref_points line_ref_param];
           line_ref_param = current_line_param;
           line_ref_points = current_line_points;
        end
    end
    
    lines_saved_count = lines_saved_count + 1;
    lines_selected(lines_saved_count,:) = [line_ref_points line_ref_param];

    lines_selected = sortrows(lines_selected, theta_pos);
    
    lines = zeros(unique_lines_count, 3);
    
% computes the line parameters
    for i=1:unique_lines_count
        p1 = lines_selected(i,1:2);
        p2 = lines_selected(i,3:4);
        lines(i,:) = LineFromPoints(p1',p2');
    end

end

