function [Scr] = InitializeWindow(inf,screenNumber,debug_mode_flag)

%set isFullScreen to 0 for the partial window for debugging
%1 for a full-screen experiment

% Clear Matlab/Octave window:
clc;
% check for OpenGL compatibility, abort otherwise:
AssertOpenGL;
% Reseed the random-number generator for each expert.
rng('default'); % restore original settings
rng(sum(100*clock));

% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows, and GNU/Linux:
KbName('UnifyKeyNames');

% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% at the wrong moment:
KbCheck;
WaitSecs(0.1);
GetSecs;

%%%%%%%%%%%%%%%%%%%%%%
% OPEN WINDOW
%%%%%%%%%%%%%%%%%%%%%%
% Get screenNumber of stimulation Scr. We choose the Scr with
% the maximum index, which is usually the right one, e.g., the external
% Scr on a Laptop:

screens      = Screen('Screens');

if nargin < 2 || ~exist('screenNumber','var') 
    screenNumber = max(screens);
end

%Problems with synchronization. If we uncomment, this lines script doesn't start.
Screen('Preference', 'ConserveVRAM', 4096); %%%% See help win Beampositionqueries
[Scr.oldDebugLevel] = Screen('Preference', 'VisualDebugLevel', 1);
% Screen('Preference', 'SkipSyncTests', 0);  % 0 for tests, 1 for skip
Screen('Preference', 'SkipSyncTests', 1);  % 0 for tests, 1 for skip


if nargin < 3 || ~exist('debug_mode_flag','var') || isempty(debug_mode_flag) || debug_mode_flag == 1
    PsychDebugWindowConfiguration(0,0.5);
end

% Returns as default the mean gray value of screen:

% Define screen colors
Scr.white               = WhiteIndex(screenNumber);
Scr.black               = BlackIndex(screenNumber);
Scr.gray                = (Scr.white+Scr.black)/2;
% Scr.gray = GrayIndex(screenNumber); % Alternative version

% Open a buffered fullscreen window on the stimulation screen
% 'screenNumber' and choose/draw a gray background. 'Scr.w' is the handle
% used to direct all drawing commands to that window - the "Name" of
% the window. 'Scr.wRect' is a rectangle defining the size of the window.
% See "help PsychRects" for help on such rectangles and useful helper
% functions.
try
    % Check if window is still open by using the Screen function
    Scr.ifi = Screen('GetFlipInterval', Scr.w);
catch
    if inf.isFullScreen
%         [Scr.w, Scr.wRect] = Screen('OpenWindow',screenNumber,Scr.black,[],[],[]);
        [Scr.w, Scr.wRect] = Screen('OpenWindow',screenNumber,Scr.gray,[],[],[]);
        ListenChar(2)
    end
end

%%%%
Scr.ifi=Screen('GetFlipInterval', Scr.w);


% try %% check whether the window is already open
%     gammaVal=1.75; %  see ('intensity10_54.51(Before_experiment5)%_28_02','intensity10')
% catch
%     gammaVal=1;
% end
% 
% % Gamma calibration
% linCLUT=repmat(linspace(0,1,256)',1,3);
% Screen('LoadNormalizedGammaTable', 0, linCLUT ,0);
% gammaCLUT=repmat(linspace(0,1,256)'.^(1/gammaVal),1,3);
% Screen('LoadNormalizedGammaTable', 0, gammaCLUT ,0);
% Screen('ColorRange', Scr.w, 255);

% Enable alpha blending with proper blend-function. We need it for drawing
% of smoothed points.
% Screen('BlendFunction', Scr.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Set text size (Most Screen functions must be called after
% opening an onscreen window, as they only take window handles 'Scr.w' as
% input:
Screen('TextFont',Scr.w, 'Arial');
Screen('TextStyle', Scr.w, 1);
Screen('TextSize',Scr.w, 26);

% Set priority for script execution to realtime priority:
priorityLevel=MaxPriority(Scr.w);
Priority(priorityLevel);

end
