function limo_test_repeated_measures_ANOVA

% Repeated measures ANOVA + contrast
try
    % whole brain with Beta files as input
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('Rep-ANOVA'); cd('Rep-ANOVA')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',...
        {[limo_rootfiles filesep 'Beta_files_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']},...
        'analysis_type','Full scalp analysis','parameters',{[1 2 3],[4 5 6],[7 8 9]},...
        'factor names',{'face','repetition'},'type','Channels','nboot',101,'tfce',1,'skip design check','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        3,[1 1 1 -2 -2 -2 1 1 1]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        4,[1 1 1 -2 -2 -2 1 1 1]); % boostrap / tfce
    
    % whole brain with Beta files as input split by groups
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('GpRep-ANOVA'); cd('GpRep-ANOVA')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',...
        {[limo_rootfiles filesep 'Beta_files_Gp1_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt'];
        [limo_rootfiles filesep 'Beta_files_Gp2_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt'];
        [limo_rootfiles filesep 'Beta_files_Gp3_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt']},...
        'analysis_type','Full scalp analysis','parameters',{[1 2 3]},... % in theory {[1 2 3];[1 2 3];[1 2 3]} but it's taken care of
        'factor names',{'face'},'type','Channels','nboot',101,'tfce',1,'skip design check','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        3,[1 -2 1]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'LIMO.mat'],...
        4,[1 -2 1]); % boostrap / tfce
    
    % channel 50 with con files as input
    cd(fullfile(root,'2nd_level_tests'));
    clear datafiles % spurious design but we need enough subjects to run
    datafiles{1,1} = fullfile(limo_rootfiles, ['con_1_files_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']); 
    datafiles{1,2} = fullfile(limo_rootfiles, ['con_1_files_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt']); 
    datafiles{1,3} = fullfile(limo_rootfiles, ['con_2_files_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']);
    mkdir('Rep-ANOVA50'); cd('Rep-ANOVA50')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
        'analysis_type','1 channel/component only', 'Channel',50, 'factor names',{'face'},...
        'parameters',{[1 1 1]},'type','Channels','nboot',101,'tfce',1,'skip design check','yes');

    % also use gp + con files + optimized channel
    cd(fullfile(root,'2nd_level_tests'));
    clear datafiles; datafiles = cell(3,2);
    datafiles{1,1} = fullfile(limo_rootfiles, ['con_1_files_Gp1_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']); 
    datafiles{1,2} = fullfile(limo_rootfiles, ['con_2_files_Gp1_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']);
    datafiles{2,1} = fullfile(limo_rootfiles, ['con_1_files_Gp2_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']);
    datafiles{2,2} = fullfile(limo_rootfiles, ['con_2_files_Gp2_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']); 
    datafiles{3,1} = fullfile(limo_rootfiles, ['con_1_files_Gp3_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']);
    datafiles{3,2} = fullfile(limo_rootfiles, ['con_2_files_Gp3_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']);
    mkdir('GpRep-ANOVAOPT'); cd('GpRep-ANOVAOPT')
    limo_random_select('Repeated Measures ANOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
        'analysis_type','1 channel/component only', 'Channel',channel_vector, 'factor names',{'face'},...
        'parameters',{[1 1];[1 1];[1 1]},'type','Channels','nboot',101,'tfce',1,'skip design check','yes');
    limotest{9} = 'Repeated measures ANOVA + contrast successful';
catch err
    fprintf('%s\n',err.message)
    limotest{9} = sprintf('Repeated measures ANOVA + contrast failed \n%s',err.message);
end
