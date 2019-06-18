function [inst] = Instructions_RDP(inf,Scr)

if inf.language == 1                                  
     %% English
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions_new_gray1.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions_new_gray2.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_afterPractice.png';
    image = imread(imagePath);
    inst.intro3 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    
   
else
    %% German

    imagePath = 'MotionDiscrim/Instructions/RDP_instructions_new_gray1.png';
    image = imread(imagePath);
    inst.intro1 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_instructions_new_gray2.png';
    image = imread(imagePath);
    inst.intro2 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    
    imagePath = 'MotionDiscrim/Instructions/RDP_afterPractice.png';
    image = imread(imagePath);
    inst.intro3 = Screen('MakeTexture', Scr.w, image);       % Make the image into a texture.
    

end


end 


