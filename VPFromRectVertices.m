function [ VP1, VP2 ] = VPFromRectVertices( a, b, c, d )
%VPFROMQUADRILAT Summary of this function goes here
%   a b c d sono i lati specificati adiacenti uno di seguito all'altro.

if size(a,1) <2 || size(b,1) <2 || size(c,1) <2 || size(d,1) <2
    error('Parameters Error');
end

if size(a,1) == 2
        a = vertcat(a,1);
end

if size(b,1) == 2
        b = vertcat(b,1);
end

if size(c,1) == 2
        c = vertcat(c,1);
end

if size(d,1) == 2
        d = vertcat(d,1);
end

l_ab = cross(a,b);
l_cd = cross(c,d);

l_ad = cross(a,d);
l_bc = cross(c,b);

VP1 = cross(l_ad,l_bc);
VP2 = cross(l_ab,l_cd);

if VP1(3) ~= 0
    VP1 = VP1/VP1(3);
end

if VP2(3) ~= 0
    VP2 = VP2/VP2(3);
end

end

