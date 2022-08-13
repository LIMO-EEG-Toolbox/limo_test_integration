function limo_test_two_samplesttest

% two samples t-test
try
    % two-samples t-test whole brain with a cell array of con files as input
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('two-samples_t-test'); cd('two-samples_t-test')
    LIMOPath = limo_random_select('two-samples t-test',STUDY.limo.chanloc,...
        'LIMOfiles',data,'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1);
    
    % two-samples t-test channel 50 with file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('two-samples_t-test50'); cd('two-samples_t-test50')
    LIMOPath = limo_random_select('two-samples t-test',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
         'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','nboot',101,'tfce',1);
    limo_eeg(5)

    % two-samples t-test virtual channel with file list of Betas
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('two-samples_t-testOPT'); cd('two-samples_t-testOPT'); clear Bfiles
    Bfiles{1} = [limo_rootfiles filesep 'Beta_files_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt'];
    Bfiles{2} = [limo_rootfiles filesep 'Beta_files_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt'];
    LIMOPath = limo_random_select('two-samples t-test',STUDY.limo.chanloc,...
        'LIMOfiles',Bfiles, 'analysis_type','1 channel/component only', 'Channel',repmat(channel_vector,[2,1]),...
        'type','Channels','parameter',[1 4],'nboot',101,'tfce',1);
    limotest{6} = 'two samples t-test successful';
catch err
    fprintf('%s\n',err.message)
    limotest{6} = sprintf('two samples t-test failed \n%s',err.message);
end
