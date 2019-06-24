function [coherences,flag] = analyze_MDdata(block,desired_precisions,starting_bl)

% this function analyzes a single subject's categorization accuracy data from the
% motion discrimination task, and chooses subject-specific coherence levels to use
% based on their psychometric function. the flags variable contains info
% that might serve as warnings about the subject (i.e. if their performance
% is really low, their psychometric function might not be well defined for
% certain values in desired_precisions).


allCoh = [];
allAcc = [];
for bl = starting_bl:length(block)
    
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
% precisions = log((3*desired_accur)./((1-desired_accur)+exp(-16)));

% this is how to go from desired precisions to the corresponding probability of 
% choosing correctly in a 4-AFC task
desired_accur = exp(desired_precisions)./(3+exp(desired_precisions));

coherences = zeros(length(desired_accur),1);
CIs = zeros(length(desired_accur),numel(psychometric_fit.options.confP),2);
for accur_i = 1:length(desired_accur)
    [coherences(accur_i),CIs(accur_i,:,:)] = getThreshold(psychometric_fit,desired_accur(accur_i));
end

flag = false(length(desired_accur),1); % these are true/false flags that indicate whether the confidence intervals of the fit for each coherence
% value threshold are too large (e.g. if the width of the interval is
% larger than twice the difference between successive coherence values
for accur_i = 1:length(desired_accur)
    
    if accur_i == 1
        if abs(diff(squeeze(CIs(accur_i,1,:)))) > 2*(coherences(accur_i+1) - coherences(accur_i))
            flag(accur_i) = true;
        end 
    elseif accur_i == length(desired_accur)
        if abs(diff(squeeze(CIs(accur_i,1,:)))) > 2*(coherences(accur_i) - coherences(accur_i-1))
            flag(accur_i) = true;
        end 
    else
        if or(abs(diff(squeeze(CIs(accur_i,1,:)))) > 2 *(coherences(accur_i)-coherences(accur_i-1)),...
                diff(squeeze(CIs(accur_i,1,:))) > 2 *(coherences(accur_i+1)-coherences(accur_i)))
            flag(accur_i) = true;
        end
    end
    
end
    


