function [inf,block,el,tr] = RunSingleTrial(Scr,inf,myVar,el,bl,tr,block,trialData)

trialSTART = GetSecs;                                                       %%%%TIME%%%%%%%

% Prepare response variables
trialRT                 = nan;
trialAcc                = nan;
keyPressed              = nan;
increment               = nan;

% Timing Points
fixationOnset           = nan;
soundOnset              = nan;
targetOnset             = nan;
endRT                   = nan;
RespOnsetFlip           = nan;
feedbackOnset           = nan;
trialEND                = nan;

% Prepare variables for stimulation.
rotate      = 90;               % the orientation of GABOR
trialError  = 0;
eegEyeError = 1;
eyeCheck    = true;             % for fixation
trialIsOK   = true;             % Check eye position during trial
respToBeMade= true;
trialRep    = false;            % repeate at the end of the experiment (To brevent multiple repetitions)
noResponse  = false;
eyeMoved    = false;            % check for target eye position less then 1 deg.

% Timing in frames
eyeCheckDur  = round(.2 /Scr.ifi);                                  % Duration of Eye Check
fixationDur  = round((randsample(.5:0.1:1.2,1)) /Scr.ifi);          % Duration of Fixation;
cueDur       = round(.25 /Scr.ifi);                                 % Duration of Target (Gabor)

% Adjust response keys

key1 = myVar.upKey;
key2 = myVar.downKey;
eegPlus = 30;


%% Prepare EyeTracker and EEG
if ~inf.dummy && bl ~= 1
    
    % START RECORDING to EDF file.
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);                 % Let eyeTracker to make a transition.
    Eyelink('startrecording');
    WaitSecs(0.1);                  % Record few samples to be sure
    inf.eye = Eyelink('EyeAvailable');
    if inf.eye == el.BINOCULAR;
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
    Eyelink('message', 'Bl_Tr_Cn_Rp_Go %d %d %d %d %d',...              % MESSAGE FOR EDF
        bl, tr,trialData.conditionType,trialData.relativePos,trialData.gaborOri);
    Eyelink('command', 'record_status_message "TRIAL %d/%d   BLOCK %d/%d   ACCURACY %d proc  ThExtra(2-Yes) %d"',...
        length(block(bl).trials)-tr, length(block(length(block)).trials),bl,length(block),accuracyForEye,inf.GabCalibExtra+1);% MESSAGE FOR eyeTraker SCREEN
end



% Prepare SCREEN
Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
% if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
% Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
vbl = Screen('Flip', Scr.w); %%synch%%

%% CHECK: IS EYE ON THE FIXATION?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eyeCheckOnset = vbl;                                                                           %%%%TIME%%%%%%%
if ~inf.dummy && bl ~= 1
    Eyelink('message', 'EYE_CHECK');
    while eyeCheck
        
        [KeyIsDown,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
        if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
            error('EXIT button!\n');
        elseif KeyCode(myVar.cKey)      % Do whole CALIBRATION
            Eyelink('stoprecording');
            EyelinkDoTrackerSetup(el);  % CALIBRATION!!!!
            trialRep  = true; trialError = 5; trialIsOK = false; eyeCheck  = false; % Stop EyeCheck
        elseif KeyCode(myVar.dKey)      % Do DRIFT CORRECTION
            Eyelink('stoprecording');
            % Do drift correction
            Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
            Screen('Flip', Scr.w);
            EyelinkDoDriftCorrection(el, myVar.fixXLoc, myVar.fixYLoc,0); % DRIFT CORRECTION!!!!
            Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
            Screen('Flip', Scr.w);
            %finish the trial
            trialRep  = true; trialError = 5; trialIsOK = false; eyeCheck  = false; % Stop EyeCheck
        elseif KeyCode(myVar.pKey)      % Skip EyeCheck
            eyeCheck  = false;
        elseif KeyCode(myVar.tKey)      % Do Threshold calibration before the next block
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
                if sqrt((eyeX - myVar.centerX)^2 + (eyeY - myVar.centerY)^2) > inf.eyeWindow * Scr.pixelsperdegree
                    Eyelink('command','draw_filled_box %d %d %d %d 4', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                    Eyelink('command', 'draw_text %d %d 0 Eye NOT in the CENTER!',round(Scr.width/2),round(Scr.height-Scr.height/32));
                    Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 12, Scr.black, [], 2);
                    % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
                    % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
                    vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                    eyeCheckDur = round(.2/Scr.ifi);    % Restore eyeCheckDur
                    if eegEyeError==1 && ~inf.dumEEG,io64(inf.ioObject,inf.LPT1address,3+eegPlus);WaitSecs(0.001); eegEyeError =0; end %%%%%%%%%%    EEG 3 EYECHECK ERROR    !!!!!!!
                else % OR LOOKING
                    Eyelink('command','draw_filled_box %d %d %d %d %d', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height,frameCol);
                    Eyelink('command', 'draw_text %d %d 0 Eye is OK',round(Scr.width/2),round(Scr.height-Scr.height/32));
                    % EYE AT THE SCREEN CENTER
                    Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
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
                Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 12, Scr.black, [], 2);
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
    Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
    % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
    % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
    vbl = Screen('Flip', Scr.w);    % SCREEN SYNCH.
    fixationOnset = vbl;                                                                            %%%%TIME%%%%%%%
    if ~inf.dummy, Eyelink('message', 'FIXATION'); end
    if ~inf.dumEEG,io64(inf.ioObject,inf.LPT1address,4+eegPlus);WaitSecs(0.001); end                %%%%%%%%%%    EEG4 FIXATION OnSET   !!!!!!!
    
    for fixationFlips = 1:fixationDur-1
        %%%%%%%%%%%%%%I.Present the Fixation point
        Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
        % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
        % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
        vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
        
        %%%%%%%%%%%%%%II.Check The EyeLink if not Dummy mode
        if ~inf.dummy && trialData.BlPrePost ~= 3 && bl ~= 1
            % if Eyelink('NewFloatSampleAvailable')>0 % If NO EYE DATA
            evt = Eyelink('NewestFloatSample'); % take EyePosition
            eyeX = evt.gx(inf.eye+1);
            eyeY = evt.gy(inf.eye+1);
            
            if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && evt.pa(inf.eye+1) > 0  % IF EYE OK
                if sqrt((eyeX - myVar.centerX)^2 + (eyeY - myVar.centerY)^2) > inf.eyeWindow * Scr.pixelsperdegree
                    Eyelink('message', 'SACCADE');
                    % PsychPortAudio('Stop', myVar.pahandle);
                    Eyelink('command','draw_filled_box %d %d %d %d 13', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                    Eyelink('command','draw_text %d %d 0 Eye Movement during FIXATION',round(Scr.width/2),round(Scr.height-Scr.height/32));
                    trialRep = true; trialError = 3; % trialIsOK = false; break;
                end
            end
        end
    end
    
    %% TARGET OnSET
    %%%%%%%%%%
    
    if trialIsOK
        for cueFlips = 1:cueDur
            %%%%%%%%%%%%%%I.Present the Gabor
            Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
            if trialData.BlPrePost ~= 3 || bl==1 % DRAW GABOR
                Screen('DrawTextures', Scr.w, myVar.gabortex, [], trialData.gaborXLoc,... % SHOW GABOR!!!!
                    trialData.gaborOri*inf.PSE+rotate, [], [], [], [],kPsychDontDoRotation, myVar.propertiesMat');
            end
            
            vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
            
            if cueFlips == 1
                targetOnset = vbl;                                                          %%%%TIME%%%%%%%
                if ~inf.dummy,Eyelink('message', 'TARGET');end
            end
            
            %%%%%%%%%%%%%%II.Check Response
            [KeyIsDown,endRTRaw, KeyCodeRaw] = KbCheck();
            if (KeyIsDown==1) && respToBeMade
                if KeyCodeRaw(myVar.escapeKey)  % EXIT key pressed to exit experiment
                    error('EXIT button!\n');
                end
                endRT = endRTRaw;       % Avoid double press at WairResp(below)
                KeyCode = KeyCodeRaw;   % Avoid double press
                if ~inf.dummy, Eyelink('message', 'BUTTON_PRESSED'); end
                if ~inf.dumEEG,io64(inf.ioObject,inf.LPT1address,7+eegPlus);WaitSecs(0.001); end  %%%%%%%%%%    EEG7 RESPONSE   !!!!!!!
                respToBeMade = false;
            end
            
            %%%%%%%%%%%%%%III.Check EyeLink
            if ~inf.dummy && trialData.BlPrePost ~= 3 && bl ~= 1
                % if Eyelink('NewFloatSampleAvailable')>0 % If NO EYE DATA
                evt = Eyelink('NewestFloatSample'); % take EyePosition
                eyeX = evt.gx(inf.eye+1);
                eyeY = evt.gy(inf.eye+1);
                if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && evt.pa(inf.eye+1) > 0  % IF EYE OK
                    Eyelink('message', 'SACCADE');
                    Eyelink('command','draw_filled_box %d %d %d %d 13', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                    Eyelink('command','draw_text %d %d 0 Eye Movement during TARGET',round(Scr.width/2),round(Scr.height-Scr.height/32));
                    trialRep = true; trialError = 4;
                end
            end
        end
        
        %% TARGET OffSET
        %%%%%%%%%%%%%%
        if trialIsOK
            if bl~=1
                Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
                % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
                % Screen('FillOval', Scr.w, [0 0 0], myVar.gaborRects(:,1)); %%%for test
                RespOnsetFlip = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);          %%%%TIME%%%%%%%
                if ~inf.dummy, Eyelink('message', 'TARGET_OFF'); end
            else % If block 1 (Training) GABOR is on the screen till Response
                RespOnsetFlip = GetSecs();
            end
            trialRespWait = RespOnsetFlip+myVar.maxProbeResponse;        % WAIT FOR RESPONSE TIME
            
            
            %% RESPONSE
            %%%%%%%%%%%
            while respToBeMade
                [KeyIsDown, endRTRaw, KeyCodeRaw] = KbCheck();
                if KeyCodeRaw(myVar.escapeKey)  % EXIT key pressed to exit experiment
                    error('EXIT button!\n');
                elseif (KeyIsDown==1)           % if RESPONSE
                    endRT = endRTRaw;
                    KeyCode = KeyCodeRaw;
                    if ~inf.dummy, Eyelink('message', 'BUTTON_PRESSED'); end
                    respToBeMade = false;
                elseif trialRespWait < GetSecs() && bl~=1
                    respToBeMade = false;
                    noResponse = true;
                end
            end
            
            if noResponse
                if ~inf.dummy
                    Eyelink('command','draw_filled_box %d %d %d %d 14', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                    Eyelink('command','draw_text %d %d 0 TOO LONG RESPONSE!',round(Scr.width/2),round(Scr.height-Scr.height/32));
                end
                trialRep = true; trialError = 2; trialIsOK = false;           % END THE TRIAL
            elseif ~noResponse
                trialRT = endRT - targetOnset; % save RT!!!!
                if KeyCode(key1)
                    keyPressed = 1;                 % if UP BUTTON (Or LEFT)
                    if trialData.gaborOri < 0       % check if the response is correct
                        trialAcc = 0;               % we compare orientation angle and response
                    elseif trialData.gaborOri > 0   % + counter-clockwise
                        trialAcc = 1;
                    end
                elseif KeyCode(key2)          % if DOWN BUTTON (RIGHT)
                    keyPressed = 2;
                    if trialData.gaborOri < 0 % - clockwise e.g. -5 is 355deg DOWN
                        trialAcc = 1;
                    elseif trialData.gaborOri > 0
                        trialAcc = 0;
                    end  % example: if Pp respond with the leftKey upKey, the angle should be in + (angle>0) to be correct
                else
                    trialError = 1;
                end
                
                if trialError == 1 % WRONG BUTTON
                    if ~inf.dummy
                        Eyelink('command','draw_filled_box %d %d %d %d 12', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
                        Eyelink('command','draw_text %d %d 0 WRONG BUTTON!',round(Scr.width/2),round(Scr.height-Scr.height/32));
                    end
                    trialRep = true; trialError = 1; trialIsOK = false;           % END THE TRIAL
                end
            end
        end
    end
    
    
    if trialIsOK
        if ~inf.dummy && bl ~= 1
            Eyelink('message', 'TRIAL_END %d %d %d', trialError, trialAcc, KeyCode(key2));
            WaitSecs(0.1);                     % Record few samples to be sure
            Eyelink('stoprecording');
        else
            WaitSecs(0.1);
        end
    elseif ~trialIsOK % After saccade or no/wrong response
        PsychPortAudio('Stop', myVar.pahandle);
        if ~inf.dummy && bl ~= 1, Eyelink('message', 'TRIAL_END %d 0 0', trialError); end
        WaitSecs(0.1);  % Record few samples to be sure
        if ~inf.dummy && bl ~= 1, Eyelink('stoprecording'); end
        
        if trialError == 1 % If wrong Button
            DrawFormattedText(Scr.w, text,'center', 'center', [255 0 0]);
            Screen('Flip', Scr.w);
            WaitSecs(2);
        elseif ~trialIsOK % If another problem
            Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
            % Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);
            % if trialData.BlPrePost==3,Screen('FrameOval', Scr.w, myVar.colGrey, myVar.frameRects, myVar.frameLineWidth);end
            Screen('Flip', Scr.w);
            WaitSecs(0.7);
        end
    end
end

%% SAVE THE DATA
%%%%%%%%%%%%%%%%

% Important data
block(bl).trials(tr).Accuracy       = trialAcc;
block(bl).trials(tr).keyPressed     = keyPressed;
block(bl).trials(tr).Reward         = increment;
block(bl).trials(tr).PSE            = inf.PSE;
block(bl).trials(tr).RT             = trialRT;
block(bl).trials(tr).error          = trialError;
if bl~=37 % for the last block that contains errors keep the original tial and block numbers.
    block(bl).trials(tr).trialNum       = tr;
    block(bl).trials(tr).BlNumber       = bl;
end
% Timing Points
block(bl).trials(tr).trialSTART     = trialSTART;
block(bl).trials(tr).eyeCheckOnset  = eyeCheckOnset;
block(bl).trials(tr).fixationOnset	= fixationOnset;
block(bl).trials(tr).soundOnset     = soundOnset;
block(bl).trials(tr).targetOnset    = targetOnset;
block(bl).trials(tr).endRT          = endRT;
block(bl).trials(tr).RespOnsetFlip  = RespOnsetFlip;
block(bl).trials(tr).feedbackOnset  = feedbackOnset;
block(bl).trials(tr).trialEND       = trialEND;

fprintf(inf.resultsFile,'%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%1.2f\t%d\t%d\t%2.1f\t%4.0f\t%d\t%d\t%d\n',...
    num2str(inf.subNo),block(bl).trials(tr).BlNumber,block(bl).trials(tr).trialNum,trialData.BlPrePost,...
    trialData.VisAudMix,inf.expMode,trialData.conditionType,trialData.condition,trialData.StimValue,...
    trialData.relativePos,round(mean([trialData.gaborXLoc(1) trialData.gaborXLoc(3)])),trialData.GL,trialData.gaborOri,round(mean([trialData.boxXLoc(1) trialData.boxXLoc(3)])),...
    trialData.BL,trialData.boxCol(1),trialData.BC,trialData.soundPitch,trialData.SL,...
    trialData.SP,round(inf.PSE,3), trialAcc, keyPressed,increment,...
    round(trialRT,3)*1000,round(targetOnset-fixationOnset,3)*1000, round(RespOnsetFlip-targetOnset,3)*1000, trialError);

if trialRep
    if ~inf.dummy && bl ~= 1, Eyelink('message', 'TRIAL_END %d 0 0', trialError); end
    if ismember(trialData.BlPrePost,2)
        block(length(block)).trials(length(block(length(block)).trials)+1) = block(bl).trials(tr);
    elseif ismember(trialData.BlPrePost,[0 1 3])
        block(bl).trials(length(block(bl).trials)+1) = block(bl).trials(tr);
    end
end

% Check button release
while (KeyIsDown==1)&& trialError ~= 5
    [KeyIsDown]=KbCheck();
end

% Clear screen
Screen('DrawDots', Scr.w, [myVar.fixXLoc myVar.fixYLoc], 6, Scr.black, [], 2);
Screen('Flip', Scr.w);

if ~inf.dummy
    Eyelink('command','draw_filled_box %d %d %d %d 0', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
    Eyelink('command', 'draw_text %d %d 15 Trial is over',round(Scr.width/2),round(Scr.height-Scr.height/32));
end
return; 
end
