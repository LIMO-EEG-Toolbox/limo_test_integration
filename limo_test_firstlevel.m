function [integration_results,firstlevelfiles] = limo_test_firstlevel(Type)

% run 1st level analysis of Wakeman and Henson data using three different designs 
% also runs each one on different data type (ERP, ERSP, Spectrum) to make
% sure LIMO recognize them and can apply to parameters
%
% 1 - ERP categorical design face*repetition, i.e. 9 categories using WLS 
%     + contrasts to compute main effects
% 2 - ERSP mixed design face*time delay in repetition using OLS (faster)
%     + contrast for covariates (test WLS on last subject, JIC)
% 3 - Spectrum constant design (weighted mean)
%
% FORMAT [integration_results,firstlevelfiles] = limo_test_firstlevel(STUDY,ALLEEG,EEG,Type)
%
% INPUTS STUDY,ALLEEG,EEG are the usual EEGLAB variables
%        Type is 'Channels' or 'Components' (to do 'Sources')
%
% OUTPUT integration_results is a structure
%           integration_results.firstlevel.constant_designWLS 
%               - updates STUDY and run a 1st level ananlysis with no conditions (i.e. just contant term) using WLS
%           integration_results.firstlevel.categorical_designOLS
%               - updates STUDY and run a 1st level ananlysis with 9 faces conditions using OLS
%           integration_results.firstlevel.mixed_designWLS
%               - updates STUDY and run a 1st level ananlysis with 3 face categories and times as continuous using WLS
%
%       firstlevelfiles is a structure with lists of files use by limo_test_integration to test 2nd level analyses
%           fieldnames follow the integration_results structure
%
% Cyril Pernet 2022

%% check type
if ~contains(Type,{'Channels','ICs'},'IgnoreCase',true)
    error('data Type ''Channels'' or ''ICs'' must be entered')
end
global STUDY ALLEEG EEG

%% run cases one by one

% categorical design & estimate with WLS on ERP
% ----------------------------------------------

try
    STUDY = std_makedesign(STUDY, ALLEEG, 1, 'name','FaceRepetition','delfiles','off','defaultdesign','off',...
        'variable1','type','values1',{'famous_new','famous_second_early','famous_second_late','scrambled_new','scrambled_second_early','scrambled_second_late','unfamiliar_new','unfamiliar_second_early','unfamiliar_second_late'},...
        'vartype1','categorical','subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');
    
    % cleanup previous version
    [~,limo_STUDY.filepathfiles,~] = fileparts(STUDY.filename);
    limo_STUDY.filepathfiles       = fullfile(STUDY.filepath,['LIMO_' limo_STUDY.filepathfiles]);
    if exist([limo_STUDY.filepathfiles filesep 'limo_batch_report'],'dir')
        rmdir([limo_STUDY.filepathfiles filesep 'limo_batch_report'],'s')
    end
    
    for sub = 1:length(STUDY.subject)
        if strcmpi(Type,'Channels') && exist(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_FaceRepetition_GLM_Channels_Time_WLS']),'dir')
            rmdir(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_FaceRepetition_GLM_Channels_Time_WLS']),'s')
        elseif strcmpi(Type,'ICs') && exist(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_FaceRepetition_GLM_Components_Time_WLS']),'dir')
            rmdir(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_FaceRepetition_GLM_Components_Time_WLS']),'s')
        end
    end
    
    % compute 1st model with OLS
    if strcmpi(Type,'Channels')
        [STUDY, ~, files] = pop_limo(STUDY, ALLEEG, 'method','WLS','measure','daterp','timelim',[-50 650],'erase','on','splitreg','off','interaction','off');
        firstlevelfiles.categorical_designWLS.Channels.model = files;
    else
        [STUDY, ~, files] = pop_limo(STUDY, ALLEEG, 'method','WLS','measure','icaerp','timelim',[-50 650],'erase','on','splitreg','off','interaction','off');
        firstlevelfiles.categorical_designWLS.ICs.model = files;
    end
    integration_results.firstlevel.categorical_designWLS.(Type) = 'categorical design with WLS estimates successful';
    
    contrast.LIMO_files      = files.mat;
    contrast.mat             = [1 1 1 -1 -1 -1 0 0 0 0 ; 0 0 0 1 1 1 -1 -1 -1 0];
    confiles                 = limo_batch('contrast only',[],contrast,STUDY); % batch here doesn't care channels or ICs since the model already exists
    if strcmpi(Type,'channels')
        firstlevelfiles.categorical_designWLS.Channels.con = confiles.con;
    else
        firstlevelfiles.categorical_designWLS.ICs.con = confiles.con;
    end
    clear confiles
    integration_results.firstlevel.categorical_designWLS.(Type) = 'categorical design and contrasts with WLS estimates successful';

catch err
    fprintf('%s\n',err.message)
    integration_results.firstlevel.categorical_designWLS.(Type) = sprintf('categorical design + contrasts with WLS estimates failed \n%s',err.message);
end

% mixed design categorical+continuous, estimate with WLS on ERSP
% --------------------------------------------------------------

try
    STUDY = std_makedesign(STUDY, ALLEEG, 2, 'name','Face_time','delfiles','off','defaultdesign','off',...
        'variable1','face_type','values1',{'famous','scrambled','unfamiliar'},'vartype1','categorical',...
        'variable2','time_dist','values2',[],'vartype2','continuous',...
        'variable3','trial_dist','values3',[],'vartype3','continuous',...
        'subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');
    
    % cleanup previous version
    for sub = 1:length(STUDY.subject)
        if strcmpi(Type,'Channels') && exist(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Face_time_GLM_Channels_Time-Frequency_OLS']),'dir')
            rmdir(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Face_time_GLM_Channels_Time-Frequency_OLS']),'s')
        elseif strcmpi(Type,'ICs') && exist(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Face_time_GLM_Components_Time-Frequency_OLS']),'dir')
            rmdir(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Face_time_GLM_Components_Time-Frequency_OLS']),'s')
        end
    end
    
    % compute 1st model with WLS
    if strcmpi(Type,'Channels')
        [STUDY, ~, files] = pop_limo(STUDY, ALLEEG, 'method','OLS','measure','dattimef','timelim',[-50 650],'freqlim',[5 30],'erase','on','splitreg','off','interaction','off');
        design = ['ses-1' filesep 'Face_detection_Face_time_GLM_Channels_Time-Frequency_OLS'];
        firstlevelfiles.mixed_designOLS.Channels.model = files;
    else
        [STUDY, ~, files] = pop_limo(STUDY, ALLEEG, 'method','OLS','measure','icatimef','timelim',[-50 650],'freqlim',[5 30],'erase','on','splitreg','off','interaction','off');
        design = ['ses-1' filesep 'Face_detection_Face_time_GLM_Components_Time-Frequency_OLS'];
        firstlevelfiles.mixed_designOLS.ICs.model = files;
    end
    integration_results.firstlevel.mixed_designOLS.(Type) = 'mixed design with OLS estimates successful';
    
    % -----------------------------------------
    % just to be sure WLS works, redo last subject
    LIMO = load(fullfile(STUDY.datasetinfo(end).filepath,[design filesep 'LIMO.mat']));
    LIMO = LIMO.LIMO;
    LIMO.design.method = 'WLS';
    LIMO.design.status = 'to do';
    save(fullfile(LIMO.dir,'LIMO.mat'),'LIMO','-v7.3')
    limo_eeg(4,LIMO.dir); clear LIMO;
    integration_results.firstlevel.mixed_designOLS.(Type) = 'mixed design with OLS estimates successful (WLS works to, test on last subject)';
    % ------------------------------------------   
    
    contrast.LIMO_files      = files.mat;
    contrast.mat             = [0 0 0 -1 1 0]; % are covariates different
    confiles                 = limo_batch('contrast only',[],contrast); % do not pass STUDY argument, should still figure it out
    if strcmpi(Type,'channels')
        firstlevelfiles.mixed_designOLS.Channels.con = confiles.con;
    else
        firstlevelfiles.mixed_designOLS.ICs.con = confiles.con;
    end
    clear confiles
    integration_results.firstlevel.mixed_designOLS.(Type) = 'mixed design with OLS estimates and contrast successful (WLS works to, test on last subject)';

catch err
    fprintf('%s\n',err.message)
    integration_results.firstlevel.mixed_designOLS.(Type) = sprintf('mixed design with OLS estimates + contrast failed \n%s',err.message);
end

% no design = mean estimate with WLS on spectrum
% --------------------------------------------------------------

try
    STUDY = std_makedesign(STUDY, ALLEEG, 3, 'name','Average','delfiles','off','defaultdesign','off',...
        'subjselect',{'sub-002','sub-003','sub-004','sub-005','sub-006','sub-007','sub-008','sub-009','sub-010','sub-011','sub-012','sub-013','sub-014','sub-015','sub-016','sub-017','sub-018','sub-019'});
    [STUDY, EEG] = pop_savestudy( STUDY, EEG, 'savemode','resave');
    
    % cleanup previous version
    for sub = 1:length(STUDY.subject)
        if strcmpi(Type,'Channels') && exist(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Average_GLM_Channels_Frequency_WLS']),'dir')
            rmdir(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Average_GLM_Channels_Frequency_WLS']),'s')
        elseif strcmpi(Type,'ICs') && exist(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Average_GLM_Components_Frequency_WLS']),'dir')
            rmdir(fullfile(STUDY.filepath,[STUDY.subject{sub} filesep 'eeg' filesep 'ses-1' filesep 'Face_detection_Average_GLM_Components_Frequency_WLS']),'s')
        end
    end
    
    % compute 1st model with WLS
    if strcmpi(Type,'Channels')
        [STUDY, ~, files] = pop_limo(STUDY, ALLEEG, 'method','WLS','measure','datspec','freqlim',[5 30],'erase','on','splitreg','on','interaction','off');
        firstlevelfiles.Average_WLS.Channels.model = files;
    else
        [STUDY, ~, files] = pop_limo(STUDY, ALLEEG, 'method','WLS','measure','icaspec','freqlim',[5 30],'erase','on','splitreg','on','interaction','off');
        firstlevelfiles.Average_WLS.ICs.model = files;
    end
    integration_results.firstlevel.Average_WLS.(Type) = 'Average with WLS estimates successful';
catch err
    fprintf('%s\n',err.message)
    integration_results.firstlevel.Average_WLS.(Type) = sprintf('Average_WLS with WLS estimates + contrast failed \n%s',err.message);
end
