function [ out_vett] = DeleteDuplicates( in_vett )
%DELETEDUPLICATES Summary of this function goes here
%   Detailed explanation goes here

    if size(in_vett,1) >1

        tmp_vett = zeros(size(in_vett));
        tmp_index = 1;

        tmp_vett(1,:) = in_vett(1,:);

        for el_index=2:size(in_vett,1)
            check = 1;
            tmp_scan=1;
            while tmp_scan <= tmp_index && check == 1
                check = check & ~isequal(tmp_vett(tmp_scan,:),in_vett(el_index,:));
                tmp_scan = tmp_scan + 1;
            end
            if check == 1
                tmp_index = tmp_index + 1;
                tmp_vett(tmp_index,:) = in_vett(el_index,:);
            end
        end

        out_vett = tmp_vett(1:tmp_index,:);
    else
        out_vett = in_vett;
    end
    
end

