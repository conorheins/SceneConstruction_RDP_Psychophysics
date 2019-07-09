%% script for converting a single subject's batch of .EDF data into .ASCII files

%% start by adding necessary paths and choosing data directory
addpath(genpath('utilities'));

fprintf('Choose the folder where subject''s specific data is stored...\n')
data_dir = uigetdir();


matlab_data = dir([data_dir,filesep,'*.mat']);
matlab_data = load(fullfile(data_dir,matlab_data.name));
behav_blocks = matlab_data.block; 
myVar = matlab_data.myVar; clear matlab_data;
quadrant_vertices = zeros(2,4,4); % 2 rows for x and y coordinates of the vertices, 4 columns for each of the four vertices, 4 slices since there are 4 quadrants total

for quad_i = 1:size(quadrant_vertices,3)
    quadrant_vertices(1,:,quad_i) = [myVar.RDMRects(1,quad_i) myVar.RDMRects(1,quad_i) ...
        myVar.RDMRects(3,quad_i) myVar.RDMRects(3,quad_i)];
    quadrant_vertices(2,:,quad_i) = [myVar.RDMRects(2,quad_i) myVar.RDMRects(4,quad_i) ...
        myVar.RDMRects(4,quad_i) myVar.RDMRects(2,quad_i)];
end

%% convert all EDF files into .ASC files 

edf_files = dir(fullfile(data_dir,'*.edf'));
idx2keep = find(cellfun(@(x) isempty(x), strfind(lower({edf_files.name}),'calib')));

for f_i = 1:length(idx2keep)
    readEDFASC(fullfile(data_dir,edf_files(idx2keep(f_i)).name),1,1);
end

%% after conversion, sort the .ASC filenames according to Block/Trial

% note about file naming convention, that contextualizes the following
% code:
% eye data from one block is named as follows -
% '[SUBJECT_ID]_Block_[BLOCK_ID]_toTrial[LASTTRIAL_ID].edf/.asc'
% e.g. 991546040_Block_2_toTrial120.edf is the 2nd block of eyetracking
% data from subject 991546040, going from an unknown starting trial until
% trial 120. If there is no other Block 2 data from this subject, then the
% starting trial is 1. However, if there's a file named e.g. 991546040_Block_2_toTrial50.edf 
% it means that Block 2 was split into two recordings, one going from
% Trials 1 - 50, and another going from Trial 50 - 120. For the 'real'
% Trial 50 (the one that wasn't interrupted in the middle), use the Trial50
% from the last file, that starts at 50 and ends at 120.

asc_files = dir(fullfile(data_dir,'*.asc'));
asc_files = {asc_files.name};
sorted_indices = zeros(length(asc_files),2);
for f_i = 1:length(asc_files)
    split_nam = strsplit(asc_files{f_i},'_');
    sorted_indices(f_i,1) = str2double(split_nam{3});
    split_trial_nam = strsplit(split_nam{4},'.');
    sorted_indices(f_i,2) = str2double(split_trial_nam{1}(8:end));
end

[sorted_indices,srt_idx] = sortrows(sorted_indices,[1 2]);

asc_files = asc_files(srt_idx);

%% now read in the eye-tracking data (now sorted, in .ASC form) into the workspace and turn in the
% continuous vector of eye-positions into a sequence of
% quadrant/scene-symbol visits

block_ids = unique(sorted_indices(:,1));
all_analyzed = [];
for bl = 3:length(block_ids)
    
    asc_idx = find(sorted_indices(:,1) == block_ids(bl));
    eyeBlock = readEDFASC(fullfile(data_dir,asc_files{asc_idx(1)}),1,1);
    if numel(asc_idx) > 1 
        eyeBlock(end) = [];
        for asc_ii = 2:length(asc_idx)
            eyeBlock = [eyeBlock, readEDFASC(fullfile(data_dir,asc_files{asc_idx(asc_ii)}),1,1)];
            if asc_ii ~= length(asc_idx)
                eyeBlock(end) = [];
            end
        end
    end
    
    nTrials = length(eyeBlock);
    block_analyzed = [];
    
    for trial_ii = 1:nTrials
        
        result =  trialEyeData_analyze(eyeBlock(trial_ii),behav_blocks(block_ids(bl)).trials(trial_ii),quadrant_vertices);
        block_analyzed = [block_analyzed; [trial_ii*ones(size(result,1),1), result]];
        
    end
    
    all_analyzed = [all_analyzed; [block_ids(bl) * ones(size(block_analyzed,1),1), block_analyzed]];
    
    
end


%%

column_to_use = 6;

unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,column_to_use)),column_to_use));
durations = all_analyzed(:,5) - all_analyzed(:,4);

stats_array = zeros(length(unique_labels),3);
for coh_i = 1:length(unique_labels)
    data_temp = durations(all_analyzed(:,column_to_use) == unique_labels(coh_i));
    N = length(data_temp);
    stats_array(coh_i,1) = mean(data_temp);
    stats_array(coh_i,2) = std(data_temp)/sqrt(N);
% 	stats_array(coh_i,2) = std(data_temp);
    stats_array(coh_i,3) = N;
end

barwitherr(stats_array(:,2)./1000,stats_array(:,1)./1000);

%% add another column to the analyzed data matrix that indicates whether the quadrant fixated was 
% seen (for the first time) after seeing another pattern of higher
% coherence

post_flag = zeros(size(all_analyzed,1),1);
for sacc_i = 1:size(all_analyzed,1)
    
    current_sacc = all_analyzed(sacc_i,:);
    
    if and(~isnan(current_sacc(6)),sacc_i > 1)
        
        curr_bl = current_sacc(1);
        curr_trial = current_sacc(2);
        
        filter_idx = find(all_analyzed(:,1) == curr_bl & all_analyzed(:,2) == curr_trial);
        other_saccs = all_analyzed(filter_idx,:);
        
        previous_saccs = other_saccs(filter_idx < sacc_i,:);
        previous_saccs = previous_saccs(~isnan(previous_saccs(:,6)),:);
        
        if and(~isempty(previous_saccs),~any(previous_saccs(:,6) == current_sacc(6)))
            if any(previous_saccs(:,7) == current_sacc(7))
                post_flag(sacc_i) = 1; % the case when a previously-fixated pattern was of the same coherence
            end
            
            if any(previous_saccs(:,7) > current_sacc(7))
                post_flag(sacc_i) = 2; % the case when the previously-fixated pattern was of higher coherence than the current one
            elseif any(previous_saccs(:,7) < current_sacc(7))
                post_flag(sacc_i) = 3; % the case when the previously-fixated pattern was of lower coherence than the current one
            end
        elseif and(~isempty(previous_saccs),any(previous_saccs(:,6) == current_sacc(6)))
            post_flag(sacc_i) = 4; % the case when the quadrant was revisited
        end
    end
    
end

%%

durations = all_analyzed(:,5) - all_analyzed(:,4);

dir_column = 6;
coh_column = 7;
unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));

stats_array = zeros(length(unique_labels)-1,3,2);

for lab_i = 1:length(unique_labels)-1
    
    coh_filter = all_analyzed(:,coh_column) == unique_labels(lab_i);
    post_flag_filter = post_flag == 0;
    
    data_temp = durations(coh_filter & post_flag_filter);
    N = length(data_temp);
    stats_array(lab_i,1,1) = mean(data_temp);
    stats_array(lab_i,2,1) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,1) = std(data_temp);
    stats_array(lab_i,3,1) = N;
    
    post_flag_filter = post_flag == 2;
    data_temp = durations(coh_filter & post_flag_filter);
    N = length(data_temp);
    stats_array(lab_i,1,2) = mean(data_temp);
    stats_array(lab_i,2,2) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,2) = std(data_temp);
    stats_array(lab_i,3,2) = N;
    
end

means = squeeze(stats_array(:,1,:))./1000;
sems = squeeze(stats_array(:,2,:))./1000;
barwitherr(sems,means)

set(gca,'XTickLabel',{sprintf('%.1f coherence',unique_labels(1)),sprintf('%.1f coherence',unique_labels(2))});
legend('First saccade','After seeing a higher coherence RDP')
ylabel('Dwell time')
            
    

%%

stats_array = zeros(length(unique_labels),3,2);

for lab_i = 1:length(unique_labels)
    
    coh_filter = all_analyzed(:,coh_column) == unique_labels(lab_i);
    post_flag_filter = post_flag == 0;
    
    data_temp = durations(coh_filter & post_flag_filter);
    N = length(data_temp);
    stats_array(lab_i,1,1) = mean(data_temp);
    stats_array(lab_i,2,1) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,1) = std(data_temp);
    stats_array(lab_i,3,1) = N;
    
%     post_flag_filter = post_flag == 1 | post_flag == 2 | post_flag == 3;
    post_flag_filter =  post_flag == 3 | post_flag == 4;

    data_temp = durations(coh_filter & post_flag_filter);
    N = length(data_temp);
    stats_array(lab_i,1,2) = mean(data_temp);
    stats_array(lab_i,2,2) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,2) = std(data_temp);
    stats_array(lab_i,3,2) = N;
    
end

means = squeeze(stats_array(:,1,:))./1000;
sems = squeeze(stats_array(:,2,:))./1000;
barwitherr(sems,means)

coh_labels = cellfun(@(x) sprintf('%.1f',x), mat2cell(unique_labels,ones(3,1),1),'UniformOutput',false);
set(gca,'XTickLabel',coh_labels);
legend('First saccade','After seeing a previous patch')
ylabel('Dwell time')

%%

unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));
stats_array = zeros(length(unique_labels),3);

for lab_i = 1:length(unique_labels)
    
    coh_filter = all_analyzed(:,coh_column) == unique_labels(lab_i);
%     post_flag_filter = post_flag == 0;
    
%     data_temp = durations(coh_filter & post_flag_filter);
    data_temp = durations(coh_filter);

    N = length(data_temp);
    stats_array(lab_i,1) = mean(data_temp);
    stats_array(lab_i,2) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,1) = std(data_temp);
    stats_array(lab_i,3) = N;
    
    
end

barwitherr(stats_array(:,2),stats_array(:,1))


            
    
    





