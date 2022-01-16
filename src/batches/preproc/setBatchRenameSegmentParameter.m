function matlabbatch = setBatchRenameSegmentParameter(varargin)
  %
  %
  % USAGE::
  %
  %   matlabbatch = setBachRenameSegmentParameter(matlabbatch, opt)
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type matlabbatch: cell
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'opt', @isstruct);

  parse(p, varargin{:});

  matlabbatch = p.Results.matlabbatch;
  opt = p.Results.opt;

  printBatchName('rename segmentation parameter file', opt);

  cfg_fileparts.files(1) = cfg_dep('Segment: Seg Params', ...
                                   returnDependency(opt, 'segment'), ...
                                   substruct('.', 'param', '()', {':'}));

  matlabbatch{end + 1}.cfg_basicio.file_dir.cfg_fileparts = cfg_fileparts;

  files = cfg_dep('Segment: Seg Params', ...
                  returnDependency(opt, 'segment'), ...
                  substruct('.', 'param', '()', {':'}));

  moveTo = cfg_dep('Get Pathnames: Directories (unique)', ...
                   substruct('.', ...
                             'val', '{}', {numel(matlabbatch)}, '.', ...
                             'val', '{}', {1}, '.', ...
                             'val', '{}', {1}), ...
                   substruct('.', 'up'));

  % TODO: adapt in case suffix is not T1w
  patternReplace(1).pattern = 'T1w';
  patternReplace(1).repl = 'label-T1w';
  patternReplace(2).pattern = 'seg8';
  patternReplace(2).repl = 'segparam';

  matlabbatch = setBachRename(matlabbatch, files, moveTo, patternReplace);

end