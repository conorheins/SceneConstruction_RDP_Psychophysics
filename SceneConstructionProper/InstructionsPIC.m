function [inst] = InstructionsPIC(inf,Scr)
if inf.language == 1                                  %% English
    %introduction
    imagePath = 'Instructions/E_Intro.png';
    image = imread(imagePath);
    inst.intro = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    % threshold estimation
    imagePath = 'Instructions/E_Threshold.png';
    image = imread(imagePath);
    inst.threshold = Screen('MakeTexture', Scr.w, image);
    
    % Main Task
    imagePath = 'Instructions/E_Main_Task.png';
    image = imread(imagePath);
    inst.mainTask = Screen('MakeTexture', Scr.w, image);
    
    % Conditioning
    imagePath = 'Instructions/E_Conditioning.png';
    image = imread(imagePath);
    inst.conditioning = Screen('MakeTexture', Scr.w, image);
    
    % Eye Calibration/Validation
    imagePath = 'Instructions/E_Eye_calibration.png';
    image = imread(imagePath);
    inst.calibration = Screen('MakeTexture', Scr.w, image);
    
    % Main Task Sound
    imagePath = 'Instructions/E_Main_Task_Sound.png';
    image = imread(imagePath);
    inst.mainTask_Sound = Screen('MakeTexture', Scr.w, image);
    
    % Main Task Visual
    imagePath = 'Instructions/E_Main_Task_Visual.png';
    image = imread(imagePath);
    inst.mainTask_Visual = Screen('MakeTexture', Scr.w, image);
    
    % Conditioning Sound
    imagePath = 'Instructions/E_Conditioning_Sound.png';
    image = imread(imagePath);
    inst.conditioning_Sound = Screen('MakeTexture', Scr.w, image);
    
    % Conditioning Visual
    imagePath = 'Instructions/E_Conditioning_Visual.png';
    image = imread(imagePath);
    inst.conditioning_Visual = Screen('MakeTexture', Scr.w, image);
    
    % Main mini
    imagePath = 'Instructions/E_Main_Task_mini.png';
    image = imread(imagePath);
    inst.mainTask_mini = Screen('MakeTexture', Scr.w, image);
    x = size(image);
    baseRect = [0 0 x(2)*.8 x(1)*.8];
    inst.mainTask_miniFrame =  CenterRectOnPointd(baseRect,  Scr.wRect(3)/2, Scr.wRect(4)/2-Scr.wRect(4)/3);
    % Conditioning Mini
    imagePath = 'Instructions/E_Conditioning_mini.png';
    image = imread(imagePath);
    inst.conditioning_mini = Screen('MakeTexture', Scr.w, image);
    x = size(image);
    baseRect = [0 0 x(2)*.8 x(1)*.8];
    inst.mainTask_conditioningFrame =  CenterRectOnPointd(baseRect,  Scr.wRect(3)/2, Scr.wRect(4)/2-Scr.wRect(4)/3);
    
else
    %% German
    %introduction
    imagePath = 'Instructions/G_Intro.png';
    image = imread(imagePath);
    inst.intro = Screen('MakeTexture', Scr.w, image);
    
    % threshold estimation
    imagePath = 'Instructions/G_Threshold.png';
    image = imread(imagePath);
    inst.threshold = Screen('MakeTexture', Scr.w, image);
    
    % Main Task
    imagePath = 'Instructions/G_Main_Task.png';
    image = imread(imagePath);
    inst.mainTask = Screen('MakeTexture', Scr.w, image);
    
    % Conditioning
    imagePath = 'Instructions/G_Conditioning.png';
    image = imread(imagePath);
    inst.conditioning = Screen('MakeTexture', Scr.w, image);
    
    % Eye Calibration/Validation
    imagePath = 'Instructions/G_Eye_calibration.png';
    image = imread(imagePath);
    inst.calibration = Screen('MakeTexture', Scr.w, image);
    
    % Main Task Sound
    imagePath = 'Instructions/G_Main_Task_Sound.png';
    image = imread(imagePath);
    inst.mainTask_Sound = Screen('MakeTexture', Scr.w, image);
    
    % Main Task Visual
    imagePath = 'Instructions/G_Main_Task_Visual.png';
    image = imread(imagePath);
    inst.mainTask_Visual = Screen('MakeTexture', Scr.w, image);
    
    % Conditioning Sound
    imagePath = 'Instructions/G_Conditioning_Sound.png';
    image = imread(imagePath);
    inst.conditioning_Sound = Screen('MakeTexture', Scr.w, image);
    
    % Conditioning Visual
    imagePath = 'Instructions/G_Conditioning_Visual.png';
    image = imread(imagePath);
    inst.conditioning_Visual = Screen('MakeTexture', Scr.w, image);
    
    % Main mini
    imagePath = 'Instructions/G_Main_Task_mini.png';
    image = imread(imagePath);
    inst.mainTask_mini = Screen('MakeTexture', Scr.w, image);
    x = size(image);
    baseRect = [0 0 x(2)*.8 x(1)*.8];
    inst.mainTask_miniFrame =  CenterRectOnPointd(baseRect,  Scr.wRect(3)/2, Scr.wRect(4)/2-Scr.wRect(4)/3);
    % Conditioning Mini
    imagePath = 'Instructions/G_Conditioning_mini.png';
    image = imread(imagePath);
    inst.conditioning_mini = Screen('MakeTexture', Scr.w, image);
    x = size(image);
    baseRect = [0 0 x(2)*.8 x(1)*.8];
    inst.mainTask_conditioningFrame =  CenterRectOnPointd(baseRect,  Scr.wRect(3)/2, Scr.wRect(4)/2-Scr.wRect(4)/3);
end
% Arrows Cond
imagePath = 'Instructions/KeysLR.png';
image = imread(imagePath);
inst.condTask_arrow = Screen('MakeTexture', Scr.w, image);

% Arrows Cond
imagePath = 'Instructions/KeysUD.png';
image = imread(imagePath);
inst.mainTask_arrow = Screen('MakeTexture', Scr.w, image);

end 
