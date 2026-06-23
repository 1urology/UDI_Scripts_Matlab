function [peak_idx, peak] = findpeak(z)

peak_idx = find(z==max(z));
peak = max(z);

end