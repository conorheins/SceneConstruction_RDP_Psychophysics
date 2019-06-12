function [inf,trial_data,el] = RunTrial_SC(Scr,inf,myVar,el,bl,tr,block,trialParams,save_flag)

% Script for a single trial of the scene construction paradigm

%% INPUTS:
% - Scr:         structure containing information about the screen (e.g. Scr.wRect
%                contains dimensions of the screen, Scr.w contains the window pointer,
%                etc.)
% - inf:         structure containing general, invariant information (e.g.
%                inf.dummy indicates whether experiment is being run with/without
%                eyetracking
% - myVar:       structure containing constants related to presentation of stimuli, trial-structure,
%                timing, etc.
% - el:          EyeLink related variable
% - bl:          index of current block
% - tr:          index of current trial
% - block:       structure containing block- and trial-specific experimental (independent) and behavioral (dependent) measures, e.g
%                parameters of stimuli to display on block(bl).trials(tr), participant's reaction time
%                on block(bl).trials(tr).
% - trialParams: structure containing trial-specific experimental (independent) and behavioral (dependent) measures
% - save_flag:   Boolean true/false flag (1 / 0) indicating whether to save
%                the frames of the trial into a video

trialSTART = GetSecs;                                                      %%%%TIME%%%%%%%

fixationCoord = [myVar.fixXLoc myVar.fixYLoc];% location of center of fixation cross

% Prepare response variables
trialRT                 = nan;
trialAcc                = nan;
sceneChoice             = nan;

% Timing Points
fixationOnset           = nan;
exploreOnset            = nan;
choiceOnset             = nan;
feedbackOnset           = nan;
trialEND                = nan;

% Prepare variables for stimulation.
trialError  = 0;
trialIsOK   = true;             % Check eye position during trial
respToBeMade= true;
noResponse  = true;

Reward = 0; % fix this later

% Timing in frames
if tr == 1
    ShowCursor(1) 
    fixationDur  = round(myVar.fixationTime/Scr.ifi);                        % Duration of Fixation is longer if it's the first trial (gives subject time to move cursor/eyes to center)
else
    fixationDur = round(  (myVar.ITI_sd*randn(1) + myVar.intertrialTime) /Scr.ifi );
end

if bl < 2
    exploreDur     = round(myVar.train_exploreTime /Scr.ifi);                 % For early/practice blocks, make scene exploration time basically infinite
else
    exploreDur     = round(myVar.exploreTime /Scr.ifi);                       % Duration of explore phase
end
choiceDur  = round(myVar.choiceTime/Scr.ifi);                        % Choice display duration in flips
feedbackDur  = round(myVar.feedbackTime/Scr.ifi);                        % Feedback display duration in flips


% Adjust response keys
up_right   = myVar.aKey;
right_down = myVar.sKey;
down_left  = myVar.dKey;
left_up    = myVar.fKey;

% Initialize coordinates of fixation cross
fix_x = [-myVar.fixCrossDimPix myVar.fixCrossDimPix 0 0];
fix_y = [0 0 -myVar.fixCrossDimPix myVar.fixCrossDimPix];
all_fix_coords = [fix_x;fix_y];

dotParams = trialParams.dotParams; % get the RDP dot parameters for the current trial

% Retrieve coordinates of the frames / quadrants 

% myVar.centers gives the centers of each quadrant (including both
% RDP-containing and empty quadrants

numQuads = size(myVar.centers,2); 
quadColors = repmat(ceil([255/2 255/2 255/2])',1,numQuads);      % gray rects to cover each quadrant when they're not being inspected
quadFrameColors = repmat(ceil((5/8).*[255 255 255])',1,numQuads); % slightly-lighter gray frames around the covering quadrants

numPatterns = size(dotParams,2);

filled_quad_idx = zeros(numQuads,1);
for patt_id = 1:numPatterns
    dotData(patt_id) = initialize_dots(dotParams,patt_id,Scr.ifi,Scr.pixelsperdegree);
    nearby_idx = sqrt(sum( ( repmat(dotParams(patt_id).centers,numQuads,1) - myVar.centers').^2,2)) < 50;
    if any(nearby_idx)
        filled_quad_idx(nearby_idx) = patt_id;
    end
end

%% Prepare EyeTracker
if ~inf.dummy && bl ~= 1
    
    % START RECORDING to EDF file.
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);                 % Let eyeTracker to make a transition.
    Eyelink('startrecording');
    WaitSecs(0.1);                  % Record few samples to be sure
    inf.eye = Eyelink('EyeAvailable');
    if inf.eye == el.BINOCULAR
        inf.eye = el.RIGHT_EYE;
    end
    
    % CHECK RECORDING. Better because it is dedicated for checking
    elERR=Eyelink('CheckRecording');
    if(elERR~=0)
        error('EyeTracker is not recording!\n');
    end
    accuracyForEye = round(nanmean([block(bl).trials.Accuracy])*100,0); %Calculate mean accuracy of Pp
    if isnan(accuracyForEye),accuracyForEye = 0; end                    % EyeTracker accepts only positive numbers
    
    % Important messages
    Eyelink('message', 'Bl_Tr_Sc_Config %d %d %d %d',...              % MESSAGE FOR EDF
        bl, tr,trialParams.scene_ID,trialParams.config);
    
    
    % Ask Roman about this -- May 28 2019
    Eyelink('command', 'record_status_message "TRIAL %d/%d   BLOCK %d/%d   ACCURACY %d proc  ThExtra(2-Yes) %d"',...
        length(block(bl).trials)-tr, length(block(length(block)).trials),bl,length(block),accuracyForEye,inf.GabCalibExtra+1);% MESSAGE FOR eyeTraker SCREEN
end

% Prepare SCREEN
UR_ptr = Screen('MakeTexture',Scr.w,myVar.UR_symbol); 
RD_ptr = Screen('MakeTexture',Scr.w,myVar.RD_symbol); 
DL_ptr = Screen('MakeTexture',Scr.w,myVar.DL_symbol); 
LU_ptr = Screen('MakeTexture',Scr.w,myVar.LU_symbol); 

% draw the scene symbols at the bottom of the screen
Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect); 
Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect); 
Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect); 
Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect); 

Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);

vbl = Screen('Flip', Scr.w); %%synch%%

if save_flag
    trial_video = [];
end

%% CHECK: IS EYE ON THE FIXATION?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eyeCheckOnset = vbl;                                                                           %%%%TIME%%%%%%%
if ~inf.dummy && bl ~= 1
    Eyelink('message', 'EYE_CHECK');
    while eyeCheck
        
        [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
        if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
            Screen('CloseAll')
            error('EXIT button!\n');
        elseif KeyCode(myVar.cKey)      % Do whole CALIBRATION
            Eyelink('stoprecording');
            EyelinkDoTrackerSetup(el);  % CALIBRATION!!!!
            trialRep  = true; trialError = 5; trialIsOK = false; eyeCheck  = false; % Stop EyeCheck
        elseif KeyCode(myVar.dKey)      % Do DRIFT CORRECTION
            Eyelink('stoprecording');
            % Do drift correction
%             Screen('DrawDots', Scr.w, fixationCoord, 6, Scr.black, [], 2);
            Screen('DrawDots', Scr.w, fixationCoord, 6, Scr.white, [], 2); % changed this because now our background screen is black, not gray
            Screen('Flip', Scr.w);
            EyelinkDoDriftCorrection(el, myVar.fixXLoc, myVar.fixYLoc,0); % DRIFT CORRECTION!!!!
%             Screen('DrawDots', Scr.w, fixationCoord, 6, Scr.black, [], 2);
            Screen('DrawDots', Scr.w, fixationCoord, 6, Scr.white, [], 2);
            Screen('Flip', Scr.w);
            %finish the trial
            trialRep  = true; trialError = 5; trialIsOK = false; eyeCheck  = false; % Stop EyeCheck
        elseif KeyCode(myVar.pKey)      % Skip EyeCheck
            eyeCheck  = false;
        elseif KeyCode(myVar.tKey)      % Do Threshold calibration before the next block
            % Ask Roman about this -- May 28 2019
            Eyelink('command', 'record_status_message "TRIAL %d/%d   BLOCK %d/%d   ACCURACY %d proc  ThExtra(2-Yes) %d"',...
                length(block(bl).trials)-tr, length(block(length(block)).trials),bl,length(block),accuracyForEye,inf.GabCalibExtra+1);% MESSAGE FOR eyeTraker SCREEN
            inf.GabCalibExtra = true;
        end
        
        if Eyelink('NewFloatSampleAvailable')>0 % If NO EYE DATA
            evt = Eyelink('NewestFloatSample'); % take EyePosition
            eyeX = evt.gx(inf.eye +1);
            eyeY = evt.gy(inf.eye +1);
            
            if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && evt.pa(inf.eye +1) > 0  % IF EYE OK
                
                % IF Pp NOT LOOKING AT THE FIXATION
                if sqrt(sum( (fixationCoord - [eyeX eyeY]).^2,2)) > inf.eyeWindow * Scr.pixelsperdegee
%                 if sqrt((eyeX - myVar.centerX)^2 + (eyeY - myVar.centerY)^2) > inf.eyeWindow * Scr.pixelsperdegree
                    Eyelink('command','draw_filled_box %d %d %d %d 4', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                    Eyelink('command', 'draw_text %d %d 0 Eye NOT in the CENTER!',round(Scr.width/2),round(Scr.height-Scr.height/32));
%                     Screen('DrawDots', Scr.w, fixationCoord, 12, Scr.black, [], 2);
                    Screen('DrawDots', Scr.w, fixationCoord, 12, Scr.white, [], 2);
                    % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
                    % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
                    vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                    eyeCheckDur = round(.2/Scr.ifi);    % Restore eyeCheckDur
                else % OR LOOKING
                    Eyelink('command','draw_filled_box %d %d %d %d %d', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height,frameCol);
                    Eyelink('command', 'draw_text %d %d 0 Eye is OK',round(Scr.width/2),round(Scr.height-Scr.height/32));
                    % EYE AT THE SCREEN CENTER
%                     Screen('DrawDots', Scr.w, fixationCoord, 6, Scr.black, [], 2);
                    Screen('DrawDots', Scr.w, fixationCoord, 6, Scr.white, [], 2);
                    % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
                    % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
                    vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                    eyeCheckDur = eyeCheckDur - 1;  % COUNTDOWN FLIPS
                    if  eyeCheckDur-1 <= 0
                        eyeCheck = false; % NO errDur and NO checkDur
                    end
                end
                
            else % Pp BLINKED
                Eyelink('command','draw_filled_box %d %d %d %d 1', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                Eyelink('command', 'draw_text %d %d 15 NO EYE!',round(Scr.width/2),round(Scr.height-Scr.height/32));
%                 Screen('DrawDots', Scr.w, fixationCoord, 12, Scr.black, [], 2);
                Screen('DrawDots', Scr.w, fixationCoord, 12, Scr.white, [], 2);
                % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
                % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
                vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                eyeCheckDur = round(.2/Scr.ifi); % Restore eyeCheckDur
            end
        end
    end
end

if trialIsOK
    
    %% FIXATION
    %%%%%%%%%%%
    
    % Synchronize screen and send messages
   
    % draw the scene symbols at the bottom of the screen
    Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
    Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
    Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
    Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);

    Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
    Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
    Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
    
    vbl = Screen('Flip', Scr.w);    % SCREEN SYNCH.
    fixationOnset = vbl;             %%%%TIME%%%%%%%
    
    grab_flag = true;
    
    for fixationFlips = 1:fixationDur-1
        %%%%%%%%%%%%%%I.Present the Fixation point
        
        [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
        if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
            Screen('CloseAll')
            error('EXIT button!\n');
        end
        
       
        % draw the scene symbols at the bottom of the screen
        Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
        Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
        Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
        Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);
        
        DrawFormattedText(Scr.w,'Please Fixate on the Cross!','center',Scr.wRect(4)-0.1*Scr.pixelsperdegree,[255 255 255]);
        
        Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
        Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
        Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
        
        vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
        
        if grab_flag && save_flag
            tmp_img = Screen('GetImage',Scr.w);
            tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
            trial_video = cat(4,trial_video,tmp_img);
        end
        grab_flag = ~grab_flag;
        
        if inf.dummy
            [pos_x,pos_y] = GetMouse(Scr.w);
            %             else
            % check for position of eyes
            %                 evt = Eyelink('NewestFloatSample'); % take EyePosition
            %                 pos_x = evt.gx(inf.eye +1);
            %                 pos_y = evt.gy(inf.eye +1);
        end
                
        if sqrt(sum(([pos_x,pos_y] - fixationCoord).^2)) <= inf.eyeWindow * Scr.pixelsperdegree
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
        
        quadrant_dwell_counters = zeros(numQuads,1);
               
        button_state = false(1,3);

%         while and(((KeyIsDown~=1) && noResponse),exploreFlips < exploreDur)
         while and(( ~button_state(1) && noResponse),exploreFlips < exploreDur)
            
            [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
            if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
                Screen('CloseAll');
                error('EXIT button!\n');   
            end
            
            Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
            % draw the scene symbols at the bottom of the screen
            Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
            Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
            Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
            Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);
            
            DrawFormattedText(Scr.w,'Explore the scene...','center',Scr.wRect(4)-0.1*Scr.pixelsperdegree,[255 255 255]);
            
            if inf.dummy
                [pos_x,pos_y,button_state] = GetMouse(Scr.w);
%                 [pos_x,pos_y] = GetMouse(Scr.w);
%             else
                % check for position of eyes
%                 evt = Eyelink('NewestFloatSample'); % take EyePosition
%                 pos_x = evt.gx(inf.eye +1);
%                 pos_y = evt.gy(inf.eye +1);
            end

%             quadrant_idx = sqrt(sum( ( repmat([pos_x,pos_y],numQuads,1) - myVar.centers').^2,2)) <= myVar.gazeWindow;
            % old boundary conditions (using radius from center)
            
            %new rectangular boundary conditions (more appropriate for the
            %quadrants)
            quadrant_idx = false(numQuads,1);
            for quad_i = 1:numQuads
                xv = [myVar.RDMRects(1,quad_i) myVar.RDMRects(1,quad_i) myVar.RDMRects(3,quad_i) myVar.RDMRects(3,quad_i)];
                yv = [myVar.RDMRects(2,quad_i) myVar.RDMRects(4,quad_i) myVar.RDMRects(4,quad_i) myVar.RDMRects(2,quad_i)];
                quadrant_idx(quad_i) = inpolygon(pos_x,pos_y,xv,yv);
            end
            
            numChoices = size(myVar.choiceRects,2);
            choice_idx = false(numChoices,1);
            for c_i = 1:numChoices
                xv = [myVar.choiceRects(1,c_i) myVar.choiceRects(1,c_i) myVar.choiceRects(3,c_i) myVar.choiceRects(3,c_i)];
                yv = [myVar.choiceRects(2,c_i) myVar.choiceRects(4,c_i) myVar.choiceRects(4,c_i) myVar.choiceRects(2,c_i)];
                choice_idx(c_i) = inpolygon(pos_x,pos_y,xv,yv);
            end
            
                                
            if any(quadrant_idx)
                
                rev_quadrant = find(quadrant_idx);
                
                quadrant_dwell_counters(rev_quadrant) = quadrant_dwell_counters(rev_quadrant) + Scr.ifi;
                
                if  quadrant_dwell_counters(rev_quadrant) >= myVar.revealTime
                    if ismember(rev_quadrant,find(filled_quad_idx))
                   
                        patt_id_temp = filled_quad_idx(rev_quadrant);
                        dotData(patt_id_temp) = update_dots(dotData(patt_id_temp));
                        % draws the current dots, using position, single size argument and dotType
                        Screen('DrawDots', Scr.w, dotData(patt_id_temp).dotPos, dotData(patt_id_temp).size, [255 255 255], [0 0], dotData(patt_id_temp).dotType);
                                              
                    end
                    
                    remaining_quadrants = ~ismember(1:numQuads,rev_quadrant); % this yields the logical indices for the remaining, non-revealed quadrants
                    % for the following 'FillRect' command
                    
                    Screen('FillRect',Scr.w,quadColors(:,remaining_quadrants),myVar.RDMRects(:,remaining_quadrants))
                    Screen('FrameRect',Scr.w,quadFrameColors(:,remaining_quadrants),myVar.RDMRects(:,remaining_quadrants),myVar.frameLineWidth);
                else
                    Screen('FillRect',Scr.w,quadColors,myVar.RDMRects)
                    Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);     
                end
                

            else
                quadrant_dwell_counters = zeros(numQuads,1);

                Screen('FillRect',Scr.w,quadColors,myVar.RDMRects)
                Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);

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
            
            Reward = myVar.discount_function(exploreFlips);
            
            exploreFlips = exploreFlips + 1;
            
            %%%%%%%%%%%%%%II.Check Response
            [KeyIsDown,endRTRaw, KeyCodeRaw] = KbCheck();
            
%             if (KeyIsDown==1) && respToBeMade
            if or( ((KeyIsDown==1) && respToBeMade),button_state(1))

                if KeyCodeRaw(KbName('ESCAPE'))  % EXIT key pressed to exit experiment
                    Screen('CloseAll')
                    error('EXIT button!\n');
                else
%                     if any(KeyCodeRaw([up_right,right_down,down_left,left_up]))      
                    if any(choice_idx)
                        trialRT = endRTRaw - exploreOnset; % save RT!!!!
                        noResponse = false;
                        if choice_idx(1)
%                         if KeyCodeRaw(up_right)
                            sceneChoice = 1;
                            if trialParams.scene_ID == 1
                                trialAcc = 1;
                            else
                                trialAcc = 0;
                            end
%                         elseif KeyCodeRaw(right_down)
                        elseif choice_idx(2)
                            sceneChoice = 2;
                            if trialParams.scene_ID == 2
                                trialAcc = 1;
                            else
                                trialAcc = 0;
                            end
%                         elseif KeyCodeRaw(down_left) 
                        elseif choice_idx(3)
                            sceneChoice = 3;
                            if trialParams.scene_ID == 3
                                trialAcc = 1;
                            else
                                trialAcc = 0;
                            end
%                         elseif KeyCodeRaw(left_up)
                        elseif choice_idx(4)
                            sceneChoice = 4;
                            if trialParams.scene_ID == 4
                                trialAcc = 1;
                            else
                                trialAcc = 0;
                            end
                        else
                            trialAcc = 0; sceneChoice = NaN;
                        end                       
                    else
                        trialError = 1; noResponse = false; sceneChoice = NaN;          % END THE TRIAL
                    end
                end
            else
                noResponse = true; sceneChoice = NaN; % ran out of time
            end
              
        end
        
        if trialAcc == 1
            Reward = Reward + 200;
        else
            Reward = Reward - 400;
        end
        
        if trialIsOK
            
            grab_flag = true;
            for i = 1:choiceDur 
                
                [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
                if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
                    Screen('CloseAll')
                    error('EXIT button!\n');
                end
                      
                % draw the scene symbols at the bottom of the screen
                Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
                Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
                Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
                Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);
                
                if trialAcc == 1
                    Screen('FrameRect',Scr.w,[0 200 50],myVar.choiceRects(:,sceneChoice),myVar.feedbackFrameWidth);
                    DrawFormattedText(Scr.w,'Correct','center',Scr.wRect(4)-0.1*Scr.pixelsperdegree,[0 200 50]);
                elseif and(trialAcc == 0,~isnan(sceneChoice))
                    Screen('FrameRect', Scr.w, [255 0 ceil(255/4)], myVar.choiceRects(:,sceneChoice),myVar.feedbackFrameWidth);
                    DrawFormattedText(Scr.w,'Incorrect','center',Scr.wRect(4)-1.0*Scr.pixelsperdegree,[255 0 ceil(255/4)]);
                elseif noResponse
                    DrawFormattedText(Scr.w,'Ran out of time!','center',Scr.wRect(4)-1.0*Scr.pixelsperdegree,[255 0 ceil(255/4)]);
                else                   
                    DrawFormattedText(Scr.w,'Invalid response!','center',Scr.wRect(4)-1.0*Scr.pixelsperdegree,[255 0 ceil(255/4)]);
                end
                
                Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
                Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
                Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
                vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                
                if grab_flag && save_flag
                    tmp_img = Screen('GetImage',Scr.w);
                    tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
                    trial_video = cat(4,trial_video,tmp_img);
                end
                
                grab_flag = ~grab_flag;
                
                if i == 1
                    choiceOnset = vbl;                                              %%%%%%%TIME%%%%%%%%%
                end
                
            end
            
            grab_flag = true;
            for i = 1:feedbackDur 
                
                [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
                if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
                    Screen('CloseAll')
                    error('EXIT button!\n');
                end
                      
                
                if trialAcc == 1
                    rew_message = sprintf('%.2f points awarded!',Reward);
                    DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[0 200 50]);
                elseif and(trialAcc == 0,~isnan(sceneChoice))
                    rew_message = sprintf('%.2f points awarded!',Reward);
                    DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[255 0 ceil(255/4)]);
                elseif noResponse
                    rew_message = sprintf('%.2f points awarded!',Reward);
                    DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[255 0 ceil(255/4)]);
                else
                    rew_message = sprintf('%.2f points awarded!',Reward);
                    DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[255 0 ceil(255/4)]);
                end
                
                if tr == 1
                    DrawFormattedText(Scr.w,sprintf('Total score: %.2f points',Reward),'center',myVar.centerY + (1.5 * Scr.pixelsperdegree),[255 255 255]);
                else
                    DrawFormattedText(Scr.w,sprintf('Total score: %.2f points',(block(bl).trials(tr-1).Reward + Reward)),'center',myVar.centerY + (1.5 * Scr.pixelsperdegree),[255 255 255]);
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
trial_data.sceneChoice = sceneChoice;
trial_data.trialError = trialError;
if tr == 1
    trial_data.Reward     = Reward;
else
    trial_data.Reward     = block(bl).trials(tr-1).Reward + Reward; % accumulate total score
end

trial_data.trialSTART = trialSTART;
trial_data.fixationOnset = fixationOnset;
trial_data.exploreOnset = exploreOnset;
trial_data.choiceOnset = choiceOnset;
trial_data.feedbackOnset = feedbackOnset;
trial_data.trialEND = trialEND;

if save_flag
    trial_data.trial_video = trial_video;
end

% Clear screen
Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
Screen('Flip', Scr.w);


        
            
        
        
        
    
    




