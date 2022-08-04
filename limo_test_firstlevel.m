function [integration_results,firstlevelfiles] = limo_test_firstlevel(STUDY,ALLEEG,EEG)

% run 1st level analysis of Wakeman and Henson data using three different designs 
% 1 - ERP categorical design face*repetition, i.e. 9 categories using OLS 
%     + contrasts to compute main effects
% 2 - ERSP mixed design face*time delay in repetition using WLS
%     + contrast for faces
% 3 - Spectrum constant design
%
% FORMAT [integration_results,firstlevelfiles] = limo_test_firstlevel(STUDY,ALLEEG,EEG)
%
% OUTPUT integration_results is a structure
%           integration_results.firstlevel.constant_designWLS 
%               - updates STUDY and run a 1st level ananlysis with no conditions (i.e. just contant term) using WLS
%           integration_results.firstlevel.categorical_designOLS
%               - updates STUDY and run a 1st level ananlysis with 9 faces conditions using OLS
%           integration_results.firstlevel.mixed_designWLS
%               - updates STUDY and run a 1st level ananlysis with 3 face categories and times as continuous using WLS
%
%       firstlevelfiles is a structure with lists of files use internally to test 2nd level analyses
%           fieldnames follow the integration_results structure

try
    % make categorical design & estimate with OLS
    STUDY = std_makedesign(STUDY, ALLEEG, 1, 'name','FaceRepetition','delfiles','off','defaultdesign','off',...
        'variable1','type','values1',{'famous_new','famous_second_early','famous_second_late','scrambled_new','scrambled_second_early','scrambled_second_late','unfamiliar_new','unfamiliar_second_early','unfamiliar_second_late'},...
        'vartype1','categorical','subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');
    
    % cleanup previous version
    [~,limo_rootfiles,~]=fileparts(STUDY.filename);
    limo_rootfiles = fullfile(root,['LIMO_' limo_rootfiles]);
    if exist([limo_rootfiles filesep 'limo_batch_report'],'dir')
        rmdir([limo_rootfiles filesep 'limo_batch_report'],'s')
    end
    for sub = 1:length(STUDY.subject)
        if exist(fullfile(root,[STUDY.subject{1} filesep 'eeg' filesep 'FaceRepetition_GLM_Channels_Time_OLS']),'dir')
            rmdir(fullfile(root,[STUDY.subject{1} filesep 'eeg' filesep 'FaceRepetition_GLM_Channels_Time_OLS']),'s')
        end
    end
    
    % compute 1st model with OLS
    [STUDY, ~, Model1_files] = pop_limo(STUDY, ALLEEG, 'method','OLS','measure','daterp','timelim',[-50 650],'erase','on','splitreg','off','interaction','off');
    contrast.LIMO_files      = Model1_files.mat; 
    contrast.mat             = [1 1 1 -1 -1 -1 0 0 0 0 ; 0 0 0 1 1 1 -1 -1 -1 0];
    confiles                 = limo_batch('contrast only',[],contrast,STUDY); 
    Model1_files.con         = confiles.con;
    clear confiles
    limotest{1} = 'categorical design + contrasts with OLS estimates successful';
catch err
    fprintf('%s\n',err.message)
    limotest{1} = sprintf('categorical design + contrasts with OLS estimates failed \n%s',err.message);
end

try
    % make categorical+continuous design & estimate with WLS
    STUDY = std_makedesign(STUDY, ALLEEG, 2, 'name','Face_time','delfiles','off','defaultdesign','off',...
        'variable1','face_type','values1',{'famous','scrambled','unfamiliar'},'vartype1','categorical',...
        'variable2','time_dist','values2',[],'vartype2','continuous',...
        'variable3','trial_dist','values3',[],'vartype3','continuous',...
        'subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');
    
    % cleanup previous version
    for sub = 1:length(STUDY.subject)
        if exist(fullfile(root,[STUDY.subject{1} filesep 'eeg' filesep 'Face_time_GLM_Channels_Time_WLS']),'dir')
            rmdir(fullfile(root,[STUDY.subject{1} filesep 'eeg' filesep 'Face_time_GLM_Channels_Time_WLS']),'s')
        end
    end
    
    % compute 1st model with WLS
    [STUDY, ~, Model2_files] = pop_limo(STUDY, ALLEEG, 'method','WLS','measure','daterp','timelim',[-50 650],'erase','on','splitreg','on','interaction','off');
    contrast.LIMO_files      = Model2_files.mat; 
    contrast.mat             = [0 0 0 -1 0 1];
    confiles                 = limo_batch('contrast only',[],contrast); % do not pass STUDY argument, should still figure it out
    Model2_files.con         = confiles.con;
    clear confiles
    limotest{2} = 'mixed design with WLS estimates + contrast successful';
catch err
    fprintf('%s\n',err.message)
    limotest{2} = sprintf('mixed design with WLS estimates + contrast failed \n%s',err.message);
end

