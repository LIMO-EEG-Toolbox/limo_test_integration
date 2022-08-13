function limo_test_ANCOVA

% 1-way ANCOVA + contrast
try
    % N-Ways ANCOVA whole brain with a cell array of con files as input with empty cells 
    clear data
    index = find(arrayfun(@(x) contains(x.group,'1'), STUDY.datasetinfo));
    for s=1:length(index); data{1,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'2'), STUDY.datasetinfo));
    for s=1:length(index); data{2,s} = Model1_files.con{index(s)}(1); end
    index = find(arrayfun(@(x) contains(x.group,'3'), STUDY.datasetinfo));
    for s=1:length(index); data{3,s} = Model1_files.con{index(s)}(1); end
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('ANCOVA'); cd('ANCOVA')
    LIMOPath = limo_random_select('ANCOVA',STUDY.limo.chanloc,'LIMOfiles',data,... % transpose data = wrong but let limo fix it
        'analysis_type','Full scalp analysis', 'type','Channels',...
        'regressor_file', randn(18,2), 'nboot',101,'tfce',1,'skip design check','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'Betas.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',1,[0 0 0 1 -1 0]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'H0' filesep 'H0_Betas.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',2,[0 0 0 1 -1 0]); % boostrap / tfce

    % N-Ways ANCOVA channel 50 with file list of con files
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('ANCOVA50'); cd('ANCOVA50')
    LIMOPath = limo_random_select('ANCOVA',STUDY.limo.chanloc,'LIMOfiles',datafiles(1:2),...
        'analysis_type','1 channel/component only', 'Channel',50,'type','Channels',...
        'regressor_file', randn(13,2),'nboot',101,'tfce',1,'skip design check','yes');
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'Betas.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',1,[0 0 1 -1 0]); % contrast
    limo_contrast([pwd filesep 'Yr.mat'], [pwd filesep 'H0' filesep 'H0_Betas.mat'], ...
        [pwd filesep 'LIMO.mat'],'T',2,[0 0 1 -1 0]); % boostrap / tfce
    
    % N-Ways ANCOVA  virtual channel with file list of Betas and input parameters
    cd(fullfile(root,'2nd_level_tests'));
    mkdir('ANCOVAOPT'); cd('ANCOVAOPT')
    LIMOPath = limo_random_select('ANCOVA',STUDY.limo.chanloc,...
        'LIMOfiles',Bfiles, 'analysis_type','1 channel/component only', 'Channel',repmat(channel_vector,[2,1]),...
        'regressor_file', randn(18,2),'type','Channels','parameter',[1 4 1],'nboot',101,'tfce',1,'skip design check','yes');    
    limotest{8} = 'ANCOVA + contrast successful';
catch err
    fprintf('%s\n',err.message)
    limotest{8} = sprintf('1-way ANCOVA + contrast failed \n%s',err.message);
end
