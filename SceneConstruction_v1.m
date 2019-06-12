%% CHECK THE Pp NAME
%%%%%%%%%%%%%%%%%%%%%%
fclose all;
PsychDefaultSetup(1);       % to define color in range of 255 instead of 1
delete AA_lasterrormsg.mat  % If we got an error, we would see it in root folder


% Number of blocks to run
prompt                  ={'Please enter the subject ID'};
title                   ='Subject Number';  
answer                  =inputdlg(prompt,title);

if isempty(answer{1}) % If no name is provided
    inf.isTestMode = 1; % Just assign random value, like 1.
    inf.subNo = [];
else
    inf.isTestMode = 0;
    inf.subNo                 = str2double(answer{1});  % if the name is provided, then store it into a variable
end

% addpath Calibrate\COLOR;    % Integrate TestColorFlick
format shortG               % this command especially for date formatting.
inf.experimentStart = clock;

%% SETUP EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%

% First complete the motion-detection pre-calibration 

try
    [inf]               = GetSubInfo(inf);              % Gather Pp information
    
    [Scr]               = InitializeWindow(inf,0,false);        % Turn on Screen
    
    [inst_rdp]          = Instructions_RDP(inf,Scr);     % Load pictures with instructions
    
    [Scr,inf,myVar]     = SetUpConstants_RDP(Scr,inf);        % setUp VARIABLES
    
    [el,inf]            = EyeLinkON(Scr,inf);           % Turn on EyeLink
    
    if ~inf.afterBreak
        
        [myVar, block]  = SetUpTrialsMixed_RDP(Scr,inf, myVar); % setUp CONDITIONS
        
%         Show general instructions
        Screen('DrawTexture', Scr.w, inst_rdp.intro); % intro instruction
        Screen('Flip',Scr.w); KbStrokeWait; bl = 1;
        
    else % IF AFTER BREAK
        
        fName = sprintf('Subject%d__allData.mat',inf.subNo);
        fileLoc = fullfile(Scr.expDir,'Data','SubjectsData',num2str(inf.subNo), fName);
        load(fileLoc); bl = bl+1; inf.threshold = false;
        
    end
        
    %% BLOCK LOOP---------%
    %%%%%%%%%%%%%
    for bl = 1:length(block)
        
        FileName        = ['block_' num2str(bl)];
        [inf,myVar, edfFile]  = EyeLinkStart(Scr,inf,myVar,bl,FileName); % Instructions inside!!!!
        
         %% Experiment Trials-by-Trial-------------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tr = 1;
        while tr <= length(block(bl).trials)
            
            [inf,trialData,el] = RunTrial_MD(Scr,inf,myVar,el,bl,tr,block,block(bl).trials(tr),false);
            
            % add current trial's results to block structure
            block(bl).trials(tr).trialRT = trialData.trialRT;
            block(bl).trials(tr).trialAcc= trialData.trialAcc;
            block(bl).trials(tr).dirResponse = trialData.dirResponse;
            block(bl).trials(tr).trialError = trialData.trialError;
            
            block(bl).trials(tr).trialSTART = trialData.trialSTART;
            block(bl).trials(tr).fixationOnset = trialData.fixationOnset;
            block(bl).trials(tr).accumOnset = trialData.accumOnset;
            block(bl).trials(tr).feedbackOnset = trialData.feedbackOnset;
            block(bl).trials(tr).trialEND = trialData.trialEND;
            
            tr = tr+1;
            
        end
        text = sprintf('Please Wait');
        DrawFormattedText(Scr.w, text, 'center','center', [255 255 255]);
        Screen('Flip', Scr.w);
        EyeLinkStop(inf,bl,edfFile);
                
        %% Saving mat data after each block
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        inf.experimentEnd = clock;  % record when the experiment ended
        if ~inf.isTestMode
            cd(inf.rootSub);
            fName = sprintf('Subject%d__allData.mat',inf.subNo);
            save(fName);
        else
            cd(inf.rootTest);
            fName = sprintf('test%d__allData.mat',inf.subNo);
            save(fName);
        end
%         cd(Scr.rootDir);
        cd(Scr.mainDir); % Go back to our main directory..

    end
    
    
    %% END OF FIRST EXPERIMENT
    %%%%%%%%%%%%%%%%%%%%
    
    CleanUpExpt(inf);
    
catch errorInfo
    % The rest of this code is just for debugging in case something crashes
    % Output the error message that describes the error:
    try
        for errStr = length(errorInfo.stack):-1:1
            fprintf('%s| %d\n',errorInfo.stack(errStr).name,errorInfo.stack(errStr).line);
        end
        fprintf('%s\n',errorInfo.message);
        save AA_lastErrorMsg errorInfo;
        DrawFormattedText(Scr.w, errorInfo.message, 'center', 'center', Scr.black);
        Screen('Flip', Scr.w);
        GetClicks(Scr.w);
        CleanUpExpt(inf);
    catch
        CleanUpExpt(inf);
    end
end

%% Determine subject's psychometric function in order to choose coherences

[coherences,flags] = analyze_MDdata(block,inf);


%% SETUP EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%

% Now we can proceed to the Scene Construction (main) study 

try
    
    % Number of blocks to run if SC
    prompt                  ={'How many blocks of scene construction would you like to run?'};
    title                   ='Number of blocks to complete';  % The main title of input dialog interface.
    answer                  =inputdlg(prompt,title);
    
    % Gather answers into variables
    inf.numBlocks_SC                 = str2double(answer{1});
    
    % look into this -- may not need to do this if we don't close the
    % screen from before! can just add a waiting screen in between or
    % something
    [Scr]              = InitializeWindow(inf,0,false);        % Turn on Screen
    
    [inst_sc]          = Instructions_SC(inf,Scr);     % Load pictures with instructions
    
    [Scr,inf,myVar]    = SetUpConstants_SC(Scr,inf);        % setUp VARIABLES
    
    [el,inf]           = EyeLinkON(Scr,inf);           % Turn on EyeLink
    
    if ~inf.afterBreak
        
        [myVar, block]  = SetUpTrialsMixed_SC(Scr,inf, myVar); % setUp CONDITIONS
        
%         Show general instructions
        Screen('DrawTexture', Scr.w, inst_sc.intro); % intro instruction
        Screen('Flip',Scr.w); KbStrokeWait; bl = 1;
        
    else % IF AFTER BREAK
        
        fName = sprintf('Subject%d__allData.mat',inf.subNo);
        fileLoc = fullfile(Scr.expDir,'Data','SubjectsData',num2str(inf.subNo), fName);
        load(fileLoc); bl = bl+1; inf.threshold = false;
        
    end
        
    %% BLOCK LOOP---------%
    %%%%%%%%%%%%%
    for bl = 1:length(block)
        
        FileName        = ['block_' num2str(bl)];
        [inf,myVar, edfFile]  = EyeLinkStart(Scr,inf,myVar,bl,FileName); % Instructions inside!!!!
        
         %% Experiment Trials-by-Trial-------------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tr = 1;
        while tr <= length(block(bl).trials)
            
            [inf,trialData,el] = RunTrial_SC(Scr,inf,myVar,el,bl,tr,block,block(bl).trials(tr),false);
             
            tr = tr+1;
            
        end
        text = sprintf('Please Wait');
        DrawFormattedText(Scr.w, text, 'center','center', [255 255 255]);
        Screen('Flip', Scr.w);
        EyeLinkStop(inf,bl,edfFile);
                
        %% Saving mat data after each block
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        inf.experimentEnd = clock;  % record when the experiment ended
        if ~inf.isTestMode
            cd(inf.rootSub);
            fName = sprintf('Subject%d__allData.mat',inf.subNo);
            save(fName);
        else
            cd(inf.rootTest);
            fName = sprintf('test%d__allData.mat',inf.subNo);
            save(fName);
        end
        %         cd(Scr.rootDir);
        cd(Scr.mainDir); % Go back to our main directory..
    end
    
    %% END OF FIRST EXPERIMENT
    %%%%%%%%%%%%%%%%%%%%
    
    CleanUpExpt(inf);
    
catch errorInfo
    % The rest of this code is just for debugging in case something crashes
    % Output the error message that describes the error:
    try
        for errStr = length(errorInfo.stack):-1:1
            fprintf('%s| %d\n',errorInfo.stack(errStr).name,errorInfo.stack(errStr).line);
        end
        fprintf('%s\n',errorInfo.message);
        save AA_lastErrorMsg errorInfo;
        DrawFormattedText(Scr.w, errorInfo.message, 'center', 'center', Scr.black);
        Screen('Flip', Scr.w);
        GetClicks(Scr.w);
        CleanUpExpt(inf);
    catch
        CleanUpExpt(inf);
    end
end


    
