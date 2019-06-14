function Stim = Saccade_bimodal_nobin_offline2_prepost_bump(Data,TSaccDurThresh,TLatThreshMin,...
    TLatThreshMax,TSaccAmpThresh,NanThresh,doreverse,rectify_each_trial)
% function Stim = Saccade_bimodal_nobin_offline2_prepost_bump(Data,TSaccDurThreshMin,TSaccDurThreshMax,TLatThreshMin,...
%     TLatThreshMax,TSaccAmpThresh,NanThresh,doreverse,rectify_each_trial)

%
% NAME:
%   SaccadeAnalysis_bimodal_nobin_offline2
%
% PURPOSE:
%   Offline analysis of saccade data for the bimodal experiment, without dividing
%   into bins
%
% USAGE:
%   SaccadeAnalysis_bimodal_nobin_offline2
%
% INPUT(S):
%   None.
%
% OUTPUT(S):
%   Plots of saccade trajectories on screen for each trial.
%   Plot of mean saccade trajectory.
%



% Parameters
plotall=0;
plotit=0;
consecutive_point_crit=1; %%%check with Barbara if using consecutive point+ Npoint makes sense, or alternatively we only increase the NPomit
NPoint=10;  %%%% defined based on mathmatical or physiological reasoning
ppd=Data.ExpInfo.Screen.ppd;
SaccStartFlight=5;  % in ms, start of saccade flight (see Godijn et al. 2004)
fixation=Data.ExpInfo.Screen.SpotPosition; %fixation point
radius=Data.ExpInfo.Stimuli.fixRad;  %%%%% size of the fixation window: note that in the prepost version this was 1.6, so should be adjusted for some analyzes for the sake of consistency
MinRatio=0.9;
TSaccMinDur=40;
%% linear interpolation of the trajectory and take evenly spaced points %%
% Mean saccade trajectory is calculated from data based on the selection criteria
% plot average saccade trajectory for high vs. low reward
tinterp  = 0:0.01:1;
dtinterp = tinterp(2)-tinterp(1);
%for TimeBin=1:NTimeBins
correct_4_fixshift = 1;  %%%% subjects fixate on different location within and especially across blocks, to correct for this
%%%%%%%%we can shift the fixation point to where they think they are
%%%%%%%%fixating
%%
Stim=struct;
CaseVar=[0 1 2 10 20 30 60 111 211 122 222 112 212 121 221];
CaseVar_alternative=[0 1 2 20 10 121 221 112 212 122 222 111 211];
DataCaseVarName={'Neutral','HV','LV','HA','LA','HA1','LA1','SHVHA','OHVHA','SLVLA','OLVLA','SLVHA','OLVHA','SHVLA','OHVLA'};

%CaseVar_alternative=[0 1 2 10 20 11 22 12 21]; %%%% for data after 7 April 2017 mistakes removed
% Initialize var
for i=1:length(CaseVar)
    Stim(i).CaseName=[];
    %   Stim(i).x=nan(1,length(tinterp));
    %   Stim(i).y=nan(1,length(tinterp));
    Stim(i).x=[];
    Stim(i).y=[];
    Stim(i).xf= [];
    Stim(i).yf= [];
    Stim(i).ntrial=0;
    Stim(i).gtrial=[];
    Stim(i).Xdevmean=[];
    Stim(i).DistEnd=[];
    Stim(i).SaccAmp=[];
    Stim(i).V=[];
    Stim(i).Vmean=[];
    Stim(i).Vpeak=[];
    Stim(i).Ngtrial=[];
    Stim(i).meanAngleAB=[];
    Stim(i).EndDeviation = [];
    Stim(i).SaccLat=[];
    Stim(i).SaccDur=[];
    Stim(i).X_Stim={};
    Stim(i).Y_Stim={};
end


%% angular deviation analysis %%
% Mean angular deviation is calculated for each trial
% Criteria for directionality (target or distractor-directed) are applied
% Loop on trials
% bla=nan(Data.ExpInfo.NTrial,1);
% bla2=nan(Data.ExpInfo.NTrial,1);
for itrial=1:Data.ExpInfo.NTrial
    if Data.ExpInfo.Stimuli.ColorOrder(itrial) ~=0 & Data.ExpInfo.Stimuli.SoundOrder(itrial)~=0
        DataCaseVar=Data.ExpInfo.Stimuli.ColorOrder(itrial)+...
            10*Data.ExpInfo.Stimuli.SoundOrder(itrial)+100*Data.ExpInfo.Stimuli.SOOrder(itrial);        
    elseif (Data.ExpInfo.Stimuli.ColorOrder(itrial) ==0 | Data.ExpInfo.Stimuli.SoundOrder(itrial)==0) & Data.ExpInfo.Stimuli.SOOrder(itrial)==1
        DataCaseVar=Data.ExpInfo.Stimuli.ColorOrder(itrial)+...
            10*Data.ExpInfo.Stimuli.SoundOrder(itrial);
    elseif (Data.ExpInfo.Stimuli.ColorOrder(itrial) ==0 | Data.ExpInfo.Stimuli.SoundOrder(itrial)==0) & Data.ExpInfo.Stimuli.SOOrder(itrial)==2
        DataCaseVar=Data.ExpInfo.Stimuli.ColorOrder(itrial)+...
            30*Data.ExpInfo.Stimuli.SoundOrder(itrial);   
    end
    % Determin the Target position
    xtar=Data.Exp.Trial(itrial).Tar_x_center/ppd;       % Target x position (vis.deg.)
    ytar=Data.Exp.Trial(itrial).Tar_y_center/ppd;       % Target y position (vis.deg.)
    TarRad=Data.ExpInfo.Stimuli.TargetRad;
    Tar_x= xtar-(fixation(1)/ppd);   %%% Target position relative to fixation point
    Tar_y= ytar-(fixation(2)/ppd);
    if correct_4_fixshift
        fixation =[nanmean(Data.Exp.Trial(itrial).FixPhase.PupilXpos(end-250:end)) nanmean(Data.Exp.Trial(itrial).FixPhase.PupilYpos(end-250:end))];
    else
        fixation =Data.ExpInfo.Screen.SpotPosition;
    end
    % Check Target and Distractor position
    % We obtain the rectification factors xf and yf.
    % xf: +1 if distractor on the RIGHT, -1 if distractor on the LEFT
    % yf: +1 if target UP, -1 if target DOWN
    %%% added by Felicia on 02.11.2017: if it's a neutral condition, only y
    %%% factor is applied since there's no distractor, there's no need for
    %%% x factor.
    
    Neutral = [];
    
    if (Data.ExpInfo.Stimuli.ColorOrder(itrial) == 0 & Data.ExpInfo.Stimuli.SoundOrder(itrial) == 0)
        Neutral = 1;
    else
        Neutral = 0;
    end
    
    [xf,yf]=xyfactors(Data.ExpInfo.Stimuli.UDOrder(itrial),...
        Data.ExpInfo.Stimuli.LROrder(itrial));
    if Neutral
        xf=1;
    end
    
    % Get Data points starting from the saccade(in visual degree)
    X_Stim=Data.Exp.Trial(itrial).StimPhase.PupilXpos/ppd;   % x position in vis.deg.
    Y_Stim=Data.Exp.Trial(itrial).StimPhase.PupilYpos/ppd;   % y position in vis.deg.
    T_Stim= Data.Exp.Trial(itrial).StimPhase.Time;
    
    
    
    % Calculate the velocity
    [Vx,Vy,Ax,Ay,Vtheta,Vrho,Atheta,Arho,V,A] = VelNPoint4(X_Stim,Y_Stim,T_Stim,fixation(1)/ppd,fixation(2)/ppd-yf*radius,NPoint);
    %identify the start of the saccade
    
    
    %%%%%%% I. for using radial velocity    
%     sacc_start=0;
%     V_start_ind=0;
%     n=1;
%     n=TLatThreshMin-1;   %%%% start cannot be earlier than TLatThreshMin
%     while  n<length(V)
%           if (Vrho(n) >= Data.ExpInfo.Vthresh) && A(n) >= Data.ExpInfo.Athresh
%             sacc_start=sacc_start+1;
%             V_start=V(n);
%             
%             A_start=A(n);
%             A_start_ind=n;
%         else
%             sacc_start=0;
%         end
%         if sacc_start >=consecutive_point_crit
%             V_start_ind=n-consecutive_point_crit;
%             break
%         end
%         n=n+1;
%     end
%     
%     %identify the end of the saccade
%     sacc_end=0;
%     %m=1;
%     V_end_ind=0;
%     m=V_start_ind+TSaccMinDur;
%     while  m<length(Vrho)
%           if (Vrho(m) <= Data.ExpInfo.Vthresh) && A(m) <= Data.ExpInfo.Athresh
%             sacc_end=sacc_end+1;
%             V_end=V(m);
%             
%             A_end=A(m);
%             A_end_ind=m;
%         else
%             sacc_end=0;
%         end
%         
%         if sacc_end>=consecutive_point_crit
%             V_end_ind=m-consecutive_point_crit+1;
%             break
%         end
%         m=m+1;
%     end
%     
   %%%%%%% II. for using absolute velocity 
    %identify the start of the saccade
    sacc_start=0;
    V_start_ind=0;
    n=1;
    n=TLatThreshMin-1;   %%%% start cannot be earlier than TLatThreshMin
    while  n<length(V)
        if (V(n) >= Data.ExpInfo.Vthresh && A(n) >= Data.ExpInfo.Athresh)
            sacc_start=sacc_start+1;
            V_start=V(n);
            
            A_start=A(n);
            A_start_ind=n;
        else
            sacc_start=0;
        end
        if sacc_start >=consecutive_point_crit
            V_start_ind=n-consecutive_point_crit;
            break
        end
        n=n+1;
    end
    
    %identify the end of the saccade
    sacc_end=0;
    %m=1;
    V_end_ind=0;
    m=V_start_ind+1;
    %m=V_start_ind+TSaccMinDur;
    while  m<length(V)
        %if (V(m) <= Data.ExpInfo.Vthresh && A(m) <= Data.ExpInfo.Athresh && sqrt((X_Stim(m)-xtar)^2+(Y_Stim(m)-ytar)^2)<TarRad)
        if (V(m) <= Data.ExpInfo.Vthresh && A(m) <= Data.ExpInfo.Athresh) %now only the first saccade is taken
            sacc_end=sacc_end+1;
            V_end=V(m);
            
            A_end=A(m);
            A_end_ind=m;
        else
            sacc_end=0;
        end
        
        if sacc_end>=consecutive_point_crit
            V_end_ind=m-consecutive_point_crit;
            break
        end
        m=m+1;
    end
    
    
    %%%% if the saccade is not properly detected do something that they are
    %%%% removed anyways: added 07.011.2017: happend for subject '75727356'
    
    if V_end_ind==0 || V_start_ind==0
        V_start_ind=1;
        V_end_ind=1;
    end 
    
    
    
    % Calculate Saccade amplitude (in degrees)
    SaccAmp = abs((Data.Exp.Trial(itrial).StimPhase.PupilYpos(V_end_ind))...
        - Data.Exp.Trial(itrial).StimPhase.PupilYpos(V_start_ind))/ppd;
    
    
    %plot the identified saccade
    if plotit
        subplot(2,1,1), plot(V)
        hold on
        plot([V_start_ind V_start_ind],[0 400],'r')
        plot([V_end_ind V_end_ind],[0 400],'r')
        plot([1 300],[Data.ExpInfo.Vthresh Data.ExpInfo.Vthresh],':g')
        %title(['Trial= ' num2str(itrial)])
        title(['Trial=' num2str(itrial) ', ' DataCaseVarName{find(CaseVar==DataCaseVar)}])
        subplot(2,1,2), plot(A)
        hold on
        plot([V_start_ind V_start_ind],[0 40000],'r')
        plot([V_end_ind V_end_ind],[0 40000],'r')
        plot([1 300],[Data.ExpInfo.Athresh Data.ExpInfo.Athresh],':g')
        title(['Trial=' num2str(itrial) ', ' DataCaseVarName{find(CaseVar==DataCaseVar)}])
        
        pause
        close all
    end
    
    
    
    % Normalized time: 0 at start, 1 at end of saccade
    % Saccade duration corresponds to the number of data points between the start and the end of saccade
    SaccDuration =  V_end_ind- V_start_ind;    % Saccade duration
    SaccLatency = V_start_ind;  % in samples
    
    
    x= X_Stim(V_start_ind:V_end_ind)-(fixation(1)/ppd); % in pixels
    y= Y_Stim(V_start_ind:V_end_ind)-(fixation(2)/ppd); % in pixels
    t= T_Stim(V_start_ind:V_end_ind);
    t=(t-min(t))/( max(t)-min(t));       % Normalise time
    
    
    % X and Y deviations
    Xdev = x;
    Ydev = y;
    
    % Deviation radial distance
    Rdev=sqrt(Xdev.^2+Ydev.^2);
    
    % Saccade angle: angle between Saccade starting point line and
    % Fixation-Saccade point line
    % We substract first data point
    SaccAngle=180/pi*atan2(Ydev-Ydev(1),Xdev-Xdev(1));
    
    % Rectified saccade angle: saccade angle rectified to upper right
       %%%%see Heeman 2016 https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4894297/
     SaccAngle=180/pi*atan2((Xdev-Xdev(1))*xf,(Ydev-Ydev(1))*yf);
    % Rectified saccade angle: saccade angle rectified to upper right
    % to be used to determine if the eyes stay in a 36° wedge-shaped
    % area
    %    EndDeviation=180/pi*atan2((Xdev)*xf,(Ydev)*yf);
    %    EndDeviation=180/pi*atan2((Ydev)*yf,(Xdev)*xf);
    
    
    DAngle=30;   %%%% as in Hiecky et al; see their description of wedges
    % SaccDir = SaccadeDirection(Rdev,EndDeviation(SaccStartFlight:end),DAngle,xf,yf,radius,MinRatio,Neutral);
    SaccDir = SaccadeDirection(Rdev,SaccAngle,DAngle,xf,yf,radius,MinRatio,Neutral);  %%%% radius of fixation point has been 1.6 in this version
    
    
    
    %         bla(itrial)=SaccDir;
    %         [a b]=max(abs(EndDeviation));
    %         bla2(itrial)=a.*sign(EndDeviation(b));
    
    % Angle calculations (see description sheet)
    if rectify_each_trial
        BETA=180/pi*atan2((Xdev-Xdev(1))*xf,(Ydev-Ydev(1))*yf);
        ALPHA=180/pi*atan2((Tar_x-Xdev(1))*xf,(Tar_y-Ydev(1))*yf);
        GAMMA=BETA-ALPHA;
        SaccAngleRect=GAMMA;
        % Mean of X deviations
        Xdevmean = nanmean(Xdev(SaccStartFlight:end)*xf); % in vis.deg.
        
    else
        BETA=180/pi*atan2((Xdev-Xdev(1)),(Ydev-Ydev(1))*yf);
        ALPHA=180/pi*atan2((Tar_x-Xdev(1)),(Tar_y-Ydev(1))*yf);
        GAMMA=BETA-ALPHA;
        SaccAngleRect=GAMMA;
        % Mean of X deviations
        Xdevmean = nanmean(Xdev(SaccStartFlight:end)); % in vis.deg.
        
    end
    
    
    
    % Take SaccStartFlight milliseconds after saccade start (see Godijn et al. 2004)
    meanAngleAB = nanmean(SaccAngleRect(SaccStartFlight:end));
    
    DistEnd=sqrt((x(end)- Tar_x).^2+(y(end)-Tar_y).^2);
    
    % Peak velocity in degrees/s
    Vpeak = max(V);
    Vmean = nanmean(V);
    % Get indices of good trials
    % 1) NaN value should be lower than the set threshold during the whole StimPhase
    % 2) Saccade duration has a maximum threshold
    % 3) Saccade latency has a minimum and maximum limits
    % 4) Saccade Amplitude has a minumum limit
    % 5) The endpoint of the first saccade is located in the correct
    % hemifield
    %6) saccade is in a 30° region around target or distractor, see Hickey
    %and Van Zoest
    %%%%%%%%%%%%%% if these conditions hold do some additional calculations and store
    % the data
    
    if ((sum(isnan(X_Stim(V_start_ind:V_end_ind)))/length(X_Stim(V_start_ind:V_end_ind))) <= NanThresh) &&...
             SaccLatency >= TLatThreshMin &&...
            SaccLatency < TLatThreshMax &&...
            SaccAmp > TSaccAmpThresh &&...
           (Y_Stim(V_end_ind)-fixation(2)/ppd)*yf >0;
        %           SaccDuration >= TSaccDurThreshMin
 %           SaccDuration < TSaccDurThreshMax &&...
        %    SaccDir>0 && ...
        %SaccDir>0 && ...
        % DistEnd <= Data.ExpInfo.Stimuli.TargetRad &...
        %
        %
        % Bring all saccade starting points to the fixation point
%         x=x-x(1);
%         y=y-y(1);
        %         x=x;
        %         y=y;
        
        %%%%%%linear interpolation for all the trials
        % Low latency: SaccLatency(gtrial(itrial))<=c(ceil(length(c)*1/3))
        % Medium Latency: SaccLatency(gtrial(itrial))<=c(ceil(length(c)*2/3)) & SaccLatency(gtrial(itrial))>c(ceil(length(c)*1/3))
        % High latency: SaccLatency(gtrial(itrial))>c(ceil(length(c)*2/3))
        
        % Take bins of good trials according to latency
        %     if length(c)>0
        %         if SaccLatency(gtrial(itrial))>=c(floor(length(c)*(TimeBin-1)/NTimeBins+1)) &...
        %                 SaccLatency(gtrial(itrial))<=c(floor(length(c)*TimeBin/NTimeBins))
        xinterp=interp1(t,x,tinterp);
        yinterp=interp1(t,y,tinterp);
        
        
        %           % Saccade Velocities in degrees/s
        %           V = Vel(xinterp/ppd,yinterp/ppd,dtinterp*SaccDur);%based on interpolated saccade trajectory
        
        
        % Combine different cases:
        % ColorOrder: 0-No color, 1-High Reward, 2-Low Reward
        % SoundOrder: 0-No sound, 1-High Reward, 2-Low Reward
        % DataCaseVar: 0, 1, 2, 10, 11, 12, 20, 21, 22
        
        
        
        %         c= Data.ExpInfo.Stimuli.ColorOrder(itrial);
        %         s= Data.ExpInfo.Stimuli.SoundOrder(itrial);
        %         if doreverse
        %             if c~=0
        %                 c= 3-c;
        %             else
        %             end
        %             if s~=0
        %                 s= 3-s;
        %             end
        %         end
        %         DataCaseVar=c+10*s;
        
        
        % PLOTS
        if (plotall == 1)
            %             figure(1)
            %             plot(SaccAngleRect)
            %             xlabel(' Saccade time (ms)')
            %             ylabel('Rectified saccade angle (?)')
            %             title(['Trial ' num2str(itrial)])
            %
            %             figure(2)
            %             plot(Xdev,Ydev), hold on
            %             xlabel('Horizontal position (?)')
            %             ylabel('Vertical position (?)')
            %             title(['Trial ' num2str(itrial)])
            %
            %             % Plot saccades for each trial
            %             figure(3)
            figure
            plot(X_Stim(V_start_ind:V_end_ind)-(fixation(1)/ppd),Y_Stim(V_start_ind:V_end_ind)-(fixation(2)/ppd),'LineWidth',3)
            xlabel('Horizontal position (pixels)')
            ylabel('Vertical position (pixels)')
            title(['Trial=' num2str(itrial) ', ' DataCaseVarName{find(CaseVar==DataCaseVar)}])
            %title(['Trial ' num2str(itrial)])
            hold on
            
            % Fixation point
            viscircles([0,0],Data.ExpInfo.Stimuli.fixRad);
            
            % Distractor
            viscircles([Data.ExpInfo.Stimuli.DistractorPosition(1)*xf,...
                Data.ExpInfo.Stimuli.DistractorPosition(2)*yf],...
                Data.ExpInfo.Stimuli.DistractorSize);
            
            % Target
            viscircles([(Data.Exp.Trial(itrial).Tar_x_center-fixation(1))./ppd,...
                (Data.Exp.Trial(itrial).Tar_y_center-fixation(2))./ppd],Data.ExpInfo.Stimuli.TargetRad);
            
            % Add wedge area for Target
            xt=Data.Exp.Trial(itrial).Tar_x_center;
            yt=Data.Exp.Trial(itrial).Tar_y_center;
            hw_x=8;
            hw_y=12;
            dangle=atan2d(yt,xt);
            dangle=dangle-90*yf;
            %dangle=36;
            h=fill([0, 0+hw_x*tand(dangle/2), 0-hw_x*tand(dangle/2)],...
                [0 hw_y*yf+0 hw_y*yf+0],'g');
            h.FaceAlpha=0.25;
            h.EdgeAlpha=0;
            
            % Add wedge area for Distractor
            xd=Data.ExpInfo.Stimuli.DistractorPosition(1)*ppd*xf;
            yd=Data.ExpInfo.Stimuli.DistractorPosition(2)*ppd*yf;
            dangle=atan2d(yd,xd);
            dangle=dangle-90*yf;
            %dangle=36;
            xcoord=[0, 0+hw_x*tand(dangle/2), (xt-fixation(1))/ppd-hw_x*tand(dangle/2)]-0;
            ycoord=[0 hw_y*yf+0 hw_y*yf+0]-0;
            xcoordn=cosd(-dangle)*xcoord+sind(-dangle)*ycoord+0;
            ycoordn=-sind(-dangle)*xcoord+cosd(-dangle)*ycoord+0;
            h=fill(xcoordn,ycoordn,'m');
            h.FaceAlpha=0.25;
            h.EdgeAlpha=0;
            
            
            axis equal
            xlim([ -Data.ExpInfo.Screen.Size(1)./(2*ppd) Data.ExpInfo.Screen.Size(1)./(2*ppd)])
            ylim([ -Data.ExpInfo.Screen.Size(2)./(2*ppd) Data.ExpInfo.Screen.Size(2)./(2*ppd)])
            
            if itrial>3
                title(['Trial=' num2str(itrial) ', ' DataCaseVarName{find(CaseVar==DataCaseVar)} ', previous trials LROrder:' num2str(Data.ExpInfo.Stimuli.LROrder(itrial-3)) num2str(Data.ExpInfo.Stimuli.LROrder(itrial-2)) num2str(Data.ExpInfo.Stimuli.LROrder(itrial-1))])
            else
                title(['Trial=' num2str(itrial) ', ' DataCaseVarName{find(CaseVar==DataCaseVar)}])
            end
            
            hold off
            
            pause
        end
        
        i=find(DataCaseVar==CaseVar);
        %      xf=1; yf=1;
        %if SaccDir>0 %&& all(abs(Xdev)<TarRad) %%%%only take taregt- and distractor- directed saccades
        Stim(i).CaseName=DataCaseVar;
        if rectify_each_trial
            Stim(i).x=[Stim(i).x;xf*xinterp];%interpolated
            Stim(i).y=[Stim(i).y;yf*yinterp];%interpolated
        else
            Stim(i).x=[Stim(i).x;xinterp];%interpolated
            Stim(i).y=[Stim(i).y;yinterp];%interpolated
        end
        Stim(i).xf= [Stim(i).xf;xf];%interpolated
        Stim(i).yf= [Stim(i).yf;yf];%interpolated
        Stim(i).ntrial=Stim(i).ntrial+1;
        Stim(i).gtrial=[Stim(i).gtrial itrial];
        Stim(i).Xdevmean=[Stim(i).Xdevmean Xdevmean];
        Stim(i).DistEnd=[Stim(i).DistEnd DistEnd];
        Stim(i).SaccAmp=[Stim(i).SaccAmp SaccAmp];
        Stim(i).V=[Stim(i).V;V];
        Stim(i).Vpeak=[Stim(i).Vpeak Vpeak];
        Stim(i).Vmean=[Stim(i).Vmean Vmean];
        Stim(i).meanAngleAB=[Stim(i).meanAngleAB meanAngleAB];
        Stim(i).EndDeviation = [Stim(i).EndDeviation SaccAngle(end)];
        Stim(i).SaccLat=[Stim(i).SaccLat SaccLatency];
        Stim(i).SaccDur=[Stim(i).SaccDur SaccDuration];
        Stim(i).X_Stim=[Stim(i).X_Stim X_Stim];
        Stim(i).Y_Stim=[Stim(i).Y_Stim Y_Stim];
        
        % end
    end
end


%%

% % Means
for i=1:length(Stim)
    Stim(i).xmean=nanmean(Stim(i).x,1);
    Stim(i).ymean=nanmean(Stim(i).y,1);
    Stim(i).Ngtrial=length(Stim(i).gtrial);
    
end
%
% end
%% Saccade Vigor

% See Reppert et al. (2015) and Choi et al. (2014) for more details.
% Saccade peak velocity is related to saccade amplitude through a
% hyperbolic function of the form:
%        /         1    \
% v = a ( 1 -  --------- )
%        \      1 + b x /
% a, b are parameters different for each stimulus cases.

% for i=1:length(Bin(TimeBin).Stim)
%     [SaccAmpSort iSort]=sort(Bin(TimeBin).Stim(i).SaccAmp);
%     VpeakSort=Bin(TimeBin).Stim(i).Vpeak(iSort);
%
%     if length(VpeakSort)>1
%         % Calculate vigor only when there is more than 1 data point
%         % (otherwise fitting will not work since we have two parameters to
%         % determine).
%         ft = fittype( 'SaccVigor( x, a, b )' );
%         f = fit( SaccAmpSort, VpeakSort, ft, 'StartPoint', [1, 1] );
%     else
%         vigor=[];
%     end
% end




%end
%end