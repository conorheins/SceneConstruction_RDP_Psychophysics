function CountDown(Scr,myVar,dur)

% We set the text size to be nice and big here
Screen('TextSize', Scr.w, 50);

% Get the nominal framerate of the monitor. For this simple timer we are
% going to change the counterdown number every second. This means we
% present each number for "frameRate" amount of frames. This is because
% "framerate" amount of frames is equal to one second. Note: this is only
% for a very simple timer to demonstarte the principle. You can make more
% accurate sub-second timers based on this.
nominalFrameRate = 1./Screen('GetFlipInterval', Scr.w);

% Randomise a start color
% frameDimPPD = Scr.fixHalfBox*3;
frameDimPPD = myVar.RDPHalfQuad*3;
frameRect   = [0 0 frameDimPPD frameDimPPD];
text =       sprintf('Have a Break');

arcPos = CenterRectOnPointd(frameRect, myVar.centerX,myVar.centerY);
fillArc = 360;
duration = dur;
arcChange = 360/(duration*nominalFrameRate);

% Here is our drawing loop
for i = 1:duration*nominalFrameRate
    
    % Convert our current number to display into a string
    numberString =num2str(datestr( duration/86400, 'MM:SS' ));
    duration = duration-1/nominalFrameRate;
    
%     Screen('FillArc',Scr.w,myVar.colGrey,arcPos,0,fillArc);
    Screen('FillArc',Scr.w,Scr.gray,arcPos,0,fillArc);
    fillArc = fillArc - arcChange;
    
    % Draw our number to the screen
    DrawFormattedText(Scr.w, numberString, 'center', 'center',[153 153 153] );
    DrawFormattedText(Scr.w, text, 'center',myVar.fixYLoc-Scr.pixelsperdegree*8, [153 153 153]);
    
    % Flip to the screen
    Screen('Flip', Scr.w);
    
    [~, ~, KeyCodeRaw] = KbCheck();
    if any(KeyCodeRaw == KbName('ESCAPE'))  % EXIT key pressed to exit experiment
        error(sprintf('EXIT button!\n'));
    end
end
Screen('TextSize',Scr.w, 32);
% text = sprintf('To continue press Space.');
% DrawFormattedText(Scr.w, text, 'center','center', [0 0 0]);
% Screen('Flip', Scr.w);
% KbStrokeWait();
end