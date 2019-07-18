function [ binned_acc,binned_RT,x_axis ] = getLearningCurve(behav_blocks,bin_size)

num_tot_trials = 0;
for b_i = 1:length(behav_blocks)
    num_tot_trials = num_tot_trials + length(behav_blocks(b_i).trials);
end;

all_acc = zeros(num_tot_trials,1);
all_RT = zeros(num_tot_trials,1);

curr_idx = 1;
for b_i = 1:length(behav_blocks)
    all_acc(curr_idx:(curr_idx + length(behav_blocks(b_i).trials) - 1)) = ...
        [behav_blocks(b_i).trials.trialAcc]';
    all_RT(curr_idx:(curr_idx + length(behav_blocks(b_i).trials) - 1)) = ...
        [behav_blocks(b_i).trials.trialRT]';
    curr_idx = curr_idx + length(behav_blocks(b_i).trials);
end

bin_idx = 1:bin_size:num_tot_trials;
x_axis = [];

binned_acc = zeros(length(bin_idx),1);
binned_RT = zeros(length(bin_idx),1);
for b_i = 1:length(bin_idx)
    x_axis = [x_axis,mean([bin_idx(b_i),min(bin_idx(b_i)+bin_size-1,num_tot_trials)])];
    binned_acc(b_i) = nanmean(all_acc(bin_idx(b_i):min(bin_idx(b_i)+bin_size-1,num_tot_trials)));
    binned_RT(b_i) = nanmean(all_RT(bin_idx(b_i):min(bin_idx(b_i)+bin_size-1,num_tot_trials)));
end



end

