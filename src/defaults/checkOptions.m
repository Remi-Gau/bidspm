function opt = checkOptions(opt)
  %
  % Check the option inputs and add any missing field with some defaults
  %
  % USAGE::
  %
  %   opt = checkOptions(opt)
  %
  % :param opt: structure or json filename containing the options.
  % :type opt: structure
  %
  % :returns:
  %
  % - :opt: the option structure with missing values filled in by the defaults.
  %
  % **IMPORTANT OPTIONS (with their defaults):**
  %
  %  - **generic**
  %
  %     - ``opt.dir``: TODO EXPLAIN
  %
  %     - ``opt.groups = {''}`` - group of subjects to analyze
  %
  %     - ``opt.subjects = {[]}`` - suject to run in each group
  %       space where we conduct the analysis
  %       are located. See ``setDerivativesDir()`` for more information.
  %
  %     - ``opt.space = {'individual', 'IXI549Space'}`` - Space where we conduct the analysis
  %
  %     - ``opt.taskName``
  %
  %     - ``opt.query = struct('modality', {{'anat', 'func'}})`` - a structure used to specify
  %       subset of files to only run analysis on.
  %       Default = ``struct('modality', {{'anat', 'func'}})``
  %       See ``bids.query`` to see how to specify.
  %
  %  - **preprocessing**
  %
  %     - ``opt.realign.useUnwarp = true``
  %
  %     - ``opt.useFieldmaps = true`` - when set to ``true`` the
  %       preprocessing pipeline will look for the voxel displacement maps (created by
  %       ``bidsCreateVDM()``) and will use them for realign and unwarp.
  %
  %     - ``opt.fwhm.func = 6`` - FWHM to apply to the preprocessed functional images.
  %
  %  - **statistics**
  %
  %     - ``opt.model.file = ''`` - path to the BIDS model file that contains the
  %       model to speficy and the contrasts to compute.
  %
  %     - ``opt.fwhm.contrast = 6`` - FWHM to apply to the contrast images before bringing
  %       them at the group level.
  %
  %     - ``'opt.model.designOnly'`` = if set to ``true``, the GLM will be set
  %       up without associating any data to it. Can be useful for quick design matrix
  %       inspection before running estimation.
  %
  % **OTHER OPTIONS (with their defaults):**
  %
  %  - **generic**
  %
  %     - ``opt.verbosity = 1;`` - Set it to ``0`` if you want to see less output on the prompt.
  %
  %     - ``opt.dryRun = false`` - Set it to ``true`` in case you don't want to run the analysis.
  %
  %     - ``opt.pipeline.type = 'preproc'`` - Switch it to ``stats`` when running GLMs.
  %     - ``opt.pipeline.name``
  %
  %     - ``opt.zeropad = 2`` - number of zeros used for padding subject numbers, in case
  %       subjects should be fetched by their number ``1`` and not their label ``O1'``.
  %
  %     - ``opt.rename = true`` - to skip renaming files with ``bidsRename()``.
  %       Mostly for debugging as the ouput files won't be usable by any of the stats
  %       workflows.
  %
  %  - **preprocessing**
  %
  %     - ``opt.anatOnly = false`` - to only preprocess the anatomical file
  %
  %     - ``opt.anatReference.type = 'T1w'`` -  type of the anatomical reference
  %     - ``opt.anatReference.session = ''`` - session label of the anatomical reference
  %
  %     - ``opt.segment.force = false`` - set to ``true`` to ignore previous output
  %       of the segmentation and force to run it again
  %
  %     - ``opt.skullstrip.mean = false`` - to skulstrip mean functional image
  %     - ``opt.skullstrip.threshold = 0.75`` - Threshold used for the skull stripping.
  %       Any voxel with ``p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold``
  %       will be included in the mask.
  %
  %     - ``opt.stc.skip = false`` - boolean flag to skip slice time correction or not.
  %     - ``opt.stc.referenceSlice = []`` - reference slice for the slice timing correction.
  %       If left emtpy the mid-volume acquisition time point will be selected at run time.
  %     - ``opt.stc.sliceOrder = []`` - To be used if SPM can't extract slice info. NOT RECOMMENDED,
  %       if you know the order in which slices were acquired, you should be able to recompute
  %       slice timing and add it to the json files in your BIDS data set.
  %
  %     - ``opt.funcVoxelDims = []`` - Voxel dimensions to use for resampling of functional data
  %       at normalization.
  %
  %  - **preprocessing QA** (see ``functionalQA``)
  %
  %     - ``opt.QA.func`` contains a lot of options used by ``spmup_first_level_qa``
  %
  %     - ``opt.QA.func.carpetPlot = true`` to plot carpet plot
  %     - ``opt.QA.func.MotionParameters = 'on'``
  %     - ``opt.QA.func.FramewiseDisplacement = 'on'``
  %     - ``opt.QA.func.Voltera = 'on'``
  %     - ``opt.QA.func.Globals = 'on'``
  %     - ``opt.QA.func.Movie = 'on'`` ; set it to ``off`` to skip generating movies
  %       of the time series
  %     - ``opt.QA.func.Basics = 'on'``
  %
  %  - **statistics**
  %
  %     - ``opt.glm.roibased.do = false`` must be set to ``true`` to use the
  %       ``bidsRoiBasedGLM`` workflow
  %
  %     - ``opt.glm.useDummyRegressor = false`` to add dummy regressors when a condition is missing
  %       from a run. See ``bidsModelSelection()`` for more information.
  %
  %     - ``opt.glm.maxNbVols = Inf`` sets the maximum number of volumes to
  %       include in a run in a subject level GLM. This can be useful if some
  %       time series have more volumes than necessary.
  %
  %     - ``opt.QA.glm.do = true`` - If set to ``true`` the residual images of a
  %       GLM at the subject levels will be used to estimate if there is any remaining structure
  %       in the GLM residuals (the power spectra are not flat) that could indicate
  %       the subject level results are likely confounded.
  %       See ``plot_power_spectra_of_GLM_residuals.m`` and `Accurate autocorrelation modeling
  %       substantially improves fMRI reliability
  %       <https://www.nature.com/articles/s41467-019-09230-w.pdf>`_ for more info.
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  fieldsToSet = setDefaultOption();
  opt = setFields(opt, fieldsToSet);

  %  Options for toolboxes
  if checkToolbox('ALI', 'verbose', opt.verbosity > 0)
    opt = setFields(opt, ALI_my_defaults());
  end

  opt = setFields(opt, rsHRF_my_defaults());
  opt = setFields(opt, MACS_my_defaults());

  checkFields(opt);

  if any(strcmp(opt.pipeline.name, {'cpp_spm-stats', 'cpp_spm-preproc'}))
    opt.pipeline.name = 'cpp_spm';
  end

  if ~iscell(opt.query.modality)
    tmp = opt.query.modality;
    opt.query = rmfield(opt.query, 'modality');
    opt.query.modality{1} = tmp;
  end

  if ~isempty(opt.model.file)
    if exist(opt.model.file, 'file') ~= 2
      msg = sprintf('model file does not exist:\n %s', opt.model.file);
      errorHandling(mfilename(), 'modelFileMissing', msg, false, opt.verbosity);
    end
    if strcmpi(opt.pipeline.type, 'stats')
      opt = overRideWithBidsModelContent(opt);
    end
  end

  if isfield(opt, 'taskName') && ~iscell(opt.taskName)
    opt.taskName = {opt.taskName};
  end

  % deal with space
  if ~strcmpi(opt.pipeline.type, 'stats')
    fieldsToSet = struct('space', {{'individual', 'IXI549Space'}});
    opt = setFields(opt, fieldsToSet);
  end
  if isfield(opt, 'space') && ~iscell(opt.space)
    opt.space = {opt.space};
  end
  opt = mniToIxi(opt);

  opt = orderfields(opt);

  opt = setDirectories(opt);

  % TODO add some checks on the content of opt.result.Nodes().Output

end

function fieldsToSet = setDefaultOption()

  % this defines the missing fields

  fieldsToSet.verbosity = 1;
  fieldsToSet.dryRun = false;

  fieldsToSet.bidsFilterFile = struct( ...
                                      'fmap', struct('modality', 'fmap'), ...
                                      'bold', struct('modality', 'func', 'suffix', 'bold'), ...
                                      't2w',  struct('modality', 'anat', 'suffix', 'T2w'), ...
                                      't1w',  struct('modality', 'anat', 'suffix', 'T1w'), ...
                                      'roi',  struct('modality', 'roi', 'suffix', 'roi'));

  fieldsToSet.pipeline.type = '';
  fieldsToSet.pipeline.name = 'cpp_spm';

  fieldsToSet.anatOnly = false;

  fieldsToSet.useBidsSchema = false;

  fieldsToSet.fwhm.func = 6;
  fieldsToSet.fwhm.contrast = 6;

  fieldsToSet.dir = struct('input', '', ...
                           'output', '', ...
                           'derivatives', '', ...
                           'raw', '', ...
                           'preproc', '', ...
                           'stats', '', ...
                           'jobs', '');

  fieldsToSet.groups = {''};
  fieldsToSet.subjects = {[]};
  fieldsToSet.zeropad = 2;

  fieldsToSet.query.modality = {'anat', 'func'};

  fieldsToSet.anatReference.type = 'T1w';
  fieldsToSet.anatReference.session = '';

  %% Options for slice time correction
  % all in seconds
  fieldsToSet.stc.referenceSlice = [];
  fieldsToSet.stc.sliceOrder = [];
  fieldsToSet.stc.skip = false;

  %% Options for realign
  fieldsToSet.realign.useUnwarp = true;
  fieldsToSet.useFieldmaps = true;

  %% Options for segmentation
  fieldsToSet.segment.force = false;

  %% Options for skullstripping
  fieldsToSet.skullstrip.threshold = 0.75;
  fieldsToSet.skullstrip.mean = false;

  %% Options for normalize
  fieldsToSet.funcVoxelDims = [];

  fieldsToSet.rename = true;

  %% Options for model specification and results
  fieldsToSet.model.file = '';
  fieldsToSet.model.designOnly = false;
  fieldsToSet.contrastList = {};

  fieldsToSet.QA.glm.do = true;
  fieldsToSet.QA.anat.do = true;
  fieldsToSet.QA.func.carpetPlot = true;
  fieldsToSet.QA.func.Motion = 'on';
  fieldsToSet.QA.func.FD = 'on';
  fieldsToSet.QA.func.Voltera = 'on';
  fieldsToSet.QA.func.Globals = 'on';
  fieldsToSet.QA.func.Movie = 'on';
  fieldsToSet.QA.func.Basics = 'on';

  fieldsToSet.glm.roibased.do = false;
  fieldsToSet.glm.maxNbVols = Inf;
  fieldsToSet.glm.useDummyRegressor = false;

  % specify the results to compute
  fieldsToSet.result.Nodes = returnDefaultResultsStructure();

end

function checkFields(opt)

  if isfield(opt, 'taskName') && isempty(opt.taskName)

    msg = 'You may need to provide the name of the task to analyze.';
    errorHandling(mfilename(), 'noTask', msg, true, opt.verbosity);

  end

  if ~all(cellfun(@ischar, opt.groups))

    msg = 'All group names should be string.';
    errorHandling(mfilename(), 'groupNotString', msg, false, opt.verbosity);

  end

  if ~ischar(opt.anatReference.session)

    msg = 'The session label should be string.';
    errorHandling(mfilename(), 'sessionNotString', msg, false, opt.verbosity);

  end

  if ~isempty(opt.stc.referenceSlice) && length(opt.stc.referenceSlice) > 1

    msg = sprintf( ...
                  ['options.stc.referenceSlice should be a scalar.' ...
                   '\nCurrent value is: %d'], ...
                  opt.stc.referenceSlice);
    errorHandling(mfilename(), 'refSliceNotScalar', msg, false, opt.verbosity);

  end

  if ~isempty (opt.funcVoxelDims) && length(opt.funcVoxelDims) ~= 3

    msg = sprintf( ...
                  ['opt.funcVoxelDims should be a vector of length 3. '...
                   '\nCurrent value is: %d'], ...
                  opt.funcVoxelDims);
    errorHandling(mfilename(), 'voxDim', msg, false, opt.verbosity);

  end

  if isfield(opt.model, 'hrfDerivatives')

    msg = ('HRF derivatives should be set in the BIDS stats model file, not in the options.');
    errorHandling(mfilename(), 'voxDim', msg, true, opt.verbosity);

  end

end
