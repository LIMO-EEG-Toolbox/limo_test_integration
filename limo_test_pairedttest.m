function limo_test_pairedttest

% paired t-test
try
    % paired t-test whole brain with a cell array of con files as input
    clear data
    for N=length(STUDY.subject):-1:1
        data{1,N} = Model1_files.con{N}(1);
        data{2,N} = Model1_files.con{N}(2);
    end
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('paired_t-test'); cd('paired_t-test')
    LIMOPath = limo_random_select('paired t-test',STUDY.limo.chanloc,...
        'LIMOfiles',data,'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1);
    limo_eeg(5)
    
    % paired t-test channel 50 with file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('paired_t-test50'); cd('paired_t-test50')
    datafiles = {[limo_rootfiles filesep 'con_1_files_Face_detection_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt'], ...
        [limo_rootfiles filesep 'con_2_files_Face_detection_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt']};
    LIMOPath = limo_random_select('paired t-test',STUDY.limo.chanloc,'LIMOfiles',datafiles,...
         'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','nboot',101,'tfce',1);
    limo_eeg(5)
    
    % paired t-test virtual channel with file list of Betas
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('paired_t-testOPT'); cd('paired_t-testOPT')
    LIMOPath = limo_random_select('paired t-test',STUDY.limo.chanloc,...
        'LIMOfiles',[limo_rootfiles filesep 'Beta_files_' STUDY.design(1).name '_GLM_Channels_Time_OLS.txt'], ...
        'analysis_type','1 channel/component only', 'Channel',channel_vector, ...
        'type','Channels','parameter',[1 4],'nboot',101,'tfce',1);
    limotest{5} = 'paired t-test successful';
catch err
    fprintf('%s\n',err.message)
    limotest{5} = sprintf('paired t-test failed \n%s',err.message);
end
