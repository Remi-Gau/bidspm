function ffxDir = getFFXdir(subLabel, opt)
  %
  % Sets the name the FFX directory
  %
  % USAGE::
  %
  %   ffxDir = getFFXdir(subLabel, opt)
  %
  % :param subLabel:
  % :type subLabel: char
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :return: :ffxDir: (string)
  %

  % (C) Copyright 2019 bidspm developers

  glmDirName = createGlmDirName(opt);

  opt = getOptionsFromModel(opt);

  % folder naming based on the rootNode name
  rootNode = opt.model.bm.get_root_node();
  nodeName = rootNode.Name;

  nodeNameLabel = regexprep(nodeName, '[ -_]', '');
  if ~isempty(nodeNameLabel) && ~ismember(nodeNameLabel, {'runlevel', 'run'})
    glmDirName = [glmDirName, '_node-', bids.internal.camel_case(nodeName)];
  end

  ffxDir = fullfile(opt.dir.stats, ...
                    ['sub-', deregexify(subLabel)], ...
                    glmDirName);

  if opt.glm.roibased.do
    ffxDir = [ffxDir '_roi'];
  end

  if opt.glm.concatenateRuns
    ffxDir = [ffxDir '_concat'];
  end

end

function string = deregexify(string)
  % remove any non alphanumeric characters
  string = regexprep(string, '[^a-zA-Z0-9]+', '');
end
