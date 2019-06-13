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
eyeCheck                = true;

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
eyeCheckDur  = round(myVar.eyeCheckTime/Scr.ifi);           % Duration of EyeLink fixation in frames

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
if ~inf.dummy
    
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
    
    % Important messages
    Eyelink('message', 'Bl_Tr_Dir_Coh %d %d %d %d',...                                     % MESSAGE FOR EDF
        bl, tr,trialParams.direction,trialParams.coherence);
    
    Eyelink('command', 'record_status_message "BLOCK %d/%d TRIAL %d/%d"',...               % MESSAGE TO BE DISPLAYED ON EYELINK SCREEN
        bl,length(block),tr,length(block(bl).trials));
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
if ~inf.dummy
    Eyelink('message', 'EYE_CHECK');
    while eyeCheck   
        [ eyeCheck,eyeCheckDur,vbl] = doEyeCheck(Scr,myVar,inf,el,fixationCoord,eyeCheck,eyeCheckDur,vbl);
    end
end

%% FIXATION
%%%%%%%%%%%

if trialIsOK
    
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
            error(sprintf('EXIT button!\n'));
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

        if inf.dummy
            [pos_x,pos_y] = GetMouse(Scr.w);
        else
            %  check for position of eyes
            if Eyelink('NewFloatSampleAvailable')>0 % If NO EYE DATA
                evt = Eyelink('NewestFloatSample'); % take EyePosition
                pos_x = evt.gx(inf.eye +1);
                pos_y = evt.gy(inf.eye +1);
            end
        end
        
        if sqrt(sum(([pos_x,pos_y] - fixationCoord).^2)) <= inf.eyeWindow * Scr.pixelsperdegree
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
trial_data.eyeCheckOnset = eyeCheckOnset;
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


        
            
        
        
        
    
    




