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

% keys for scene choices
myVar.aKey      = KbName('a'); % Scene 1 - UP RIGHT
myVar.sKey      = KbName('s'); % Scene 2 - RIGHT DOWN
myVar.dKey      = KbName('d'); % Scene 3 - DOWN LEFT
myVar.fKey      = KbName('f'); % Scene 4 - LEFT UP


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

myVar.centW             = 52.2;       % ViewPixx EEG (cm.)
myVar.centD             = 91.0;       % Distance to the screen (cm.)
myVar.centH             = 29.1;       % ViewPixx EEG (cm.)

% PPD based on Visual Psyhcophysics book, Lu and Dosher
Scr.pixelsperdegree = pi/180 * myVar.centD /myVar.centH * Scr.wRect(4);

%% SCREEN: Size and Distances

myVar.fixXLoc                 = myVar.centerX;                  % Define Fixation point X
myVar.fixYLoc                 = myVar.centerY;                  % Define Fixation point Y
myVar.RDPHalfQuad             = floor(2*Scr.pixelsperdegree);   % Define half-width in pixels, of one RDP-containing quadrant
myVar.frameLineWidth          = floor(.2*Scr.pixelsperdegree); % Define width of frames that surround each quadrant
myVar.feedbackFrameWidth      = floor(.1*Scr.pixelsperdegree); % Define width of frames that surround choice symbols upon response

% IMPORTANT variables!
inf.eyeWindow                 = 2;                              % window in visual degrees around fixation center, that subject must keep eyes within 
Scr.cueDistance               = floor(6*Scr.pixelsperdegree);   % Distance of quadrants from the screen center
Scr.waitframes                = 1;                              % Number of frames to wait before re-drawing (Used in Threshold)
Scr.choice_distance           = floor(Scr.pixelsperdegree.*[ [-10.25, -6.25, 3.75, 7.75]; [-7.75, -3.75, 6.25, 10.25] ]);  % distance of choice symbols from fixation center (in horizontal plane)
                                                                                                    % first row is leftmost displacements, second row is rightmost displacements
Scr.vertdisplace              = floor(2.25*Scr.pixelsperdegree);   % vertical displacements                                                            


myVar.fixationTime      = 5;    % time in seconds of fixation window (basically, participant has to hold gaze / mouse position in center for 5 seconds before proceeding)
myVar.exploreTime       = 15;   % time in seconds to explore the scene 
% myVar.train_exploreTime = 100;  % time in seconds to explore the scene in practice blocks
myVar.train_exploreTime = 15;  % time in seconds to explore the scene in practice blocks -- for debugging purposes
myVar.feedbackTime      = 1;    % the length in seconds of the feedback window
myVar.intertrialTime    = 2;    % time in seconds of fixation window for all other trials 
myVar.ITI_sd            = 0.5;  % standard deviation in seconds of fixation window for all other trials

myVar.gazeWindow        = floor(2*Scr.pixelsperdegree);  % how far your cursor/eye position needs to be from the center of a quadrant in order to uncover it
myVar.fixCrossDimPix    = 40;   % size of the arms of fixation cross
myVar.lineWidthPix      = 4;    % line width for our fixation cross

myVar.speed    = 5;     % speed of dots in visual degrees / second 
myVar.apSize   = floor([5 * Scr.pixelsperdegree, 5 * Scr.pixelsperdegree]); % width/height of aperture in which dots are displayed, in pixels
myVar.lifetime_ms = 0.1; % lifetime of dots in milliseconds
myVar.nDots    = ceil(20/(Scr.pixelsperdegree.^2) .* prod(myVar.apSize) ./ (1/myVar.lifetime_ms) ) ;
myVar.lifetime = floor( 1/Scr.ifi * myVar.lifetime_ms);  % lifetime of dots in flips -- use this value for psychophysics monitor
myVar.dotSize = 0.1 * Scr.pixelsperdegree;  % size of dots in pixels, following Palmer Huk & Shadlen 2005

myVar.UR_symbol    = imread('images/UR.png');  
myVar.RD_symbol = imread('images/RD.png');
myVar.DL_symbol  = imread('images/DL.png');
myVar.LU_symbol  = imread('images/LU.png');

myVar.subRect = [200 80 700 440];
myVar.UR_rect = [myVar.centerX + Scr.choice_distance(1,1) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,1) myVar.centerY + Scr.vertdisplace/2];
myVar.RD_rect = [myVar.centerX + Scr.choice_distance(1,2) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,2) myVar.centerY + Scr.vertdisplace/2];
myVar.DL_rect = [myVar.centerX + Scr.choice_distance(1,3) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,3) myVar.centerY + Scr.vertdisplace/2];
myVar.LU_rect = [myVar.centerX + Scr.choice_distance(1,4) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,4) myVar.centerY + Scr.vertdisplace/2];

myVar.choiceRects = [myVar.UR_rect;myVar.RD_rect;myVar.DL_rect;myVar.LU_rect]'; 

%% Quadrant locations

% Define RECTS of the four different quadrants  
RDPDimPix = myVar.RDPHalfQuad*2;       % full extent of a RDP-containing quadrant, in pixels
RDPRect   = [0 0 RDPDimPix RDPDimPix]; % Define size of RDM

% Positioning
pixShift = Scr.cueDistance;
xPos = [myVar.centerX - pixShift myVar.centerX - pixShift myVar.centerX + pixShift myVar.centerX + pixShift];
yPos = [myVar.centerY - pixShift myVar.centerY + pixShift myVar.centerY - pixShift myVar.centerY + pixShift];

% Assign positions to each of our Gabor and box
nRDM            = numel(xPos);
myVar.RDMRects	= nan(4, nRDM);
myVar.centers   = [xPos;yPos];
for i = 1:nRDM
    myVar.RDMRects(:, i) = CenterRectOnPointd(RDPRect,  xPos(i), yPos(i));
end

end