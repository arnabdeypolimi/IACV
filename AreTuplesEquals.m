function [ e ] = AreTuplesEquals( t1, t2 )
%AREPOINTSEQUALS Summary of this function goes here
%   Detailed explanation goes here

if size(t1,1) ~= size(t2,1) || size(t1,2) ~= size(t2,2)
    error('tuples dimension incongruency');
end

e=1;
i=1;
while i <= size(t1,2) && e==1
    if t1(i) ~= t2(i)
        e=0;
    end
    i=i+1;
end

end

