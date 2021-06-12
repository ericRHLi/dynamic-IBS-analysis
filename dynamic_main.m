%% This is the source code to perform dynamic inter-brain synchrony analysis in our paper:
% Rihui Li, Naama Mayseless, Stephanie Balters, Allan L. Reiss,
% "Dynamic Inter-Brain Synchrony in Real-life Inter-Personal Cooperation: A
% Functional Near-infrared Spectroscopy Hyperscanning Study"
% NeuroImage,2021,118263

% Only key steps for obtaining dynamic IBS states are included
% Rihui Li 
% June-10-2021
% Stanford University


% Load the data to be analyzed (not included here). 
data = load(""); % You will need the time series data in time points X ROI or chan format. 


%% ------- Dynamic functional connectivity analysis ------------%
Fs = 7.81;
window = round(30*Fs);    % 30s window
overlap = round(1*Fs);    % 1s overlap
segment = 1:overlap:duration-window;

% Get the segmented data in each window
for ii = 1:numel(segment)
    segdata(ii,:,:) = mean(data([segment(ii):segment(ii)+window],:,:));    
end

% Perform k-mean cluster at group level
ibsdata = mean(segdata, 3);

% Check the cluster-cost curve first 
for k = 1:15
    display(string(k))
    [idx,C,sumd,D] = kmeans(ibsdata, k,'MaxIter', 500,  'Distance','correlation','Replicates', 1000);
    ratio(k) = sum(sumd(:))/sum(D(:));  
end

figure,
plot(ratio)

%% Set k based on elbow method and get the group-level FC stage, here we use k = 5
cluster = 5;
[idx, C] = kmeans(ibsdata, cluster,'MaxIter', 500,  'Distance','correlation','Replicates', 1000);

% Sort the cluster order to follow 1 to 5 order
newCent = zeros(size(C));
state = unique(idx, 'stable');
newCent = C(state,:);
newidx = zeros(size(idx));

for ii = 1:length(state)
   newidx(find(idx == state(ii))) = ii;   
end

% Plot for visualization
figure,
plot(newidx,'LineWidth', 4); ylim([0  6]);yticks([[] 1:4 []])

% Plot the FC
roi_name = {'SFG','aPFC','IFG','aSTG','PG','pSTG','IPL','TPJ'};
roi = 8;

group_ibs = convert2roi(ibsdata,roi);
allstate = plotdfn(group_ibs,newidx, roi_name);

figure, imagesc(mean(group_ibs,3)); title('Static IBS')
set(gca, 'XTickLabel', roi_name, 'YTickLabel', roi_name,'FontSize',12,'FontWeight','bold');


%% Let's look into the dIBS for single subject using the group-defined centroids
centroid = C;

for i = 1:size(segdata,3)
        [state(:,i), centt(:,:,i)] = kmeans(segdata(:,:,i), cluster,'MaxIter', 500,'Distance','correlation', 'Start', centroid );
end


%% Examine properties of the dIBS.

% Occurrence frequency
for st = 1:cluster
    
    for win = 1:size(state,1)
        occu(win,st) = length(find(state(win,:) == st))/size(state,2);
    end  
    
    for sub = 1:20
       occupersub(st,sub) = length(find(state(:,sub) == st))/size(state,1);
    end    
    
    overallOccu(st) = length(find(state == st))/numel(state);
end
% 
% % plot occurence
% figure,  plot(occu)


% Transform matrix(not included in our paper)
tm = zeros(cluster, cluster, size(state,2));

for i = 1:size(state,2)
    tempstate = state(:,i);
    difstate = diff(state);
    idx = find(difstate~=0);
    
    tm(1,1,i) = length(find(tempstate == 1))-1;
    tm(2,2,i) = length(find(tempstate == 2))-1;
    tm(3,3,i) = length(find(tempstate == 3))-1;
    tm(4,4,i) = length(find(tempstate == 4))-1;
    tm(5,5,i) = length(find(tempstate == 5))-1;
    
    
    for j = 1:length(idx)
        t0 = tempstate(idx(j));
        t1 = tempstate(idx(j)+1);
        tm(t0,t1, i) = tm(t0,t1, i)+1;
        
    end
    tm(:,:,i) = tm(:,:,i)./sum(tm(:,:,i));
        
end

grouptm = mean(tm,3);
figure, imagesc(grouptm)





