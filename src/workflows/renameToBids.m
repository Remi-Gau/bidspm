function renameToBids(opt, FWHM)
  %
  % (C) Copyright 2019 CPP_SPM developers

  createdFiles = {};

  opt.useBidsSchema = false;

  tmp = check_cfg();
  opt.spm_2_bids = tmp.spm_2_bids;

  fwhm = '';
  if nargin > 1
    opt.spm_2_bids.fwhm = FWHM;
    fwhm = sprintf('%i', opt.spm_2_bids.fwhm);
  end

  pfx = get_spm_prefix_list();

  mapping = opt.spm_2_bids.mapping;

  % TODO update entities normalization to reflect the resolution of each output image

  % this conversion could be into desc-preproc
  %   usub-01_task-facerepetition_space-individual_desc-stc_bold.nii -->
  %     sub-01_task-facerepetition_space-individual_desc-realignUnwarp_bold.nii

  % TODO write and update json content

  % TODO refactor this:
  %  - use spm prefixes instead of hard coding
  %  - probably need to turn mapping into an object with dedicated methods

  % TODO should those image exist after spatial preprocessing
  %     'cpp_spm-preproc/sub-01/anat/sub-01_space-individual_res-bold_label-GM_probseg.nii'

  % add resolution entity when reslicing TPMs
  mapping(end + 1).prefix = {'rc1'};
  mapping(end).name_spec = opt.spm_2_bids.segment.gm;
  mapping(end).name_spec.entities.res = 'bold';

  mapping(end + 1).prefix = {'rc2'};
  mapping(end).name_spec = opt.spm_2_bids.segment.wm;
  mapping(end).name_spec.entities.res = 'bold';

  mapping(end + 1).prefix = {'rc3'};
  mapping(end).name_spec = opt.spm_2_bids.segment.csf;
  mapping(end).name_spec.entities.res = 'bold';

  % segmentation of mean bold image
  mapping(end + 1).prefix = {'iy_wmeanu', 'iy_wmeanua'};
  mapping(end).name_spec = opt.spm_2_bids.segment.deformation_field.from_mni;
  mapping(end).name_spec.entities.to = 'bold';

  mapping(end + 1).prefix = {'y_wmeanu', 'y_wmeanua'};
  mapping(end).name_spec = opt.spm_2_bids.segment.deformation_field.to_mni;
  mapping(end).name_spec.entities.from = 'bold';

  mapping(end + 1).prefix = {'c1wmeanu', 'c1wmeanua'};
  mapping(end).name_spec = opt.spm_2_bids.segment.gm_norm;

  mapping(end + 1).prefix = {'c2wmeanu', 'c2wmeanua'};
  mapping(end).name_spec = opt.spm_2_bids.segment.wm_norm;

  mapping(end + 1).prefix = {'c3wmeanu', 'c3wmeanua'};
  mapping(end).name_spec = opt.spm_2_bids.segment.csf_norm;

  mapping(end + 1).prefix = {'c3wmeanu', 'c3wmeanua'};
  mapping(end).name_spec = opt.spm_2_bids.segment.csf_norm;

  % when there is the FXHM after smoothing prefix
  mapping(end + 1).prefix = {[pfx.smooth, fwhm, pfx.norm], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.unwarp, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.realign, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.unwarp], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.realign] };
  mapping(end).name_spec = opt.spm_2_bids.smooth_norm;

  mapping(end + 1).prefix = {[pfx.smooth, fwhm], ...
                             [pfx.smooth, fwhm, pfx.unwarp, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.realign, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.unwarp], ...
                             [pfx.smooth, fwhm, pfx.realign] };
  mapping(end).name_spec = opt.spm_2_bids.smooth;

  % specifics for certain files
  mapping(end + 1).prefix = {'std_u', 'std_ua'};
  mapping(end).name_spec = opt.spm_2_bids.mean;
  mapping(end).name_spec.entities.desc = 'std';

  mapping(end + 1).prefix = 'm';
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = opt.spm_2_bids.segment.bias_corrected;
  mapping(end).name_spec.entities.desc = 'skullstripped';

  mapping(end + 1).prefix = 'm';
  mapping(end).suffix = 'mask';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('label', 'brain');
  mapping(end).name_spec.entities = struct('label', 'brain', 'desc', '');

  mapping(end + 1).prefix = 'c1';
  mapping(end).ext = '.surf.gii';
  mapping(end).suffix = 'T1w';
  mapping(end).entities = '*';
  mapping(end).name_spec.ext = '.gii';
  mapping(end).name_spec.entities = struct('desc', 'pialsurf');

  % modify defaults
  for i = 1:3
    idx = strcmp(sprintf('wc%i', i), {mapping.prefix}');
    mapping(idx).name_spec.entities.res = 'bold';
  end

  idx = strcmp('wm', {mapping.prefix}');
  mapping(idx).name_spec.entities.res = 'hi';
  mapping(idx).name_spec.entities.desc = '';

  mapping(end + 1).prefix = 'wm';
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = opt.spm_2_bids.preproc_norm;
  mapping(end).name_spec.entities.res = 'hi';

  opt.spm_2_bids.mapping = flatten_mapping(mapping);

  opt.dir.input = opt.dir.preproc;
  [BIDS, opt] = setUpWorkflow(opt, 'renaming to BIDS derivatives');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    % TODO allow for posibility to only appply to certain files
    data = bids.query(BIDS, 'data', 'sub', subLabel);

    for iFile = 1:size(data, 1)

      [new_filename, ~, json] = spm_2_bids(data{iFile}, opt);

      msg = sprintf('%s --> %s\n', spm_file(data{iFile}, 'filename'), new_filename);
      printToScreen(msg, opt);

      if ismember(new_filename, createdFiles)
        warning('file already created');
      end

      createdFiles{end + 1, 1} = new_filename;

      if ~opt.dryRun && ~strcmp(new_filename, spm_file(data{iFile}, 'filename'))

        % TODO write test for this
        if ~exist(new_filename, 'file')
          movefile(data{iFile}, spm_file(data{iFile}, 'filename', new_filename));
        else
          msg = sprintf('This file already exists. Will not overwrite.\n\t%s\n', ...
                        new_filename);
          error_handling(mfilename(), 'fileAlreadyExist', msg, true, opt.verbosity);
        end

      end
    end

  end

end
