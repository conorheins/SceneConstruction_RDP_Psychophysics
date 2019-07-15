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

choice_vertices = zeros(2,4,4); % 2 rows for x and y coordinates of the vertices, 4 columns for each of the four vertices, 4 slices since there are 4 choices total
for ch_i = 1:size(choice_vertices,3)
    choice_vertices(1,:,ch_i) = [myVar.choiceRects(1,ch_i) myVar.choiceRects(1,ch_i) ...
        myVar.choiceRects(3,ch_i) myVar.choiceRects(3,ch_i)];
    choice_vertices(2,:,ch_i) = [myVar.choiceRects(2,ch_i) myVar.choiceRects(4,ch_i) ...
        myVar.choiceRects(4,ch_i) myVar.choiceRects(2,ch_i)];
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
for bl = 1:length(block_ids)
    
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
        
        result =  trialEyeData_analyze(eyeBlock(trial_ii),behav_blocks(block_ids(bl)).trials(trial_ii),quadrant_vertices,choice_vertices);
        block_analyzed = [block_analyzed; [trial_ii*ones(size(result,1),1), result]];
        
    end
    
    all_analyzed = [all_analyzed; [block_ids(bl) * ones(size(block_analyzed,1),1), block_analyzed]];
    
end

%% Main effect of coherence on dwell time

column_to_use = 7;

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



%% Look at the effect of coherence + revisit index on dwell time

durations = all_analyzed(:,5) - all_analyzed(:,4);

dir_column = 6;
coh_column = 7;
unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));

sacc_idx = all_analyzed(:,8);
revisit_idx = all_analyzed(:,9);
prev_higher = all_analyzed(:,10);
prev_lower = all_analyzed(:,11);
prev_equal = all_analyzed(:,12);

stats_array = zeros(length(unique_labels),3,2);

for lab_i = 1:length(unique_labels)
    
    coh_filter = all_analyzed(:,coh_column) == unique_labels(lab_i);
    
    data_temp = durations(coh_filter & revisit_idx == 1);
    N = length(data_temp);
    stats_array(lab_i,1,1) = mean(data_temp);
    stats_array(lab_i,2,1) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,1) = std(data_temp);
    stats_array(lab_i,3,1) = N;
    
    data_temp = durations(coh_filter & revisit_idx > 1 );
    N = length(data_temp);
    stats_array(lab_i,1,2) = mean(data_temp);
    stats_array(lab_i,2,2) = std(data_temp)/sqrt(N);
% 	stats_array(lab_i,2,2) = std(data_temp);
    stats_array(lab_i,3,2) = N;
    
end

means = squeeze(stats_array(:,1,:))./1000;
sems = squeeze(stats_array(:,2,:))./1000;
barwitherr(sems,means)

coh_labels = cellfun(@(x) sprintf('%.1f',x), num2cell(unique_labels),'UniformOutput',false);
set(gca,'XTickLabel',coh_labels);
legend('First visit','Second or later visit')
ylabel('Dwell time')
            

%% Look at the effect of previous coherence on dwell time

durations = all_analyzed(:,5) - all_analyzed(:,4);

dir_column = 6;
coh_column = 7;
unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));

sacc_idx = all_analyzed(:,8);
revisit_idx = all_analyzed(:,9);
prev_higher = all_analyzed(:,10);
prev_lower = all_analyzed(:,11);
prev_equal = all_analyzed(:,12);

stats_array = zeros(length(unique_labels),3,4);

for lab_i = 1:length(unique_labels)
    
    coh_filter = all_analyzed(:,coh_column) == unique_labels(lab_i);
   
    data_temp = durations(coh_filter & revisit_idx == 1 & prev_higher == 0 & prev_equal==0 & prev_lower == 0);

    N = length(data_temp);
    stats_array(lab_i,1,1) = mean(data_temp);
    stats_array(lab_i,2,1) = std(data_temp)/sqrt(N);
    stats_array(lab_i,3,1) = N;
    
    data_temp = durations(coh_filter & prev_lower == 1);
    N = length(data_temp);
    stats_array(lab_i,1,2) = mean(data_temp);
    stats_array(lab_i,2,2) = std(data_temp)/sqrt(N);
    stats_array(lab_i,3,2) = N;
    
    data_temp = durations(coh_filter & prev_equal == 1);
    N = length(data_temp);
    stats_array(lab_i,1,3) = mean(data_temp);
    stats_array(lab_i,2,3) = std(data_temp)/sqrt(N);
    stats_array(lab_i,3,3) = N;
    
    data_temp = durations(coh_filter & prev_higher == 1);
    N = length(data_temp);
    stats_array(lab_i,1,4) = mean(data_temp);
    stats_array(lab_i,2,4) = std(data_temp)/sqrt(N);
    stats_array(lab_i,3,4) = N;
    
end

means = squeeze(stats_array(:,1,:))./1000;
sems = squeeze(stats_array(:,2,:))./1000;
barwitherr(sems,means)

coh_labels = cellfun(@(x) sprintf('%.1f',x), num2cell(unique_labels),'UniformOutput',false);
set(gca,'XTickLabel',coh_labels);
legend({'First RDP seen','Previous RDP lower coherence','Previous RDP equal coherence','Previous RDP higher coherence'})
    
ax = gca;
ax.FontSize = 18;
xlabel('Coherence (%)')
ylabel('Dwell time (seconds)')
title('Effect of previous quadrant''s contents on current fixational dwell time')

%% look at mean number of revisits, as a function of coherence

coh_column = 7;
unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));

revisit_idx = all_analyzed(:,9);

stats_array = zeros(length(unique_labels),3);

for lab_i = 1:length(unique_labels)
    
    coh_filter = all_analyzed(:,coh_column) == unique_labels(lab_i);
   
    data_temp = revisit_idx(coh_filter);

    N = length(data_temp);
    stats_array(lab_i,1) = mean(data_temp);
    stats_array(lab_i,2) = std(data_temp)/sqrt(N);
    stats_array(lab_i,3) = N;
    
end
    
barwitherr(stats_array(:,2),stats_array(:,1));

%% probability of revisiting a quadrant, as a function of both that quadrant's coherence and the other quadrant's coherence

coh_column = 7;
unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));

revisit_idx = all_analyzed(:,9);

first_visits = revisit_idx == 1;

revisit_probs = zeros(length(unique_labels));

for lab_i = 1:length(unique_labels)
    
    SoI_idx = find(first_visits & all_analyzed(:,coh_column)==unique_labels(lab_i));
    SoI = all_analyzed(SoI_idx,:);
    
    
    for lab_j = 1:length(unique_labels)
        
        revisit_counts = NaN(size(SoI,1),1);

        for s_i = 1:size(SoI,1)
            
            bl_tr_labs = SoI(s_i,1:2);
            
            bl_tr_sacc_idx = find(all_analyzed(:,1)==bl_tr_labs(1) & all_analyzed(:,2)==bl_tr_labs(2));
            prev_sacc_idx = bl_tr_sacc_idx(bl_tr_sacc_idx < SoI_idx(s_i));
            fut_sacc_idx = bl_tr_sacc_idx(bl_tr_sacc_idx > SoI_idx(s_i));
            
            if ~any(all_analyzed(prev_sacc_idx,6)) % this makes sure the saccade of interest is the first filled-quadrant of the trial
                
                if ~isempty(fut_sacc_idx)
                    if any(all_analyzed(fut_sacc_idx,3)==SoI(s_i,3)) && any(all_analyzed(fut_sacc_idx,coh_column) == unique_labels(lab_j))
                        revisit_counts(s_i) = 1;
                    elseif ~any(all_analyzed(fut_sacc_idx,3)==SoI(s_i,3)) && any(all_analyzed(fut_sacc_idx,coh_column) == unique_labels(lab_j))
                        revisit_counts(s_i) = 0;
                    end
                end
                
            end
            
        end
        revisit_probs(lab_i,lab_j) = nansum(revisit_counts)./sum(~isnan(revisit_counts));

    end
end


%% look at correlation between dwell time and saccade index

scatter(durations, all_analyzed(:,8));
    
%% look at accuracy over time (learning)

bin_size = 20;

num_tot_trials = 0;
for b_i = 1:length(behav_blocks)
    num_tot_trials = num_tot_trials + length(behav_blocks(b_i).trials);
end;

all_acc = zeros(num_tot_trials,1);
all_RT = zeros(num_tot_trials,1);

curr_idx = 1;
for b_i = 1:length(behav_blocks)
    all_acc(curr_idx:(curr_idx + length(behav_blocks(b_i).trials) - 1)) = ...
        [behav_blocks(b_i).trials.trialAcc]';
    all_RT(curr_idx:(curr_idx + length(behav_blocks(b_i).trials) - 1)) = ...
        [behav_blocks(b_i).trials.trialRT]';
    curr_idx = curr_idx + length(behav_blocks(b_i).trials);
end

bin_idx = 1:bin_size:num_tot_trials;

binned_acc = zeros(length(bin_idx),1);
binned_RT = zeros(length(bin_idx),1);
for b_i = 1:length(bin_idx)
    binned_acc(b_i) = nanmean(all_acc(bin_idx(b_i):min(bin_idx(b_i)+bin_size-1,num_tot_trials)));
    binned_RT(b_i) = nanmean(all_RT(bin_idx(b_i):min(bin_idx(b_i)+bin_size-1,num_tot_trials)));
end

%%


    


            
            
        
        
        
        
        
        
        
    
    


            
   


            
    
    





