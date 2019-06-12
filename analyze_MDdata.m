function [coherences,flags] = analyze_MDdata(block,inf,desired_precisions)
%ANALYZE_MDDATA This function takes a single-subject's results from the
% motion direction discrimination pre-calibration test in order to determine a psychometric function,
% from which an appropriate list of coherence values can be determined for
% the main experiment


fprintf('Fitting psychometric function for Subject No. %d...\n',inf.SubNo);
fprintf('Please wait...\n');

numBl = length(block);

all_data = [];

for bl = 1:numBl
    
    numTr = length(block(bl).trials);
    for tr = 1:numTr
        
        


end

