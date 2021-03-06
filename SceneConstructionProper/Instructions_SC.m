function [inst] = Instructions_SC(inf,Scr)
if inf.language == 1                                  
     %% English
    imagePath = 'images/placeholder_instr1.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'images/placeholder_instr2.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'images/breakScreen.png';
    image = imread(imagePath);
    inst.breakScreen = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
   
else
    %% German
    
    imagePath = 'images/placeholder_instr1.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'images/placeholder_instr2.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'images/breakScreen.png';
    image = imread(imagePath);
    inst.breakScreen = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
end


end 
