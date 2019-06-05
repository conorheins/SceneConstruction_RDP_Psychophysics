% fit psychometric functions to accuracy data in motion discrimination task


addpath(genpath('psignifit-master'));
addpath(genpath('mseb'));

data_dir = fullfile('Data','SubjectsData');

subj_folders = dir(data_dir);

rel_folders = {};
idx = 1;
for i = 1:length(subj_folders)
    if ~isnan(str2double(subj_folders(i).name))
        rel_folders{idx} = subj_folders(i).name;
        idx = idx + 1;
    end
end
subj_folders = rel_folders; clear rel_folders;

subj_to_remove = [3,5,6,7,20]; % list of subject numbers to remove

for i = 1:length(subj_to_remove)
    remove_idx = find(strcmp(sprintf('%d',subj_to_remove(i)),subj_folders));
    subj_folders(remove_idx) = [];
end

%%

dir_idx = 3;
coh_idx = 4;
RT_idx = 5;
acc_idx = 6;
dir_choice_idx = 7;

all_results = cell(1,length(subj_folders));
all_raw = cell(1,length(subj_folders));

for subj_i = 1:length(subj_folders)
    
    load(fullfile(data_dir,subj_folders{subj_i},...
        sprintf('Subject%d__allData.mat',str2double(subj_folders{subj_i}))));
    
    coh_levels = unique(dataArray(:,4));
    num_coh = length(coh_levels);
    acc_Table = zeros(num_coh,3);
    
    for coh_level_i = 1:num_coh
        all_accz = dataArray(dataArray(:,coh_idx)==coh_levels(coh_level_i),acc_idx);
        if coh_levels(coh_level_i) == 0
%             acc_Table(coh_level_i,1) = log(0.5);
            acc_Table(coh_level_i,1) = 0.5;
        else
%             acc_Table(coh_level_i,1) = log(coh_levels(coh_level_i));
            acc_Table(coh_level_i,1) = coh_levels(coh_level_i);
        end
        
        acc_Table(coh_level_i,2) = nansum(all_accz);
        acc_Table(coh_level_i,3) = length(all_accz);
        
        
    end
    
    all_raw{subj_i} = acc_Table;
    
    options             = struct;   % initialize as an empty struct
    
    options.sigmoidName = 'weibull';   % choose a cumulative Gaussian as the sigmoid
    options.expType     = 'nAFC';   % choose 4-AFC as the paradigm of the experiment
    % this sets the guessing rate to .25 and
    % fits the rest of the parameters
    options.expN        = 4;

    
    all_results{subj_i} = psignifit(acc_Table,options);
    
%     plotPsych(all_results{subj_i});
%     title(sprintf('Psychometric function for Subject %d',str2double(subj_folders{subj_i})));
%     
%     pause;
    
    
end
    
%%

coh_axis = 0.1:0.1:100;

% labels = {'RCH','MZ','RV','EA'};
% labels = {'RCH2','RCH1'};
% labels = {'Masha','Dima'};
% labels = {'New1','New2','New3','New4','New5','Old1','Old2','Old3','Old4'};
labels = {'MZ','DN','RCH','AZ','SD'};

colors = cool(ceil(1.5*length(labels)));
colors = colors(1:length(labels),:);
% 
% colors_new = repmat([0 0.25 1],4,1);
% colors_old = repmat([1 0.25 0],4,1);
% 
% colors = [colors_new;colors_old];

lines_array = {};
lines_counter = 1;
for subj_i = 1:length(all_results)
    
    lines_array{lines_counter} = plot(coh_axis,all_results{subj_i}.psiHandle(coh_axis),'LineWidth',1,'DisplayName',labels{subj_i},'Color',colors(subj_i,:));
    hold on;
    lines_counter = lines_counter + 1;
    lines_array{lines_counter} = plot(all_raw{subj_i}(:,1),all_raw{subj_i}(:,2)./all_raw{subj_i}(:,3),'.','Color',colors(subj_i,:),'MarkerSize',50);
    lines_counter = lines_counter + 1;

end

ax = gca;
ax.FontSize = 16;

legend([lines_array{1:2:end}],labels)
    
xlabel('Coherence (%)','FontSize',18);
ylabel('Accuracy (% Correct)','FontSize',18)

title(sprintf('Psychometric curves with averages overlaid from %d runs',length(all_results)),'FontSize',20)
grid on;

%%  test plotting one individual's psychometric function with the upper/lower confidence intervals (95%)

temp = all_results{1};

% coh_axis         = exp(linspace(log(0.1),log(100),1000));
coh_axis         = exp(linspace(log(min(temp.data(:,1))),log(max(temp.data(:,1))),1000));

psiHandle_MAP = @(x)temp.Fit(4) + (1-temp.Fit(3) - temp.Fit(4)) * temp.options.sigmoidHandle(x,temp.Fit(1),temp.Fit(2));

params_lowerB = temp.conf_Intervals(:,1,1);
params_upperB = temp.conf_Intervals(:,2,1);

psiHandle_lower = @(x)params_lowerB(4) + (1-params_lowerB(3) - params_lowerB(4)) * temp.options.sigmoidHandle(x,params_lowerB(1),params_lowerB(2));
psiHandle_upper = @(x)params_upperB(4) + (1-params_upperB(3) - params_upperB(4)) * temp.options.sigmoidHandle(x,params_upperB(1),params_upperB(2));
% 
plot(coh_axis,psiHandle_MAP(coh_axis),'k-');
hold on;
plot(coh_axis,psiHandle_lower(coh_axis),'r-');
plot(coh_axis,psiHandle_upper(coh_axis),'b-');

% y = psiHandle_MAP(coh_axis);
% y_lower = psiHandle_lower(coh_axis);
% y_upper = psiHandle_upper(coh_axis);
% mseb(coh_axis,y,cat(3,y_lower-y,y-y_upper));
% mseb(coh_axis,y,cat(3,y-y_upper,y_lower-y));

