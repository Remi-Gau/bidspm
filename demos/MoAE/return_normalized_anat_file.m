function [anat_normalized_file, anat_range] = return_normalized_anat_file(opt, sub_label)
  %

  % (C) Copyright 2021 Remi Gau

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  anat_normalized_file = bids.query(BIDS, 'data',  ...
                                    'modality', 'anat', ...
                                    'space', 'IXI549Space', ...
                                    'suffix', 'T1w');

  if isempty(anat_normalized_file)
    opt.query.space = 'IXI549Space';
    [anat_normalized_file, anatDataDir] = getAnatFilename(BIDS, opt, sub_label);
    anat_normalized_file = fullfile(anatDataDir, anat_normalized_file);
  else
    anat_normalized_file = anat_normalized_file{1};
  end

  hdr = spm_vol(anat_normalized_file);
  vol = spm_read_vols(hdr);

  anat_range = [min(vol(:)) max(vol(:))];

end
