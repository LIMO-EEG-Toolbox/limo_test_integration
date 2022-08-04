% function [STUDY, ALLEEG, EEG] = limo_test_preprocess(bids_folder)

% Basic Preprocessing Pipeline - Pernet & Delorme (2021)
% Ref: From BIDS-Formatted EEG Data to Sensor-Space Group Results: 
% A Fully Reproducible Workflow With EEGLAB and LIMO EEG.
% Front. Neurosci. 14:610388. doi: 10.3389/fnins.2020.610388
% <https://www.frontiersin.org/articles/10.3389/fnins.2020.610388/full>
%
% This function preprocesses Wakeman and Henson data to create ERPs, Spectrum, 
% and ERSP than can then be used to test 1st level and 2nd level LIMO stats
% 
% FORMAT = [STUDY, ALLEEG, EEG] = limo_test_preprocess(bids_folder)
% INPUT bids_folder is thdataset location e.g. 'F:\WakemanHenson_Faces\eeg'
% Example 
bids_folder = 'F:\WakemanHenson_Faces\eeg';
% [STUDY, ALLEEG, EEG] = limo_test_preprocess('bids_folder')


% start EEGLAB
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

% call BIDS tool BIDS
[STUDY, ALLEEG] = pop_importbids(bids_folder,'bidsevent','on','bidschanloc','on',...
                  'studyName','Face_detection','outputdir', fullfile(bids_folder, 'derivatives'), ...
                  'eventtype', 'trial_type');
ALLEEG          = pop_select( ALLEEG, 'nochannel',{'EEG061','EEG062','EEG063','EEG064'});
CURRENTSTUDY    = 1;
EEG             = ALLEEG;
CURRENTSET      = 1:length(EEG);
root            = fullfile(bids_folder, 'derivatives');

% reorient if using previous version of the data
for s=1:size(EEG,2)
    EEG(s) = pop_chanedit(EEG(s),'nosedir','+Y');
end

% Remove bad channels
EEG = pop_clean_rawdata( EEG,'FlatlineCriterion',5,'ChannelCriterion',0.8,...
    'LineNoiseCriterion',2.5,'Highpass',[0.25 0.75] ,...
    'BurstCriterion','off','WindowCriterion','off','BurstRejection','off',...
    'Distance','Euclidian','WindowCriterionTolerances','off' );

% Rereference using average reference
EEG = pop_reref( EEG,[],'interpchan',[]);

% Run ICA and flag artifactual components using IClabel
for s=1:size(EEG,2)
    EEG(s) = pop_runica(EEG(s), 'icatype','runica','concatcond','on','options',{'pca',EEG(s).nbchan-1});
    EEG(s) = pop_iclabel(EEG(s),'default');
    EEG(s) = pop_icflag(EEG(s),[NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
    EEG(s) = pop_subcomp(EEG(s), find(EEG(s).reject.gcompreject), 0);
end

% clear data using ASR - just the bad epochs
EEG = pop_clean_rawdata( EEG,'FlatlineCriterion','off','ChannelCriterion','off',...
    'LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,...
    'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian',...
    'WindowCriterionTolerances',[-Inf 7] );

% Extract data epochs (no baseline removed)
EEG    = pop_epoch( EEG,{'famous_new','famous_second_early','famous_second_late', ...
         'scrambled_new','scrambled_second_early','scrambled_second_late','unfamiliar_new', ...
         'unfamiliar_second_early','unfamiliar_second_late'},[-0.5 1] ,'epochinfo','yes');
EEG    = eeg_checkset(EEG);
EEG    = pop_saveset(EEG, 'savemode', 'resave');
ALLEEG = EEG;

% update study & compute single trials
STUDY        = std_checkset(STUDY, ALLEEG);
[STUDY, EEG] = std_precomp(STUDY, EEG, {}, 'savetrials','on','interp','on','recompute','on',...
    'erp','on','erpparams', {'rmbase' [-200 0]}, 'spec','off', 'ersp','off','itc','off');
eeglab redraw