function vbl = fixationPeriod_SC(Scr,myVar,fixationCoord,quadFrameColors,quadColors,fixationDur,choice_pointers,vbl)
%fixationPeriod Wrapper function for the loop over fixationDur flips that
%waits another fixationTime seconds before beginning the exploration phase

for fixationFlips = 1:fixationDur-1
    %%%%%%%%%%%%%%I.Present the Fixation point
    
    [~,~, KeyCode] = KbCheck();     
    if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
        Screen('CloseAll')
        error(sprintf('EXIT button!\n'));
    end
    
    % draw the scene symbols at the bottom of the screen
    Screen('DrawTexture', Scr.w, choice_pointers{1},myVar.subRect,myVar.UR_rect);
    Screen('DrawTexture', Scr.w, choice_pointers{2},myVar.subRect,myVar.RD_rect);
    Screen('DrawTexture', Scr.w, choice_pointers{3},myVar.subRect,myVar.DL_rect);
    Screen('DrawTexture', Scr.w, choice_pointers{4},myVar.subRect,myVar.LU_rect);
    
    Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
    Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
    Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
    
    vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
    
    
end

% clears the dot from the fixation center, signalling beginning of the
% exploration phase
vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);

end

