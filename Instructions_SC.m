function [inst] = Instructions_SC(inf,Scr)
if inf.language == 1                                  
     %% English
    imagePath = 'SceneConstructionProper/images/instr1_E.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/instr2_E.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/instr3_E.png';
    image = imread(imagePath);
    inst.intro3 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/instr4_E.png';
    image = imread(imagePath);
    inst.intro4 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/breakScreen_E.png';
    image = imread(imagePath);
    inst.breakScreen = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/calibration_E.png';
    image = imread(imagePath);
    inst.calibration = Screen('MakeTexture',Scr.w,image);    % Make the image into a texture.
    
    
   
else
    %% German
    
    imagePath = 'SceneConstructionProper/images/instr1_G.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/instr2_G.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/instr3_G.png';
    image = imread(imagePath);
    inst.intro3 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/breakScreen_G.png';
    image = imread(imagePath);
    inst.breakScreen = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'SceneConstructionProper/images/calibration_G.png';
    image = imread(imagePath);
    inst.calibration = Screen('MakeTexture',Scr.w,image);    % Make the image into a texture.
    
    
   
end


end 
