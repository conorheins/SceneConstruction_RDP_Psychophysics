function [ eyeCheck,eyeCheckDur,vbl] = doEyeCheck_SC(Scr,myVar,inf,el,fixationCoord,quadFrameColors,quadColors,choice_pointers,eyeCheck,eyeCheckDur,vbl)
%DOEYECHECK: Wrapper function for Roman's eye-checking procedures (checks
%            if eyes are in the fixation window)
% INPUTS:   Scr: structure containing Screen-specific information
%           myVar: contains constants related to the current study (e.g. fixation
%           coordinations, durations of particular trial periods/stimuli)
%           inf: general information structure also containing constants
%           related to the task
%           el: EyeLink data structure (contains  parameters
%           relevant to eye-tracking)
%           fixationCoord: [x y] coordinates of fixation
%           eyeCheckDur:   variable that acts as a counter of the fixation
%           period
%           vbl: timestamp

[~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
% draw the scene symbols and quadrants
Screen('DrawDots', Scr.w, fixationCoord, 20, Scr.black, [], 2);
drawScreenDisp(Scr,myVar,choice_pointers,quadColors,quadFrameColors);

if KeyCode(myVar.escapeKey)     % EXIT key pressed to exit experiment
    Screen('CloseAll')
    error('EXIT button!\n');
elseif KeyCode(myVar.cKey)      % Do whole CALIBRATION
    Eyelink('stoprecording');
    EyelinkDoTrackerSetup(el);  % CALIBRATION!!!!
elseif KeyCode(myVar.dKey)      % Do DRIFT CORRECTION
    Eyelink('stoprecording');
    % Do drift correction
    Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
    drawScreenDisp(Scr,myVar,choice_pointers,fixationCoord,quadColors,quadFrameColors);
    Screen('Flip', Scr.w);
    EyelinkDoDriftCorrection(el, myVar.fixXLoc, myVar.fixYLoc,0); % DRIFT CORRECTION!!!!
    drawScreenDisp(Scr,myVar,choice_pointers,quadColors,quadFrameColors);
    Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
    Screen('Flip', Scr.w);
elseif KeyCode(myVar.pKey)      % Skip EyeCheck
    eyeCheck  = false;
end

if Eyelink('NewFloatSampleAvailable')>0 % If NO EYE DATA
    evt = Eyelink('NewestFloatSample'); % take EyePosition
    eyeX = evt.gx(inf.eye +1);
    eyeY = evt.gy(inf.eye +1);
    
    if eyeX ~= el.MISSING_DATA && eyeY ~= el.MISSING_DATA && evt.pa(inf.eye +1) > 0  % IF EYE OK
        
        % IF Pp NOT LOOKING AT THE FIXATION
        if sqrt(sum( (fixationCoord - [eyeX eyeY]).^2,2)) > inf.eyeWindow * Scr.pixelsperdegree
            Eyelink('command','draw_filled_box %d %d %d %d 4', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
            Eyelink('command', 'draw_text %d %d 0 Eye NOT in the CENTER!',round(Scr.width/2),round(Scr.height-Scr.height/32));
            Screen('DrawDots', Scr.w, fixationCoord, 20, Scr.black, [], 2);
            drawScreenDisp(Scr,myVar,choice_pointers,quadColors,quadFrameColors);
            vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
            eyeCheckDur = round(myVar.eyeCheckTime/Scr.ifi);    % Restore eyeCheckDur
            eyeCheck = true;
        else % OR LOOKING
%             Eyelink('command','draw_filled_box %d %d %d %d %d', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height,frameCol);
            Eyelink('command', 'draw_text %d %d 0 Eye is OK',round(Scr.width/2),round(Scr.height-Scr.height/32));
            % EYE AT THE SCREEN CENTER
            Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
            drawScreenDisp(Scr,myVar,choice_pointers,quadColors,quadFrameColors);
            vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
            eyeCheckDur = eyeCheckDur - 1;  % COUNTDOWN FLIPS
            if  eyeCheckDur-1 <= 0
                eyeCheck = false; % NO errDur and NO checkDur
            else
                eyeCheck = true;
            end
        end
        
    else % Pp BLINKED
        Eyelink('command','draw_filled_box %d %d %d %d 1', 0, round(Scr.height-Scr.height/16), Scr.width, Scr.height);
        Eyelink('command', 'draw_text %d %d 15 NO EYE!',round(Scr.width/2),round(Scr.height-Scr.height/32));
        Screen('DrawDots', Scr.w, fixationCoord, 20, Scr.black, [], 2);
        drawScreenDisp(Scr,myVar,choice_pointers,quadColors,quadFrameColors);
        vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
        eyeCheckDur = round(myVar.eyeCheckTime/Scr.ifi); % Restore eyeCheckDur
        eyeCheck = true;
    end
end

function drawScreenDisp(Scr,myVar,choice_pointers,quadColors,quadFrameColors)
    
    Screen('DrawTexture', Scr.w, choice_pointers{1},myVar.subRect,myVar.UR_rect);
    Screen('DrawTexture', Scr.w, choice_pointers{2},myVar.subRect,myVar.RD_rect);
    Screen('DrawTexture', Scr.w, choice_pointers{3},myVar.subRect,myVar.DL_rect);
    Screen('DrawTexture', Scr.w, choice_pointers{4},myVar.subRect,myVar.LU_rect);
    
    Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
    Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
    
end

end

