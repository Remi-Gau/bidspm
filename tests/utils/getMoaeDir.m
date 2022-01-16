function moaeDir = getMoaeDir()
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  moaeDir = spm_file(fullfile(thisDir, '..', '..', 'demos', 'MoAE'), 'cpath');

end