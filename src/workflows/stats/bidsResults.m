function matlabbatch = bidsResults(opt)
  %
  % Computes the results for a series of contrast that can be
  % specified at the run, subject or dataset step level (see contrast specification
  % following the BIDS stats model specification).
  %
  % USAGE::
  %
  %  bidsResults(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % See also: setBatchSubjectLevelResults, setBatchGroupLevelResults
  %
  %
  % Below is an example of how specify the option structure
  % to getsome speific results outputs for certain contrasts.
  %
  % See the `online documentation <https://cpp-spm.readthedocs.io/en/dev>`_
  % for example of those outputs.
  %
  % The field ``opt.result.Nodes`` allows you to get results from several Nodes
  % from the BIDS stats model. So you could run ``bidsResults`` once to view
  % results from the subject and the dataset level.
  %
  % Specify a default structure result for this node::
  %
  %   opt.result.Nodes(1) = returnDefaultResultsStructure();
  %
  % Specify the Node level type (run, subject or dataset)::
  %
  %   opt.result.Nodes(1).Level = 'subject';
  %
  % Specify the name of the contrast whose resul we want to see.
  % This must match one of the existing contrats (dummy contrast or contrast)
  % in the BIDS stats model for that Node::
  %
  %   opt.result.Nodes(1).Contrasts(1).Name = 'listening_1';
  %
  % For each contrat, you can adapt:
  %
  %  - voxel level threshold (``p``) [between 0 and 1]
  %  - cluster level threshold (``k``) [positive integer]
  %  - type of multiple comparison (``MC``):
  %
  %    - ``'FWE'`` is the defaut
  %    - ``'FDR'``
  %    - ``'none'``
  %
  % You can thus specify something different for a second contrast::
  %
  %   opt.result.Nodes(1).Contrasts(2).Name = 'listening_lt_baseline';
  %   opt.result.Nodes(1).Contrasts(2).MC =  'none';
  %   opt.result.Nodes(1).Contrasts(2).p = 0.01;
  %   opt.result.Nodes(1).Contrasts(2).k = 0;
  %
  % Specify how you want your output
  % (all the following are on ``false`` by default):
  %
  % .. code-block:: matlab
  %
  %   % simple figure with glass brain view and result table
  %   opt.result.Nodes(1).Output.png = true();
  %
  %   % result table as a .csv: very convenient when comes the time to write papers
  %   opt.result.Nodes(1).Output.csv = true();
  %
  %   % thresholded statistical map
  %   opt.result.Nodes(1).Output.thresh_spm = true();
  %
  %   % binarised thresholded statistical map (useful to create ROIs)
  %   opt.result.Nodes(1).Output.binary = true();
  %
  % You can also create a montage to view the results
  % on several slices at once:
  %
  % .. code-block:: matlab
  %
  %   opt.result.Nodes(1).Output.montage.do = true();
  %
  %   % slices position in mm [a scalar or a vector]
  %   opt.result.Nodes(1).Output.montage.slices = -0:2:16;
  %
  %   % slices orientation: can be 'axial' 'sagittal' or 'coronal'
  %   % axial is default
  %   opt.result.Nodes(1).Output.montage.orientation = 'axial';
  %
  %   % path to the image to use as underlay
  %   % Will use the SPM MNI T1 template by default
  %   opt.result.Nodes(1).Output.montage.background = ...
  %        fullfile(spm('dir'), 'canonical', 'avg152T1.nii');
  %
  % Finally you can export as a NIDM results zip files.
  %
  % NIDM results is a standardized results format that is readable
  % by the main neuroimaging softwares (SPM, FSL, AFNI).
  % Think of NIDM as BIDS for your statistical maps.
  % One of the main other advantage is that it makes it VERY easy
  % to share your group results on `neurovault <https://neurovault.org/>`_
  % (which you should systematically do).
  %
  % - `NIDM paper <https://www.hal.inserm.fr/view/index/identifiant/inserm-01570626>`_
  % - `NIDM specification <http://nidm.nidash.org/specs/nidm-results_130.html>`_
  % - `NIDM results viewer for SPM <https://github.com/incf-nidash/nidmresults-spmhtml>`
  %
  % To generate NIDM results zip file for a given contrats simply::
  %
  %   opt.result.Nodes(1).Output.NIDM_results = true();
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO move ps file
  % TODO rename NIDM file

  currentDirectory = pwd;

  opt.pipeline.type = 'stats';

  opt.dir.output = opt.dir.stats;

  [BIDS, opt] = setUpWorkflow(opt, 'computing GLM results');

  if isempty(opt.model.file)
    opt = createDefaultStatsModel(BIDS, opt);
    opt = overRideWithBidsModelContent(opt);
  end

  % loop trough the steps and more results to compute for each contrast
  % mentioned for each step
  for iNode = 1:length(opt.result.Nodes)

    % TODO: add a check to make sure that the request Node level exists
    % in this bids stats model: we might request dataset level,
    % but it may not be present.

    % Depending on the level step we migh have to define a matlabbatch
    % for each subject or just on for the whole group
    switch lower(opt.result.Nodes(iNode).Level)

      case 'run'

        notImplemented(mfilename, 'run level not implemented yet', opt.verbosity);

        continue

        % TODO check what happens for models with a run level specified but no
        %      subject level

      case 'subject'

        for iSub = 1:numel(opt.subjects)

          subLabel = opt.subjects{iSub};

          printProcessingSubject(iSub, subLabel, opt);

          [matlabbatch, result] = bidsResultsSubject(opt, subLabel, iNode);

          batchName = sprintf('compute_sub-%s_results', subLabel);

          saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

          renameOutputResults(result);

          renamePng(result);

        end

      case 'dataset'

        [matlabbatch, result] = bidsResultsdataset(opt, iNode);

        batchName = 'compute_group_level_results';

        saveAndRunWorkflow(matlabbatch, batchName, opt);

        renameOutputResults(result);

        renamePng(result);

      otherwise

        error('This BIDS model does not contain an analysis step I understand.');

    end

  end

  cd(currentDirectory);

end

function [matlabbatch, result] = bidsResultsSubject(opt, subLabel, iNode)

  matlabbatch = {};

  result.space = opt.space;

  result.dir = getFFXdir(subLabel, opt);

  for iCon = 1:length(opt.result.Nodes(iNode).Contrasts)

    result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);
    if isfield(opt.result.Nodes(iNode), 'Output')
      result.Output =  opt.result.Nodes(iNode).Output;
    end

    matlabbatch = setBatchSubjectLevelResults(matlabbatch, ...
                                              opt, ...
                                              subLabel, ...
                                              result);

  end

end

function [matlabbatch, result] = bidsResultsdataset(opt, iNode)

  matlabbatch = {};

  result.space = opt.space;

  for iCon = 1:length(opt.result.Nodes(iNode).Contrasts)

    result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);
    if isfield(opt.result.Nodes(iNode), 'Output')
      result.Output =  opt.result.Nodes(iNode).Output;
    end

    result.dir = fullfile(getRFXdir(opt), result.Contrasts.Name);

    matlabbatch = setBatchGroupLevelResults(matlabbatch, ...
                                            opt, ...
                                            result);

    matlabbatch = setBatchPrintFigure(matlabbatch, ...
                                      opt, ...
                                      fullfile(result.dir, figureName(opt)));

  end

end

function renameOutputResults(results)
  % we create new name for the nifti output by removing the
  % spmT_XXXX prefix and using the XXXX as label- for the file

  outputFiles = spm_select('FPList', results.dir, '^spmT_[0-9].*_sub-.*$');

  for iFile = 1:size(outputFiles, 1)

    source = deblank(outputFiles(iFile, :));

    basename = spm_file(source, 'basename');
    split = strfind(basename, '_sub');
    p = bids.internal.parse_filename(basename(split + 1:end));
    p.entities.label = basename(split - 4:split - 1);

    bidsFile = bids.File(p);

    target = spm_file(source, 'basename', bidsFile.filename);

    movefile(source, target);
  end

end

function renamePng(results)
  %
  % removes the _XXX suffix before the PNG extension.

  pngFiles = spm_select('FPList', results.dir, '^sub-.*[0-9].png$');

  for iFile = 1:size(pngFiles, 1)
    source = deblank(pngFiles(iFile, :));
    basename = spm_file(source, 'basename');
    target = spm_file(source, 'basename', basename(1:end - 4));
    movefile(source, target);
  end

end

function filename = figureName(opt)
  p = struct( ...
             'suffix', 'designmatrix', ...
             'ext', '.png', ...
             'entities', struct( ...
                                'task', strjoin(opt.taskName, ''), ...
                                'space', opt.space));
  bidsFile = bids.File(p, 'use_schema', false);
  filename = bidsFile.filename;
end
