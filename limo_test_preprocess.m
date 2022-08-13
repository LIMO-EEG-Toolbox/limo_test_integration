function studyfullname = limo_test_preprocess(bids_folder)

% Basic Preprocessing Pipeline - Pernet & Delorme (2021)
% Ref: From BIDS-Formatted EEG Data to Sensor-Space Group Results: 
% A Fully Reproducible Workflow With EEGLAB and LIMO EEG.
% Front. Neurosci. 14:610388. doi: 10.3389/fnins.2020.610388
% <https://www.frontiersin.org/articles/10.3389/fnins.2020.610388/full>
%
% This function preprocesses Wakeman and Henson data to create ERPs, Spectrum, 
% and ERSP than can then be used to test 1st level and 2nd level LIMO stats
% 
% FORMAT studyfullname = limo_test_preprocess(bids_folder)
%
% INPUT bids_folder is the dataset location e.g. 'F:\WakemanHenson_Faces\eeg'
% OUTPUT is the study full name i.e. fullfile(STUDY.filepath,STUDY.filename)
% Example 
%         bids_folder = 'F:\WakemanHenson_Faces\eeg';
%         [STUDY, ALLEEG, EEG] = limo_test_preprocess('bids_folder')

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
% for s=1:size(EEG,2)
%    EEG(s) = pop_chanedit(EEG(s),'nosedir','+Y');
% end

% Remove bad channels
EEG = pop_clean_rawdata( EEG,'FlatlineCriterion',5,'ChannelCriterion',0.8,...
    'LineNoiseCriterion',4,'Highpass',[0.25 0.75] ,...
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
EEG  = pop_clean_rawdata(EEG,'FlatlineCriterion','off','ChannelCriterion','off',...
     'LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,...
     'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian',...
     'WindowCriterionTolerances',[-Inf 7] );

% Extract data epochs (no baseline removed)
EEG    = pop_epoch(EEG,{'famous_new','famous_second_early','famous_second_late', ...
         'scrambled_new','scrambled_second_early','scrambled_second_late','unfamiliar_new', ...
         'unfamiliar_second_early','unfamiliar_second_late'},[-0.1 1] ,'epochinfo','yes');
epoch_test = arrayfun(@(x) size(x.data),EEG,'UniformOutput',false);
if ~all(cellfun(@(x) all(size(x)==size(epoch_test{1})), epoch_test))
    error('yikes, at least one dataset is not epoched properly!')
end
EEG    = eeg_checkset(EEG);
EEG    = pop_saveset(EEG, 'savemode', 'resave');
ALLEEG = EEG;

% update study & compute single trials
STUDY         = std_checkset(STUDY, ALLEEG);
[STUDY, EEG]  = std_precomp(STUDY, EEG, 'channels', 'savetrials','on','interp','on','recompute','on',...
    'erp','on','erpparams', {'rmbase' [-200 0]}, 'spec','on', 'ersp','on','itc','on',...
    'erspparams', {'freqlims', [5 30], 'timelimits', [-50 650]});
[STUDY, EEG]  = std_precomp(STUDY, EEG, 'components', 'savetrials','on','interp','on','recompute','on',...
    'erp','on','erpparams', {'rmbase' [-200 0]}, 'spec','on', 'ersp','on','itc','on',...
    'erspparams', {'freqs', [5 30], 'timelimits', [-50 650]});
studyfullname = fullfile(STUDY.filepath,STUDY.filename);
