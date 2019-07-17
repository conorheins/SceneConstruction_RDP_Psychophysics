
%%
addpath(genpath('utilities'));

data_dir = uigetdir();

%%


dir_column = 6;
coh_column = 7;
    
subj_folders = dir(data_dir);

subj_folders(1:3) = [];

stats_array = zeros(length(subj_folders),3,3,3);

for s_i = 1:length(subj_folders)
    mat_data = dir(fullfile(data_dir,subj_folders(s_i).name,'*.mat'));
    mat_names = {mat_data.name};
    mat_data(~strcmp(mat_names,'sacc_anal.mat')) = [];
    mat_names(~strcmp(mat_names,'sacc_anal.mat')) = [];
    
    load(fullfile(data_dir,subj_folders(s_i).name,mat_names{1}));
    
    durations = all_analyzed(:,5) - all_analyzed(:,4);
    
    unique_labels = unique(all_analyzed(~isnan(all_analyzed(:,coh_column)),coh_column));
    
    sacc_idx = all_analyzed(:,8);
    revisit_idx = all_analyzed(:,9);
    prev_higher = all_analyzed(:,10);
    prev_lower = all_analyzed(:,11);
    prev_equal = all_analyzed(:,12);
    
    prev_cohers = NaN(size(all_analyzed,1),1);
    
    for row_i = 1:size(all_analyzed,1)
        if ~isnan(all_analyzed(row_i,coh_column))
            prev_cohers_temp = all_analyzed(all_analyzed(:,2) == all_analyzed(row_i,2) & all_analyzed(:,8) < all_analyzed(row_i,8),coh_column);
            if prev_higher(row_i) || prev_lower(row_i) || prev_equal(row_i)
                prev_cohers(row_i) = prev_cohers_temp(find(~isnan(prev_cohers_temp),1));
            end
        end
    end
    

    for lab_i = 1:length(unique_labels)
        
        coh_filter_current = all_analyzed(:,coh_column) == unique_labels(lab_i);
        
        for lab_j = 1:length(unique_labels)
            
            coh_filter_prev = prev_cohers == unique_labels(lab_j);
            data_temp = durations(coh_filter_current & coh_filter_prev);
            N = length(data_temp);
            stats_array(s_i,lab_i,1,lab_j) = nanmean(data_temp);
            stats_array(s_i,lab_i,2,lab_j) = nanstd(data_temp)/sqrt(N);
            stats_array(s_i,lab_i,3,lab_j) = N;
        end
         
    end
    
end




    