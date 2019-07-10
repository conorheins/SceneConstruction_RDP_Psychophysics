function [Scr,inf, myVar] = SetUpConstants_SC(Scr,inf,myVar)
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
Scr.mainDir = pwd;
Scr.expDir = fullfile(Scr.mainDir,'SceneConstructionProper');
% Scr.rootDir = pwd;

% Define filenames of input files and result file:
cd(Scr.expDir);

% Create a unique name for participant files:
if inf.subNo == 1                                                       % in GetSubInfo we define the subject name as 1, so it is a test
    inf.afterBreak = false;
    inf.rootTest = fullfile(Scr.expDir,'Data','test');
    if ~exist(inf.rootTest,'dir')
        mkdir(Scr.expDir,fullfile('Data','test'));
    end
    cd(inf.rootTest);                                                   % move to the test directory
    while exist(fullfile(inf.rootTest,sprintf('test%d__allData.mat',inf.subNo)),'file')
        inf.subNo= inf.subNo+1;
    end
else                                                                    % in the main script we define inf.subNo as first argument
    %...the subject code.
    inf.rootSub = fullfile(Scr.expDir,'Data','SubjectsData',num2str(inf.subNo));
    if exist(fullfile(inf.rootSub,sprintf('Subject%d__allData.mat',inf.subNo)),'file') % Does the matlab file exists?
        inf.afterBreak = true;                                          % Then use this folder!
    else %if not
        inf.afterBreak = false;
        mkdir(inf.rootSub);
    end  
end

% cd(Scr.rootDir); % Go back to our main directory.
cd(Scr.mainDir); % Go back to our main directory..

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
myVar.kKey      = KbName('k'); % initiate Kalibration 
myVar.tKey      = KbName('t'); % Do Threshold calibration before the next block
myVar.dKey      = KbName('d'); % do drift correction

myVar.spacebar  = KbName('space'); % spacebar -- in eyetracking mode, must be pressed simultaneous to looking at a scene

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
% myVar.centD             = 91.0;       % Distance to the screen (cm.)
myVar.centD             = 60.0;     % Distance to the screen (cm.) in
%                                       the psychophysics room
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


myVar.fixationTime      = 0.250;    % time in seconds of fixation window (basically, participant has to hold gaze / mouse position in center for 5 seconds before proceeding)
myVar.exploreTime       = 30;   % time in seconds to explore the scene 
myVar.train_exploreTime = 30;   % time in seconds to explore the scene in practice blocks -- for debugging purposes
myVar.choiceTime        = 0.5;  % the length in seconds of choice display
myVar.feedbackTime      = 2.25;  % the length in seconds of the feedback window
myVar.eyeCheckTime      = 1.0;  %  duration of EyeLink fixation period in seconds for the first trial of each block 
myVar.intertrialTime    = 0.5;  % time in seconds of EyeCheck window for all other trials 
myVar.ITI_sd            = 0.15; % standard deviation in seconds of EyeCheck window for all other trials

myVar.revealTime        = 0.1; % time in seconds before quadrant is revealed, once fixation has been detected
myVar.starting_points   = 200; % number of points that participant starts with at the beginning of each trial (conversion rate: 10k points / euro)
% myVar.discount_scale    = myVar.starting_points / (myVar.exploreTime / Scr.ifi); % scale of discounting function
% myVar.discount_function = @(x) (-(myVar.discount_scale)*x + myVar.starting_points); % function handle to encode temporal discounting of rewards over exploration time

penalty = -.00025;
T = round(myVar.exploreTime/Scr.ifi);
cumulative = 1:T-1;
cumulative = [0 cumulative];
for t = 2:T
    myVar.discount_function(t) = sum(cumulative(2:t))*penalty + myVar.starting_points;
end

myVar.correct_reward    = 200; % reward (in points) of categorizing correctly
myVar.miss_cost         = 400; % cost (in points) of being incorrect or failing to respond

myVar.gazeWindow        = floor(2*Scr.pixelsperdegree);  % how far your cursor/eye position needs to be from the center of a quadrant in order to uncover it
myVar.fixCrossDimPix    = 40;   % size of the arms of fixation cross
myVar.lineWidthPix      = 4;    % line width for our fixation cross

myVar.speed    = 5;     % speed of dots in visual degrees / second 
myVar.apSize   = floor([5 * Scr.pixelsperdegree, 5 * Scr.pixelsperdegree]); % width/height of aperture in which dots are displayed, in pixels
myVar.lifetime_ms = 0.1; % lifetime of dots in milliseconds
myVar.nDots    = ceil(20/(Scr.pixelsperdegree.^2) .* prod(myVar.apSize) ./ (1/myVar.lifetime_ms) ) ;
myVar.lifetime = floor( 1/Scr.ifi * myVar.lifetime_ms);  % lifetime of dots in flips -- use this value for psychophysics monitor
myVar.dotSize = 0.1 * Scr.pixelsperdegree;  % size of dots in pixels, following Palmer Huk & Shadlen 2005

% myVar.UR_symbol  = imread('images/UR.png');  
% make sure background of these in powerpoint is #808080ff in hex
myVar.UR_symbol  = imread('SceneConstructionProper/images/UR_gray.png');  
% myVar.RD_symbol  = imread('images/RD.png');
myVar.RD_symbol  = imread('SceneConstructionProper/images/RD_gray.png');
% myVar.DL_symbol  = imread('images/DL.png');
myVar.DL_symbol  = imread('SceneConstructionProper/images/DL_gray.png');
% myVar.LU_symbol  = imread('images/LU.png');
myVar.LU_symbol  = imread('SceneConstructionProper/images/LU_gray.png');

myVar.subRect = [275 80 715 440];
% myVar.UR_rect = [myVar.centerX + Scr.choice_distance(1,1) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,1) myVar.centerY + Scr.vertdisplace/2];
% myVar.RD_rect = [myVar.centerX + Scr.choice_distance(1,2) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,2) myVar.centerY + Scr.vertdisplace/2];
% myVar.DL_rect = [myVar.centerX + Scr.choice_distance(1,3) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,3) myVar.centerY + Scr.vertdisplace/2];
% myVar.LU_rect = [myVar.centerX + Scr.choice_distance(1,4) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,4) myVar.centerY + Scr.vertdisplace/2];

myVar.UR_rect = [myVar.centerX + Scr.choice_distance(1,1) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,1) myVar.centerY + Scr.vertdisplace/2];
myVar.RD_rect = [myVar.centerX + Scr.choice_distance(1,3) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,3) myVar.centerY + Scr.vertdisplace/2];
myVar.DL_rect = [myVar.centerX + Scr.choice_distance(1,2) myVar.centerY - Scr.vertdisplace/2 myVar.centerX + Scr.choice_distance(2,2) myVar.centerY + Scr.vertdisplace/2];
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