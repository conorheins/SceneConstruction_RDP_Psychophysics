function [inf] = GetSubInfo(inf)

if inf.isTestMode % No name provided yet
    inf.subNo               = 1; % call this participant test1, latter we will assign proper number
    inf.dummy               = menu('Dummy mode? (without EyeTraking)', {'Yes','No'});
    inf.isFullScreen        = menu('Display full screen?', {'Yes','No'});
    inf.language            = menu('What language?', {'English','German'});
    
    % Text questions
    prompt                  ={'How many blocks would you like to run?'};
    title                   ='Number of blocks to complete';  % The main title of input dialog interface.
    answer                  =inputdlg(prompt,title);
    
    % Gather answers into variables
    inf.numBlocks                 = str2double(answer{1});
    
else 
    inf.dummy               = menu('Dummy mode? (without EyeTraking)', {'Yes','No'});
    inf.isFullScreen        = menu('Display full screen?', {'Yes','No'});
    inf.language            = menu('What language?', {'English','German'});
    
    % demographics 
    inf.gender              = menu('What is your gender.', {'Male','Female'});
    inf.primaryHand         = menu('What is your primary hand?', {'Left','Right'});
    inf.vision              = menu('Do you wear glasses?', {'Yes','No'});
    
    % Text questions
    prompt                  ={'How old are you?:'};
    title                   ='participant information';  % The main title of input dialog interface.
    answer                  =inputdlg(prompt,title);
    
    % Gather answers into variables
    inf.age                 = str2double(answer{1});
    
    % Text questions
    prompt                  ={'How many blocks would you like to run?'};
    title                   ='Number of blocks to complete';  % The main title of input dialog interface.
    answer                  =inputdlg(prompt,title);
    
    % Gather answers into variables
    inf.numBlocks                 = str2double(answer{1});
    
end

inf.dummy = abs(inf.dummy - 2);
inf.isFullScreen = abs(inf.isFullScreen-2); % to make it 0 or 1. 1 if it is true

end
