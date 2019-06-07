 function SimpleRDM(subNo)

%% CHECK THE Pp NAME
%%%%%%%%%%%%%%%%%%%%%%
fclose all;
PsychDefaultSetup(1);       % to define color in range of 255 instead of 1
delete AA_lasterrormsg.mat  % If we got an error, we would see it in root folder
% addpath Calibrate\COLOR;    % Integrate TestColorFlick
format shortG               % this command especially for date formatting.
inf.experimentStart = clock;

if nargin < 1               % If no name is provided
    inf.isTestMode = 1;     % Just assign random value, like 1.
    inf.subNo = [];
else                        % if the name, then store it into a variable
    inf.isTestMode = 0;
    inf.subNo = subNo;
end

%% SETUP EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%
% The core of the experiment. Everything is prepared here: Subject information,
% constant values and variables
try
    [inf]               = GetSubInfo(inf);              % Gather Pp information
    
    scrNum = 0;  % specific to Conor's set-up -- use 0 to make the display screen the personal laptop (external monitor is for MATLAB)
    debug_mode_flag = false;
    [Scr]               = InitializeWindow(inf,scrNum,debug_mode_flag);        % Turn on Screen
    
    [inst]              = Instructions_SC(inf,Scr);     % Load pictures with instructions
    
    [Scr,inf,myVar]     = SetUpConstants(Scr,inf);        % setUp VARIABLES
    
    [el,inf]            = EyeLinkON(Scr,inf);           % Turn on EyeLink
    
    if ~inf.afterBreak
        
        [myVar, block]  = SetUpTrialsMixed(Scr,inf, myVar); % setUp CONDITIONS
        
%         Show general instructions
        Screen('DrawTexture', Scr.w, inst.intro); % intro instruction
        Screen('Flip',Scr.w); KbStrokeWait; bl = 1;
        
%     else % IF AFTER BREAK
%         fName = strcat(inf.subNo, '__allData.mat');
%         fileLoc = [Scr.rootDir  filesep() 'Data' filesep() 'SubjectsData' filesep() inf.subNo filesep() fName];
%         load(fileLoc); bl = bl+1; inf.threshold = false; %fprintf(inf.resultsFile,'After_Break\n'); 

    else % IF AFTER BREAK
        
        fName = sprintf('Subject%d__allData.mat',inf.subNo);
        fileLoc = fullfile(Scr.rootDir,'Data','SubjectsData',num2str(inf.subNo), fName);
        load(fileLoc); bl = bl+1; inf.threshold = false;
        
    end
    
    dataArray = [];

    %% BLOCK LOOP---------%
    %%%%%%%%%%%%%
    for bl = 1:length(block)
%         if ismember(bl,[3 20]), CountDown(Scr,myVar,300);end % break for 300 sec.
        
        %% INSTRUCTIONS
        FileName        = ['block_' num2str(bl)];
        [inf,myVar, edfFile]  = EyeLinkStart(Scr,inf,myVar,bl,FileName); % Instructions inside!!!!
        
        %% Experiment Trials-by-Trial-------------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tr = 1;
        while tr <= length(block(bl).trials)
            
            [inf,trialData,el] = RunTrial_SC(Scr,inf,myVar,el,bl,tr,block,block(bl).trials(tr),false);
            
             % accumulate data into matrix
            dataArray = [dataArray;...
                [bl, tr, block(bl).trials(tr).scene_ID, block(bl).trials(tr).config, block(bl).trials(tr).coher, trialData.trialRT, trialData.trialAcc, trialData.sceneChoice]];
            
            block(bl).trials(tr).trialRT = trialData.trialRT;
            block(bl).trials(tr).trialAcc= trialData.trialAcc;
            block(bl).trials(tr).sceneChoice = trialData.sceneChoice;
            block(bl).trials(tr).trialError = trialData.trialError;
            block(bl).trials(tr).Reward     = trialData.Reward;
            
            block(bl).trials(tr).trialSTART    = trialData.trialSTART;
            block(bl).trials(tr).fixationOnset = trialData.fixationOnset;
            block(bl).trials(tr).exploreOnset  = trialData.exploreOnset;
            block(bl).trials(tr).choiceOnset   = trialData.choiceOnset;

            block(bl).trials(tr).feedbackOnset = trialData.feedbackOnset;
            block(bl).trials(tr).trialEND = trialData.trialEND;

            tr = tr+1;
        end
        % Screen('FillRect', Scr.w, [0 0 0], [0 0 300 300]);
        text = sprintf('Please Wait');
        DrawFormattedText(Scr.w, text, 'center','center', [0 0 0]);
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
        cd(Scr.rootDir);
    end
    
    
    %% END OF EXPERIMENT-----------%
    %%%%%%%%%%%%%%%%%%%%
    
    %% Saying goodbye
%     [inf] = DataPreProcessing(inf,myVar,block);
%     
%     message = sprintf('You won %g euros!\n Your accuracy was %d percent\nPress SPACE', inf.Reward,(round(inf.accuracy*100)));
%     DrawFormattedText(Scr.w, message, 'center', 'center', Scr.black, 40,[],[],1.5); delete col.mat
%     Screen('Flip', Scr.w);      % Update the SCR to show the instruction text:
%     KbStrokeWait;               % Wait for mouse click:
%     
%     message = 'Thank you for participation!\nWait for further instructions.';
%     DrawFormattedText(Scr.w, message, 'center', 'center', Scr.black, 40,[],[],1.5);
%     Screen('Flip', Scr.w);
%     GetClicks;
%     KbStrokeWait;
%     
%     % Necessary procedure for committee
%     CalDoc_Reward(Scr,inf);
%     
%     %% PLOT THE DATA
%     array2table(inf.NumTrBl,'VariableNames',{'V1' 'V2' 'S1' 'S2' 'N' 'Bl' 'Acc' 'dP'})
%     DataReadyToPlot(inf);
    
    % End of the experiment:
    CleanUpExpt(inf);
    return;
    
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
end