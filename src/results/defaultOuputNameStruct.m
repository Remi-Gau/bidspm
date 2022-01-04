function outputNameStructure = defaultOuputNameStruct(opt, result)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subLabel, funcFWHM, iNode, iCon)
  %
  % :param opt:
  % :type opt: structure
  % :param result:
  % :type result: structure
  %
  % :returns: - :outputNameStructure: (structure)
  %
  % See also: setBatchSubjectLevelResults, bidsResults
  %
  % (C) Copyright 2021 CPP_SPM developers

  outputNameStructure = struct( ...
                               'suffix', 'spmT', ...
                               'ext', '.nii', ...
                               'use_schema', 'false', ...
                               'entities', struct('sub', '', ...
                                                  'task', strjoin(opt.taskName, ''), ...
                                                  'space', result.space, ...
                                                  'desc', '', ...
                                                  'label', sprintf('%04.0f', result.contrastNb), ...
                                                  'p', '', ...
                                                  'k', '', ...
                                                  'MC', ''));

end