function trial_data = RunTrial(Scr,inf,myVar,el,bl,tr,block_structure,trial_params,save_flag)

% WIP -- a basic trial script that runs through a 'gaze-contingent'
% unveiling of particular quadrants ('gaze' is really just cursor position)

trialSTART = GetSecs;                                                      %%%%TIME%%%%%%%

% variables to be built into function arguments (e.g. inf or MyVar) at some point:

fixationCoord = [myVar.fixXLoc myVar.fixYLoc];% location of center of fixation cross

% Prepare response variables
trialRT                 = nan;
trialAcc                = nan;

% Timing Points
fixationOnset           = nan;
exploreOnset            = nan;
feedbackOnset           = nan;
trialEND                = nan;

% Prepare variables for stimulation.
trialError  = 0;
trialIsOK   = true;             % Check eye position during trial
respToBeMade= true;
noResponse  = true;

% Timing in frames
fixationDur  = round(myVar.fixationTime/Scr.ifi);                         % Duration of Fixation;
exploreDur   = round(myVar.exploreTime /Scr.ifi);                         % Duration of Exploration time
feedbackDur  = round(myVar.feedbackTime/Scr.ifi);                         % Feedback displayed for 500 ms

% Adjust response keys
up_right   = myVar.aKey;
right_down = myVar.sKey;
down_left  = myVar.dKey;
left_up    = myVar.fKey;

% Initialize coordinates of fixation cross
fix_x = [-myVar.fixCrossDimPix myVar.fixCrossDimPix 0 0];
fix_y = [0 0 -myVar.fixCrossDimPix myVar.fixCrossDimPix];
all_fix_coords = [fix_x;fix_y];

dotParams = trial_params.dotParams; % get the RDP dot parameters for the current trial

% Retrieve coordinates of the frames / quadrants 

% myVar.centers gives the centers of each quadrant (including both
% RDP-containing and empty quadrants

numQuads = size(myVar.centers,1); 
quadColors = repmat(ceil([255/2 255/2 255/2])',1,numQuads); % gray frames to cover each quadrant when they're not being inspected

numPatterns = size(dotParams,2);

filled_quad_idx = zeros(numQuads,1);
dotData = struct;
for patt_id = 1:numPatterns
    dotData(patt_id) = initialize_dots(dotParams,patt_id);
    nearby_idx = sqrt(sum( (dotParams(patt_id).centers - myVar.centers).^2,2)) < 50;
    if any(nearby_idx)
        filled_quad_idx(nearby_idx) = patt_id;
    end
end

% Prepare SCREEN
Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
vbl = Screen('Flip', Scr.w); %%synch%%

if save_flag
    trial_video = [];
end


if trialIsOK
    
    %% FIXATION
    %%%%%%%%%%%
    
    % Synchronize screen and send messages
    Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
    Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
    vbl = Screen('Flip', Scr.w);    % SCREEN SYNCH.
    fixationOnset = vbl;             %%%%TIME%%%%%%%
    
    grab_flag = true;
    
    for fixationFlips = 1:fixationDur-1
        %%%%%%%%%%%%%%I.Present the Fixation point
        Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
        Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
        DrawFormattedText(Scr.w,'Please Bring the Cursor to the Center of the Fixation Cross!','center',Scr.wRect(4)*0.95,[255 255 255]);
        vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
        if grab_flag && save_flag
            tmp_img = Screen('GetImage',Scr.w);
            tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
            trial_video = cat(4,trial_video,tmp_img);
        end
        grab_flag = ~grab_flag;

        [mouse_x,mouse_y] = GetMouse(Scr.w);
        
        if sqrt(sum(([mouse_x,mouse_y] - fixationCoord).^2)) <= myVar.fixationWindow
            trialIsOK = true;
        else
            trialIsOK = false;
        end
    
    end
    
    %% EXPLORATION ONSET
    %%%%%%%%%%
    if trialIsOK
        
        KeyIsDown = KbCheck();
        exploreFlips = 1;
        
        grab_flag = true;
        
        while and(((KeyIsDown~=1) && noResponse),exploreFlips < exploreDur)
            
            Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
            DrawFormattedText(Scr.w,'Explore the scene...','center',Scr.wRect(4)*0.95,[255 255 255]);

            [mouse_x,mouse_y] = GetMouse(Scr.w);
            
            quadrant_idx = sqrt(sum( ([mouse_x,mouse_y] - myVar.centers).^2,2)) <= myVar.gazeWindow;
            %replaced with rectangular boundary conditions
            
            if any(quadrant_idx)
                
                rev_quadrant = find(quadrant_idx);
                
                if ismember(rev_quadrant,find(filled_quad_idx))      
                    patt_id_temp = filled_quad_idx(rev_quadrant);
                    dotData(patt_id_temp) = update_dots(dotData(patt_id_temp));                    
                    % draws the current dots, using position, single size argument and dotType
                    Screen('DrawDots', Scr.w, dotData(patt_id_temp).dotPos, dotData(patt_id_temp).size, [255 255 255], [0 0], dotData(patt_id_temp).dotType);
                end
                
                remaining_quadrants = ~ismember(1:numQuads,rev_quadrant); % this yields the logical indices for the remaining, non-revealed quadrants for the following
                % 'FillRect' command

                Screen('FillRect',Scr.w,quadColors(:,remaining_quadrants),myVar.RDMRects(:,remaining_quadrants))
                
            else
                Screen('FillRect',Scr.w,quadColors,myVar.RDMRects)
            end
            
            vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
            
            if grab_flag && save_flag
                tmp_img = Screen('GetImage',Scr.w);
                tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
                trial_video = cat(4,trial_video,tmp_img);
            end
            grab_flag = ~grab_flag;

            if exploreFlips == 1
                exploreOnset = vbl;                                                          %%%%TIME%%%%%%%
            end
            
            exploreFlips = exploreFlips + 1;
            
            %%%%%%%%%%%%%%II.Check Response
            [KeyIsDown,endRTRaw, KeyCodeRaw] = KbCheck();
            if (KeyIsDown==1) && respToBeMade
                if KeyCodeRaw(KbName('ESCAPE'))  % EXIT key pressed to exit experiment
                    error('EXIT button!\n');
                else
                    if any(KeyCodeRaw([up_right,right_down,down_left,left_up]))                       
                        trialRT = endRTRaw - exploreOnset; % save RT!!!!
                        if KeyCodeRaw(up_right) && trial_params.scene == 1
                            trialAcc = 1;
                        elseif KeyCodeRaw(right_down) && trial_params.scene == 2
                            trialAcc = 1;
                        elseif KeyCodeRaw(down_left) && trial_params.scene == 3
                            trialAcc = 1;
                        elseif KeyCodeRaw(left_up) && trial_params.scene == 4
                            trialAcc = 1;
                        else
                            trialAcc = 0;
                        end                       
                    else
                        trialError = 1; trialIsOK = false; noResponse = false;          % END THE TRIAL
                    end
                end
            else
                noResponse = true;
            end
             
        end
        
        if trialIsOK
            
            grab_flag = true;
            for i = 1:feedbackDur 
                if trialAcc == 1
                    Screen('FrameRect', Scr.w, [0 255 0], CenterRectOnPointd([0 0 50 50],fixationCoord(1),fixationCoord(2)), 5);
                    DrawFormattedText(Scr.w,'Correct','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
                else
                    Screen('FrameRect', Scr.w, [255 0 0], CenterRectOnPointd([0 0 50 50],fixationCoord(1),fixationCoord(2)), 5);
                    DrawFormattedText(Scr.w,'Incorrect','center',Scr.wRect(4)*0.95,[255 0 ceil(255/4)]);
                end
                vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                
                if grab_flag && save_flag
                    tmp_img = Screen('GetImage',Scr.w);
                    tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
                    trial_video = cat(4,trial_video,tmp_img);
                end
                
                grab_flag = ~grab_flag;
                
                if i == 1
                    feedbackOnset = vbl;                                              %%%%%%%TIME%%%%%%%%%
                end
            end
            trialEND = vbl;
            
        end    
    end
end


% save the data

trial_data.trialRT = trialRT;
trial_data.trialAcc = trialAcc;
trial_data.trialError = trialError;

trial_data.trialSTART = trialSTART;
trial_data.fixationOnset = fixationOnset;
trial_data.exploreOnset = exploreOnset;
trial_data.feedbackOnset = feedbackOnset;
trial_data.trialEND = trialEND;

if save_flag
    trial_data.trial_video = trial_video;
end

Screen('CloseAll')


        
            
        
        
        
    
    




