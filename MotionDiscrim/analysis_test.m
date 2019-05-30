
coherence_levels = unique(dataArray(:,4));
numCohers = length(coherence_levels);

RT_stats    = zeros(numCohers,2);
Accur_stats = zeros(numCohers,2); 

RT_raw = zeros(size(dataArray,1)/numCohers,numCohers);
Accur_raw = zeros(size(dataArray,1)/numCohers,numCohers);

for coh_i = 1:length(coherence_levels)
    RTs_temp = dataArray(dataArray(:,4)==coherence_levels(coh_i),5); 
    RT_stats(coh_i,1) = nanmean(RTs_temp);
    RT_stats(coh_i,2) = nanstd(RTs_temp)./sqrt(sum(~isnan(RTs_temp)));
    
    RTs_temp(isnan(RTs_temp)) = 1.25; % max response time
    RT_raw(:,coh_i) = RTs_temp;
    
    accurs_temp = dataArray(dataArray(:,4)==coherence_levels(coh_i),6);
    Accur_stats(coh_i,1) = nanmean(accurs_temp);
    Accur_stats(coh_i,2) = nanstd(accurs_temp)./sqrt(sum(~isnan(accurs_temp)));
    
    accurs_temp(isnan(accurs_temp)) = 0; % default to incorrect, in case of no response
    Accur_raw(:,coh_i) = accurs_temp;
    
end

figure(1)
subplot(121)
coherence_levels(1) = 0.5;
semilogx(coherence_levels,Accur_stats(:,1),'b.','MarkerSize',25)  
subplot(122)
semilogx(coherence_levels,RT_stats(:,1),'b.','MarkerSize',25)

