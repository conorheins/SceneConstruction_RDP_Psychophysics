function [myVar, block] = SetUpTrialsMixed(Scr,inf, myVar)

% Levels for defining trials
% RDP LOCATION                : Upper left (Loc 1), Lower left (Loc 2), Upper right (Loc 3), Lower Right (Loc 4) 
% COHERENCE                   : 6 levels: 0%, 12.8%, 25.6%, 36%, 51.2%, 100% 
% RDP DIRECTION COMBINATIONS  : 180 degrees & 90 degrees ('UP RIGHT'); 90 degrees
%                               & 0 degrees ('RIGHT DOWN'); 0 degrees & 270 degrees
%                               ('DOWN LEFT'); 270 degrees & 90 degreess ('LEFT UP')
                               
%% Levels of variables

%Number of iterations and blocks
numBlocks          = inf.numBlocks;     % How many blocks do we have?

coherz = [0 12.8 25.6 36 51.2 100]';

factor.RDMcohers      = 2; % the number of values that a given RDP can take, per level/factor
factor.scenes         = 2; % the number of values that a given RDP can take, per level/factor

numQuads = size(myVar.RDMRects,2);

config_counter = 0;
for quad1 = 1:numQuads
    for quad2 = 1:numQuads
        if quad1 ~= quad2
            config_counter = config_counter + 1;
            RDM.configs(config_counter).x = [myVar.centers(:,quad1)'; myVar.centers(:,quad2)']; % transpose to prepare it for input to createDotParams_struct
        end
    end
end

factor.RDMconfigs = config_counter;

RDM.cohers = zeros(length(coherz),factor.RDMcohers); 
for coh_i = 1:length(coherz)
    RDM.cohers(coh_i,:) = [coherz(coh_i) coherz(coh_i)];
end
    
RDM.scenes = zeros(4,factor.scenes); 
RDM.scenes(1,:)    = [180 90]; % UP RIGHT
RDM.scenes(2,:)    = [90 0];   % RIGHT DOWN
RDM.scenes(3,:)    = [0 270];  % DOWN LEFT
RDM.scenes(4,:)    = [270 180];% LEFT UP

%% create block struct
block = struct;

numPatterns = size(RDM.scenes,2);

for bl = 1:numBlocks
    tr = 0;
    for config_i = 1:factor.RDMconfigs
        for coh_i = 1:length(coherz)
            for scene_i = 1:size(RDM.scenes,1)
                tr = tr + 1;
                block(bl).trials(tr).dotParams = createDotParams_struct(Scr.wRect,numPatterns,'centers',RDM.configs(config_i).x,'cohers',RDM.cohers(coh_i,:),'directions',RDM.scenes(scene_i,:),...
                    'speeds',repmat(myVar.speed,1,numPatterns),'apSizes',repmat(myVar.apSize,numPatterns,1),'nDots',repmat(myVar.nDots,1,numPatterns),...
                    'lifetimes',repmat(myVar.lifetime,1,numPatterns),'dotSizes',repmat(myVar.dotSize,1,numPatterns));
                block(bl).trials(tr).scene_dirs= RDM.scenes(scene_i);
                block(bl).trials(tr).scene_ID  = scene_i;
                block(bl).trials(tr).config = config_i;
                block(bl).trials(tr).coher = coherz(coh_i);
            end
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
    [block(b).trials.Pp]                = deal(inf.subNo);
    [block(b).trials.Reward]            = deal(nan);
    [block(b).trials.BlType]            = deal(nan);
    %Timing
    [block(b).trials.trialSTART]        = deal(nan);
    [block(b).trials.eyeCheckOnset]     = deal(nan);
    [block(b).trials.fixationOnset]     = deal(nan);
    [block(b).trials.endRT]             = deal(nan);
    [block(b).trials.RespOnsetFlip]     = deal(nan);
    [block(b).trials.feedbackOnset]     = deal(nan);
    [block(b).trials.trialEND]          = deal(nan);
    
    randomOrder = randperm(size(block(b).trials,2)); % create random order from that.
    block(b).trials = block(b).trials(randomOrder);

%     block(b).trials = block(b).trials(1:10); % for testing purposes
    
    % [~,randomOrder] = CheckShuffle([block(b).trials.conSort],2); %Advanced check by Adam
    % block(b).trials = block(b).trials(randomOrder);
    
   
end
% block(length(block)+1).trials = block(4).trials;    % Block before error block Extra Conditioning
% block(length(block)+1).trials = block(b).trials(1); % Create Extra block to store error trials
% block(length(block)).trials(1) = [];
end