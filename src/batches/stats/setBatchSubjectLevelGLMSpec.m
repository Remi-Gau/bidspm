function matlabbatch = setBatchSubjectLevelGLMSpec(varargin)
  %
  % Sets up the subject level GLM
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param BIDS:
  % :type BIDS: structure
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  [matlabbatch, BIDS, opt, subLabel] =  deal(varargin{:});

  if ~isfield(BIDS, 'raw')
    msg = sprintf(['Provide raw BIDS dataset path in opt.dir.raw .\n' ...
                   'It is needed to load events.tsv files.\n']);
    errorHandling(mfilename(), 'missingRawDir', msg, false, opt.verbosity);
  end

  getModelType(opt.model.file);

  printBatchName('specify subject level fmri model', opt);

  fmri_spec = struct('volt', 1, ...
                     'global', 'None');

  sliceOrder = returnSliceOrder(BIDS, opt, subLabel);

  TR = getAndCheckRepetitionTime(BIDS, queryFilter(opt, subLabel));

  fmri_spec.timing.units = 'secs';
  fmri_spec.timing.RT = TR;

  nbTimeBins = numel(unique(sliceOrder));
  fmri_spec.timing.fmri_t = nbTimeBins;

  % If no reference slice is given for STC,
  % then STC took the mid-volume as reference time point for the GLM.
  % When no STC was done, this is usually a good way to do it too.
  if isempty(opt.stc.referenceSlice)
    refBin = floor(nbTimeBins / 2);
  else
    refBin = opt.stc.referenceSlice / TR;
  end
  fmri_spec.timing.fmri_t0 = refBin;

  % Create ffxDir if it doesnt exist
  % If it exists, issue a warning that it has been overwritten
  ffxDir = getFFXdir(subLabel, opt);
  overwriteDir(ffxDir, opt);

  fmri_spec.dir = {ffxDir};

  fmri_spec.fact = struct('name', {}, 'levels', {});

  fmri_spec.mthresh = getInclusiveMaskThreshold(opt.model.file);

  fmri_spec.bases.hrf.derivs = getHRFderivatives(opt.model.file);

  fmri_spec.cvi = getSerialCorrelationCorrection(opt.model.file);

  subLabel = regexify(subLabel);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  sesCounter = 1;

  for iTask = 1:numel(opt.taskName)

    opt.query.task = opt.taskName{iTask};

    for iSes = 1:nbSessions

      % get all runs for that subject across all sessions
      [runs, nbRuns] = ...
          getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

      for iRun = 1:nbRuns

        % get functional files
        fullpathBoldFilename = getBoldFilenameForFFX(BIDS, opt, subLabel, iSes, iRun);

        fmri_spec = setScans(opt, fullpathBoldFilename, fmri_spec, sesCounter);

        onsetsFile = returnOnsetsFile(BIDS, opt, ...
                                      subLabel, ...
                                      sessions{iSes}, ...
                                      opt.taskName{iTask}, ...
                                      runs{iRun});

        fmri_spec.sess(sesCounter).multi = ...
            cellstr(onsetsFile);

        % get confounds
        fmri_spec.sess(sesCounter).multi_reg = {''};
        confoundsRegFile = getConfoundsRegressorFilename(BIDS, ...
                                                         opt, ...
                                                         subLabel, ...
                                                         sessions{iSes}, ...
                                                         runs{iRun});
        if ~isempty(confoundsRegFile)
          counfoundMatFile = createAndReturnCounfoundMatFile(opt, confoundsRegFile);
          fmri_spec.sess(sesCounter).multi_reg = ...
              cellstr(counfoundMatFile);
        end

        % multiregressor selection
        fmri_spec.sess(sesCounter).regress = ...
            struct('name', {}, 'val', {});

        % multicondition selection
        fmri_spec.sess(sesCounter).cond = ...
            struct('name', {}, 'onset', {}, 'duration', {});

        fmri_spec.sess(sesCounter).hpf = getHighPassFilter(opt.model.file);

        sesCounter = sesCounter + 1;

      end
    end
  end

  if opt.model.designOnly
    matlabbatch{end + 1}.spm.stats.fmri_design = fmri_spec;
  else

    fmri_spec.mask = {getInclusiveMask(opt)};

    matlabbatch{end + 1}.spm.stats.fmri_spec = fmri_spec;

  end

end

function filter = queryFilter(opt, subLabel)
  filter = opt.query;
  filter.sub =  subLabel;
  filter.suffix = 'bold';
  filter.extension = '.nii';
  filter.prefix = '';
  % in case task was not passed through opt.query
  if ~isfield(filter, 'task')
    filter.task = opt.taskName;
  end
end

function sliceOrder = returnSliceOrder(BIDS, opt, subLabel)

  filter = queryFilter(opt, subLabel);

  % Get slice timing information.
  % Necessary to make sure that the reference slice used for slice time
  % correction is the one we center our model on;
  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

  if isempty(sliceOrder) && ~opt.dryRun
    % no slice order defined here (or different across tasks)
    % so we fall back on using the number of
    % slice in the first bold image to set the number of time bins
    % we will use to upsample our model during regression creation
    fileName = bids.query(BIDS, 'data', filter);
    hdr = spm_vol(fileName{1});

    % we are assuming axial acquisition here
    sliceOrder = 1:hdr(1).dim(3);
  end

end

function fmriSpec = setScans(opt, fullpathBoldFilename, fmriSpec, sesCounter)
  if opt.model.designOnly
    try
      hdr = spm_vol(fullpathBoldFilename);
    catch
      warning('Could not open %s.\nThis expected during testing.', fullpathBoldFilename);
      % TODO a value should be passed by user for this
      % hard coded value for test
      hdr = ones(200, 1);
    end
    fmriSpec.sess(sesCounter).nscan = numel(hdr);
  else
    if opt.glm.maxNbVols == Inf
      scans = {fullpathBoldFilename};
    else
      scans = cellstr(spm_select('ExtFPList', ...
                                 spm_fileparts(fullpathBoldFilename), ...
                                 spm_file(fullpathBoldFilename, 'filename'), ...
                                 1:opt.glm.maxNbVols));
    end
    fmriSpec.sess(sesCounter).scans = scans;
  end
end

function onsetFilename = returnOnsetsFile(BIDS, opt, subLabel, session, task, run)

  % get events file from raw data set and convert it to a onsets.mat file
  % store in the subject level GLM directory
  filter = struct( ...
                  'sub',  subLabel, ...
                  'task', task, ...
                  'ses', session, ...
                  'run', run, ...
                  'suffix', 'events', ...
                  'extension', '.tsv');

  tsvFile = bids.query(BIDS.raw, 'data', filter);

  if isempty(tsvFile)
    msg = sprintf('No events.tsv file found in:\n\t%s\nfor filter:%s\n', ...
                  BIDS.raw.pth, ...
                  createUnorderedList(filter));
    errorHandling(mfilename(), 'emptyInput', msg, false);
  end

  onsetFilename = createAndReturnOnsetFile(opt, ...
                                           subLabel, ...
                                           tsvFile);
end

function mask = getInclusiveMask(opt)
  %
  % use the mask specified in the BIDS stats model
  %
  % if none is specified and we are in MNI space
  % we use the Intra Cerebal Volume SPM mask
  %

  mask = getModelMask(opt.model.file);

  if isempty(mask) && ...
          (~isempty(strfind(opt.space{1}, 'MNI')) || strcmp(opt.space, 'IXI549Space'))
    mask = spm_select('FPList', fullfile(spm('dir'), 'tpm'), 'mask_ICV.nii');
  end

  if ~isempty(mask)
    validationInputFile([], mask);
  end

end