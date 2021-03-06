function [inf,myVar, edfFile] = EyeLinkStart(Scr,inf,myVar,bl,FileName)

%% EYE TRACKER
if ~inf.dummy
    %% CREATE FILE ON EYE-TRACKER
    edfFile = strcat(FileName,'.edf');          % Eyelink runs in DOS, max eight digits!
    res = Eyelink('Openfile', edfFile);         % Open file on Eye-Tracker
    if res~=0   % check status
        error('Cannot create EDF file %s', edfFile);
    end
    Eyelink('command', 'add_file_preamble_text ''Vakhrushev_SimpleCrossModal''', date);
    
    %% DRAW ON EYE-TRACKER SCREEN
    if Eyelink('IsConnected')~=1
        error('Something with Eye Thacker!\n');
    end
    Eyelink('Command','set_idle_mode');        % to write on EyeTracker screen first we need to set it in idle mode
    Eyelink('Command','clear_screen %d', 0);   % clear the screen
    Eyelink('command','draw_cross %d %d 10', Scr.width/2, Scr.height/2);
%     Eyelink('command','draw_box %d %d %d %d 15', myVar.frameRects(1,1),myVar.frameRects(2,1),myVar.frameRects(3,1),myVar.frameRects(4,1));
%     Eyelink('command','draw_box %d %d %d %d 15', myVar.frameRects(1,2),myVar.frameRects(2,2),myVar.frameRects(3,2),myVar.frameRects(4,2));
    WaitSecs(0.3);
else
    edfFile = 0;
end
end 