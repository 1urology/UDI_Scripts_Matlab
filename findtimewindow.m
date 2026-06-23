function [idx_time] = findtimewindow(t_window,Pmax_idx, w1, w2)

if length(Pmax_idx)~=1
    sprintf('dual peak flag = %1.0f', 1)
    idx_time = find(t_window>t_window(Pmax_idx(1))-w1 & t_window<=t_window(Pmax_idx(1))+w2); 
else
    idx_time = find(t_window>t_window(Pmax_idx)-w1 & t_window<=t_window(Pmax_idx)+w2);
end

end

%%Kai used t, I used tt -> why?
%%I changed it from t to t_window