function limo_test_one_samplettest

% ---------------------------------------------------------------------
% one sample t-test
try
    % one sample t-test whole brain with a cell array of con files as input
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('one_sample'); cd('one_sample')
    LIMOPath = limo_random_select('one sample t-test',STUDY.limo.chanloc,...
        'LIMOfiles',Model3_files.Beta,'parameter',1,...
        'analysis_type','Full scalp analysis', 'type','Channels','nboot',101,'tfce',1);
    
    % one sample t-test channel 50 file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('one_sample50'); cd('one_sample50')
    LIMOPath = limo_random_select('one sample t-test',STUDY.limo.chanloc,...
        'LIMOfiles',[limo_rootfiles filesep 'con_1_files_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt'],...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','nboot',101,'tfce',1);
    
    % one sample t-test virtual channel - array of Betas
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('one_sampleOPT'); cd('one_sampleOPT')
    LIMOPath = limo_random_select('one sample t-test',STUDY.limo.chanloc,...
        'LIMOfiles',Model2_files.Beta, 'analysis_type','1 channel/component only', 'Channel',channel_vector, ...
        'type','Channels','parameter',{[1  3 7]},'nboot',101,'tfce',1);
    limotest{3} = 'one sample t-tests successful';
catch err
    fprintf('%s\n',err.message)
    limotest{3} = sprintf('one sample t-tests failed \n%s',err.message);
end

