function DataReadyToPlot(inf)
format compact
targetVar = {'dPrime', 'Acc', 'RT'};
for plotType = 1:length(targetVar)
    figure();
    for subPlotNumber = 1:2
        subplot(1,2,subPlotNumber);
        
        if subPlotNumber == 1
            caption=['Before learning; d\prime is ', num2str(round(inf.dpPre,2))];
            message = {'Neurtal','Visual','Sound','Visual','Sound'};
            matrixToPlot =    [[inf.StatPreCond(1).(targetVar{plotType});NaN]'; inf.PlotPreCond.(targetVar{plotType})'];
            numbersToAddAcc = [[inf.StatPreCond(1).(targetVar{plotType});NaN]'; inf.PlotPreCond.(targetVar{plotType})'];
            numbersToAddNTr = [[inf.StatPreCond(1).TrNum;NaN]';inf.PlotPreCond.TrNum'];
            % errorBars       = [[inf.StatPreCond(1).RTsd;NaN]';inf.PlotPreCond.RTsd'];
        else
            caption=['After learning; d\prime is ', num2str(round(inf.dpPost,2))];
            message = {'Neurtal','Visual','Sound','Visual','Sound'};
            matrixToPlot =    [[inf.StatPostCond(1).(targetVar{plotType});NaN]'; inf.PlotPostCond.(targetVar{plotType})'];
            numbersToAddAcc = [[inf.StatPostCond(1).(targetVar{plotType});NaN]'; inf.PlotPostCond.(targetVar{plotType})'];
            numbersToAddNTr = [[inf.StatPostCond(1).TrNum;NaN]';inf.PlotPostCond.TrNum'];
            % errorBars       = [[inf.StatPostCond(1).RTsd;NaN]'; inf.PlotPostCond.RTsd'];
        end
        %     message = {'Neurtal','SameVisualPre','SameSoundPre','DiffVisualPre','DiffSoundPre','SameVisualPost','SameSoundPost','DiffVisualPost','DiffSoundPost'};
        %     matrixToPlot =    [[inf.StatPreCond(1).RT;   inf.StatPostCond(1).RT]';   inf.PlotPreCond.RT';    inf.PlotPostCond.RT'];
        %     numbersToAddAcc = [[inf.StatPreCond(1).Acc;  inf.StatPostCond(1).Acc]';  inf.PlotPreCond.Acc';   inf.PlotPostCond.Acc'];
        %     numbersToAddNTr = [[inf.StatPreCond(1).TrNum;inf.StatPostCond(1).TrNum]';inf.PlotPreCond.TrNum'; inf.PlotPostCond.TrNum'];
        fontSize = 30;
        
        
        myBar = bar(matrixToPlot,'BarWidth',1);
        %     caption=['Accuracy dp =', num2str(inf.dp)];
        title(caption, 'FontSize', fontSize);
        set(gca,'Xtick',1:5,'xticklabel',message); % ,'XTickLabelRotation',45
        set(gcf,'name','Simple Data Analysis','numbertitle','off');
        %xlabel('Conditions', 'FontSize', fontSize);
        ylabelText = (targetVar{plotType});
        ylabel(ylabelText, 'FontSize', fontSize);
        set(gca,'FontSize',16);
        %     ylim([0 1.1]);                     %%%Fix Y axis! necessary for the 2-in layer of captions
        % Enlarge figure to full screen.
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        grid on;
        
        hold on;
        
        barWidth = myBar.BarWidth;
        numCol = size(matrixToPlot,2);
        %numDist = max(mean(matrixToPlot));
        
        xSection = 0;
        myColors = lines(6);
        for ii = numbersToAddAcc'
            xSection = xSection + 1;
            xPos = linspace(xSection - barWidth/7, xSection + barWidth/2.4, numCol+1);
            idx = 1;
            for targetBar = xPos(1:end-1)
                val1 = round(numbersToAddAcc(xSection,idx),2);
                val2 = numbersToAddNTr(xSection,idx);
                y = matrixToPlot(xSection,idx);
                % errorForMe = errorBars(xSection,idx);
                % errorbar(targetBar,y,errorForMe, 'Color','k')
                text(targetBar, y+.015, num2str(val1), 'FontSize', 10, 'HorizontalAlignment', 'center');      % Add text to specific bar numDist*.025
                text(targetBar, y-.015, num2str(val2), 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color','w');      %.03 add text to specific bar .015
                myBar(idx).FaceColor = myColors(idx,:); % change color of the specific bar
                
                idx = idx +1;
            end
        end
        %% ADD SECOND LAYER OF CAPTIONS
        groupX = [2.5 4.5]; %// central value of each group
        groupY = -.06;% 11-numDist*.125; %-1// vertical position of texts. Adjust as needed
        deltaY = 0;%numDist*.0; %.3// controls vertical compression of axis. Adjust as needed
        groupNames = {'Same Loc', 'Different Loc'}; %// note different lengths to test centering
        for g = 1:numel(groupX)
            h = text(groupX(g), groupY, groupNames{g}, 'Fontsize', 20, 'Fontweight', 'bold');
            %// create text for group with appropriate font size and weight
            pos = get(h, 'Position');
            ext = get(h, 'Extent');
            pos(1) = pos(1) - ext(3)/2; %// horizontally correct position to make it centered
            set(h, 'Position', pos); %// set corrected position for text
        end
        pos = get(gca, 'position');
        pos(2) = pos(2) + deltaY; %// vertically compress axis to make room for texts
        set(gca, 'Position', pos); %/ set corrected position for axis
    end
end
end 
