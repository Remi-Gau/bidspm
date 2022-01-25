function [BIDS, opt] = getData(varargin)
  %
  % Reads the specified BIDS data set and updates the list of subjects to analyze.
  %
  % USAGE::
  %
  %   [BIDS, opt] = getData(opt, bidsDir)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param bidsDir: the directory where the data is ; default is :
  %                 ``fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm')``
  % :type bidsDir: string
  %
  % :returns:
  %           - :opt: (structure)
  %           - :BIDS: (structure)
  %
  % (C) Copyright 2020 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'bidsDir', @isdir);

  parse(p, varargin{:});

  opt = p.Results.opt;
  bidsDir = p.Results.bidsDir;

  if isfield(opt, 'taskName')
    msg = sprintf('\nFOR TASK(s): %s\n', strjoin(opt.taskName, ' '));
    printToScreen(msg, opt);
  end

  msg = sprintf('Getting data from:\n %s\n', bidsDir);
  printToScreen(msg, opt);

  validationInputFile(bidsDir, 'dataset_description.json');

  BIDS = bids.layout(bidsDir, opt.useBidsSchema);

  if strcmp(opt.pipeline.type, 'stats')
    BIDS.raw = bids.layout(opt.dir.raw);
  end

  % make sure that the required tasks exist in the data set
  if isfield(opt, 'taskName') && ~any(ismember(opt.taskName, bids.query(BIDS, 'tasks')))

    msg = sprintf(['The task %s that you have asked for ', ...
                   'does not exist in this data set.\n', ...
                   'List of tasks present in this dataset:\n%s'], ...
                  strjoin(opt.taskName), ...
                  createUnorderedList(bids.query(BIDS, 'tasks')));

    errorHandling(mfilename(), 'noMatchingTask', msg, false, opt.verbosity);

  end

  % TODO add check for space

  % get IDs of all subjects
  opt = getSubjectList(BIDS, opt);

  printToScreen('\nWILL WORK ON SUBJECTS\n', opt);
  printToScreen(createUnorderedList(opt.subjects), opt);
  printToScreen('\n', opt);

end