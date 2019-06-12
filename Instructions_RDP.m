function [inst] = Instructions_RDP(inf,Scr)

if inf.language == 1                                  
     %% English
    imagePath = 'Instructions/RDP_instructions_new.png';
    image = imread(imagePath);
    inst.intro = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
   
else
    %% German

    imagePath = 'Instructions/RDP_instructions.png';
    image = imread(imagePath);
    inst.intro = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.

end


end 


