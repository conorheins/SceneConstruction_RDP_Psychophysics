function [inst] = Instructions_RDP(inf,Scr)

if inf.language == 1                                  
     %% English
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions_E.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions2_E.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_afterPractice_E.png';
    image = imread(imagePath);
    inst.intro3 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/calibration_E.png';
    image = imread(imagePath);
    inst.calibration = Screen('MakeTexture',Scr.w,image);    % Make the image into a texture.
    
   
else
    %% German
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions_G.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions2_G.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_afterPractice_G.png';
    image = imread(imagePath);
    inst.intro3 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/calibration_G.png';
    image = imread(imagePath);
    inst.calibration = Screen('MakeTexture',Scr.w,image);    % Make the image into a texture.
    
    
end


end 


