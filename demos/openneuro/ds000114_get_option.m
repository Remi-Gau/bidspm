function opt = ds000114_get_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  % The directory where the data are located
  opt.dir.raw = '/home/remi/openneuro/ds000114/raw';

  % suject to run in each group
  opt.subjects = {'01', '02'};

  % task to analyze
  opt.taskName = 'linebisection';

  opt.query.modality = {'anat', 'func'};

  opt.bidsFilterFile.t1w.ses = 'retest';

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  %   opt.realign.useUnwarp = false;
  % - in "native" space: don't do normalization
  %   opt.space = 'individual';

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-ds000114-lineBisectionRunLevel_smdl.json');

  % specify the result to compute
  opt.results(1) = struct( ...
                               'Level',  'run', ...
                               'Contrasts', struct( ...
                                                   'Name', 'Correct_Task', ... % has to match
                                                   'Mask', false, ...
                                                   'MC', 'FWE', ... FWE, none, FDR
                                                   'p', 0.05, ...
                                                   'k', 0));

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
