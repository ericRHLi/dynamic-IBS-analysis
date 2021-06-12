function allstate = plotdfn(ibsdata, statevector, roi_label)
% This funciton plot each dynamic FC network based on the input
% Input:
%     ibsdata: must be roi x roi x time frame (window number)
%     statevector: include the state labels, must equals to the number of window
%     label: the name of each ROI
%
% Output:
% allstate: all network for each state, roi x roi x state.

% Rihui Li
% June-10-2021
% Stanford University

[num_roi1, num_roi2,num_win] = size(ibsdata);
num_state = length(unique(statevector));

if num_win ~= length(statevector)
    error('number of time window does not equal to state number!')
end

if ~exist('roi_label','var')
    roi_label = cellstr(string([1:num_roi1]));
end

figure, hold on
for i = 1: num_state
    idx = find(statevector == i);
    allstate(:,:,i) = mean(ibsdata(:,:,idx),3);
   
    subplot(1,num_state,i)
    imagesc(allstate(:,:,i));
    colorbar;
    title(['State: ' string(i)])
    set(gca, 'XTickLabel', roi_label, 'YTickLabel', roi_label);
end
hold off

end