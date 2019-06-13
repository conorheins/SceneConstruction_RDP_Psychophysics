function [err, tmp] = edf2asc(fileName)
%% is it a folder or file?
if isdir(fileName)
    oldCD = cd;
    cd(fileName);
    folder = true;
elseif exist(fileName, 'file')
    folder = false;
else
    fprintf('\nYOU ARE IN WRONG DIRECTORY\n');
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~folder %% this is a file
prespectedName = [fileName(1:end-4),'.asc'];
    if ~exist(prespectedName, 'file')
        command = ['C:\toolbox\newEye\edf2asc.exe ', fileName];
        [err, tmp] = system(command, '-echo');%
    else
        fprintf('\nFILE ALREADY PROCESSED\n');
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%    
else %% this is a folder
    filenames = dir([fileName, filesep, '*.edf']); % workfolder
    allNames = {filenames.name}';
    %             folder = [filenames(1).folder];
    nrFiles = numel(allNames);
    
    isFail = false(nrFiles,1);
    for currentfile = 1:nrFiles
        try
            prespectedName = [allNames{currentfile}(1:end-4),'.asc'];
            if ~exist(prespectedName, 'file')
                edf2asc(allNames{currentfile}); % file
            end
            
            isFail(currentfile) = false;
            fprintf('Status: %d out of %d done. %s\n', currentfile, nrFiles,allNames{currentfile});
        catch
            isFail(currentfile) = true;
            fprintf('Status: %s convertion failed\n', allNames{currentfile});
        end
    end
    fprintf('\nStatus: FINISHED\n');
    cd(oldCD);
end
end