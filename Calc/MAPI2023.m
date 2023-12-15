%% MAPI 2023: Poultry
% JK October 2023
% Github
% Measurements conducted in autumn 20233


clear

cd 'C:\Users\AU323818\Dropbox\Uni\NIFA LagerMet\Manure Pile Poultry\MatLab'

tic

PLOT_SWITCH = 0; % Plot: 0 = NO, 1 = YES
PLOT_SWITCH_COMP = 0;
PLOT_TEMP = 0;
SAVE_FIG = 1;
ii = 1;

foldout = 'C:\Users\AU323818\Dropbox\Uni\NIFA LagerMet\Manure Pile Poultry\Figures';


% Load files
load('TT_CRDS_Line_13_10_2023.mat')
load('TT_CRDS_BG_13_10_2023.mat')

load('TT_VejrFoulum_13_10_2023.mat')
load('TT_bLS_13_10_2023.mat')
load('TT_Temp_Pile.mat')


%% Combine concentrations, bLS output, calculte emissions, and apply filtering
TT_CRDS = synchronize(TT_CRDS_BG, TT_CRDS_Line);

TT_CRDS(TT_CRDS.Time < datetime('2023-08-29 09:00:00'),:) = [];

TT_emis_all = synchronize(TT_CRDS, TT_bLS);
TT_emis_all.Emis_NH3 = (TT_emis_all.NH3 - TT_emis_all.NH3_BG) ./ TT_emis_all.CE;
TT_emis_all.Emis_CH4 = (TT_emis_all.CH4 - TT_emis_all.CH4_BG) ./ TT_emis_all.CE;
TT_emis_all.Emis_N20 = (TT_emis_all.N2O - TT_emis_all.N2O_BG) ./ TT_emis_all.CE;

% All quality applied:
TT_emis = TT_emis_all;

TT_emis(TT_emis.C0 > 10 | TT_emis.Ustar < 0.05 | abs(TT_emis.L) < 2 | TT_emis.sUu > 4.5 | TT_emis.sVu > 4.5, :) = [];
TT_emis((TT_emis.N_TD./TT_emis.N0) < 0.1, :) = [];

TT_emis = rmmissing(TT_emis, 'DataVariables','Emis_NH3');

%% Statistics
T_START = datetime('2023-08-29 09:30:00'); % Time for start of pile building - starts uncovered
T_COV = datetime('2023-09-04 10:20:00'); % Time for start of covering pile 
T_UNCOV = datetime('2023-10-02 10:30:00'); % Time for start of removing cover
T_REM = datetime('2023-10-12 10:25:00'); % Time for start of pile removal

TT_emis.GROUP = categorical(zeros(height(TT_emis),1));

TT_emis.GROUP(TT_emis.Time < T_COV, :) = categorical("UNCOV_1");
TT_emis.GROUP(TT_emis.Time > T_COV & TT_emis.Time < T_UNCOV, :) = categorical("COV");
TT_emis.GROUP(TT_emis.Time > T_UNCOV & TT_emis.Time < T_REM, :) = categorical("UNCOV_2");
TT_emis.GROUP(TT_emis.Time > T_REM, :) = categorical("REM");

% Table 2
stats_all = grpstats(TT_emis,"GROUP", ["mean", "std", "numel", "min", "max", "sem", "meanci"], "DataVars", ["Emis_CH4", "Emis_NH3", "Emis_N20"]);
writetable(stats_all,'stats.xlsx', 'Sheet', 'MyNewSheet', 'WriteRowNames',true, 'WriteVariableNames',true);

disp('Mean CH4 g/m2/h uncover - cover - uncover - remove')
disp([mean(TT_emis.Emis_CH4(TT_emis.Time < T_COV),"omitnan")*60*60/10^6 mean(TT_emis.Emis_CH4(TT_emis.Time > T_COV & TT_emis.Time < T_UNCOV),"omitnan")*60*60/10^6 ...
    mean(TT_emis.Emis_CH4(TT_emis.Time > T_UNCOV & TT_emis.Time < T_REM),"omitnan")*60*60/10^6 mean(TT_emis.Emis_CH4(TT_emis.Time > T_REM),"omitnan")*60*60/10^6])

disp('Mean NH3 mg/m2/h uncover - cover - uncover - remove')
disp([mean(TT_emis.Emis_NH3(TT_emis.Time < T_COV),"omitnan")*60*60/10^3 mean(TT_emis.Emis_NH3(TT_emis.Time > T_COV & TT_emis.Time < T_UNCOV),"omitnan")*60*60/10^3 ...
    mean(TT_emis.Emis_NH3(TT_emis.Time > T_UNCOV & TT_emis.Time < T_REM),"omitnan")*60*60/10^3 mean(TT_emis.Emis_NH3(TT_emis.Time > T_REM),"omitnan")*60*60/10^3])

disp('Mean N2O mg/m2/h uncover - cover - uncover - remove')
disp([mean(TT_emis.Emis_N20(TT_emis.Time < T_COV),"omitnan")*60*60/10^3 mean(TT_emis.Emis_N20(TT_emis.Time > T_COV & TT_emis.Time < T_UNCOV),"omitnan")*60*60/10^3 ...
    mean(TT_emis.Emis_N20(TT_emis.Time > T_UNCOV & TT_emis.Time < T_REM),"omitnan")*60*60/10^3 mean(TT_emis.Emis_N20(TT_emis.Time > T_REM),"omitnan")*60*60/10^3])

[~,~,stats1] = anova1(TT_emis.Emis_CH4, TT_emis.GROUP, 'off');
stats1.n(1) = [];
stats1.means(1) = [];
[c1,~,~,gnames] = multcompare(stats1);
tbl1 = array2table(c1,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl1.("Group A") = gnames(tbl1.("Group A"));
tbl1.("Group B") = gnames(tbl1.("Group B"));

[~,~,stats2] = anova1(TT_emis.Emis_NH3, TT_emis.GROUP, 'off');
stats2.n(1) = [];
stats2.means(1) = [];
[c2,~,~,gnames] = multcompare(stats2);
tbl2 = array2table(c2,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl2.("Group A") = gnames(tbl2.("Group A"));
tbl2.("Group B") = gnames(tbl2.("Group B"));

[~,~,stats3] = anova1(TT_emis.Emis_N20, TT_emis.GROUP, 'off');
stats3.n(1) = [];
stats3.means(1) = [];
[c3,~,~,gnames] = multcompare(stats3);
tbl3 = array2table(c3,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
tbl3.("Group A") = gnames(tbl3.("Group A"));
tbl3.("Group B") = gnames(tbl3.("Group B"));


%% Plots Emissions
if PLOT_SWITCH == 1
    TimeLim = [datetime('2023-08-29 09:00:00'), datetime('2023-10-12 13:00:00')];
    SizeOfFont = 11;
    SizeOfFontLgd = 10;
    
    % Figure 1 in manuscript
    fig100 = figure(ii);
    tiledlayout(3,1, 'TileSpacing', 'tight');

    nexttile % 1
    plot(TT_emis.Time, TT_emis.Emis_NH3, 'o')
    ylabel('NH_3 (\mug m^{-2} s^{-1})')
    grid minor
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    text(T_COV, max(TT_emis.Emis_NH3)*0.9, 'Cover')
    text(T_UNCOV, max(TT_emis.Emis_NH3)*0.9, 'Uncover')
    text(T_REM, max(TT_emis.Emis_NH3)*0.9, 'Remove')
    
    nexttile % 2
    plot(TT_emis.Time, TT_emis.Emis_CH4, 'o')
    ylabel('CH_4 (\mug m^{-2} s^{-1})')
    grid minor
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    text(T_COV, max(TT_emis.Emis_CH4)*0.9, 'Cover')
    text(T_UNCOV, max(TT_emis.Emis_CH4)*0.9 ,'Uncover')
    text(T_REM, max(TT_emis.Emis_CH4)*0.9, 'Remove')
    
    nexttile % 3
    plot(TT_emis.Time, TT_emis.Emis_N20, 'o')
    ylabel('N_2O (\mug m^{-2} s^{-1})')
    grid minor
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    text(T_COV, max(TT_emis.Emis_N20), 'Cover')
    text(T_UNCOV, max(TT_emis.Emis_N20), 'Uncover')
    text(T_REM, max(TT_emis.Emis_N20), 'Remove')
    ii = ii + 1;


    if SAVE_FIG == 1
        FigFileName = 'Fig100 Flux tiled';
        fullFileName = fullfile(foldout, FigFileName);
        fig100 = gcf;
        fig100.PaperUnits = 'centimeters';
        fig100.PaperPosition = [0 0 19 11];
        print(fullFileName,'-dpng','-r800')
    end

    % Figure 3 in manuscript
    fig102=figure(ii);
    subplot(4,1,1)
    h1 = bar(TT_VejrFoulum.Time, TT_VejrFoulum.prec);
    ylabel({'Precipitation', '(mm hr^{-1})'},'FontSize',SizeOfFont, 'color','k')
    grid minor
    xlim(TimeLim)
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    legend(h1, 'Precipitation', 'FontSize', SizeOfFontLgd);

    subplot(4,1,2)
    h2 = plot(TT_VejrFoulum.Time, TT_VejrFoulum.wv2);
    ylabel({'Wind speed', '(m s^{-1})'},'FontSize',SizeOfFont, 'color','k')
    grid minor
    xlim(TimeLim)
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    f=get(gca,'Children');
    legend(h2, 'Wind speed', 'FontSize', SizeOfFontLgd);

    subplot(4,1,3)
    h3 = plot(TT_VejrFoulum.Time, TT_VejrFoulum.TempAir);
    grid minor
    ylabel({'Temperature', '(^oC)'},'FontSize',SizeOfFont, 'color','k')
    xlim(TimeLim)
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    legend(h3,'Air temperature', 'FontSize', SizeOfFontLgd);

    subplot(4,1,4)
    h4 = plot(TT_emis_all.Time, 1./TT_emis_all.L);
    ylabel({'1 / L', '(m^{-1})'},'FontSize',SizeOfFont, 'color','k')
    grid minor
    xlim(TimeLim)
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    legend(h4,'1/L', 'FontSize', SizeOfFontLgd);
    ylim([-0.5 0.7])
    xtickformat('MMM dd HH:mm')

    samexaxis('join','abc','xmt','on','yld',1,'YLabelDistance',1.0,'XLim',TimeLim)

    if SAVE_FIG == 1
        FigFileName = 'Fig101 Atmospheric';
        fullFileName = fullfile(foldout, FigFileName);
        fig102 = gcf;
        fig102.PaperUnits = 'centimeters';
        fig102.PaperPosition = [0 0 19 11];
        print(fullFileName,'-dpng','-r800')
    end

end


%% Temp plots
if PLOT_TEMP == 1
    
    % Figure 2
    fig200 = figure(ii);
    h = plot(TT_Temp.Time, TT_Temp.T1, TT_Temp.Time, TT_Temp.T12, TT_Temp.Time, TT_Temp.T3, TT_VejrFoulum.Time, TT_VejrFoulum.TempAir);
    grid minor
    xlim([TT_Temp.Time(1), TT_Temp.Time(end)])
    xline(T_COV); xline(T_UNCOV); xline(T_REM)
    text(T_COV, 58, 'Cover')
    text(T_UNCOV, 58 ,'Uncover')
    text(T_REM, 58, 'Remove')
    legend([h(1), h(2), h(3), h(4)], {'Bottom', 'Middle', 'Top', 'Air'}, 'NumColumns',4, 'Location','northoutside')
    ii = ii + 1;


    if SAVE_FIG == 1
        FigFileName = 'Fig200 Temperature';
        fullFileName = fullfile(foldout, FigFileName);
        fig200 = gcf;
        fig200.PaperUnits = 'centimeters';
        fig200.PaperPosition = [0 0 19 11];
        print(fullFileName,'-dpng','-r800')
    end



end



toc