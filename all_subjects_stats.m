%%
addpath(genpath('utilities'));

data_dir = uigetdir();

%%

coh_column = 7;
    
subj_folders = dir(data_dir);

subj_folders(1:4) = [];

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

    
%% Run a repeated-measures ANOVA 
anovdata_names = cell(1,length(unique_labels)^2);
cond_num = 1;
anovdata = [];

levels = {'L','M','H'};

for curr_coh = 1:length(unique_labels)
    for prev_coh = 1:length(unique_labels)
%         coher_conditions(cond_num,1) = curr_coh;
%         coher_conditions(cond_num,2) = prev_coh;
        anovdata = [anovdata, squeeze(stats_array(:,curr_coh,1,prev_coh))];
        anovdata_names{cond_num} = sprintf('%s%s',levels{curr_coh},levels{prev_coh});
        cond_num = cond_num + 1;
    end
end

for  i=1:length(anovdata_names)
    subfactor{i}= ['F' num2str(i)];
end

t = array2table(anovdata,'VariableNames',subfactor);
factorNames = {'CurrCoher','PrevCoher'};

within = table({'L';'L';'L';'M';'M';'M';'H';'H';'H'},... %current quadrant's coherence
    {'L';'M';'H';'L';'M';'H';'L';'M';'H'},...%previous quadrant's coherence
    'VariableNames',factorNames);

% fit the repeated measures model
rm = fitrm(t,['F1-F' num2str(length(anovdata_names)) '~1'],'WithinDesign',within);

% run my repeated measures anova here
[ranovatbl] = ranova(rm, 'WithinModel','CurrCoher*PrevCoher');

%% Look at effect of previous quadrant's coherence on current quadrant's dwell time
close gcf;
subj_colors = jet(size(stats_array,1));

curr_coher_horizontal = [8 10 12];
prev_coher_horizontal = [-0.5 0 0.5];

for s_i = 1:size(stats_array,1)
    
    means_temp = squeeze(stats_array(s_i,:,1,:))./1000;
    
    hold on;
    
    for ii = 1:size(means_temp,1)
        scatter(curr_coher_horizontal(ii) + prev_coher_horizontal, means_temp(ii,:),100,repmat(subj_colors(s_i,:),3,1),'filled');
        plot(curr_coher_horizontal(ii) + prev_coher_horizontal,means_temp(ii,:),'Color',subj_colors(s_i,:),'LineWidth',2);
    end
    
end

xticks(reshape(curr_coher_horizontal + prev_coher_horizontal',1,9))
xticklabels({'47%','71%','98%','47%','71%','98%','47%','71%','98%'})
xlim([7.25, 12.75])
ylim([0 2])

ylabel('Reaction time (seconds)');
xlabel('RDP discrimination accuracy (previous pattern)')
    

t0 = text(9.4,1.9,'Current pattern');
t0.FontSize = 22;
t0.FontWeight = 'bold';

t1 = text(7.9,1.75,'47%');
t1.FontSize = 18;
t1.FontWeight = 'bold';

t2 = text(9.9,1.75,'71%');
t2.FontSize = 18;
t2.FontWeight = 'bold';

t3 = text(11.9,1.75,'98%');
t3.FontSize = 18;
t3.FontWeight = 'bold';


ax = gca;
ax.FontSize = 20;

%% Accuracies for the different coherence conditions

addpath(genpath('utilities'));

data_dir = uigetdir();

%%
subj_folders = dir(data_dir);

subj_folders(1:4) = [];

nSubj = length(subj_folders);

learning_curves = cell(1,nSubj);
bin_size = 100; % how many trials per bin when calculating learning curves

all_acc = zeros(nSubj,6);

for s_i = 1:length(subj_folders)
    
    mat_data = dir(fullfile(data_dir,subj_folders(s_i).name,'*.mat'));
    mat_names = {mat_data.name};
    mat_data(cellfun(@(x) isempty(x), strfind(mat_names,'allData.mat'))) = [];
    mat_names(cellfun(@(x) isempty(x), strfind(mat_names,'allData.mat'))) = [];
    
    behavDat = load(fullfile(data_dir,subj_folders(s_i).name,mat_names{1}));
    
    behav_blocks = behavDat.block; clear behavDat;
    
    %% collect accuracy over time (learning)
    
    [learning_curves{s_i},~] = getLearningCurve(behav_blocks,bin_size);
    
    %% get average accuracy for different coherence conditions
    
    all_acc_temp = [];
    all_cond_temp = [];
    
    for b_i = 2:length(behav_blocks)
        
        all_acc_temp = [all_acc_temp;[behav_blocks(b_i).trials.trialAcc]'];
        
        for tr = 1:length(behav_blocks(b_i).trials)
            all_cond_temp = [all_cond_temp; [behav_blocks(b_i).trials(tr).coherence(1),behav_blocks(b_i).trials(tr).coherence(2)]];
        end
        
    end
    
    unique_conds = sortrows(unique(all_cond_temp,'rows'),[1 2]);
    
    for cond_i = 1:size(unique_conds,1)
        all_acc(s_i,cond_i) = nanmean(all_acc_temp(all_cond_temp(:,1) == unique_conds(cond_i,1) & all_cond_temp(:,2) == unique_conds(cond_i,2)));
    end
    
end
        
    
    
    




    