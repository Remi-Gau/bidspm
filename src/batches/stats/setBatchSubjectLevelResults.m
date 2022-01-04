function matlabbatch = setBatchSubjectLevelResults(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subLabel, result)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch: (structure)
  %
  % See also: bidsResults, setBatchResults
  %
  % (C) Copyright 2019 CPP_SPM developers

  [matlabbatch, opt, subLabel, result] = deal(varargin{:});

  result.nbSubj = 1;

  result.contrastNb = getContrastNb(result, opt);
  if isempty(result.contrastNb)
    msg = sprintf('Skipping contrast named %s', result.Contrasts.Name);
    errorHandling(mfilename(), 'skippingContrastResults', msg, true, true);
    return
  end

  result.label = subLabel;

  result.outputNameStructure = defaultOuputNameStruct(opt, result);

  matlabbatch = setBatchResults(matlabbatch, result);

end

function contrastNb = getContrastNb(result, opt)
  %
  % identify which contrast nb actually has the name the user asked
  %

  load(fullfile(result.dir, 'SPM.mat'));

  if isempty(result.Contrasts.Name)

    printAvailableContrasts(SPM, opt);

    msg = 'No contrast name specified';

    errorHandling(mfilename(), 'missingContrastName', msg, false, true);

  end

  contrastNb = find(strcmp({SPM.xCon.name}', result.Contrasts.Name));

  if isempty(contrastNb)

    printAvailableContrasts(SPM, opt);

    msg = sprintf( ...
                  '\nThis SPM file %s does not contain a contrast named %s', ...
                  fullfile(result.dir, 'SPM.mat'), ...
                  result.Contrasts.Name);

    errorHandling(mfilename(), 'noMatchingContrastName', msg, true, true);

  end

end

function printAvailableContrasts(SPM, opt)
  printToScreen('List of contrast in this SPM file\n', opt);
  printToScreen(strjoin({SPM.xCon.name}, '\n'), opt);
  printToScreen('\n', opt);
end