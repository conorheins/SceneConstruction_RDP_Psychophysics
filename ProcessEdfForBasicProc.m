% function ProcessEDF(block)
% edition 11.12
clearvars
start_path = fullfile('C:\');
myPath = uigetdir(start_path);
cd(myPath);
SubFold = cd;
% filePattern = fullfile(SubFold, '*.*');
folders = dir;
if 2 == exist('doneFileEYE.mat','file')
%     load('allData'); % problem here
    load('doneFileEYE');
    doneFileInx = length(doneFileEYE)+1;
else
    allData = [];
    doneFileEYE = struct; 
    doneFileEYE.Pp = [];
    doneFileInx = 1;
end

for fls = 3:length(folders) % for each folder (Participant)
    if folders(fls).isdir && ~any(strcmp({doneFileEYE.Pp}, folders(fls).name)) && all(~strcmp(folders(fls).name,{'99999999','Studies'})) %&& ~isnan(str2double(folders(fls).name)) % It must be new folder
        inFolder = [SubFold filesep folders(fls).name];
        load([inFolder filesep strcat(folders(fls).name,'_', '_allData','.mat')]); % load BLOCKS
        % allBlocks = [myVar.strGabPre myVar.strGabPost];
        allBlocks = 1:length(block);
        bloPost = struct; bloPost = block(2).trials;
        for blo = 3:length(block)
            if ismember(block(blo).trials(1).BlPrePost,[1,2]), bloPost = [bloPost block(blo).trials]; end
        end
        meanRT = nanmean([bloPost.RT]); sdRT = nanstd([bloPost.RT]);
        
        files = dir(inFolder);
        for targFiles = 3:length(files)                                             % all files (1,2 is navigation)
            for targBlocks = 1:length(allBlocks)                                    % all blocks
                if strcmp(files(targFiles).name,...
                        [folders(fls).name '_Block_' num2str(allBlocks(targBlocks)) '.edf'])
                    %% Extract Eye data
                    name = [inFolder filesep files(targFiles).name];                % locate directory
                    tempASC = readEDFASC(name,1,1);                                 % Process current block
                    
                    %% Combine structures
                    temToStore = block(allBlocks(targBlocks)).trials;               % PREPARE block structure
                    tempComb = catstruct(temToStore,tempASC);                       % COMBINE EYE and BLOCK
                    tempComb([tempComb.error]==5)=[];                               % Error 5 - no eye data, remove                    
                    
                    %% Remove extra fields
                    if isfield(tempComb,'CAL_m'),       tempComb = rmfield(tempComb,'CAL_m');       tempComb = rmfield(tempComb,'CAL_t');end                    
                    if isfield(tempComb,'SACCADE_m'),   tempComb = rmfield(tempComb,'SACCADE_m');   tempComb = rmfield(tempComb,'SACCADE_t'); end
                    if isfield(tempComb,'VALIDATE_t'),  tempComb = rmfield(tempComb,'VALIDATE_t');  tempComb = rmfield(tempComb,'VALIDATE_m');end
                    if isfield(tempComb,'DRIFTCORRECT_m'),tempComb = rmfield(tempComb,'DRIFTCORRECT_m'); tempComb = rmfield(tempComb,'DRIFTCORRECT_t');end
                    
                    %% SELECT FIXATION and TARGET
                    selectionFixation = arrayfun(@(x)...                                        %Prepare FIXATION only
                        tempComb(x).pos(tempComb(x).FIXATION_t+1:tempComb(x).TARGET_t,:),...
                        1:length(tempComb), 'UniformOutput',false);
                    selection = arrayfun(@(x)...                                                %Prepare TARGET only
                        tempComb(x).pos(tempComb(x).TARGET_t+1:tempComb(x).TARGET_OFF_t,:),...
                        1:length(tempComb), 'UniformOutput',false);
                    
                    %% ESTIMATE MOVEMENT
                    maxDistSample = arrayfun(@(x) abs(max(selection{x}(:,2))-myVar.centerX),... % Screen CENTER
                        1:length(selection), 'UniformOutput', 0);
                    dist = arrayfun(@(x) ...                                                    % FIXATION BASELINE
                        sqrt((nanmean(selection{x}(:,2)) - nanmean(selectionFixation{x}(end-198:end,2)))^2 +...
                             (nanmean(selection{x}(:,3)) - nanmean(selectionFixation{x}(end-198:end,3)))^2),...
                        1:length(selection), 'UniformOutput', 0);
                    %% Combine structures
                    for i=1:length(selection)
                        tempComb(i).posSel  = selection{i};
                        tempComb(i).maxDist = maxDistSample{i}/Scr.pixelsperdegree;
                        tempComb(i).badRT   = bloPost(i).RT> (meanRT+6*sdRT)| bloPost(i).RT<(meanRT-6*sdRT) ;
                        tempComb(i).dist    = dist{i}/Scr.pixelsperdegree;
                    end
                    
                    %% Combine blocks
                    block(allBlocks(targBlocks)).trials = tempComb;
%                     if 1 == exist('allData','var'), allData = [allData tempComb]; else allData = tempComb; end % STRUC with all Pp
                end
            end
        end
        doneFileEYE(doneFileInx).Pp = folders(fls).name;
        doneFileEYE(doneFileInx).path = inFolder;
        doneFileEYE(doneFileInx).date = date;
        save([inFolder filesep strcat(folders(fls).name,'_', '_allDataEyE','.mat')],'block','Scr','myVar','inf');
        save('doneFileEYE','doneFileEYE');
        doneFileInx = doneFileInx+1;
    end
%     save('allData','allData','doneFileEYE','Scr','myVar','inf','-v7.3');
end
disp('PROCESSING IS COMPLETE');

% % cont = menu('continue?','Yes','No');
% % if cont
%
% %     load('allData'); % problem here
% allData([allData.error]==1)=[]; % cleanUp from error trials
% emptyIndex = find(arrayfun(@(allData) isempty(allData.RECCFG_t),allData));
% allData(emptyIndex)=[];
%
% selectionFixation = arrayfun(@(x)...                Select only inportant part from eye
%     allData(x).pos(allData(x).FIXATION_t+1:allData(x).TARGET_t,:),...
%     1:length(allData), 'UniformOutput',false);
%
% selection = arrayfun(@(x)...                Select only inportant part from eye
%     allData(x).pos(allData(x).TARGET_t+1:allData(x).RESPONSE_t,:),...
%     1:length(allData), 'UniformOutput',false);
%
% maxDistSample = arrayfun(@(x) abs(max(selection{x}(:,2))-myVar.centerX), 1:length(selection), 'UniformOutput', 0);
%
% dist = arrayfun(@(x) ...
%     sqrt((nanmean(selection{x}(:,2)) - nanmean(selectionFixation{x}(end-198:end,2)))^2 +...
%     (nanmean(selection{x}(:,3)) - nanmean(selectionFixation{x}(end-198:end,3)))^2),...
%     1:length(selection), 'UniformOutput', 0);
% for i=1:length(selection)
%     allData(i).posSel = selection{i};
%     allData(i).maxDist = maxDistSample{i}/Scr.pixelsperdegree;
%     allData(i).dist = dist{i}/Scr.pixelsperdegree;
% end % put it back to dataSet
%
%
%
% %     dest(:,1) = arrayfun(@(y) nanmean(arrayfun(@(x) selection{x}(y,3),1:length(selection))),1:249)'; % calculate means for each timepoint
% %     dest(:,2) = arrayfun(@(y)  nanstd(arrayfun(@(x) selection{x}(y,3),1:length(selection))),1:249)'; % calculate    Sd for each timepoint
% %
% %     maxDistSample = arrayfun(@(x) abs(max(selection{x}(:,2))-myVar.centerX), 1:length(selection))'./Scr.pixelsperdegree;
% %     maxDistanceList =   [maxDistSample'; [allData.Accuracy]]';   % Get the accuracy of this trial and add both values into the global list
% save('allData','allData','doneFileEYE','Scr','myVar','inf');
% % end