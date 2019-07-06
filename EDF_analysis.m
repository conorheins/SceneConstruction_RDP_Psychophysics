%% script for converting a single subject's batch of .EDF data into .ASCII files

%% start by adding necessary paths and choosing data directory
addpath(genpath('utilities'));

fprintf('Choose the folder where subject''s specific data is stored...\n')
data_dir = uigetdir();

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

block_ids = unique(sorted_indices(1,:));
for bl = 1:length(block_ids)
    
    asc_idx = find(sorted_indices(:,1) == block_ids(bl));
    full_block = readEDFASC(fullfile(data_dir,asc_files{asc_idx(1)}),1,1);
    if numel(asc_idx) > 1 
        full_block(end) = [];
        for asc_ii = 2:length(asc_idx)
            full_block = [full_block, readEDFASC(fullfile(data_dir,asc_files{asc_idx(asc_ii)}),1,1)];
            if asc_ii ~= length(asc_idx)
                full_block(end) = [];
            end
        end
    end
    
    nTrials = length(full_block);
    block_analyzed = zeros(nTrials,10); % number of column is number of dependent measurements we're extracting from the data
    
    for trial_ii = 1:length(full_block)
        
        block_analyzed(trial_ii,:) = trialEyeData_analyze(full_block(trial_ii));
        
    end
    
end
        
        
    
    





