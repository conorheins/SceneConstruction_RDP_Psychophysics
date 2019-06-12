function [inf,trial_data,el] = RunTrial_MD(Scr,inf,myVar,el,bl,tr,block,trialParams,save_flag)

% Script for a single trial of the motion-direction discrimination paradigm

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
%                parameters of stimuli to display on block(bl).trial(tr), participant's reaction time
%                on block(bl).trial(tr).
% - trialParams: structure containing trial-specific experimental (independent) and behavioral (dependent) measures
% - save_flag:   Boolean true/false flag (1 / 0) indicating whether to save
%                the frames of the trial into a video

trialSTART = GetSecs;                                                      %%%%TIME%%%%%%%

fixationCoord = [myVar.fixXLoc myVar.fixYLoc];% location of center of fixation cross

% Prepare response variables
trialRT                 = nan;
trialAcc                = nan;
dirResponse             = nan;

% Timing Points
fixationOnset           = nan;
accumOnset              = nan;
feedbackOnset           = nan;
trialEND                = nan;

% Prepare variables for stimulation.
trialError  = 0;
trialIsOK   = true;             % Check eye position during trial
respToBeMade= true;
noResponse  = true;

% Timing in frames
if tr == 1
    ShowCursor(1)
    fixationDur  = round(myVar.fixationTime/Scr.ifi);                        % Duration of Fixation is longer if it's the first trial (gives subject time to move cursor/eyes to center)
else
    fixationDur = round(  (myVar.ITI_sd*randn(1) + myVar.intertrialTime) /Scr.ifi );
end

if bl < 3
    accumDur = round(myVar.train_accumTime /Scr.ifi);                            % For early/practice blocks, make RDP time basically infinite
else
    accumDur     = round(myVar.accumTime /Scr.ifi);                             % Duration of RDP duration 
end
feedbackDur  = round(myVar.feedbackTime/Scr.ifi);                        % Feedback display for 250 ms

% Adjust response keys
UP_choice    = myVar.upKey;
RIGHT_choice = myVar.rightKey;
DOWN_choice  = myVar.downKey;
LEFT_choice  = myVar.leftKey;

% Initialize coordinates of fixation cross
fix_x = [-myVar.fixCrossDimPix myVar.fixCrossDimPix 0 0];
fix_y = [0 0 -myVar.fixCrossDimPix myVar.fixCrossDimPix];
all_fix_coords = [fix_x;fix_y];

dotParams = trialParams.dotParams; % get the RDP dot parameters for the current trial

dotData = initialize_dots(dotParams,1,Scr.ifi,Scr.pixelsperdegree);

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
        bl, tr,trialParams.scene,trialParams.config);
    
    
    % Ask Roman about this -- May 28 2019
    Eyelink('command', 'record_status_message "TRIAL %d/%d   BLOCK %d/%d   ACCURACY %d proc  ThExtra(2-Yes) %d"',...
        length(block(bl).trials)-tr, length(block(length(block)).trials),bl,length(block),accuracyForEye,inf.GabCalibExtra+1);% MESSAGE FOR eyeTraker SCREEN
end

% Prepare SCREEN
Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);

UP_ptr = Screen('MakeTexture',Scr.w,myVar.UP); 
RIGHT_ptr = Screen('MakeTexture',Scr.w,myVar.RIGHT); 
DOWN_ptr = Screen('MakeTexture',Scr.w,myVar.DOWN); 
LEFT_ptr = Screen('MakeTexture',Scr.w,myVar.LEFT); 

% draw the direction choice symbols at the bottom of the screen
Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect); 
Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect); 
Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect); 
Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect); 

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
    Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
    % draw the direction choice symbols at the bottom of the screen
    Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect);
    Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect); 
    Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect); 
    Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect); 
    
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
        
        Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
        % draw the direction choice symbols at the bottom of the screen
        Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect);
        Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect);
        Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect);
        Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect);
        
        if tr == 1
            DrawFormattedText(Scr.w,'Please Bring the Cursor to the Center of the Fixation Cross!','center',Scr.wRect(4)*0.95,[255 255 255]);
        end
        
        vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
        
        if grab_flag && save_flag
            tmp_img = Screen('GetImage',Scr.w);
            tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
            trial_video = cat(4,trial_video,tmp_img);
        end
        grab_flag = ~grab_flag;

        [mouse_x,mouse_y] = GetMouse(Scr.w);
        
        if sqrt(sum(([mouse_x,mouse_y] - fixationCoord).^2)) <= inf.eyeWindow * Scr.pixelsperdegree
            trialIsOK = true;
        else
            trialIsOK = false;
        end
    
    end
    
    %% DOTS DISPLAY ONSET
    %%%%%%%%%%
    if trialIsOK
        
        HideCursor();
        
        KeyIsDown = KbCheck();
        accumFlips = 1;
        
        grab_flag = true;
        
        while and(((KeyIsDown~=1) && noResponse),accumFlips < accumDur)
            
            [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
            if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
                Screen('CloseAll')
                error('EXIT button!\n');   
            end
            
            % draw the direction choice symbols at the bottom of the screen
            Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect); 
            Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect);
            Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect);
            Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect);
            
            dotData = update_dots(dotData);
            Screen('DrawDots', Scr.w, dotData.dotPos, dotData.size, [255 255 255], [0 0], dotData.dotType);
        
            vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
            
            if grab_flag && save_flag
                tmp_img = Screen('GetImage',Scr.w);
                tmp_img = tmp_img(1:2:end,1:2:end,:); % downsample by a factor of 2 to save space
                trial_video = cat(4,trial_video,tmp_img);
            end
            grab_flag = ~grab_flag;

            if accumFlips == 1
                accumOnset = vbl;                                                          %%%%TIME%%%%%%%
            end
            
            accumFlips = accumFlips + 1;
            
            %%%%%%%%%%%%%%II.Check Response
            [KeyIsDown,endRTRaw, KeyCodeRaw] = KbCheck();
            if (KeyIsDown==1) && respToBeMade
                if KeyCodeRaw(myVar.escapeKey)  % EXIT key pressed to exit experiment
                    Screen('CloseAll')
                    error('EXIT button!\n');
                else
                    if any(KeyCodeRaw([UP_choice,RIGHT_choice,DOWN_choice,LEFT_choice]))                       
                        trialRT = endRTRaw - accumOnset; % save RT!!!!
                        noResponse = false;
                        if KeyCodeRaw(UP_choice)
                            dirResponse = 180;
                            if trialParams.direction == 180
                                trialAcc = 1; 
                            else
                                trialAcc = 0;
                            end
                        elseif KeyCodeRaw(RIGHT_choice)
                            dirResponse = 90;
                            if trialParams.direction == 90
                                trialAcc = 1;
                            else
                                trialAcc = 0;
                            end
                        elseif KeyCodeRaw(DOWN_choice)
                            dirResponse = 0;
                            if trialParams.direction == 0
                                trialAcc = 1; 
                            else
                                trialAcc = 0;
                            end
                        elseif KeyCodeRaw(LEFT_choice)
                            dirResponse = 270;
                            if trialParams.direction == 270
                                trialAcc = 1; 
                            else
                                trialAcc = 0;
                            end
                        else
                            trialAcc = 0; dirResponse = NaN;
                        end                       
                    else
                        trialError = 1; trialIsOK = false; noResponse = false; dirResponse = NaN;          % END THE TRIAL
                    end
                end
            else
                noResponse = true; dirResponse = NaN;
            end
             
        end
        
        if trialIsOK
            
            grab_flag = true;
            for i = 1:feedbackDur 
                
                [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
                if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
                    Screen('CloseAll')
                    error('EXIT button!\n');
                end
                
                % draw the direction choice symbols at the bottom of the screen
                Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect);
                Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect);
                Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect);
                Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect);
                
                % uncomment if you want to provide feedback on accuracy
%                 if trialAcc == 1
%                     Screen('FrameOval', Scr.w, [0 255 0], CenterRectOnPointd([0 0 50 50],fixationCoord(1),fixationCoord(2)));
%                     DrawFormattedText(Scr.w,'Correct!','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
%                 else
%                     Screen('FrameOval', Scr.w, [255 0 0], CenterRectOnPointd([0 0 50 50],fixationCoord(1),fixationCoord(2)));
%                     DrawFormattedText(Scr.w,'Incorrect!','center',Scr.wRect(4)*0.95,[255 0 ceil(255/4)]);
%                 end
                if noResponse
                    DrawFormattedText(Scr.w,'No response made!','center',Scr.wRect(4)*0.95,[255 0 ceil(255/4)]);
                elseif and(~noResponse,bl==1)
                    if KeyCodeRaw(UP_choice)
%                         DrawFormattedText(Scr.w,'Chose UP','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
                        DrawFormattedText(Scr.w,'Chose UP','center',Scr.wRect(4)*0.95,Scr.white);
%                         Screen('FrameRect', Scr.w, [0 200 50], myVar.UPrect, 5);
                        Screen('FrameRect', Scr.w, Scr.white, myVar.UPrect, 5);
                    elseif KeyCodeRaw(RIGHT_choice)
%                         DrawFormattedText(Scr.w,'Chose RIGHT','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
                        DrawFormattedText(Scr.w,'Chose RIGHT','center',Scr.wRect(4)*0.95,Scr.white);
%                         Screen('FrameRect', Scr.w, [0 200 50], myVar.RIGHTrect, 5);
                        Screen('FrameRect', Scr.w, Scr.white, myVar.RIGHTrect, 5);
                    elseif KeyCodeRaw(DOWN_choice)
%                         DrawFormattedText(Scr.w,'Chose DOWN','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
                        DrawFormattedText(Scr.w,'Chose DOWN','center',Scr.wRect(4)*0.95,Scr.white);
%                         Screen('FrameRect', Scr.w, [0 200 50], myVar.DOWNrect, 5);
                        Screen('FrameRect', Scr.w, Scr.white, myVar.DOWNrect, 5);
                    elseif KeyCodeRaw(LEFT_choice)
%                         DrawFormattedText(Scr.w,'Chose LEFT','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
                        DrawFormattedText(Scr.w,'Chose LEFT','center',Scr.wRect(4)*0.95,Scr.white);
%                         Screen('FrameRect', Scr.w, [0 200 50], myVar.LEFTrect, 5);
                        Screen('FrameRect', Scr.w, Scr.white, myVar.LEFTrect, 5);
                    end 
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
trial_data.dirResponse = dirResponse;
trial_data.trialError = trialError;

trial_data.trialSTART = trialSTART;
trial_data.fixationOnset = fixationOnset;
trial_data.accumOnset = accumOnset;
trial_data.feedbackOnset = feedbackOnset;
trial_data.trialEND = trialEND;

if save_flag
    trial_data.trial_video = trial_video;
end

% Clear screen
Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
Screen('Flip', Scr.w);


        
            
        
        
        
    
    




