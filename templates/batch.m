function matlabbatch = batch(varargin)
  %
  % Short batch description
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type matlabbatch: cell
  % :param BIDS: BIDS layout returned by ``getData`` or ``bids.layout`.
  % :type BIDS: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param subLabel: subject label
  % :type subLabel: string
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  %
  % Example::
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'BIDS', @isstruct);
  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'subLabel', @ischar);

  parse(p, varargin{:});

  matlabbatch = p.Results.matlabbatch;
  BIDS = p.Results.BIDS;
  opt = p.Results.opt;
  subLabel = p.Results.subLabel;

  printBatchName('name for this batch');

  for iTask = 1:numel(opt.taskName)

    opt.query.task = opt.taskName{iTask};

    [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

    for iSes = 1:nbSessions

      % get all runs for that subject across all sessions
      [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

      for iRun = 1:nbRuns

        something = foo();

      end

      runCounter = runCounter + 1;
    end

  end

  matlabbatch{end + 1}.spm.something = something;
  matlabbatch{end}.spm.else = faa;
  matlabbatch{end}.spm.other = fii;

end