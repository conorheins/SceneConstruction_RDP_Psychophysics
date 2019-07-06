function [analyzed_trial] = trialEyeData_analyze(trial_struct)

eye_pos = trial_struct.pos(trial_struct.EXPLORE_START_t : trial_struct.EXPLORE_END_t , 3:4 );

num_samples = size(eye_pos,1);






end