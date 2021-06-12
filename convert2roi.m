function group_ibs = convert2roi(ibsdata, roi)
% This funciton convert the column ibs to a 2D format for visualization
% Input:
%       ibsdata: must be time frame x pair
%       roi: number of roi
% Output:
%       group_ibs: 2D format (roi x roi x time frame

% Rihui Li 
% June-10-2021
% Stanford University


for i = 1:size(ibsdata,1)
    clear init_ibs
    temproi = ones(roi, roi);
    tempibs = ibsdata(i,:);
    init_ibs = tril(temproi);
    init_ibs(find(init_ibs~=0)) = tempibs;
    init_ibs = init_ibs + triu(init_ibs',1);
    group_ibs(:,:,i) = init_ibs;        
end

end