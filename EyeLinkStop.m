function EyeLinkStop(inf,bl,tr,edfFile)

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
        status=Eyelink('ReceiveFile',edfFile,pwd,1);
        if status~=0, fprintf('ReceiveFile status: %d\n', status); end
        if 2==exist(edfFile, 'file'),fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd); end
        
        % 4) Save file to the folder ON COMPUTER
        if inf.isTestMode == 0
            move_path = fullfile(inf.rootSub,sprintf('%d_Block_%d_toTrial%d.edf',inf.subNo,bl,tr));
            movefile(edfFile,move_path,'f');
        else
            move_path = fullfile(inf.rootSub,sprintf('test_Block_%d_toTrial%d.edf',bl,tr));
            movefile(edfFile,move_path,'f');
        end
    catch
        % 5) DEBUGGING
        fprintf('Problem receiving data file ''%s''\n', edfFile);
    end
%     WaitSecs(2);
end
end 
