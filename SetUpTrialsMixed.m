function [myVar, block] = SetUpTrialsMixed(inf, myVar)

% set all variables for running the blocks.
% To match the study
%
% RDP LOCATION      : Upper left (Loc 1), Lower left (Loc 2), Upper right (Loc 3), Lower Right (Loc 4) 
% RDP DIRECTION     : 0 degrees ('UP'), 90 degrees ('RIGHT'), 180 degrees
%                     ('DOWN'), 270 degrees ('LEFT')
% COHERENCE         : 5% (Low), 25% (Low-Medium), 50% (Medium), 75% (Medium High) 

%% Levels of variables
%number of trials will be factor1*factor2*... * iterations


factor.RDMcohers      = 2;
factor.RDMdirections  = 2;

%Number of iterations and blocks
factor.block          = 5;     % How many blocks do we have?

numQuads = size(myVar.centers,2);

config_counter = 1;
for quad1 = 1:numQuads
    for quad2 = 1:numQuads
        if quad1 ~= quad2
            RDM.configs(config_counter).x = [myVar.centers(:,quad1)'; myVar.centers(:,quad2)']; % transpose to prepare it for input to createDotParams_struct
            config_counter = config_counter + 1;
        end
    end
end

factor.RDMconfigs = config_counter;


RDM.cohers(1).x    = [5 5];
RDM.cohers(2).x    = [25 25];
RDM.cohers(3).x    = [50 50];
RDM.cohers(4).x    = [75 75];

RDM.directions(1).x    = [0 90];
RDM.directions(2).x    = [90 180];
RDM.directions(3).x    = [180 270];
RDM.directions(4).x    = [270 0];

%% create block struct
block = struct;

for bl = 1:factor.block
    tr = 0;
    for config_i = 1:factor.RDMconfigs
%         conSort = 1;
        for coh_i = 1:factor.RDMcohers
            for scene_i = 1:factor.RDMdirections
                tr = tr + 1;
                block(bl).trials(tr).dotParams = createDotParams_struct(Scr.wRect,numPatterns,'centers',RDM.configs(config_i).x,'cohers',RDM.cohers(coh_i).x,'directions',RDM.directions(scene_i).x,...
                    'speeds',[2 2],'apSizes',[200 200; 200 200],'nDots',[50 50]);
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