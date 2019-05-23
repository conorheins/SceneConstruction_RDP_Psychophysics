function [ Scr ] = InitScreen_v2(sub_rect,screenNumber,debug_mode_flag)
%INITSCREEN_WITHSUB Based on Roman's function InitScreen (but draws the
%   screen black instead of gray)
%   accepts three optional inputs: a sub_rect for debugging purposes;
%   a screenNumber to index which monitor to be used for drawing;
%   and a debug_mode_flag to decide whether you want to draw the screen in
%   debug mode or not (opaque and with access to GUIs running
%   underneath)

AssertOpenGL;
KbName('UnifyKeyNames');
% Reseed the random-number generator for each expert.
rng(sum(100*clock));
screens      = Screen('Screens');
if ~exist('screenNumber','var') || isempty(screenNumber)
    screenNumber = max(screens);
end

%Problems with synchronization. If we uncomment, this lines script doesn't start.
Screen('Preference', 'ConserveVRAM', 4096); %%%% See help win Beampositionqueries
[Scr.oldDebugLevel] = Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1);  % 0 for tests, 1 for skip


% Define screen colors
Scr.white               = WhiteIndex(screenNumber);
Scr.black               = BlackIndex(screenNumber);
Scr.gray                = (Scr.white+Scr.black)/2;

if ~exist('debug_mode_flag','var') || isempty(debug_mode_flag) || debug_mode_flag == 1
    PsychDebugWindowConfiguration(0,0.5);
end

if ~exist('sub_rect','var') || isempty(sub_rect)
    [Scr.w, Scr.wRect] = Screen('OpenWindow',screenNumber,Scr.black,[],[],[]); % default to using the whole screen
else
    [Scr.w, Scr.wRect] = Screen('OpenWindow',screenNumber,Scr.black,sub_rect,[],[]); % otherwise, only open a window with the dimensions specified in sub_rect
end
Scr.ifi=Screen('GetFlipInterval', Scr.w);

% Enable alpha blending with proper blend-function. We need it for drawing
% of smoothed points.
Screen('BlendFunction', Scr.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Set text size (Most Screen functions must be called after
% opening an onscreen window, as they only take window handles 'Scr.w' as
% input:
Screen('TextFont',Scr.w, 'Arial');
Screen('TextStyle', Scr.w, 1);
Screen('TextSize',Scr.w, 32);

% Set priority for script execution to realtime priority:
priorityLevel=MaxPriority(Scr.w);
Priority(priorityLevel);

end

