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

% cleanup everything in derivatives
sub = dir('sub-*');
for s =1:size(sub,1)
    rmdir(fullfile([sub(s).folder filesep sub(s).name],['eeg' filesep 'ses-1']),'s')
end

if exist('2nd_level_tests','dir')
    rmdir('2nd_level_tests','s')
end

if exist('LIMO_Face_detection','dir')
    rmdir('LIMO_Face_detection','s')
end


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
fn = fieldnames(tmp_results.firstlevel.model);
for f=1:size(fn,1)
    integration_results.firstlevel.model.(fn{f}).ICs = tmp_results.firstlevel.model.(fn{f}).ICs;
end

fn = fieldnames(tmp_results.firstlevel.contrasts);
for f=1:size(fn,1)
    integration_results.firstlevel.contrasts.(fn{f}).ICs = tmp_results.firstlevel.contrasts.(fn{f}).ICs;
end

fn = fieldnames(tmp_files.model);
for f=1:size(fn,1)
    firstlevelfiles.model.(fn{f}).ICs = tmp_files.model.(fn{f}).ICs;
end

fn = fieldnames(tmp_files.contrasts);
for f=1:size(fn,1)
    firstlevelfiles.contrasts.(fn{f}).ICs = tmp_files.contrasts.(fn{f}).ICs;
end
clear tmp_results tmp_files

%% 2nd level

%% make some virtual channels // best ICs selection file
cd(root); mkdir('2nd_level_tests'); cd('2nd_level_tests');
channel_vector = limo_best_electrodes(firstlevelfiles.model.categorical_designWLS.channels.mat); % from LIMO files, maps R2
% limo_best_electrodes(firstlevelfiles.model.categorical_designWLS.channels.mat,fullfile(root,'limo_gp_level_chanlocs.mat'))
save('virtual_electrode','channel_vector')

for s=size(firstlevelfiles.contrasts.categorical_designWLS.ICs,1):-1:1
    cond{s} = fullfile(fileparts(firstlevelfiles.contrasts.categorical_designWLS.ICs{1}{1}),'Condition_effect_1.mat');
end
IC_vector = limo_best_electrodes(cond'); % map face effects on best component
% limo_best_electrodes(cond',fullfile(root,'limo_gp_level_chanlocs.mat'))
save('IC_vector','IC_vector')

%% start doing some tests! 
integration_results.secondlevel.one_samplettest.channels_spectrum = limo_test_one_samplettest


integration_results.secondlevel.two_samplesttest = limo_test_two_samplesttest
integration_results.secondlevel.pairedttest = limo_test_pairedttest
integration_results.secondlevel.regression = limo_test_regression
integration_results.secondlevel.ANCOVA = limo_test_ANCOVA
integration_results.secondlevel.ANOVA = limo_test_ANOVA
integration_results.secondlevel.repeated_measures_ANOVA = limo_test_repeated_measures_ANOVA

%% finish off
if all(contains(limotest,'successful'))
    disp('deleting all created files - test successful')
    try mdir('2nd_level_tests','s'); end
    try rmdir(limo_rootfiles,'s'); end
else
    warning('test failure - files were not deleted from drive')
end
limotest'

