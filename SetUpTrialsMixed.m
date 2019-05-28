function [myVar, block] = SetUpTrialsMixed(Scr,inf, myVar)

% set all variables for running the blocks.
% To match the study
%
% RDP LOCATION                : Upper left (Loc 1), Lower left (Loc 2), Upper right (Loc 3), Lower Right (Loc 4) 
% COHERENCE                   : 5% (Low), 25% (Low-Medium), 50% (Medium-High), 75% (High) 
% RDP DIRECTION COMBINATIONS  : 0 degrees & 90 degrees ('UP RIGHT'); 90 degrees
%                               & 180 degrees ('RIGHT DOWN'); 180 degrees & 270 degrees
%                               ('DOWN LEFT'); 270 degrees & 0 degreess ('LEFT UP')
                               
%% Levels of variables
%number of trials will be factor1*factor2*... * iterations

numCoherLevels = 4;
numScenes      = 4;

factor.RDMcohers      = 2; % the number of values that a given RDP can take, per level/factor
factor.scenes         = 2; % the number of values that a given RDP can take, per level/factor

%Number of iterations and blocks
factor.block          = 5;     % How many blocks do we have?

numQuads = size(myVar.centers,2);

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

RDM.cohers = zeros(numCoherLevels,factor.RDMcohers); 
RDM.cohers(1,:)    = [5 5];
RDM.cohers(2,:)    = [25 25];
RDM.cohers(3,:)    = [50 50];
RDM.cohers(4,:)    = [75 75];

RDM.scenes = zeros(numScenes,factor.scenes); 
RDM.scenes(1,:)    = [0 90];
RDM.scenes(2,:)    = [90 180];
RDM.scenes(3,:)    = [180 270];
RDM.scenes(4,:)    = [270 0];

numPatterns = size(RDM.scenes,2);

%% create block struct
block = struct;

for bl = 1:factor.block
    tr = 0;
    for config_i = 1:factor.RDMconfigs
%         conSort = 1;
        for coh_i = 1:factor.RDMcohers
            for scene_i = 1:factor.scenes
                tr = tr + 1;
                block(bl).trials(tr).dotParams = createDotParams_struct(Scr.wRect,numPatterns,'centers',RDM.configs(config_i).x,'cohers',RDM.cohers(coh_i,:),'directions',RDM.scenes(scene_i,:),...
                    'speeds',[2 2],'apSizes',[200 200; 200 200],'nDots',[50 50]);
                block(bl).trials(tr).scene  = scene_i;
                block(bl).trials(tr).config = config_i;
%                 conSort = conSort + 1;
%                 block(b).trials(tr).conSort = conSort;
            end
        end
    end
end

%% STIMULI GENERATOR
for b = 1:factor.block

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