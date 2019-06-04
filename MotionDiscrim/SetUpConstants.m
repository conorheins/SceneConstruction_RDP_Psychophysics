function [Scr,inf, myVar] = SetUpConstants(Scr,inf)
%   SetUpConstants create all constant variables for the experiment.
%
%   Structure:
%       1. Define values
%               This is the variable that varies the value of color/sound
%               between participants. One is for magenta/high pitch higher
%               value; two is for orange/low pitch.
%       2. Filename
%               We specify the file name. It could be the real experiment, then
%               file stored in SubjectsData folder. If not then it will be
%               saved in test filter with automatic name generator. To
%               make real experiment some should call SimpleCrossmodal.m
%               function with the attribute of participant name.
%       3. Screen and CUE locations
%               Define PPD and locations of cues by this PPD.
%
%       PS: Visual cue location defined at RunTrial function.
%       Also despite this function called SetUpConstants, we define here
%       variables as well, BUT we only generate this variables, not
%       manipulate with them. All manipulations are in SetUpTrialsMixed
%       function.

%% FILE NAME
% In this section, we define the name of the file with Pp responses.

% Save file directory before we start.
Scr.rootDir = pwd;

% Define filenames of input files and result file:
cd(Scr.rootDir);

% Create a unique name for participant files:
if inf.subNo == 1                                                       % in GetSubInfo we define the subject name as 1, so it is a test
    inf.afterBreak = false;
    inf.rootTest = fullfile(Scr.rootDir,'Data','test');
    if ~exist(inf.rootTest,'dir')
        mkdir(Scr.rootDir,fullfile('Data','test'));
    end
    cd(inf.rootTest);                                                   % move to the test directory
    while exist(fullfile(inf.rootTest,sprintf('test%d__allData.mat',inf.subNo)),'file')
        inf.subNo= inf.subNo+1;
    end
else                                                                    % in the main script we define inf.subNo as first argument
    %...the subject code.
    inf.rootSub = fullfile(Scr.rootDir,'Data','SubjectsData',num2str(inf.subNo));
    if exist(fullfile(inf.rootSub,sprintf('Subject%d__allData.mat',inf.subNo)),'file') % Does the matlab file exists?
        inf.afterBreak = true;                                          % Then use this folder!
    else %if not
        inf.afterBreak = false;
        mkdir(inf.rootSub);
    end  
end
cd(Scr.rootDir); % Go back to our core directory.

%% SCREEN: KEYS and PPD

% Define the keyboard keys that are listened for. We will use left
% and right arrow keys as a response keys for the task and escape key as
% exit/reset key

myVar.escapeKey = KbName('ESCAPE'); % end eye-tracking 
myVar.leftKey   = KbName('LeftArrow');
myVar.rightKey  = KbName('RightArrow');
myVar.upKey     = KbName('UpArrow');
myVar.downKey   = KbName('DownArrow');
myVar.pKey      = KbName('p'); % Skip EyeCheck
myVar.cKey      = KbName('c'); % initiate caibration 
myVar.tKey      = KbName('t'); % Do Threshold calibration before the next block
myVar.dKey      = KbName('d'); % do drift correction

% In this section we will define screen and distances

[Scr.width, Scr.height] = Screen('WindowSize', Scr.w);      % Screen in pixels.
[Scr.WMM, Scr.HMM]      = Screen('DisplaySize', Scr.w);     % Screen in mm (Wrong for windows, pixel...
%... density of 2.835 pixels/mm or 72 DPI)

% PixelPerDegree (PPD).
myVar.centerX           = Scr.width/2;
myVar.centerY           = Scr.height/2;

% myVar.centW             = 33.24;      % MacBook Pro monitor width (cm.)
% myVar.centD             = 50;         % Distance to the screen (cm.)
% myVar.centH             = 20.77;      % MacBook Pro monitor height (cm.)
% 
myVar.centW             = 52.2;       % ViewPixx EEG (cm.)
myVar.centD             = 91.0;       % Distance to the screen (cm.)
myVar.centH             = 29.1;       % ViewPixx EEG (cm.)

% PPD based on Visual Psyhcophysics book, Lu and Dosher
Scr.pixelsperdegree = pi/180 * myVar.centD /myVar.centH * Scr.wRect(4);

%% SCREEN: Size and Distances

myVar.fixXLoc                 = myVar.centerX;                  % Define Fixation point X
myVar.fixYLoc                 = myVar.centerY;                  % Define Fixation point Y
myVar.RDPHalfQuad             = floor(2*Scr.pixelsperdegree);   % Define distance in pixels, of one RDP-containing quadrant
myVar.frameLineWidth          = floor(.15*Scr.pixelsperdegree); % Define width of frames that surround each quadrant

% IMPORTANT variables!
inf.eyeWindow                 = 2;                              % window in visual degrees around fixation center, that subject must keep eyes within 
Scr.cueDistance               = floor(9*Scr.pixelsperdegree);   % Distance of quadrants from the screen center
Scr.waitframes                = 1;                              % Numer of frames to wait before re-drawing (Used in Threshold)

myVar.fixationTime   = 2;       % time in seconds of fixation window for first trial of each block (this is longer to give participant time to move cursor/eyes to the center)
myVar.intertrialTime = 0.25;    % time in seconds of fixation window for all other trials 
myVar.accumTime      = 1.25;    % time in seconds to make decision
myVar.feedbackTime   = 0.2;     % the length in seconds of the feedback window
myVar.fixCrossDimPix = 40;      % size of the arms of fixation cross
myVar.lineWidthPix   = 4;       % line width for our fixation cross

% fixed parameters related to RDP displays
% myVar.speed    = 0.75; % speed of dots in squared-pixels / flip -- use this value for Macbook pro
% myVar.speed    = 0.375; % speed of dots in squared-pixels / flip -- use this value for psychophysics monitor
% myVar.speed    = 5 * Scr.pixelsperdegree;     % speed of dots in pixels / second 
myVar.speed    = 5;     % speed of dots in visual degrees / second 
% myVar.apSize   = floor([5.3 * Scr.pixelsperdegree, 5.3 * Scr.pixelsperdegree]); % width/height of aperture in which dots are displayed, in pixels
myVar.apSize   = floor([5 * Scr.pixelsperdegree, 5 * Scr.pixelsperdegree]); % width/height of aperture in which dots are displayed, in pixels
myVar.nDots    = 50;  % number of dots per pattern
% myVar.nDots    = floor(16.7/(Scr.pixelsperdegree.^2) * prod(myVar.apSize)) ;  % number of dots (density of dots in dots / squared-degree x 1/(ppd^2) x Area of aperture in pixels) 
% myVar.lifetime = 10;  % lifetime of dots in flips  -- use this value for Macbook pro
% myVar.lifetime = 20;  % lifetime of dots in flips -- use this value for psychophysics monitor
myVar.lifetime = floor( 1/Scr.ifi * 0.10);  % lifetime of dots in flips -- use this value for psychophysics monitor
% myVar.dotSize = floor( 0.14 * Scr.pixelsperdegree);  % size of dots in pixels
% myVar.dotSize = floor( 0.1 * Scr.pixelsperdegree);  % size of dots in pixels, following Palmer Huk & Shadlen 2005
myVar.dotSize = 0.1 * Scr.pixelsperdegree;  % size of dots in pixels, following Palmer Huk & Shadlen 2005


myVar.UP    = imread('UP.png');  
myVar.RIGHT = imread('RIGHT.png');
myVar.DOWN  = imread('DOWN.png');
myVar.LEFT  = imread('LEFT.png');

myVar.subRect = [300 100 650 400];
myVar.UPrect = [Scr.wRect(3)/4 - 200 3*Scr.wRect(4)/4 Scr.wRect(3)/4 - 100 3*Scr.wRect(4)/4 + 85];
myVar.RIGHTrect = [2*Scr.wRect(3)/4 - 200 3*Scr.wRect(4)/4 2*Scr.wRect(3)/4 - 100 3*Scr.wRect(4)/4 + 85];
myVar.DOWNrect = [3*Scr.wRect(3)/4 - 200 3*Scr.wRect(4)/4 3*Scr.wRect(3)/4 - 100  3*Scr.wRect(4)/4 + 85];
myVar.LEFTrect  = [Scr.wRect(3) - 200 3*Scr.wRect(4)/4 Scr.wRect(3) - 100  3*Scr.wRect(4)/4 + 85];


end