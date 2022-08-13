function limo_test_regression

% regression
try
    % regression (calls similar routines as one sample)
    % regression whole brain with an array of con files as input and a matrix as regressor
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('regression'); cd('regression')
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,...
        'LIMOfiles',Model2_files.con,'regressor_file',randi(length(Model2_files.con),length(Model2_files.con),2),...
        'analysis_type','Full scalp analysis', 'type','Channels','zscore','yes','skip design check','yes','nboot',101,'tfce',1);

    limo_contrast('Yr.mat', 'Betas.mat', 'LIMO.mat', 'T', 1, [1 0])
    limo_contrast('Yr.mat', 'Betas.mat', 'LIMO.mat', 'T', 2, [1 0])
    
    % tripple data size for IRLS
    rmdir('H0','s'); rmdir('tfce','s')
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,...
        'LIMOfiles',[Model2_files.con ; Model2_files.con ; Model2_files.con],...
        'regressor_file',randi(length(Model2_files.con)*3,length(Model2_files.con)*3,2),...
        'analysis_type','Full scalp analysis', 'type','Channels','zscore','yes','skip design check','yes','nboot',101,'tfce',1);
    
    % regression channel 50 file list of con files as input and a file as regressor
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('regression50'); cd('regression50')
    randomreg = randn(length(Model2_files.con),1); save('reg.mat','randomreg');
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,'regressor_file',[pwd filesep 'reg.mat'],...
        'LIMOfiles',[limo_rootfiles filesep 'con_1_files_Face_detection_Face_time_GLM_Channels_Time_WLS.txt'],...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','zscore','yes','skip design check','yes','nboot',101,'tfce',1);
    
    rmdir('H0','s'); rmdir('tfce','s')
    randomreg = randn(length(Model2_files.con)*3,length(Model2_files.con)*3,2); save('reg.mat','randomreg');
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,...
        'LIMOfiles',[Model2_files.con ; Model2_files.con ; Model2_files.con],...
        'regressor_file',randi(length(Model2_files.con)*3,length(Model2_files.con)*3,2),...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels','zscore','yes','skip design check','yes','nboot',101,'tfce',1);
    
    % regression virtual channel - list of Betas files, select a parameter, load optimized channel file
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('regressionOPT'); cd('regressionOPT')
    LIMOPath = limo_random_select('regression',STUDY.limo.chanloc,...
        'LIMOfiles',[limo_rootfiles filesep 'Beta_files_' STUDY.design(2).name '_GLM_Channels_Time_WLS.txt'], ...
        'parameter',3, 'regressor_file',randi(length(Model2_files.con),length(Model2_files.con),2), ...
        'analysis_type','1 channel/component only', 'type','Channels', ...
        'Channel',fullfile(root,['2nd_level_tests' filesep 'virtual_electrode.mat']), ...
        'zscore','yes','skip design check','yes','nboot',101,'tfce',1);
    limotest{4} = 'regressions successful';
catch err
    fprintf('%s\n',err.message)
    limotest{4} = sprintf('regressions failed \n%s',err.message);
end
