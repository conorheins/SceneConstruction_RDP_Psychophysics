function CalDoc_Reward(Scr,inf)

sca;
ListenChar(0);
disp(['TOTAL REWARD EARNED: ' num2str(inf.Reward)]);
inputdlg('Enter your initials (Experimenter)');

% CHECK REWARD
Reward = inf.Reward;
moreMoney = menu('Was the money enough?', {'Yes','No'});
if moreMoney == 2, Reward = Reward + str2double(inputdlg('How much more? (euro)'));  end


% DATE
mydate=date;

% Experimenter
experimenter = inputdlg('Who was the experimenter? (Name)');

xlsinfo2write={mydate;...  % Date
    inf.experimentDur;...  % TIME
    inf.subNo;...          % Sub CODE
    num2str(Reward);...    % Reward with exp
    experimenter{1}}';     % Experimenter

%% SAVE
if ~inf.isTestMode
    cd(inf.rootSub);
    text = strcat(inf.subNo,'_', '_Probanden-Honorar', '_(', date,').mat');
    save(text, 'Reward');
    xlsfilename = strcat(inf.subNo,'_', '_Reward', '_(', date,').xls');
    xlswrite(xlsfilename,xlsinfo2write);
    
else
    cd(inf.rootTest);
    text = strcat('test',num2str(inf.subNo),'_', '_Probanden-Honorar', '_(', date,').mat');
    save(text,'Reward');
    xlsfilename = strcat('test',num2str(inf.subNo),'_', '_Reward', '_(', date,').xls');
    xlswrite(xlsfilename,xlsinfo2write);
end

% SAVE TO MAIN FILE
cd(Scr.rootDir);
xlsfilename = strcat('1_Cross_modal_2017_Vakhrushev.xls');
if exist(xlsfilename, 'file')
    [~,~,txt2] = xlsread(xlsfilename);
    xlsinfo2write=[txt2; xlsinfo2write];
else
    fprintf('\nCAUTION! NO *.XLS FILE\n');
end
xlswrite(xlsfilename,xlsinfo2write);
disp('*** EXPERIMENT FINISHED SUCCESSFULLY ***');
end 
