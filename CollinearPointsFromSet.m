function [ collinear_pts ] = CollinearPointsFromSet( points )
%COLLINEARPOINTSFROMSET Summary of this function goes here
%   Detailed explanation goes here

    if size(points,2) ~= 2 && size(points,2) ~= 3
        error('points parameter dimension error');
    end

    if size(points,2) == 2
        points = [points ones(size(points,1),1)];
    end

%   margine dovuto all'errore del floating point
    eps = 10^(-6);
    p_count = size(points, 1);
    
    for i=1:p_count
        for j=i+1:p_count
            
%             if j ~= i
                line = cross(points(i,:), points(j,:));
                for k=j+1:p_count
                    
%                     if j ~= k && i ~= k
                        collinear = dotprod(line, points(k,:)');
                        
                        if abs(collinear) < eps
                            if points(i,1)~=points(j,1)
                                if sign(points(i,1)-points(j,1)) ~= sign(points(i,1)-points(k,1))
                                   colSet = [points(j,1:2) points(i,1:2) points(k,1:2)];
                                else
                                    if sign(points(j,1)-points(i,1)) ~= sign(points(j,1)-points(k,1))
                                        colSet = [points(i,1:2) points(j,1:2) points(k,1:2)];
                                    else
                                        colSet = [points(i,1:2) points(k,1:2) points(j,1:2)];
                                    end
                                end
                            else
                                if sign(points(i,2)-points(j,2)) ~= sign(points(i,2)-points(k,2))
                                   colSet = [points(j,1:2) points(i,1:2) points(k,1:2)];
                                else
                                    if sign(points(j,2)-points(i,2)) ~= sign(points(j,2)-points(k,2))
                                        colSet = [points(i,1:2) points(j,1:2) points(k,1:2)];
                                    else
                                        colSet = [points(i,1:2) points(k,1:2) points(j,1:2)];
                                    end
                                end
                            end
                            if ~exist('collinear_pts','var')
                                collinear_pts = colSet;
                            else
                                collinear_pts = vertcat(collinear_pts,colSet);
                            end
                        else
%                             collinear
                        end
                        
%                     end
                end
%             end
        end
    end

end

