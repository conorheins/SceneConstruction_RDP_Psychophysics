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
%       4. SOUND stimulation - location and frequency
%       5. GABOR stimulation + Gabor AND Box Rects
%
%       PS: Visual cue location defined at RunSingleTrial function.
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
inf.resultsFile = strcat('test','.txt'); % Default name of cueing data file to write to (for the while loop)

% Create a unique name for participant files:
if inf.subNo == 1                                                       % in GetSubInfo we define the subject name as 1, so it is a test
    inf.afterBreak = false;
    inf.rootTest = fullfile(Scr.rootDir,'Data','test');
    if ~exist(inf.rootTest,'dir')
        mkdir(Scr.rootDir,fullfile('Data','test'));
    end
    cd(inf.rootTest);                                                   % move to the test directory
    while (fopen(inf.resultsFile, 'rt')~=-1)                            % making a loop to find a free number (till it is not possible to open)
        inf.subNo= inf.subNo+1;
        inf.resultsFile = strcat('test',num2str(inf.subNo),'.txt');     % name of the data file to write to.
    end
    inf.resultsFile = fopen(inf.resultsFile,'wt');                      % open ASCII file for writing
    strcat('Result data file already exists! Choosing: ', num2str(inf.subNo));
else                                                                    % in the main script we define inf.subNo as narin which is ...
    %...the subject code.
    inf.rootSub = [Scr.rootDir  filesep() 'Data' filesep() 'SubjectsData' filesep() inf.subNo filesep()];
    if exist([inf.rootSub filesep() inf.subNo '__allData.mat'],'file') == 2 % Does the folder exists?
        inf.afterBreak = true;                                          % Then use this folder!
        cd(inf.rootSub);
        inf.resultsFile = strcat(inf.subNo,'.txt');
        inf.resultsFile = fopen(inf.resultsFile,'at+');
    else %if not
        inf.afterBreak = false;
        mkdir(inf.rootSub);
        mkdir([inf.rootSub 'EEG' filesep 'RawData']); mkdir([inf.rootSub 'EEG' filesep 'ERPs']);
        cd(inf.rootSub);
        inf.resultsFile = strcat(inf.subNo,'.txt');                     % name of the data file to write to
        inf.resultsFile = fopen(inf.resultsFile,'wt');
    end  % open ASCII file for writing
end
cd(Scr.rootDir); % Go back to our core directory.

%% SCREEN: KEYS and PPD

% Define the keyboard keys that are listened for. We will use left
% and right arrow keys as a response keys for the task and escape key as
% exit/reset key

% myVar.escapeKey = KbName('ESCAPE');
% myVar.leftKey   = KbName('LeftArrow');
% myVar.rightKey  = KbName('RightArrow');
% myVar.upKey     = KbName('UpArrow');
% myVar.downKey   = KbName('DownArrow');
% myVar.pKey      = KbName('p');
% myVar.cKey      = KbName('c');
% myVar.tKey      = KbName('t');
% myVar.dKey      = KbName('d');

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
myVar.centW             = 52.2;       % ViewPixx EEG (cm.)
myVar.centD             = 91.0;       % Distance to the screen (cm.)
myVar.centH             = 29.1;       % ViewPixx EEG (cm.)

% PPD based on Visual Psyhcophysics book, Lu and Dosher
Scr.pixelsperdegree =pi/180 * myVar.centD /myVar.centH * Scr.wRect(4);

%% SCREEN: Size and Distances

myVar.fixXLoc                 = myVar.centerX;                  % Define Fixation point X
myVar.fixYLoc                 = myVar.centerY;                  % Define Fixation point Y
myVar.RDPHalfQuad             = floor(2*Scr.pixelsperdegree);   % Define distance in pixels, of one RDP-containing quadrant
myVar.frameLineWidth          = floor(.15*Scr.pixelsperdegree); % Define width of frames that surround each quadrant

% IMPORTANT variables!
inf.eyeWindow                 = 2;
Scr.cueDistance               = floor(9*Scr.pixelsperdegree);   % Distance of quadrants from the screen center
Scr.waitframes                = 1;                              % Numer of frames to wait before re-drawing (Used in Threshold)

myVar.fixationTime   = 5;    % time in seconds of fixation window (basically, participant has to hold gaze / mouse position in center for 5 seconds before proceeding)
myVar.exploreTime    = 15;   % time in seconds to explore the scene 
myVar.feedbackTime   = 0.5;  % the length in seconds of the feedback window
myVar.fixationWindow = 50;   % spatial distance in pixels that mouse coordinates/eye position needs to be within, in order to be counted as fixating
myVar.gazeWindow     = 150;  % how far your cursor/eye position needs to be from the center of the frame in order to uncover it
myVar.fixCrossDimPix = 40;   % size of the arms of fixation cross
myVar.lineWidthPix   = 4;    % line width for our fixation cross


%% Quadrant locations

% Define RECTS of the four different quadrants  
RDPDimPix = myVar.RDPHalfQuad*2;       % full extent of a RDP-containing quadrant, in pixels
RDPRect   = [0 0 RDPDimPix RDPDimPix]; % Define size of RDM

% Positioning
pixShift = Scr.cueDistance;
xPos = [myVar.centerX - pixShift myVar.centerX - pixShift myVar.centerX + pixShift myVar.centerX + pixShift];
yPos = [myVar.centerY - pixShift myVar.centerY + pixShift myVar.centerY - pixShift myVar.centerY + pixShift];

% Assign positions to each of our Gabor and box
nRDM            = numel(xPos*yPos);
myVar.RDMRects	= nan(4, nRDM);
myVar.centers   = [xPos;yPos];
for i = 1:nRDM
    myVar.RDMRects(:, i) = CenterRectOnPointd(RDPRect,  xPos(i), yPos(i));
end

end