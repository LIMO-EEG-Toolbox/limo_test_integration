function limo_test_ANOVA

% 1-way ANOVA + contrast
try
    % N-Ways ANOVA whole brain with a cell array of con files as input with empty cells 
    clear data
    index = find(arrayfun(@(x) contains(x.group,'1'), STUDY.datasetinfo));
    for s=1:length(index); data{1,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'2'), STUDY.datasetinfo));
    for s=1:length(index); data{2,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'3'), STUDY.datasetinfo));
    for s=1:length(index); data{3,s} = Model1_files.con{index(s)}(1); end
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('N-Ways ANOVA'); cd('N-Ways ANOVA')
    LIMOPath = limo_random_select('N-Ways ANOVA',STUDY.limo.chanloc,'LIMOfiles',data',...
        'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1,'skip design check','yes');
    
    % N-Ways ANOVA channel 50 with file list of con files
    % con per group files already exist split according to STUDY
    datafiles = {fullfile(limo_rootfiles, ['con_1_files_Gp1_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']), ...
        fullfile(limo_rootfiles, ['con_1_files_Gp2_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']),...
        fullfile(limo_rootfiles, ['con_1_files_Gp3_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt'])};
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('N-Ways ANOVA50'); cd('N-Ways ANOVA50')
    LIMOPath = limo_random_select('N-Ways ANOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels',...
        'nboot',101,'tfce',1,'skip design check','yes');
    
    % N-Ways ANOVA  virtual channel with file list of Betas and input parameters
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('N-Ways ANOVAOPT'); cd('N-Ways ANOVAOPT')
    for g=3:-1:1
        Bfiles{g} = [limo_rootfiles filesep 'Beta_files_Gp' num2str(g) '_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt'];
    end
    LIMOPath = limo_random_select('N-Ways ANOVA',STUDY.limo.chanloc,...
        'LIMOfiles',Bfiles, 'analysis_type','1 channel/component only', ...
        'Channel',fullfile(root,['2nd_level_tests' filesep 'virtual_electrode.mat']), ...
        'type','Channels','parameter',{[1;1;1]},'nboot',101,'tfce',1,'skip design check','yes');    
    limotest{7} = '1-way ANOVA successful';
catch err
    fprintf('%s\n',err.message)
    limotest{7} = sprintf('1-way ANOVA failed \n%s',err.message);
end
