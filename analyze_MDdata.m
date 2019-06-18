function [coherences,flags] = analyze_MDdata(block,inf,desired_precisions)

% this function analyzes a single subject's categorization accuracy data from the
% motion discrimination task, and chooses subject-specific coherence levels to use
% based on their psychometric function. the flags variable contains info
% that might serve as warnings about the subject (i.e. if their performance
% is really low, their psychometric function might not be well defined for
% certain values in desired_precisions).


allCoh = [];
allAcc = [];
for bl = 1:length(block)
    
    allCoh = [allCoh; [block(bl).trials.coherence]'];
    allAcc = [allAcc; [block(bl).trials.trialAcc]'];

end

coh_levels = unique(allCoh);
num_coh = length(coh_levels);
acc_Table = zeros(num_coh,3);

for coh_level_i = 1:num_coh
    
    acc_temp = allAcc(allCoh==coh_levels(coh_level_i));
    if coh_levels(coh_level_i) == 0
        acc_Table(coh_level_i,1) = 0.5;
    else
        acc_Table(coh_level_i,1) = coh_levels(coh_level_i);
    end
    
    acc_temp(isnan(acc_temp)) = 0;
    acc_Table(coh_level_i,2) = sum(acc_temp);
    acc_Table(coh_level_i,3) = length(acc_temp);
    
end
    
options             = struct;   % initialize as an empty struct
options.sigmoidName = 'weibull';   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'nAFC';   % choose 4-AFC as the paradigm of the experiment
% this sets the guessing rate to .25 and
% fits the rest of the parameters
options.expN        = 4;
psychometric_fit = psignifit(acc_Table,options);

% convert each desired precision value to a % correct value for use in the
% psychometric function

% this is how to go from desired accuracies to precisions
% precisions = log((3*desired_accur)./(1-desired_accur));

desired_accur = exp(desired_precisions)./(3+exp(desired_precisions));

coherences = zeros(length(desired_accur),1);
CIs = zeros(length(desired_accur),numel(psychometric_fit.options.confP),2);
for accur_i = 1:length(desired_accur)
    [coherences(accur_i),CIs(accur_i,:,:)] = getThreshold(psychometric_fit,desired_accur(accur_i));
end


flags = nan;


