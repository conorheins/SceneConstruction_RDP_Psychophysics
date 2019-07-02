trialSTART_all = [];
eyeCheckOnset_all = [];
fixationOnset_all = [];
exploreOnset_all = [];
choiceOnset_all = [];
feedbackOnset_all = [];
trialEND_all = [];
for block_i = 1:3
    trialSTART_all = [trialSTART_all; [block(block_i).trials.trialSTART]'];
    eyeCheckOnset_all = [eyeCheckOnset_all; [block(block_i).trials.eyeCheckOnset]'];
    fixationOnset_all = [fixationOnset_all; [block(block_i).trials.fixationOnset]'];
    exploreOnset_all = [exploreOnset_all; [block(block_i).trials.exploreOnset]'];
    choiceOnset_all = [choiceOnset_all; [block(block_i).trials.choiceOnset]'];
    feedbackOnset_all = [feedbackOnset_all; [block(block_i).trials.feedbackOnset]'];
    trialEND_all = [trialEND_all; [block(block_i).trials.trialEND]'];
end