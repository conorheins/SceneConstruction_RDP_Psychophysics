% Clear the workspace and the screen
sca;
close all;
clearvars;
  
screens = Screen('Screens'); 

% sub_rect = [0 0 500 500];
sub_rect = []; % use full screen
screenNumber = 0;
debug_mode_flag = 0;

[ Scr ] = InitScreen_v2(sub_rect,screenNumber,debug_mode_flag);


%% Explanation:
% the way I've been setting up the parameters for each RDP is through
% different rows of a structure array, where each row contains the relevant
% information (center, aperture size, number of dots, coherence, etc.) for
% a given RDP (since we'll have 2 possible RDPs per trial, so I guess for a 
% given trial, this dotParams structure would have exactly 2 rows, one for
% each RDP).

% this configuration of centers has them being drawn in the four corners of
% the screen
% centers = [ Scr.wRect(3)/4, Scr.wRect(4)/4;
%             Scr.wRect(3)/4, 3*Scr.wRect(4)/4;
%             3*Scr.wRect(3)/4, Scr.wRect(4)/4; 
%             3*Scr.wRect(3)/4, 3*Scr.wRect(4)/4; ];
%         
% dotParams = createDotParams_struct(Scr.wRect,4,'centers',centers,'cohers',[25 50 50 100],'directions',[0 90 180 270],...
%             'speeds',[2 2 2 2],'apSizes',[200 200; 200 200; 200 200; 200 200],'nDots',[50 50 50 50]);

numPatterns = 2;       
centers = [ Scr.wRect(3)/4, Scr.wRect(4)/4;
            Scr.wRect(3)/4, 3*Scr.wRect(4)/4];
        
dotParams = createDotParams_struct(Scr.wRect,numPatterns,'centers',centers,'cohers',[80 80],'directions',[0 90],...
            'speeds',[0.75 0.75],'apSizes',[200 200; 200 200],'nDots',[50 50],'lifetimes',[10 10]);
        

% this function creates a dotParams structure array of the parameters used
% to draw/create each RDP, with the following defaults listed below:
% -center: coordinates of the center [x y] of the corresponding RDM
%          pattern (defaults to center of screenRect)
% -apSize: size in [w h] of the aperture around each RDP (defaults to 1/4
%          of the width and 1/4 of the height of screenRect)
% -edge_spillover: how much the quadrant should respectively extend beyond the
%                  width and height of the aperture, in pixels. Defaults to
%                  [5 5] in width and height
% -nDots: number of dots in the RDM (defaults to 25)
% -speed: speed of motion in pixels/second (defaults to 1)
% -direction: direction (0 to 360 degrees) of motion (defaults to 0)
% -coherence: coherence of motion (% of dots moving in direction) -
% defaults to 100
% -lifetime: lifetime of a single dot, in frames/screen flips (defaults to 20)


%% testing out a simple trial fuanction

scene_id = 1;
save_flag = false;
trial_data = run_trial_old(Scr,dotParams,scene_id,save_flag);


%% Explanation:
% This function 'initialize_dots' creates the starting dotData for a given RDP
% in the structure array dotParams, using the index patt_id to create the
% dotData for the relevant one

% numPatterns = 4;       
% centers = [ Scr.wRect(3)/4, Scr.wRect(4)/4;
%             Scr.wRect(3)/4, 3*Scr.wRect(4)/4;
%             3*Scr.wRect(3)/4, Scr.wRect(4)/4;
%             3*Scr.wRect(3)/4, 3*Scr.wRect(4)/4];
%         
% dotParams = createDotParams_struct(Scr.wRect,numPatterns,'centers',centers,'cohers',[5 15 25 75],'directions',[0 90 180 270],...
%             'speeds',[0.75 0.75 0.75 0.75],'apSizes',[200 200; 200 200; 200 200; 200 200],'nDots',[50 50 50 50]);
%         
% 
% for patt_id = 1:numPatterns
%     dotData(patt_id) = initialize_dots(dotParams,patt_id);
% end
% % 
% % % 1, 2 and 3 draw round dots (circles) with
% % % anti-aliasing: 1 favors performance, 2 tries to use high-quality anti-aliasing,
% % % if supported by your hardware. 3 Uses a builtin shader-based implementation.
% % % dot_type 1 and 2 may not be supported by all graphics cards and drivers.
% % 
% numFlips = 1000;
% % 
% priorityLevel = MaxPriority(Scr.wRect,'KbCheck');
% Priority(priorityLevel);
% % 
% 
% % video_dat = zeros(Scr.wRect(4)/2,Scr.wRect(3)/2,3,numFlips);
% 
% for flip_i = 1:numFlips 
% 
%     %% Explanation:
%     % update dots: this function will take the dotData (if flip_i == 1, it
%     % will take the dotData output from initialize_dots) and update the
%     % positions/lifetimes/etc.
%     for patt_i = 1:numPatterns
%         dotData(patt_i) = update_dots(dotData(patt_i));
%     end
%     
%     %     After all computations, flip
%     Screen('Flip', Scr.w,0,0);
%     
%     % draws the current dots, using position, single size argument and
%     % dotType
%     for patt_i = 1:numPatterns
%         Screen('DrawDots', Scr.w, dotData(patt_i).dotPos, dotData(patt_i).size, [255 255 255], [0 0], dotData(patt_i).dotType);
%     end
%     
%     %      Presentation
%     Screen('DrawingFinished',Scr.w,0);
% %     tmp = Screen('GetImage',Scr.w);
% %     video_dat(:,:,:,flip_i) = tmp(1:4:end,1:4:end,:);
% 
% end
% % 
% % Present last dots
% Screen('Flip', Scr.w,0,0);
% 
% % Erase last dots
% Screen('DrawingFinished',Scr.w,0);
% Screen('Flip', Scr.w,0,0);
% 
% Screen('CloseAll'); % Close display windows
% Priority(0); % Shutdown realtime mode.
% 
% % video_dat = video_dat./255; % normalize to between 0 and 1
% % 
% % for flip_i = 1:numFlips
% %     % Gifs can't take RBG matrices: they have to be specified with the
% %     % pixels as indices into a colormap
% %     % See the help for imwrite for more details
% %     [y, newmap] = cmunique(video_dat(:,:,:,flip_i));
% %     
% %     %Creates a .gif animation - makes first frame, then appends the rest
% %     if flip_i==1
% %         imwrite(y, newmap, 'RDP_example.gif');
% %     else
% %         imwrite(y, newmap, 'RDP_example.gif', 'DelayTime', 1/30, 'WriteMode', 'append');
% %     end
% % end
% %      
%     
%     