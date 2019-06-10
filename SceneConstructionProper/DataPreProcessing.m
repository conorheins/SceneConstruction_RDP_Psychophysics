function [inf] = DataPreProcessing(inf,myVar,block)

%% GENERAL REWARD AMOUNT

% Important variables
inf.experimentDur   =     ceil((inf.experimentEnd(4)-inf.experimentStart(4))*60+ inf.experimentEnd(5)-inf.experimentStart(5));   % duration of the experiment in min.
inf.accuracy        =     nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.error]==0).Accuracy]), [myVar.strGabPre, myVar.strGabPost]));            % accuracy from 0 to 1
inf.Reward          =     round(nansum(arrayfun(@(x) nansum([block(x).trials.Reward]), 1:length(block)))*0.01);                % Reward transformed
if inf.Reward<8.5,inf.Reward= 8.5; elseif inf.Reward>35, inf.Reward= 35; end % in case only 50% is correct

% dPrime for entire experiment
h                   =     nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.gaborOri]== 1&[block(x).trials.error]==0).Accuracy]), [myVar.strGabPre, myVar.strGabPost])); % Correct   responses on RIGHT orientation
fA                  = 1 - nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.gaborOri]==-1&[block(x).trials.error]==0).Accuracy]), [myVar.strGabPre, myVar.strGabPost])); % INcorrect responses on LEFT  orientation
[inf.dp]            =     Dprime2(h,fA);

% Direct dPrime before/after conditioning
h                   =     nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.gaborOri]== 1&[block(x).trials.error]==0).Accuracy]), myVar.strGabPre)); % Correct   responses on RIGHT orientation
fA                  = 1 - nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.gaborOri]==-1&[block(x).trials.error]==0).Accuracy]), myVar.strGabPre)); % INcorrect responses on LEFT  orientation
[inf.dpPre]         =     Dprime2(h,fA);
h                   =     nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.gaborOri]== 1&[block(x).trials.error]==0).Accuracy]), myVar.strGabPost)); % Correct   responses on RIGHT orientation
fA                  = 1 - nanmean(arrayfun(@(x) nanmean([block(x).trials([block(x).trials.gaborOri]==-1&[block(x).trials.error]==0).Accuracy]), myVar.strGabPost)); % INcorrect responses on LEFT  orientation
[inf.dpPost]        =    Dprime2(h,fA);


%% LATENCY: SCREEN FLIP SOUND SYNCH
fprintf('\nTime errors of FLIP duration(ms). Good values < 0.01\n\t\t\tFlipErr\tSoundFlip\n');
for i = [myVar.strGabPre, myVar.strGabPost]
    flipErr = nanmean(arrayfun(@(x) nanmean(([block(i).trials(x).RespOnsetFlip]-   [block(i).trials(x).targetOnset])*1000-250), find([block(i).trials.error]==0)));
    SoundErr= nanmean(arrayfun(@(x) nanmean(([block(i).trials(x).targetOnset]-     [block(i).trials(x).soundOnset])*1000-8.2), find([block(i).trials.error]==0)));  
    fprintf('Block_%d:\t%1.3f\t%1.3f\n',i,flipErr,SoundErr);  
    % Little explanation: Flip's accuracy measured by comparing duration
    % of feedback circle in blocks with Gabor. Sound synchronization
    % measured by comparing sound and target onsets. The sound is EARLIER
    % because of the RAMP on 3.4 ms.
end


%% GENERATE SIMPLE STATISTIC
x1 = {'N' 'BOX' 'SOUND'};
x2 = {'NO' 'Low' 'High'};
x3 = {'N' 'Same' 'Diff'};
%inf.prelimResPost = struct;
PrePostNames = {'StatPreCond', 'StatPostCond'};
for PrePost = 1:length(PrePostNames)
    if PrePost == 1
        blockP = block(myVar.strGabPre(1)).trials;
        for i = myVar.strGabPre(2:end)
            blockP = [blockP block(i).trials];
        end
    else
        blockP = block(myVar.strGabPost(1)).trials;
        for i = myVar.strGabPost(2:end)
            blockP = [blockP block(i).trials];
        end
    end
    i= 1;
    for RelPos = 2:length(x3)
        for cond = 2:length(x1)
            for rew = 2:length(x2)
                i = i+1;
                
                % Name of variables
                inf.(PrePostNames{PrePost})(i).cond       = x1(cond);
                inf.(PrePostNames{PrePost})(i).rew        = x2(rew);
                inf.(PrePostNames{PrePost})(i).RelPos     = x3(RelPos);
                
                % VARIABLES
                inf.(PrePostNames{PrePost})(i).TrNum      =          sum([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0);
                inf.(PrePostNames{PrePost})(i).RT         = nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).RT]);
                inf.(PrePostNames{PrePost})(i).Acc        = nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).Accuracy]);
                inf.(PrePostNames{PrePost})(i).RTsd       =  std([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).RT])...
                    /sqrt(length([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).RT]));
                h                                      =    nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0&[blockP.gaborOri]== 1).Accuracy]);% Correct   responses on RIGHT orientation
                fA                                     =1 - nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0&[blockP.gaborOri]==-1).Accuracy]); % INcorrect responses on LEFT  orientation
                [inf.(PrePostNames{PrePost})(i).dPrime]=    Dprime2(h,fA);
            end
        end
    end
    
    % NEUTRAL CONDITION (STORE VARS. AND ASSIGN VALUES)
    i= 1; cond = 1; rew = 1; RelPos = 1;
    inf.(PrePostNames{PrePost})(i).cond       = x1(cond);
    inf.(PrePostNames{PrePost})(i).rew        = x2(rew);
    inf.(PrePostNames{PrePost})(i).RelPos     = x3(RelPos);
    
    inf.(PrePostNames{PrePost})(i).TrNum      =          sum([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0);
    inf.(PrePostNames{PrePost})(i).RT         = nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).RT]);
    inf.(PrePostNames{PrePost})(i).Acc        = nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).Accuracy]);
    inf.(PrePostNames{PrePost})(i).RTsd       =  std([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).RT])...
        /sqrt(length([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0).RT]));
    h                                      =    nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0&[blockP.gaborOri]== 1).Accuracy]);% Correct   responses on RIGHT orientation
    fA                                     =1 - nanmean([blockP([blockP.condition]==cond-1&[blockP.StimValue]==rew-1&[blockP.relativePos]==RelPos-1&[blockP.error]==0&[blockP.gaborOri]==-1).Accuracy]); % INcorrect responses on LEFT  orientation
    [inf.(PrePostNames{PrePost})(i).dPrime]=    Dprime2(h,fA);
end


%% TRANSFORM DATA TO PLOT IT
PlotNames = {'PlotPreCond', 'PlotPostCond'};
for PrePost = 1:length(PlotNames)
    for re = 1:2
        inf.(PlotNames{PrePost}).Acc(re,:)   = [inf.(PrePostNames{PrePost})(strncmp([inf.(PrePostNames{PrePost}).rew],x2(re+1),4)).Acc];
        %         inf.transf.Accsd(re,:) = [inf.prelimResPost(strncmp([inf.prelimResPost.rew],x2(re+1),4)).Accsd];
        inf.(PlotNames{PrePost}).RT(re,:)    = [inf.(PrePostNames{PrePost})(strncmp([inf.(PrePostNames{PrePost}).rew],x2(re+1),4)).RT];
        inf.(PlotNames{PrePost}).RTsd(re,:)  = [inf.(PrePostNames{PrePost})(strncmp([inf.(PrePostNames{PrePost}).rew],x2(re+1),4)).RTsd];
        inf.(PlotNames{PrePost}).dPrime(re,:)= [inf.(PrePostNames{PrePost})(strncmp([inf.(PrePostNames{PrePost}).rew],x2(re+1),4)).dPrime];
        inf.(PlotNames{PrePost}).TrNum(re,:) = [inf.(PrePostNames{PrePost})(strncmp([inf.(PrePostNames{PrePost}).rew],x2(re+1),4)).TrNum];
    end
end


%% COUNT TRIALS
inf.NumTrBl = nan(length(block),5);
conditions= {'VisualLow','VisualHigh','SoundLow','SoundHigh'};
countBL = 1;
for i = 1:length(block)% 2:2:length(block)
    for type = 1:length(conditions)
        if type == 1    % visual low
            cond = 1;
            value = 1;
        elseif type == 2% visual high
            cond = 1;
            value = 2;
        elseif type == 3% sound low
            cond = 2;
            value = 1;
        elseif type == 4% sound high
            cond = 2;
            value = 2;
        end
        inf.NumTrBl(countBL,type) = sum([block(i).trials.condition] == cond  &...
            [block(i).trials.StimValue] == value &...
            [block(i).trials.error]     == 0);          % Count conditions
    end
    inf.NumTrBl(countBL,type+1) =        sum([block(i).trials.condition] == 0 &...
        [block(i).trials.error] == 0);         % Count neutral conditions
    inf.NumTrBl(countBL,type+2) = i;
    inf.NumTrBl(countBL,type+3) = round(nanmean([block(i).trials.Accuracy]),2)*100;    % Count accuraqcy
    if ~any(i == myVar.strCond)
        inf.NumTrBl(countBL,type+4) = Dprime2(nanmean([block(i).trials([block(i).trials.gaborOri]== 1).Accuracy]),...
            1-nanmean([block(i).trials([block(i).trials.gaborOri]==-1).Accuracy]));
    end
    countBL = countBL +1;
end
end 
