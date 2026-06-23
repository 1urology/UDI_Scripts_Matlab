function [section] = findsection(t,z_idx_Pmax, w_idx_thresh2)

if length(z_idx_Pmax)~=1
    section = find(t>t(w_idx_thresh2(1)) & t<=t(z_idx_Pmax(1))); 
else
    section = find(t>t(w_idx_thresh2(1)) & t<=t(z_idx_Pmax));
end

end
