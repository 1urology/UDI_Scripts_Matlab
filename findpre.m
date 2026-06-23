function [idx_pre] = findpre(t_window,Pmax_idx, w1)

if length(Pmax_idx)~=1
    sprintf('dual peak flag = %1.0f', 1)
    idx_pre = find(t_window>t_window(Pmax_idx(1))-w1 & t_window<=t_window(Pmax_idx(1))); 
else
    idx_pre = find(t_window>t_window(Pmax_idx)-w1 & t_window<=t_window(Pmax_idx));
end

end

% time span from first peak-w1 to one before first peak