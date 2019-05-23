function trial_data = run_trial(Scr,dotParams,scene_id)
% WIP -- a basic trial script that runs through a 'gaze-contingent'
% unveiling of particular quadrants ('gaze' is really just cursor position)

trialSTART = GetSecs;                                                      %%%%TIME%%%%%%%

% variables to be built into function arguments (e.g. inf or MyVar) at some point:

fixationTime = 5; % time in seconds of fixation window (basically, participant has to hold gaze / mouse position in center for 5 seconds before proceeding)
exploreTime = 15; % time in seconds to explore the scene 
feedbackTime = 0.5; % the length in seconds of the feedback window 
[x,y] = RectCenter(Scr.wRect);
fixationCoord = [x y]; clear x y; % location of center of fixation cross
fixationWindow = 50; % spatial distance in pixels that mouse coordinates/eye position needs to be within, in order to be counted as fixating
Scr.waitframes = 1; % wait frames time (property of screen) before updating
gazeWindow = 150; % how far your cursor/eye position needs to be from the center of the frame in order to uncover it

% Prepare response variables
trialRT                 = nan;
trialAcc                = nan;

% Timing Points
fixationOnset           = nan;
exploreOnset            = nan;
feedbackOnset           = nan;
trialEND                = nan;

% Prepare variables for stimulation.
trialError  = 0;
trialIsOK   = true;             % Check eye position during trial
respToBeMade= true;
noResponse  = true;

% Timing in frames
fixationDur  = round(fixationTime/Scr.ifi);                         % Duration of Fixation;
exploreDur   = round(exploreTime /Scr.ifi);                         % Duration of Exploration time
feedbackDur  = round(feedbackTime/Scr.ifi);                         % Feedback displayed for 500 ms

% Adjust response keys
up_right = KbName('a');
right_down = KbName('s');
down_left = KbName('d');
left_up = KbName('f');

% Initialize coordinates of fixation cross
fixCrossDimPix = 40; % size of the arms of fixation cross
fix_x = [-fixCrossDimPix fixCrossDimPix 0 0];
fix_y = [0 0 -fixCrossDimPix fixCrossDimPix];
all_fix_coords = [fix_x;fix_y];
lineWidthPix = 4; % line width for our fixation cross

% Initialize coordinates of the frames / quadrants 
baseQuad = [0 0 dotParams(1).apSizes(1) + dotParams(1).edge_spillovers(1) dotParams(1).apSizes(2) + dotParams(1).edge_spillovers(2)];
quadsXPos = [ Scr.wRect(3)/4, Scr.wRect(3)/4, 3*Scr.wRect(3)/4, 3*Scr.wRect(3)/4];
quadsYPos = [ Scr.wRect(4)/4, 3*Scr.wRect(4)/4, Scr.wRect(4)/4, 3*Scr.wRect(4)/4];
numQuads = length(quadsXPos);
allQuads = nan(4,numQuads);
for i = 1:numQuads
    allQuads(:,i) = CenterRectOnPointd(baseQuad,quadsXPos(i),quadsYPos(i));
end

quadColors = repmat(ceil([255/2 255/2 255/2])',1,numQuads); % gray frames

% Initialize dots
numPatterns = size(dotParams,2);
quadrant_centers = zeros(numQuads,2);
for i = 1:numQuads
    quadrant_centers(i,:) = [quadsXPos(i) quadsYPos(i)];
end

filled_quad_idx = zeros(numQuads,1);
for patt_id = 1:numPatterns
    dotData(patt_id) = initialize_dots(dotParams,patt_id);
    nearby_idx = sqrt(sum( (dotParams(patt_id).centers - quadrant_centers).^2,2)) < 50;
    if any(nearby_idx)
        filled_quad_idx(nearby_idx) = patt_id;
    end
end

% Prepare SCREEN
Screen('DrawLines',Scr.w,all_fix_coords,lineWidthPix,Scr.white,fixationCoord,0);
Screen('FillRect',Scr.w,quadColors,allQuads);
vbl = Screen('Flip', Scr.w); %%synch%%


if trialIsOK
    
    %% FIXATION
    %%%%%%%%%%%
    
    % Synchronize screen and send messages
    Screen('DrawLines',Scr.w,all_fix_coords,lineWidthPix,Scr.white,fixationCoord,0);
    Screen('FillRect',Scr.w,quadColors,allQuads);
    vbl = Screen('Flip', Scr.w);    % SCREEN SYNCH.
    fixationOnset = vbl;             %%%%TIME%%%%%%%
    
    for fixationFlips = 1:fixationDur-1
        %%%%%%%%%%%%%%I.Present the Fixation point
        Screen('DrawLines',Scr.w,all_fix_coords,lineWidthPix,Scr.white,fixationCoord,0);
        Screen('FillRect',Scr.w,quadColors,allQuads);
        DrawFormattedText(Scr.w,'Please Bring the Cursor to the Center of the Fixation Cross!','center',Scr.wRect(4)*0.95,[255 255 255]);
        vbl = Screen('Flip', Scr.w, vbl + (Scr.waitframes - 0.5) * Scr.ifi);
        
        [mouse_x,mouse_y] = GetMouse(Scr.w);
        
        if sqrt(sum(([mouse_x,mouse_y] - fixationCoord).^2)) <= fixationWindow
            trialIsOK = true;
        else
            trialIsOK = false;
        end
    
    end
    
    %% EXPLORATION ONSET
    %%%%%%%%%%
    if trialIsOK
        
        KeyIsDown = KbCheck();
        exploreFlips = 1;
        
        while and(((KeyIsDown~=1) && noResponse),exploreFlips < exploreDur)
            
            Screen('DrawLines',Scr.w,all_fix_coords,lineWidthPix,Scr.white,fixationCoord,0);
            DrawFormattedText(Scr.w,'Explore the scene...','center',Scr.wRect(4)*0.95,[255 255 255]);

            [mouse_x,mouse_y] = GetMouse(Scr.w);
            
            quadrant_idx = sqrt(sum( ([mouse_x,mouse_y] - quadrant_centers).^2,2)) <= gazeWindow;
            %replaced with rectangular boundary conditions
            
            if any(quadrant_idx)
                
                rev_quadrant = find(quadrant_idx);
                
                if ismember(rev_quadrant,find(filled_quad_idx))      
                    patt_id_temp = filled_quad_idx(rev_quadrant);
                    dotData(patt_id_temp) = update_dots(dotData(patt_id_temp));                    
                    % draws the current dots, using position, single size argument and dotType
                    Screen('DrawDots', Scr.w, dotData(patt_id_temp).dotPos, dotData(patt_id_temp).size, [255 255 255], [0 0], dotData(patt_id_temp).dotType);
                end
                
                remaining_quadrants = ~ismember(1:numQuads,rev_quadrant); % this yields the logical indices for the remaining, non-revealed quadrants for the following
                % 'FillRect' command

                Screen('FillRect',Scr.w,quadColors(:,remaining_quadrants),allQuads(:,remaining_quadrants))
                
            else
                Screen('FillRect',Scr.w,quadColors,allQuads)
            end
            
            vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);

            if exploreFlips == 1
                exploreOnset = vbl;                                                          %%%%TIME%%%%%%%
            end
            
            exploreFlips = exploreFlips + 1;
            
            %%%%%%%%%%%%%%II.Check Response
            [KeyIsDown,endRTRaw, KeyCodeRaw] = KbCheck();
            if (KeyIsDown==1) && respToBeMade
                if KeyCodeRaw(KbName('ESCAPE'))  % EXIT key pressed to exit experiment
                    error('EXIT button!\n');
                else
                    if any(KeyCodeRaw([up_right,right_down,down_left,left_up]))                       
                        trialRT = endRTRaw - exploreOnset; % save RT!!!!
                        if KeyCodeRaw(up_right) && scene_id == 1
                            trialAcc = 1;
                        elseif KeyCodeRaw(right_down) && scene_id == 2
                            trialAcc = 1;
                        elseif KeyCodeRaw(down_left) && scene_id == 3
                            trialAcc = 1;
                        elseif KeyCodeRaw(left_up) && scene_id == 4
                            trialAcc = 1;
                        else
                            trialAcc = 0;
                        end                       
                    else
                        trialError = 1; trialIsOK = false; noResponse = false;          % END THE TRIAL
                    end
                end
            else
                noResponse = true;
            end
             
        end
        
        if trialIsOK
            for i = 1:feedbackDur 
                if trialAcc == 1
                    Screen('FrameRect', Scr.w, [0 255 0], CenterRectOnPointd([0 0 50 50],fixationCoord(1),fixationCoord(2)), 5);
                    DrawFormattedText(Scr.w,'Correct','center',Scr.wRect(4)*0.95,[0 255 ceil(255/2)]);
                else
                    Screen('FrameRect', Scr.w, [255 0 0], CenterRectOnPointd([0 0 50 50],fixationCoord(1),fixationCoord(2)), 5);
                    DrawFormattedText(Scr.w,'Incorrect','center',Scr.wRect(4)*0.95,[255 0 ceil(255/4)]);
                end
                vbl = Screen('Flip',Scr.w,vbl + (Scr.waitframes - 0.5) * Scr.ifi);
                if i == 1
                    feedbackOnset = vbl;                                              %%%%%%%TIME%%%%%%%%%
                end
            end
            trialEND = vbl;
            
        end    
    end
end


% save the data

trial_data.trialRT = trialRT;
trial_data.trialAcc = trialAcc;
trial_data.trialError = trialError;

trial_data.trialSTART = trialSTART;
trial_data.fixationOnset = fixationOnset;
trial_data.exploreOnset = exploreOnset;
trial_data.feedbackOnset = feedbackOnset;
trial_data.trialEND = trialEND;

Screen('CloseAll')


        
            
        
        
        
    
    




