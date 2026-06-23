function [minimum_idx, minimum] = findmin(z)

minimum_idx = find(z==min(z));
minimum = min(z);

end