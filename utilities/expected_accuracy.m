function [ eAcc ] = expected_accuracy(p1,p2)
% expected_accuracy: given two RDPs of different coherences (given by psychometric discrimiation accuracies p1 and p2), calculate the
% expected accuracy of categorizing the scene correctly (1 of 4 scenes,
% baseline guessing accuracy = 1/4 = 25%)
%   Detailed explanation goes here


accuracies = [1 0.5 0.5 0.25]; % these accuracies correspond to the situations when:
%                       1) both RDP motions are seen 100% certainly (so scene is
%                       100% guessable
%                       2) the first RDP motion is seen certainly, the second is not
%                       seen (leaving 50% guessing accuracy)
%                       3) the second RDP motion is seen certainly, the first is
%                       not seen (leaving 50% guessing accuracy)
%                       4) neither RDP motion is seen, leaving 25% chance accuracy 

perceptual_probs = [p1 * p2, p1*(1-p2), p2*(1-p1), (1-p1)*(1-p2)]; % the corresponding probabilities of the aforementioned perceptual possibilities, given the coherence levels

eAcc = sum(accuracies.*perceptual_probs); % this is basically the average of the accuracies, where the weights going into the average are those given by the probabilities of each perceptual event 
    
end

