function  CleanUpExpt(inf)
if ~inf.dummy && ~inf.threshold
    Eyelink('Command','set_idle_mode');        % to write on EyeTracker screen first we need to set it in idle mode
    WaitSecs(0.05);
    Eyelink('Command','clear_screen %d', 0);   % clear the screen
    Eyelink('shutdown');
end
lum=linspace(0,1,256)';
gammatable=[lum lum lum];
Screen('LoadNormalizedGammaTable', 0, gammatable ,0);
ListenChar(0);
ShowCursor(1);
PsychPortAudio('Close');
sca;
Screen('CloseAll');% closes all windows and textures
fclose('all');
fclose all;
Priority(0);
end

