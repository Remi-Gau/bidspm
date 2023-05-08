function matlabbatch = bidsMeanUnderlay(varargin)
  %
  % Create a mean structural image and mean mask over the sample.
  %
  %
  % USAGE::
  %
  %  bidsMeanUnderlay(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param nodeName: name of the BIDS stats model to run analysis on
  % :type nodeName: char
  %
  %

  % (C) Copyright 2020 bidspm developers

  args = inputParser;

  args.addRequired('opt', @isstruct);

  args.parse(varargin{:});

  opt =  args.Results.opt;

  opt.pipeline.type = 'stats';

  description = 'create mean underlay';

  opt.dir.output = opt.dir.stats;

  % To speed up group level we skip indexing data
  indexData = false;
  [~, opt] = setUpWorkflow(opt, description, [], indexData);

  checks(opt);

  matlabbatch = {};

  opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');
  opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));

  matlabbatch = setBatchMeanAnatAndMask(matlabbatch, ...
                                        opt, ...
                                        opt.dir.output);
  saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

  opt.pipeline.name = 'bidspm';
  opt.pipeline.type = 'groupStats';
  initBids(opt, 'description', description, 'force', false);

  cleanUpWorkflow(opt);

end

function checks(opt)
  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    id = 'tooManySpaces';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end
end
