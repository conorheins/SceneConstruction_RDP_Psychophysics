function [myVar, block] = SetUpTrialsMixed_RDP(Scr,inf, myVar)

% Levels for defining trials
% COHERENCE                   : 0%, 12.8%, 25.6%, 36%, 51.2%, 100%
% RDP DIRECTION COMBINATIONS  : 0 degrees (DOWN), 90 degrees (RIGHT), 180 degrees (UP), 270 degrees (LEFT)
                               
%% Levels of variables

%Number of iterations and blocks
numBlocks          = inf.numBlocks_MD;     % How many blocks do we have?

coherz = [0 12.8 25.6 36 51.2 100]';
dirz = [0 90 180 270]';

%% create block struct
block = struct;

numPatterns = 1; % for this task, only a single RDP displayed in the center

for bl = 1:numBlocks
    tr = 0;
    for dir_i = 1:length(dirz)
        for coh_i = 1:length(coherz)   
            tr = tr + 1;
            block(bl).trials(tr).dotParams = createDotParams_struct(Scr.wRect,numPatterns,'centers',[myVar.centerX, myVar.centerY],'cohers',coherz(coh_i),'directions',dirz(dir_i),...
                'speeds',repmat(myVar.speed,1,numPatterns),'apSizes',repmat(myVar.apSize,numPatterns,1),'nDots',repmat(myVar.nDots,1,numPatterns),...
                'lifetimes',repmat(myVar.lifetime,1,numPatterns),'dotSizes',repmat(myVar.dotSize,1,numPatterns));
            block(bl).trials(tr).direction = dirz(dir_i);
            block(bl).trials(tr).coherence = coherz(coh_i);

        end
    end
end

%% STIMULI GENERATOR
for b = 1:numBlocks

    %-------------PreDefineVarisbles-------------%
    %Resp
    [block(b).trials.trialAcc]          = deal(nan);
    [block(b).trials.trialRT]           = deal(nan);
    [block(b).trials.dirResponse]       = deal(nan);
    
    %Stim&Struct
    [block(b).trials.Pp]                = deal(inf.subNo);

    %Timing
    [block(b).trials.trialSTART]        = deal(nan);
    [block(b).trials.eyeCheckOnset]     = deal(nan);
    [block(b).trials.fixationOnset]     = deal(nan);
    [block(b).trials.accumOnset]        = deal(nan);
    [block(b).trials.feedbackOnset]     = deal(nan);
    [block(b).trials.trialEND]          = deal(nan);
    
    randomOrder = randperm(size(block(b).trials,2)); % create random order from that.
    block(b).trials = block(b).trials(randomOrder);
    
    % [~,randomOrder] = CheckShuffle([block(b).trials.conSort],2); %Advanced check by Adam
    % block(b).trials = block(b).trials(randomOrder);
   
end
% block(length(block)+1).trials = block(4).trials;    % Block before error block Extra Conditioning
% block(length(block)+1).trials = block(b).trials(1); % Create Extra block to store error trials
% block(length(block)).trials(1) = [];
end