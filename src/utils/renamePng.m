function renamePng(directory, prefix)
  %
  % Removes the _XXX suffix before the PNG extension
  % in files generated by SPM in a directory
  %
  % Wil overwrite any file that already exists
  %
  % USAGE::
  %
  %     renamePng(directory)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 1
    directory = pwd;
  end
  if nargin < 2
    prefix = 'sub';
  end

  pngFiles = spm_select('FPList', directory, ['^' prefix '-.*[0-9].png$']);

  for iFile = 1:size(pngFiles, 1)

    source = deblank(pngFiles(iFile, :));

    basename = spm_file(source, 'basename');
    target = spm_file(source, 'basename', basename(1:end - 4));

    if exist(target, 'file')
      delete(target);
    end

    try
      movefile(source, target);

    catch
      tolerant = true;
      verbosity = 2;
      msg = sprintf('Could not move file %s to %s', source, target);
      errorHandling(mfilename(), 'cannotMoveFile', msg, tolerant, verbosity);

    end

  end

end