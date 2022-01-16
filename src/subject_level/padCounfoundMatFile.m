function spmSessOut = padCounfoundMatFile(varargin)
  %
  % USAGE::
  %
  %   status = padCounfoundMatFile(spmSess, opt)
  %
  % :param spmSess: obligatory argument.
  % :type spmSess: cell
  % :param opt: obligatory argument.
  % :type opt: structure
  %
  % :returns: - :status: (boolean)
  %
  % (C) Copyright 2022 CPP_SPM developers

  isSpmSessStruct = @(x) isstruct(x) && isfield(x, 'counfoundMatFile');

  p = inputParser;
  addRequired(p, 'spmSess', isSpmSessStruct);
  addRequired(p, 'opt', @isstruct);
  parse(p, varargin{:});

  spmSess = p.Results.spmSess;
  opt = p.Results.opt;

  spmSessOut = spmSess;

  if ~opt.glm.useDummyRegressor
    return
  end

  matFiles  = {spmSess.counfoundMatFile}';
  nbConfounds = [];
  for iRun = 1:numel(matFiles)
    load(matFiles{iRun}, 'names');
    nbConfounds(iRun) = numel(names);
  end

  % if all run have same number of confounds
  if numel(unique(nbConfounds)) == 1
    return
  end

  maxNbConfounds = max(nbConfounds);

  idxFilesToPad = find(nbConfounds < maxNbConfounds);
  for i = 1:numel(idxFilesToPad)

    fileToLoad = matFiles{idxFilesToPad(i)};
    load(fileToLoad, 'names', 'R');

    columnsToPad = (nbConfounds(idxFilesToPad(i)) + 1):maxNbConfounds;
    R(:, columnsToPad) = zeros(size(R, 1), numel(columnsToPad));
    names = cat(1, ...
                names, ...
                repmat({'dummyConfound'}, numel(columnsToPad), 1));

    bf = bids.File(fileToLoad);
    bf.entities.desc = 'confoundsPadded';
    bf.suffix = 'regressors';
    bf = bf.create_filename;
    outputFilename = fullfile(bf.pth, bf.filename);

    save(outputFilename, 'names', 'R');
    spmSessOut(idxFilesToPad(i)).counfoundMatFile = outputFilename;

  end

end