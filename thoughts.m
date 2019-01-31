a = [1 2 3];
b = [2 4 6];
c = [2 1];

if size(a)==size(b)
    fprintf('a==b\n'); % <-
else
    fprintf('a~=b\n');
end

if size(a)==size(c)
    fprintf('a==c\n');
else
    fprintf('a~=c\n');% <-
end

