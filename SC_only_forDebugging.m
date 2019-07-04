%% CHECK THE Pp NAME
%%%%%%%%%%%%%%%%%%%%%%
fclose all;
PsychDefaultSetup(1);       % to define color in range of 255 instead of 1
delete AA_lasterrormsg.mat  % If we got an error, we would see it in root folder
addpath(genpath('MotionDiscrim/psignifit-master'));
addpath(genpath('utilities'));

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

[inf]               = GetSubInfo(inf);              % Gather Pp information

%% this is where psychometric pre-calibration would usually happen

myVar.coherences2use = [10 21 59];

%% SETUP EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%

% Now we can proceed to the Scene Construction (main) study 

real_bl_idx = 1; % this is the block number at which the experimental trials begins - everything before is just practice

try
    
    % Number of blocks to run if SC
    prompt                  ={'How many blocks of scene construction would you like to run?'};
    title                   ='Number of blocks to complete';  % The main title of input dialog interface.
    answer                  =inputdlg(prompt,title);
    
    % Gather answers into variables
    inf.numBlocks_SC                 = str2double(answer{1});
    
%     timing_info_all = zeros(10,2,inf.numBlocks_SC);
    
    % look into this -- may not need to do this if we don't close the
    % screen from before! can just add a waiting screen in between or
    % something
    [Scr]              = InitializeWindow(inf,0,false);        % Turn on Screen
    
    [inst_sc]          = Instructions_SC(inf,Scr);     % Load pictures with instructions
    
    [Scr,inf,myVar]    = SetUpConstants_SC(Scr,inf,myVar);        % setUp VARIABLES
    
    UR_ptr = Screen('MakeTexture',Scr.w,myVar.UR_symbol);
    RD_ptr = Screen('MakeTexture',Scr.w,myVar.RD_symbol);
    DL_ptr = Screen('MakeTexture',Scr.w,myVar.DL_symbol);
    LU_ptr = Screen('MakeTexture',Scr.w,myVar.LU_symbol);
    choice_pointers = {UR_ptr,RD_ptr,DL_ptr,LU_ptr};

    [el,inf]           = EyeLinkON(Scr,inf);           % Turn on EyeLink
    
    if ~inf.dummy
        HideCursor();
    end
    
    if ~inf.afterBreak
        
        [myVar, block]  = SetUpTrialsMixed_SC(Scr,inf, myVar); % setUp CONDITIONS
        
%        Show general instructions
        Screen('DrawTexture', Scr.w, inst_sc.intro1); % intro instruction slide 1
        Screen('Flip',Scr.w); KbStrokeWait;
        Screen('Close',inst_sc.intro1);
        
        Screen('DrawTexture', Scr.w, inst_sc.intro2); % intro instruction slide 2
        Screen('Flip',Scr.w); KbStrokeWait;
        Screen('Close',inst_sc.intro2);
        
        Screen('DrawTexture', Scr.w, inst_sc.intro3); % intro instruction slide 3
        Screen('Flip',Scr.w); KbStrokeWait; 
        Screen('Close',inst_sc.intro3);
        
        Screen('DrawTexture', Scr.w, inst_sc.intro4); % intro instruction slide 3
        Screen('Flip',Scr.w); KbStrokeWait; startBl = 1;
        Screen('Close',inst_sc.intro4);
        
    else % IF AFTER BREAK
        
        fName = sprintf('Subject%d__allData.mat',inf.subNo);
        fileLoc = fullfile(Scr.expDir,'Data','SubjectsData',num2str(inf.subNo), fName);
        load(fileLoc); 
        if any(isnan([block(bl).trials.trialEND])) % check for whether trials got interrupted
            startBl = bl; % if so, start from the block during which the experiment was interrupted
            startT = find(isnan([block(bl).trials.trialEND]),1); % start from the trial where the interruption happened -- here, assumed to be the same 
            % as where the first trial where no end was detected 
        else
            startBl = bl+1; % otherwise, go to the next block and start from the first trial
        end   
    end
        
    %% BLOCK LOOP---------%
    %%%%%%%%%%%%%
    for bl = startBl:length(block)
        
        if ~inf.dummy
            HideCursor();
        end
        
        if bl == 1
            EyeLinkCalibration(Scr,inf,inst_sc,el);
            block(bl).trials(1).Reward = 0; % initialize first trial of first block's reward to 0
%             block(bl).trials = block(bl).trials(1:40); % make the first block only have 40 trials (since it's practice)
        else
            block(bl).trials(1).Reward = block(bl-1).trials(end).Reward; % initialize next block's reward to be the reward accumulated at the end of the previous block 
        end
        
        if bl == real_bl_idx
            
            Screen('DrawTexture', Scr.w, inst_sc.breakScreen); % slide telling participants they have a break
            Screen('Flip',Scr.w); KbStrokeWait;
            Screen('Close',inst_sc.breakScreen);
            
            CountDown(Scr,myVar,5);
            
            EyeLinkCalibration(Scr,inf,inst_sc,el); % recalibrate before main experiment
            
            block(bl).trials(1).Reward = 0; % initialize first trial of first 'real' block's reward to 0
        elseif bl > real_bl_idx
            
             EyeLinkCalibration(Scr,inf,inst_sc,el); % calibrate in between every block before main experiment
                    
        end
        
        %% Experiment Trials-by-Trial-------------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~exist('startT','var')
            tr = 1;
        else
            tr = startT;
        end
        
        counter = 1;
        FileName = sprintf('block_%d%d',bl,counter);
        [inf,edfFile] = EyeLinkStart(Scr,inf,FileName); % Instructions inside!!!!
 
        while tr <= length(block(bl).trials)
            
            if tr > 1
                block(bl).trials(tr).Reward = block(bl).trials(tr-1).Reward;
            end
            
            [inf,trialData,el,recalib_flag] = RunTrial_SC(Scr,inf,myVar,el,bl,tr,block,block(bl).trials(tr),choice_pointers,real_bl_idx);

            if recalib_flag
                EyeLinkStop(inf,bl,tr,edfFile);
                counter = counter + 1;
                FileName_next = sprintf('block_%d%d',bl,counter);
                while recalib_flag
                    EyeLinkCalibration_interrupt(Scr,inf,bl,tr,el);
                    text = sprintf('Calibration successful');
                    DrawFormattedText(Scr.w, text, 'center','center', [255 255 255]);
                    Screen('Flip', Scr.w);
                    WaitSecs(1.0);
                    [inf,edfFile] = EyeLinkStart(Scr,inf,FileName_next); % Instructions inside!!!!
                    [inf,trialData,el,recalib_flag]  = RunTrial_SC(Scr,inf,myVar,el,bl,tr,block,block(bl).trials(tr),choice_pointers,real_bl_idx);
                end
            end
            
            % add current trial's results to block structure
            block(bl).trials(tr).trialRT = trialData.trialRT;
            block(bl).trials(tr).trialAcc= trialData.trialAcc;
            block(bl).trials(tr).sceneChoice = trialData.sceneChoice;
            block(bl).trials(tr).Reward = trialData.Reward;

            block(bl).trials(tr).trialSTART = trialData.trialSTART;
            block(bl).trials(tr).eyeCheckOnset = trialData.eyeCheckOnset;
            block(bl).trials(tr).fixationOnset = trialData.fixationOnset;
            block(bl).trials(tr).exploreOnset = trialData.exploreOnset;
            block(bl).trials(tr).choiceOnset = trialData.choiceOnset;
            block(bl).trials(tr).feedbackOnset = trialData.feedbackOnset;
            block(bl).trials(tr).trialEND = trialData.trialEND; 
            
            block(bl).trials(tr).visitTmsp = trialData.visitTmsp;
            block(bl).trials(tr).visitIdx = trialData.visitIdx;
            block(bl).trials(tr).visitDurs = trialData.visitDurs;

            
            tr = tr+1;
            
        end
        text = sprintf('Please Wait');
        DrawFormattedText(Scr.w, text, 'center','center', [255 255 255]);
        Screen('Flip', Scr.w);
        EyeLinkStop(inf,bl,tr-1,edfFile);
                
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


    
