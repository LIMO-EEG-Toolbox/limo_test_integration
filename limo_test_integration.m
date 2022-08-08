function integration_results = limo_test_integration(studyfullname)

% Testing that there is an integration between the different components of 
% LIMO MEEG including the integration with std_limo.m (EEGLAB). This relies
% on the automated analysis of Wakeman and Henson (2016) Face experiment
% https://openneuro.org/datasets/ds002718/versions/1.0.2
%
% FORMAT
% integration_results  = limo_test_integration(fullfile(STUDY.filepath,STUDY.filename));
%
% OUTPUT integration_results is a structure
%           integration_results.firstlevel.constant_designWLS 
%               - updates STUDY and run a 1st level ananlysis with no conditions (i.e. just contant term) using WLS
%           integration_results.firstlevel.categorical_designOLS
%               - updates STUDY and run a 1st level ananlysis with 9 faces conditions using OLS
%           integration_results.firstlevel.mixed_designWLS
%               - updates STUDY and run a 1st level ananlysis with 3 face categories and times as continuous using WLS
%
% Example: studyfullname = 'F:\WakemanHenson_Faces\eeg\derivatives\Face_detection.study';
%          integration_results = limo_test_integration(studyfullname)
%
% Cyril Pernet 2022

%% INPUT studyfullname full name (with path) of a study
if ~exist(studyfullname,'file')
    error('cannot find the study file - trying to re-run the preprocessing')
end
[root,std_name,ext] = fileparts(studyfullname);
cd(root); EEG = eeglab;

%% load STUDY
[STUDY, ALLEEG] = pop_loadstudy('filename', [std_name ext], 'filepath', root);
% update to have 3 groups
[STUDY.datasetinfo(1:6).group]   = deal('1');
[STUDY.datasetinfo(7:13).group]  = deal('2');
[STUDY.datasetinfo(14:18).group] = deal('3');

%% 1st level
[integration_results,firstlevelfiles] = limo_test_firstlevel('channels');
[tmp_results,tmp_files]               = limo_test_firstlevel('ICs');

% update the structures
fn = fieldnames(tmp_results.firstlevel);
for f=1:size(fn,1)
    integration_results.firstlevel.(fn{f}).ICs = tmp_results.firstlevel.(fn{f}).ICs;
end

fn = fieldnames(tmp_files);
for f=1:size(fn,1)
    firstlevelfiles.(fn{f}).ICs = tmp_files.(fn{f}).ICs;
end
clear tmp_results tmp_files

%% 2nd level

%% make some virtual channels // best ICs selection file
cd(root); mkdir('2nd_level_tests'); cd('2nd_level_tests');
channel_vector = limo_best_electrodes(firstlevelfiles.Average_WLS.Channels.model.mat); % map R2
save('virtual_electrode','channel_vector')

for s=1:size(firstlevelfiles.mixed_designOLS.ICs.model.mat,1)
    cond{s} = fullfile(fileparts(firstlevelfiles.mixed_designOLS.ICs.model.mat{1}),'Condition_effect_1.mat');
end
IC_vector = limo_best_electrodes(cond'); % map face effects on best component


integration_results.secondlevel.one_samplettest = limo_test_one_samplettest


integration_results.secondlevel.two_samplesttest = limo_test_two_samplesttest
integration_results.secondlevel.pairedttest = limo_test_pairedttest
integration_results.secondlevel.regression = limo_test_regression
integration_results.secondlevel.ANCOVA = limo_test_ANCOVA
integration_results.secondlevel.ANOVA = limo_test_ANOVA
integration_results.secondlevel.repeated_measures_ANOVA = limo_test_repeated_measures_ANOVA



