function [myVar, block] = SetUpTrialsMixed(Scr,inf, myVar)

% Levels for defining trials
% COHERENCE                   : 0%, 3.2%, 6.4%, 12.8%, 25.6%, 51.2% 
% RDP DIRECTION COMBINATIONS  : 0 degrees (DOWN), 90 degrees (RIGHT), 180 degrees (UP), 270 degrees (LEFT)
                               
%% Levels of variables

%Number of iterations and blocks
numBlocks          = 2;     % How many blocks do we have?

coherz = [0 3.2 6.4 12.8 25.6 51.2]';
dirz = [0 90 180 270]';

%% create block struct
block = struct;

for bl = 1:numBlocks
    tr = 0;
    for dir_i = 1:length(dirz)
        for coh_i = 1:length(coherz)   
            tr = tr + 1;
            block(bl).trials(tr).dotParams = createDotParams_struct(Scr.wRect,1,'centers',[myVar.centerX, myVar.centerY],'cohers',coherz(coh_i),'directions',dirz(dir_i),...
                'speeds',0.75,'apSizes',[200 200],'nDots',50,'lifetimes',10);
            block(bl).trials(tr).direction = dirz(dir_i);
            block(bl).trials(tr).coherence = coherz(coh_i);

        end
    end
end

%% STIMULI GENERATOR
for b = 1:numBlocks

    %-------------PreDefineVarisbles-------------%
    %Resp
    [block(b).trials.Accuracy]          = deal(nan);
    [block(b).trials.RT]                = deal(nan);
    [block(b).trials.keyPressed]        = deal(nan);
    [block(b).trials.error]             = deal(0);
    %Stim&Struct
    [block(b).trials.trialNum]          = deal(nan);
%     [block(b).trials.BlNumber]          = deal(nan);
    [block(b).trials.Pp]                = deal(inf.subNo);
%     [block(b).trials.expMode]           = deal(inf.expMode);
%     [block(b).trials.Reward]            = deal(nan);
%     [block(b).trials.BlType]            = deal(nan);
%     [block(b).trials.PSE]               = deal(nan);
    %Timing
    [block(b).trials.trialSTART]        = deal(nan);
    [block(b).trials.eyeCheckOnset]     = deal(nan);
    [block(b).trials.fixationOnset]     = deal(nan);
%     [block(b).trials.soundOnset]        = deal(nan);
%     [block(b).trials.targetOnset]       = deal(nan);
    [block(b).trials.endRT]             = deal(nan);
    [block(b).trials.RespOnsetFlip]     = deal(nan);
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