function [inf,myVar,bl]=EyeLinkThreshold(Scr,inf,myVar,inst,bl,el)

if ~inf.dummy
    %% CREATE FILE ON EYE-TRACKER
    edfFile = strcat('cal_.edf');           % Eyelink runs in DOS, max 8 digits!
    res = Eyelink('Openfile', edfFile);     % Open file on Eye-Tracker
    if res~=0 % check status
        error('Cannot create EDF file %s', edfFile);
    end
    Eyelink('command', 'add_file_preamble_text ''SimpleCrossModal_VakhrushevRoman''', date); % Name of the experiment in the top of file
    
    %% CALIBRATION
    
    Screen('DrawTexture', Scr.w, inst.calibration); % INTRUCTION calibration
    Screen('Flip',Scr.w);
    KbStrokeWait;
    
    EyelinkDoTrackerSetup(el);              % !!!!CALIBRATION!!!!!
    
    
    %% DRAW ON EYE-TRACKER SCREEN
    if Eyelink('IsConnected')~=1
        error('EyeTracker is not connected!\n');
    end
    Eyelink('Command','set_idle_mode');        % to write on EyeTracker screen first we need to set it in idle mode
    Eyelink('Command','clear_screen %d', 0);   % clear the screen
    Eyelink('command','draw_cross %d %d 10', Scr.width/2, Scr.height/2);
    Eyelink('command','draw_box %d %d %d %d 15', myVar.frameRects(1,1),myVar.frameRects(2,1),myVar.frameRects(3,1),myVar.frameRects(4,1));
    Eyelink('command','draw_box %d %d %d %d 15', myVar.frameRects(1,2),myVar.frameRects(2,2),myVar.frameRects(3,2),myVar.frameRects(4,2));
    
else
    edfFile = 0;
end

if ~inf.dummy
    %% TRANSFER DATA FROM EYE-TRACKER
    % 1) Pause Eye-tracker
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    
    % 2) Close file on Eye-tracker
    status = Eyelink('closefile');
    if status ~=0
        fprintf('closefile error, status: %d',status);
    end
    
    try
        % 3) Recieve file from Eye-tracker
        status=Eyelink('ReceiveFile',edfFile,pwd,1); %'DATA/'
        if status~=0, fprintf('ReceiveFile status: %d\n', status); end
        if 2==exist(edfFile, 'file'), fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd); end
        
        % 4) Save file to the folder ON COMPUTER
        if inf.isTestMode == 0
            dir = [inf.rootSub num2str(inf.subNo)  '_Calibration_', num2str(bl),'.edf'];
            movefile(edfFile,dir,'f');
        else
            dir = [inf.rootTest 'test' num2str(inf.subNo) '_Calibration_', num2str(bl),'.edf'];
            movefile(edfFile,dir,'f');
        end
    catch
        % 5) DEBUGGING
        fprintf('Problem receiving data file ''%s''\n', edfFile);
    end
    % WaitSecs(2);
end
end 
