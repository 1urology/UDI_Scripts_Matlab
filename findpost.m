function [idx_post] = findpost(t_window,Pmax_idx, w2, fs)

if length(Pmax_idx)~=1
    sprintf('dual peak flag = %1.0f', 1)
    idx_post = find(t_window>t_window(Pmax_idx(1)) & t_window<(t_window(Pmax_idx(1))+w2)+1/fs); 
else
    idx_post = find(t_window>t_window(Pmax_idx) & t_window<(t_window(Pmax_idx)+w2)+1/fs);
end

end

