function [inf,trial_data,el] = RunTrial_MD(Scr,inf,myVar,el,bl,tr,block,trialParams)

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
respToBeMade= true;
noResponse  = true;

% Timing in frames
if tr == 1
    fixationDur  = round(myVar.fixationTime/Scr.ifi);                        % Duration of Fixation is longer if it's the first trial (gives subject time to move cursor/eyes to center)
else
    fixationDur = round(  (myVar.ITI_sd*randn(1) + myVar.intertrialTime) /Scr.ifi );
end

if bl < 3
    accumDur = round(myVar.train_accumTime /Scr.ifi);                            % For early/practice blocks, make RDP time basically infinite
else
    accumDur     = round(myVar.accumTime /Scr.ifi);                             % Duration of RDP duration 
end
feedbackDur  = round(myVar.feedbackTime/Scr.ifi);           % Duration of 'Feedback' display (just shows participant what they chose)
eyeCheckDur  = round(myVar.eyeCheckTime/Scr.ifi);           % Duration of EyeLink fixation in frames

% Adjust response keys
UP_choice    = myVar.upKey;
RIGHT_choice = myVar.rightKey;
DOWN_choice  = myVar.downKey;
LEFT_choice  = myVar.leftKey;

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
    Eyelink('message', 'Bl_Tr_Dir_Coh %d %d %d %d ',...              % MESSAGE FOR EDF
        bl, tr,trialParams.direction,round(trialParams.coherence));
    
    Eyelink('command', 'record_status_message "BLOCK %d/%d TRIAL %d/%d"',...               % MESSAGE TO BE DISPLAYED ON EYELINK SCREEN
        bl,length(block),tr,length(block(bl).trials));
    
end

UP_ptr = Screen('MakeTexture',Scr.w,myVar.UP); 
RIGHT_ptr = Screen('MakeTexture',Scr.w,myVar.RIGHT); 
DOWN_ptr = Screen('MakeTexture',Scr.w,myVar.DOWN); 
LEFT_ptr = Screen('MakeTexture',Scr.w,myVar.LEFT); 
choice_pointers = {UP_ptr,RIGHT_ptr,DOWN_ptr,LEFT_ptr};

% draw the direction choice symbols at the bottom of the screen
Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect); 
Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect); 
Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect); 
Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect); 

vbl = Screen('Flip', Scr.w); %%synch%%

%% CHECK: IS EYE ON THE FIXATION?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eyeCheckOnset = vbl;                                                                           %%%%TIME%%%%%%%
if ~inf.dummy
    Eyelink('message', 'EYE_CHECK');
    while eyeCheck   
        [ eyeCheck,eyeCheckDur,vbl] = doEyeCheck_MD(Scr,myVar,inf,el,fixationCoord,choice_pointers,eyeCheck,eyeCheckDur,vbl);
    end
end

%% FIXATION
%%%%%%%%%%%
   
% Synchronize screen and send messages
Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
% draw the direction choice symbols at the bottom of the screen
Screen('DrawTexture', Scr.w, UP_ptr,myVar.subRect,myVar.UPrect);
Screen('DrawTexture', Scr.w, RIGHT_ptr,myVar.subRect,myVar.RIGHTrect);
Screen('DrawTexture', Scr.w, DOWN_ptr,myVar.subRect,myVar.DOWNrect);
Screen('DrawTexture', Scr.w, LEFT_ptr,myVar.subRect,myVar.LEFTrect);

vbl = Screen('Flip', Scr.w);    % SCREEN SYNCH.
fixationOnset = vbl;             %%%%TIME%%%%%%%

vbl = fixationPeriod_MD(Scr,myVar,fixationCoord,fixationDur,choice_pointers,vbl);

%% DOTS DISPLAY ONSET
%%%%%%%%%%

if ~inf.dummy
    Eyelink('message', 'ACCUM_START');
end

HideCursor();

KeyIsDown = KbCheck();
accumFlips = 1;
        
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
    
    if i == 1
        feedbackOnset = vbl;                                              %%%%%%%TIME%%%%%%%%%
    end
end
trialEND = vbl;
            
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

% Clear screen
Screen('Flip', Scr.w);


        
            
        
        
        
    
    




