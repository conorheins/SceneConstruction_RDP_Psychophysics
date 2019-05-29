fclose all;
PsychDefaultSetup(1);       % to define color in range of 255 instead of 1
delete AA_lasterrormsg.mat  % If we got an error, we would see it in root folder
% addpath Calibrate\COLOR;    % Integrate TestColorFlick
format shortG               % this command especially for date formatting.

scrNum = 0;  % specific to Conor's set-up -- use 0 to make the display screen the personal laptop (external monitor is for MATLAB)
debug_mode_flag = true;

clc;
% check for OpenGL compatibility, abort otherwise:
AssertOpenGL;

%Problems with synchronization. If we uncomment, this lines script doesn't start.
Screen('Preference', 'ConserveVRAM', 4096); %%%% See help win Beampositionqueries
[Scr.oldDebugLevel] = Screen('Preference', 'VisualDebugLevel', 1);
% Screen('Preference', 'SkipSyncTests', 0);  % 0 for tests, 1 for skip
Screen('Preference', 'SkipSyncTests', 1);  % 0 for tests, 1 for skip
if debug_mode_flag
    PsychDebugWindowConfiguration(0,0.5);
end

Scr.white               = WhiteIndex(scrNum);
Scr.black               = BlackIndex(scrNum);
Scr.gray                = (Scr.white+Scr.black)/2;

[Scr.w, Scr.wRect] = Screen('OpenWindow',scrNum,Scr.black,[],[],[]);

% Set text size (Most Screen functions must be called after
% opening an onscreen window, as they only take window handles 'Scr.w' as
% input:
Screen('TextFont',Scr.w, 'Arial');
Screen('TextStyle', Scr.w, 1);
Screen('TextSize',Scr.w, 32);

% Set priority for script execution to realtime priority:
priorityLevel=MaxPriority(Scr.w);
Priority(priorityLevel);


UP = imread('UP.png');
RIGHT = imread('RIGHT.png');
DOWN = imread('DOWN.png');
LEFT = imread('LEFT.png');

subRect = [300 100 650 400];

posRect1 = [Scr.wRect(3)/4 - 200 3*Scr.wRect(4)/4 Scr.wRect(3)/4 - 100 3*Scr.wRect(4)/4 + 85];
UP_ptr = Screen('MakeTexture',Scr.w,UP); 
% Screen('DrawTexture', Sc.w, UP_ptr,[],bigIm); % draw the scene 
Screen('DrawTexture', Scr.w, UP_ptr,subRect,posRect1); % draw the scene 

posRect2 = [2*Scr.wRect(3)/4 - 200 3*Scr.wRect(4)/4 2*Scr.wRect(3)/4 - 100 3*Scr.wRect(4)/4 + 85];
RIGHT_ptr = Screen('MakeTexture',Scr.w,RIGHT); 
Screen('DrawTexture', Scr.w, RIGHT_ptr,subRect,posRect2); % draw the scene 

posRect3 = [3*Scr.wRect(3)/4 - 200 3*Scr.wRect(4)/4 3*Scr.wRect(3)/4 - 100  3*Scr.wRect(4)/4 + 85];
DOWN_ptr = Screen('MakeTexture',Scr.w,DOWN); 
% Screen('DrawTexture', Sc.w, UP_ptr,[],bigIm); % draw the scene 
Screen('DrawTexture', Scr.w, DOWN_ptr,subRect,posRect3); % draw the scene 

posRect4 = [Scr.wRect(3) - 200 3*Scr.wRect(4)/4 Scr.wRect(3) - 100  3*Scr.wRect(4)/4 + 85];
LEFT_ptr = Screen('MakeTexture',Scr.w,LEFT); 
Screen('DrawTexture', Scr.w, LEFT_ptr,subRect,posRect4); % draw the scene 


Screen('Flip',Scr.w)



             



pause(0.5);
Screen('CloseAll');
