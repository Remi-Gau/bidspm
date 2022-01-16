function [node, iNode] = returnModelNode(model, nodeType)
  %
  % (C) Copyright 2021 Remi Gau

  iNode = nan;
  node = {};

  nbNodes = numel(model.Nodes);

  if nbNodes == 1
    model.Nodes = {model.Nodes};
  end

  % TODO should probably be made more robust in case model.Nodes is a structure
  levels = cellfun(@(x) lower(x.Level), model.Nodes, 'UniformOutput', false);

  idx = ismember(levels, lower(nodeType));
  if any(idx)
    node = model.Nodes{idx};
    iNode = find(idx);
  else
    msg = sprintf('could not find a model node of type %s', nodeType);
    errorHandling(mfilename(), 'missingModelNode', msg, false, true);
  end

end