%finds a prolonged section which starts 1s before w_idx_thresh2 and ends 1s
%after z_idx_Pmax --> helps to overcome the "endpoint problem" when
%smoothing the data
function [section] = findprolongedsection(t,z_idx_Pmax, w_idx_thresh2)

if length(z_idx_Pmax)~=1
    section = find(t>(t(w_idx_thresh2(1))-1) & t<=(t(z_idx_Pmax(1)))+1); 
else
    section = find(t>(t(w_idx_thresh2(1))-1) & t<=(t(z_idx_Pmax))+1);
end

end
