function [ eAcc ] = expected_accuracy_bayes(p1,p2,prior,likelihood)
% expected_accuracy: given two RDPs of different coherences (given by psychometric discrimiation accuracies p1 and p2), calculate the
% expected accuracy of categorizing the scene correctly using a Bayesian belief update (1 of 4 scenes,
% baseline guessing accuracy = 1/4 = 25%)

%likelihood
if or(nargin < 4,~exist('likelihood','var'))
    scene1 = [1 1 0 0]';
    A = [scene1 circshift(scene1,1) circshift(scene1,2) circshift(scene1,3)];
    A = A./sum(A + exp(-16),1);
end

%prior
if or(nargin < 3,~exist('prior','var'))
    og_prior = ones(4,1);
    og_prior = og_prior./sum(og_prior);
end

% marginal likelihood of outcomes (determined by given discrimination
% accuracies of the two RDPs, p1 and p2)
s1 = [p1 ((1-p1)./3)*ones(1,3)]';
s2 = circshift([p2 ((1-p2)./3)*ones(1,3)]',1); 

% first case, when you see s1 first
first_density = A'*s1; % obtain empirical prior by passing outcomes through likelihood for the first-seen RDP (s1)

emp_prior = exp(log(first_density+exp(-16)) + log(og_prior + exp(-16))); % update empirical prior with original prior

second_density = A'*s2; % obtain empirical prior by passing outcomes through likelihood for the second RDP
second_density = exp(log(emp_prior+exp(-16)) + log(second_density+exp(-16))); % combine empirical prior with 
posterior1 = second_density./sum(second_density);

% second case, when you see s2 first
first_density = A'*s2; % obtain empirical prior by passing outcomes through likelihood for the first-seen RDP (s2)

emp_prior = exp(log(first_density+exp(-16)) + log(og_prior + exp(-16))); % empirical prior + old prior

second_density = A'*s1; % obtain empirical prior by passing outcomes through likelihood for the second RDP
second_density = exp(log(emp_prior+exp(-16)) + log(second_density+exp(-16))); % combine them
posterior2 = second_density./sum(second_density);

% debugging
% if any(abs(posterior1 - posterior2) > 1e-6)
%     fprintf('P1 = %.2f, P2 = %.2f, Not equal\n',p1,p2);
% end

average = mean([posterior1,posterior2],2);

eAcc = average(1);















end



