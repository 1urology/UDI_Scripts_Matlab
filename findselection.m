function [bbb] = findselection(z,x)

bbb = find(z > x(1) & z < x(2));

end
