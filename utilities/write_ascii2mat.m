function write_ascii2mat(data_dir)
%WRITE_EDF2MAT Reads in .ASC data files from different subject folders in
% data_dir, analyzes the quadrant/symbol fixations in terms of duration,
% and saves the resulting matfiles into the same subject folders

subj_folders = dir(data_dir);

subj_folders(1:3) = []; % this includes the dirs '.','..', and '.DS_Store';

for s_i = 1:length(subj_folders)
    
    subj_dir = fullfile(data_dir,subj_folders(s_i).name);
    
    matlab_data = dir([subj_dir,filesep,'*.mat']);
    
    if length(matlab_data) > 1

        warning(sprintf('More than 1 .mat file found in folder of subject %s\n',subj_folders(s_i).name));
        
    else
        matlab_data = load(fullfile(subj_dir,matlab_data.name));
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
        
        asc_files = dir(fullfile(subj_dir,'*.asc'));
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
            eyeBlock = readEDFASC(fullfile(subj_dir,asc_files{asc_idx(1)}),1,1);
            if numel(asc_idx) > 1
                eyeBlock(end) = [];
                for asc_ii = 2:length(asc_idx)
                    eyeBlock = [eyeBlock, readEDFASC(fullfile(subj_dir,asc_files{asc_idx(asc_ii)}),1,1)];
                    if asc_ii ~= length(asc_idx)
                        eyeBlock(end) = [];
                    end
                end
            end
            
            nTrials = length(eyeBlock);
            block_analyzed = [];
            
            for trial_ii = 1:nTrials
                
                result =  trialEyeData_analyze(eyeBlock(trial_ii),behav_blocks(block_ids(bl)).trials(trial_ii),quadrant_vertices,choice_vertices);
                if ~isempty(result)
                    block_analyzed = [block_analyzed; [trial_ii*ones(size(result,1),1), result]];
                end
                
            end
            
            all_analyzed = [all_analyzed; [block_ids(bl) * ones(size(block_analyzed,1),1), block_analyzed]];
            
        end
        
        save(fullfile(subj_dir,'sacc_anal.mat'),'all_analyzed'); 
    end
    
end


end

