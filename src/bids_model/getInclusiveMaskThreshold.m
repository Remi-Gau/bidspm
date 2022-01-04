function threshold = getInclusiveMaskThreshold(modelFile, nodeType)
  %
  % returns the threshold for inclusive masking of subject level GLM
  % node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  elseif ismember(nodeType, 'dataset')
    warning('No inclusive mask threshold for dataset level GLM.');
    return
  end

  model = bids.util.jsondecode(modelFile);

  node = returnModelNode(model, nodeType);

  try
    threshold = node.Model.Software.SPM.InclusiveMaskingThreshold;
  catch
    threshold = '';
  end

  if isempty(threshold)

    spm_defaults = spm_get_defaults();
    threshold =  spm_defaults.mask.thresh;

  elseif strcmpi(threshold, '-Inf')

    threshold =  -Inf;

  end

end