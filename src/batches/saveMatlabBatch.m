function saveMatlabBatch(matlabbatch, batchType, opt, subLabel)
  %
  % Saves the matlabbatch job in a .mat and a .json file.
  %
  %  % USAGE::
  %
  %   saveMatlabBatch(matlabbatch, batchType, opt, [subLabel])
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param batchType:
  % :type batchType: string
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  % The .mat file can directly be loaded with the SPM batch or run directly
  % by SPM standalone or SPM docker.
  %
  % The .json file also contains heaps of info about the "environment" used
  % to set up that batch including the version of:
  %
  % - OS,
  % - MATLAB or Octave,
  % - SPM,
  % - CPP_SPM
  %
  % This can be useful for methods writing though if the the batch is generated
  % in one environment and run in another (for example set up the batch with Octave
  % on Mac OS and run the batch with Docker SPM),
  % then this information will be of little value
  % in terms of computational reproducibility.
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 4 || isempty(subLabel)
    subLabel = 'group';
  else
    subLabel = ['sub-' subLabel];
  end

  jobsDir = fullfile(opt.dir.jobs, subLabel);
  [~, ~, ~] = mkdir(jobsDir);

  filename = sprintf( ...
                     '%s_batch_%s.mat', ...
                     timeStamp(), ...
                     batchType);

  [OS, GeneratedBy] = getEnvInfo(opt);
  GeneratedBy(1).Description = batchType;

  save(fullfile(jobsDir, filename), 'matlabbatch', '-v7');

  % write as json for more "human readibility"
  opts.indent = '    ';

  json.matlabbach = matlabbatch;
  json.GeneratedBy = GeneratedBy;
  json.OS = OS;

  try
    spm_jsonwrite( ...
                  fullfile(jobsDir, strrep(filename, '.mat', '.json')), ...
                  json, opts);
  catch
    % if we have a dependency object in the batch
    % then we can't save the batch structure as a json
    % so we remove the batch
    json = rmfield(json, 'matlabbach');
    spm_jsonwrite( ...
                  fullfile(jobsDir, strrep(filename, '.mat', '.json')), ...
                  json, opts);
  end

end