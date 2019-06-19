function [inf,trial_data,el] = RunTrial_SC(Scr,inf,myVar,el,bl,tr,block,trialParams)

% Script for a single trial of the scene construction paradigm

%% INPUTS:
% - Scr:         structure containing information about the screen (e.g. Scr.wRect
%                contains dimensions of the screen, Scr.w contains the window pointer,
%                etc.)
% - inf:         structure containing general, invariant information (e.g.
%                inf.dummy indicates whether experiment is being run with/without
%                eyetracking
% - myVar:       structure containing constants related to presentation of stimuli, trial-structure,
%                timing, etc.
% - el:          EyeLink related variable
% - bl:          index of current block
% - tr:          index of current trial
% - block:       structure containing block- and trial-specific experimental (independent) and behavioral (dependent) measures, e.g
%                parameters of stimuli to display on block(bl).trials(tr), participant's reaction time
%                on block(bl).trials(tr).
% - trialParams: structure containing trial-specific experimental (independent) and behavioral (dependent) measures

trialSTART = GetSecs;                                                      %%%%TIME%%%%%%%

fixationCoord = [myVar.fixXLoc myVar.fixYLoc];% location of center of fixation cross

% Prepare response variables
trialRT                 = nan;
trialAcc                = nan;
sceneChoice             = nan;
eyeCheck                = true;

% Timing Points
fixationOnset           = nan;
exploreOnset            = nan;
choiceOnset             = nan;
feedbackOnset           = nan;
trialEND                = nan;

% Prepare variables for stimulation.
trialError  = 0;
respToBeMade= true;
noResponse  = true;

Reward = 0; % fix this later

ShowCursor('Arrow') 

% Timing in frames
if tr == 1
    fixationDur  = round(myVar.fixationTime/Scr.ifi);                        % Duration of Fixation is longer if it's the first trial (gives subject time to move cursor/eyes to center)
else
    fixationDur = round(  (myVar.ITI_sd*randn(1) + myVar.intertrialTime) /Scr.ifi );
end

if bl < 2
    exploreDur     = round(myVar.train_exploreTime /Scr.ifi);                 % For early/practice blocks, make scene exploration time basically infinite
else
    exploreDur     = round(myVar.exploreTime /Scr.ifi);                       % Duration of explore phase
end
choiceDur  = round(myVar.choiceTime/Scr.ifi);               % Choice display duration in flips
feedbackDur  = round(myVar.feedbackTime/Scr.ifi);           % Feedback display duration in flips
eyeCheckDur  = round(myVar.eyeCheckTime/Scr.ifi);           % Duration of EyeLink fixation in frames

dotParams = trialParams.dotParams; % get the RDP dot parameters for the current trial

% Retrieve coordinates of the frames / quadrants 

% myVar.centers gives the centers of each quadrant (including both
% RDP-containing and empty quadrants

numQuads = size(myVar.centers,2); 
% quadColors = repmat(ceil([255/2 255/2 255/2])',1,numQuads);      % gray rects to cover each quadrant when they're not being inspected
quadColors = repmat(ceil((5/8).*[255 255 255])',1,numQuads);      % light-gray rects to cover each quadrant when they're not being inspected
quadFrameColors = repmat(ceil((7/8).*[255 255 255])',1,numQuads); % even-lighter gray frames around the covering quadrants

numPatterns = size(dotParams,2);

filled_quad_idx = zeros(numQuads,1);
for patt_id = 1:numPatterns
    dotData(patt_id) = initialize_dots(dotParams,patt_id,Scr.ifi,Scr.pixelsperdegree);
    nearby_idx = sqrt(sum( ( repmat(dotParams(patt_id).centers,numQuads,1) - myVar.centers').^2,2)) < 50;
    if any(nearby_idx)
        filled_quad_idx(nearby_idx) = patt_id;
    end
end

%% Prepare EyeTracker
if ~inf.dummy
    
    % START RECORDING to EDF file.
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);                 % Let eyeTracker to make a transition.
    Eyelink('startrecording');
    WaitSecs(0.1);                  % Record few samples to be sure
    inf.eye = Eyelink('EyeAvailable');
    if inf.eye == el.BINOCULAR
        inf.eye = el.RIGHT_EYE;
    end
    
    % CHECK RECORDING. Better because it is dedicated for checking
    elERR=Eyelink('CheckRecording');
    if(elERR~=0)
        error('EyeTracker is not recording!\n');
    end
    
    % Important messages
    Eyelink('message', 'Bl_Tr_Dir1_Dir2_Scene_Config_Coh1_Coh2 %d %d %d %d %d %d %d %d',...              % MESSAGE FOR EDF
        bl, tr,trialParams.scene_dirs(1),trialParams.scene_dirs(2),trialParams.scene_ID,trialParams.config,round(trialParams.coherence(1)),round(trialParams.coherence(2)));
    
    Eyelink('command', 'record_status_message "BLOCK %d/%d TRIAL %d/%d"',...               % MESSAGE TO BE DISPLAYED ON EYELINK SCREEN
        bl,length(block),tr,length(block(bl).trials));
    
end

% Prepare SCREEN

UR_ptr = Screen('MakeTexture',Scr.w,myVar.UR_symbol); 
RD_ptr = Screen('MakeTexture',Scr.w,myVar.RD_symbol); 
DL_ptr = Screen('MakeTexture',Scr.w,myVar.DL_symbol); 
LU_ptr = Screen('MakeTexture',Scr.w,myVar.LU_symbol); 
choice_pointers = {UR_ptr,RD_ptr,DL_ptr,LU_ptr};

% draw the scene symbols at the bottom of the screen
Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect); 
Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect); 
Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect); 
Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect); 

% Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);

vbl = Screen('Flip', Scr.w); %%synch%%

%% CHECK: IS EYE ON THE FIXATION?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eyeCheckOnset = vbl;                                                                           %%%%TIME%%%%%%%
if ~inf.dummy
    Eyelink('message', 'EYE_CHECK');
    while eyeCheck   
        [ eyeCheck,eyeCheckDur,vbl] = doEyeCheck_SC(Scr,myVar,inf,el,fixationCoord,quadFrameColors,quadColors,choice_pointers,eyeCheck,eyeCheckDur,vbl);
    end
end

%% FIXATION
%%%%%%%%%%%

% draw the scene symbols in the middle of the screen
Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);

Screen('DrawDots', Scr.w, fixationCoord, 10, Scr.black, [], 2);
Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);

vbl = Screen('Flip', Scr.w);    % SCREEN SYNCH.
fixationOnset = vbl;             %%%%TIME%%%%%%%

vbl = fixationPeriod_SC(Scr,myVar,fixationCoord,quadFrameColors,quadColors,fixationDur,choice_pointers,vbl);

%% EXPLORATION ONSET
%%%%%%%%%%
if ~inf.dummy
    Eyelink('message', 'EXPLORE_START');
end
exploreFlips = 1;

quadrant_dwell_counters = zeros(numQuads,1);

button_state = false(1,3);

while and(( ~any(button_state) && noResponse),exploreFlips < exploreDur)
    
    [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
    if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
        Screen('CloseAll');
        error('EXIT button!\n');
    end
    
%     Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
    % draw the scene symbols at the bottom of the screen
    Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
    Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
    Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
    Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);
    
%     DrawFormattedText(Scr.w,'Explore the scene...','center',Scr.wRect(4)-0.1*Scr.pixelsperdegree,[255 255 255]);
    
    if exploreFlips == 1
        exploreOnset = vbl;                                                          %%%%TIME%%%%%%%
    end
    
    [mouse_x,mouse_y,button_state] = GetMouse(Scr.w);
    if inf.dummy
        pos_x = mouse_x;
        pos_y = mouse_y;
    else
        if Eyelink('NewFloatSampleAvailable')>0 % If NO EYE DATA
            evt = Eyelink('NewestFloatSample'); % take EyePosition
            pos_x = evt.gx(inf.eye +1);
            pos_y = evt.gy(inf.eye +1);
        end
    end
    
    % rectangular boundary conditions
    quadrant_idx = false(numQuads,1);
    for quad_i = 1:numQuads
        xv = [myVar.RDMRects(1,quad_i) myVar.RDMRects(1,quad_i) myVar.RDMRects(3,quad_i) myVar.RDMRects(3,quad_i)];
        yv = [myVar.RDMRects(2,quad_i) myVar.RDMRects(4,quad_i) myVar.RDMRects(4,quad_i) myVar.RDMRects(2,quad_i)];
        quadrant_idx(quad_i) = inpolygon(pos_x,pos_y,xv,yv);
    end
    
    numChoices = size(myVar.choiceRects,2);
    choice_idx = false(numChoices,1);
    for c_i = 1:numChoices
        xv = [myVar.choiceRects(1,c_i) myVar.choiceRects(1,c_i) myVar.choiceRects(3,c_i) myVar.choiceRects(3,c_i)];
        yv = [myVar.choiceRects(2,c_i) myVar.choiceRects(4,c_i) myVar.choiceRects(4,c_i) myVar.choiceRects(2,c_i)];
        if inf.dummy
            choice_idx(c_i) = inpolygon(mouse_x,mouse_y,xv,yv);
        else
            choice_idx(c_i) = inpolygon(pos_x,pos_y,xv,yv);
        end
    end
    
    
    if any(quadrant_idx)
        
        rev_quadrant = find(quadrant_idx);
        
        quadrant_dwell_counters(rev_quadrant) = quadrant_dwell_counters(rev_quadrant) + Scr.ifi;
        
        if  quadrant_dwell_counters(rev_quadrant) >= myVar.revealTime
            if ismember(rev_quadrant,find(filled_quad_idx))
                
                patt_id_temp = filled_quad_idx(rev_quadrant);
                dotData(patt_id_temp) = update_dots(dotData(patt_id_temp));
                % draws the current dots, using position, single size argument and dotType
                Screen('DrawDots', Scr.w, dotData(patt_id_temp).dotPos, dotData(patt_id_temp).size, [255 255 255], [0 0], dotData(patt_id_temp).dotType);
                
            end
            
            remaining_quadrants = ~ismember(1:numQuads,rev_quadrant); % this yields the logical indices for the remaining, non-revealed quadrants
            % for the following 'FillRect' command
            
            Screen('FillRect',Scr.w,quadColors(:,remaining_quadrants),myVar.RDMRects(:,remaining_quadrants))
            Screen('FrameRect',Scr.w,quadFrameColors(:,remaining_quadrants),myVar.RDMRects(:,remaining_quadrants),myVar.frameLineWidth);
        else
            Screen('FillRect',Scr.w,quadColors,myVar.RDMRects)
            Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
        end
        
        
    else
        quadrant_dwell_counters = zeros(numQuads,1);
        
        Screen('FillRect',Scr.w,quadColors,myVar.RDMRects)
        Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
        
    end
    
    vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
    
    Reward = myVar.discount_function(exploreFlips);
    
    exploreFlips = exploreFlips + 1;
    
    %%%%%%%%%%%%%%II.Check Response
    [KeyIsDown,endRTRaw, KeyCodeRaw] = KbCheck();
    
    if or( ((KeyIsDown==1) && respToBeMade),any(button_state))
        
        if KeyCodeRaw(KbName('ESCAPE'))  % EXIT key pressed to exit experiment
            Screen('CloseAll')
            error(sprintf('EXIT button!\n'));
        else
            if any(choice_idx) && KeyCodeRaw(myVar.spacebar)
                trialRT = endRTRaw - exploreOnset; % save RT!!!!
                noResponse = false;
                if choice_idx(1)
                    sceneChoice = 1;
                    if trialParams.scene_ID == 1
                        trialAcc = 1;
                    else
                        trialAcc = 0;
                    end
                elseif choice_idx(2)
                    sceneChoice = 2;
                    if trialParams.scene_ID == 2
                        trialAcc = 1;
                    else
                        trialAcc = 0;
                    end
                elseif choice_idx(3)
                    sceneChoice = 3;
                    if trialParams.scene_ID == 3
                        trialAcc = 1;
                    else
                        trialAcc = 0;
                    end
                elseif choice_idx(4)
                    sceneChoice = 4;
                    if trialParams.scene_ID == 4
                        trialAcc = 1;
                    else
                        trialAcc = 0;
                    end
                else
                    trialAcc = 0; sceneChoice = NaN;
                end
            else
                trialError = 1; noResponse = false; sceneChoice = NaN;          % END THE TRIAL
            end
        end
    else
        noResponse = true; sceneChoice = NaN; % ran out of time
    end
    
end

if ~inf.dummy
    Eyelink('Message', 'EXPLORE_END');
end


if trialAcc == 1
    Reward = Reward + myVar.correct_reward;
else
    Reward = Reward - myVar.miss_cost;
    %             Reward = -myVar.miss_cost;
end


for i = 1:choiceDur
    
    [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
    if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
        Screen('CloseAll')
        error('EXIT button!\n');
    end
    
    % draw the scene symbols at the bottom of the screen
    Screen('DrawTexture', Scr.w, UR_ptr,myVar.subRect,myVar.UR_rect);
    Screen('DrawTexture', Scr.w, RD_ptr,myVar.subRect,myVar.RD_rect);
    Screen('DrawTexture', Scr.w, DL_ptr,myVar.subRect,myVar.DL_rect);
    Screen('DrawTexture', Scr.w, LU_ptr,myVar.subRect,myVar.LU_rect);
    
    if trialAcc == 1
        Screen('FrameRect',Scr.w,[0 200 50],myVar.choiceRects(:,sceneChoice),myVar.feedbackFrameWidth);
        DrawFormattedText(Scr.w,'Correct','center',Scr.wRect(4)-0.1*Scr.pixelsperdegree,[0 200 50]);
    elseif and(trialAcc == 0,~isnan(sceneChoice))
        Screen('FrameRect', Scr.w, [255 0 ceil(255/4)], myVar.choiceRects(:,sceneChoice),myVar.feedbackFrameWidth);
        DrawFormattedText(Scr.w,'Incorrect','center',Scr.wRect(4)-1.0*Scr.pixelsperdegree,[255 0 ceil(255/4)]);
    elseif noResponse
        DrawFormattedText(Scr.w,'Ran out of time!','center',Scr.wRect(4)-1.0*Scr.pixelsperdegree,[255 0 ceil(255/4)]);
    else
        DrawFormattedText(Scr.w,'Invalid response!','center',Scr.wRect(4)-1.0*Scr.pixelsperdegree,[255 0 ceil(255/4)]);
    end
    
%     Screen('DrawLines',Scr.w,all_fix_coords,myVar.lineWidthPix,Scr.white,fixationCoord,0);
    Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
    Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
    vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
    
    if i == 1
        choiceOnset = vbl;                                              %%%%%%%TIME%%%%%%%%%
    end
    
end

for i = 1:feedbackDur
    
    [~,~, KeyCode] = KbCheck();     % In case if eye tracker lost eye
    if KeyCode(myVar.escapeKey)             % EXIT key pressed to exit experiment
        Screen('CloseAll')
        error('EXIT button!\n');
    end
    
    if trialAcc == 1
        rew_message = sprintf('%.2f points awarded!',Reward);
        DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[0 200 50]);
    elseif and(trialAcc == 0,~isnan(sceneChoice))
        rew_message = sprintf('%.2f points awarded!',Reward);
        DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[255 0 ceil(255/4)]);
    elseif noResponse
        rew_message = sprintf('%.2f points awarded!',Reward);
        DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[255 0 ceil(255/4)]);
    else
        rew_message = sprintf('%.2f points awarded!',Reward);
        DrawFormattedText(Scr.w,rew_message,'center',myVar.centerY,[255 0 ceil(255/4)]);
    end
    
    if tr == 1
        DrawFormattedText(Scr.w,sprintf('Total score: %.2f points',Reward),'center',myVar.centerY + (1.5 * Scr.pixelsperdegree),[255 255 255]);
    else
        DrawFormattedText(Scr.w,sprintf('Total score: %.2f points',(block(bl).trials(tr-1).Reward + Reward)),'center',myVar.centerY + (1.5 * Scr.pixelsperdegree),[255 255 255]);
    end
    
    vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
    
    if i == 1
        feedbackOnset = vbl;                                              %%%%%%%TIME%%%%%%%%%
    end
end

trialEND = vbl;
            

%% save the data

trial_data.trialRT = trialRT;
trial_data.trialAcc = trialAcc;
trial_data.sceneChoice = sceneChoice;
trial_data.trialError = trialError;
if tr == 1
    trial_data.Reward     = Reward;
else
    trial_data.Reward     = block(bl).trials(tr-1).Reward + Reward; % accumulate total score
end

trial_data.trialSTART = trialSTART;
trial_data.eyeCheckOnset = eyeCheckOnset;
trial_data.fixationOnset = fixationOnset;
trial_data.exploreOnset = exploreOnset;
trial_data.choiceOnset = choiceOnset;
trial_data.feedbackOnset = feedbackOnset;
trial_data.trialEND = trialEND;

% Clear screen
Screen('FillRect',Scr.w,quadColors,myVar.RDMRects);
Screen('FrameRect',Scr.w,quadFrameColors,myVar.RDMRects,myVar.frameLineWidth);
Screen('Flip', Scr.w);


        
            
        
        
        
    
    




