function vbl = fixationPeriod_MD(Scr,myVar,fixationCoord,fixationDur,choice_pointers,vbl)
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
    Screen('DrawTexture', Scr.w, choice_pointers{1},myVar.subRect,myVar.UPrect);
    Screen('DrawTexture', Scr.w, choice_pointers{2},myVar.subRect,myVar.RIGHTrect);
    Screen('DrawTexture', Scr.w, choice_pointers{3},myVar.subRect,myVar.DOWNrect);
    Screen('DrawTexture', Scr.w, choice_pointers{4},myVar.subRect,myVar.LEFTrect);
    
    Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
    
    vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
    
    
end
