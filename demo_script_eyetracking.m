%% demo script for loading in one block of EyeLink EDF data (after conversion to .asc) and visualizing 
% the gaze trajectory, coloring the saccades by those identified by EyeLink

cd(uigetdir());

addpath(genpath('utilities'))
dirName = uigetdir();
local_fname = uigetfile(fullfile(dirName,'*.asc'));

%% read data into structure array

% note: I commented out some fprintf parts of readEDFASC to make it print
% less stuff in the command line
eye_data = readEDFASC(fullfile(dirName,local_fname),1,1);                                 % Process current block



%% loop over trials and plot gaze trajectories

image_directory = '/Users/conorheins/Desktop';
for trial_idx = 1:length(eye_data)

    gaze_x_y = eye_data(trial_idx).pos(:,2:3);
    saccade_data = eye_data(trial_idx).saccade;
    fix_data = eye_data(trial_idx).fixation;
    
    mins_xy = min(gaze_x_y,[],1);
    maxs_xy = max(gaze_x_y,[],1);
    
    dotCols = cool(size(gaze_x_y,1));
    
    figure('Position',[100 500 1200 900])
    title(sprintf('Trial # %d',trial_idx))
    
    subplot(121)
    scatter(gaze_x_y(:,1),gaze_x_y(:,2),10,dotCols);
    xlim( [mins_xy(1) maxs_xy(1)]);
    ylim( [mins_xy(2) maxs_xy(2)]);
    
    subplot(122)
    scatter(gaze_x_y(:,1),gaze_x_y(:,2),10,dotCols);
    xlim( [mins_xy(1) maxs_xy(1)]);
    ylim( [mins_xy(2) maxs_xy(2)]);
%     
%     fix_colors = {'r','g','b','k','c','p'};
%     color_iter = 0;
%     for fix_i = 1:size(fix_data,1)
%         fix_idx = fix_data(fix_i,1):fix_data(fix_i,2);
%         hold on; scatter(gaze_x_y(fix_idx,1),gaze_x_y(fix_idx,2),80,fix_colors{mod(color_iter,length(fix_colors))+1},'filled',...
%             'DisplayName',sprintf('Fixation Number: %d',fix_i));
%         color_iter = color_iter + 1;
%     end
    
%     sacc_colors = hot(5);
    sacc_colors = {'r','g','b','k','c','p'};
    sacc_legend = cell(1,size(saccade_data,1));
    color_iter = 0;
    for sacc_i = 1:size(saccade_data,1)
        sacc_idx = saccade_data(sacc_i,1):saccade_data(sacc_i,2);
%         hold on; scatter(gaze_x_y(sacc_idx,1),gaze_x_y(sacc_idx,2),50,sacc_colors(mod(color_iter,length(sacc_colors))+1,:),'filled',...
%             'DisplayName',sprintf('Saccade Number: %d',sacc_i));
%         hold on; scatter(gaze_x_y(sacc_idx,1),gaze_x_y(sacc_idx,2),50,sacc_colors{mod(color_iter,length(sacc_colors))+1},'filled',...
%             'DisplayName',sprintf('Saccade Number: %d',sacc_i));
        hold on; scatter(gaze_x_y(sacc_idx,1),gaze_x_y(sacc_idx,2),50,sacc_colors{mod(color_iter,length(sacc_colors))+1},'filled');
        sacc_legend{sacc_i} = sprintf('Saccade # %d',sacc_i);
        color_iter = color_iter + 1;
    end
    
    ax = gca;
    ax.FontSize = 16;
    
%     legend('show')
    if length(sacc_legend) > 30
        legend({'Too many saccades to show!'},'Location','Best','FontSize',20);
    elseif length(sacc_legend) <= 6
        legend(sacc_legend,'Location','Best','FontSize',16);
    else
        legend(sacc_legend,'Location','Best','FontSize',10);
    end
    
%     pause;
    saveas(gcf,fullfile(image_directory,sprintf('Trial_%d_traj',trial_idx)),'jpg')
    close gcf;

end


% matlab_data = load(fullfile(dirName,['6',filesep,'Subject6__allData.mat']));









