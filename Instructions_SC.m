function [inst] = Instructions_SC(inf,Scr)
if inf.language == 1                                  
     %% English
    imagePath = 'SceneConstructionProper/images/placeholder_instr.png';
    image = imread(imagePath);
    inst.intro = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
   
else
    %% German

    imagePath = 'SceneConstructionProper/placeholder_instr.png';
    image = imread(imagePath);
    inst.intro = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.

end


end 
