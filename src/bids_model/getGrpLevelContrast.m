function [grpLvlCon, iNode] = getGrpLevelContrast(opt)
  %
  % Returns the autocontrast part of the dataset step of the BIDS model
  %
  % USAGE::
  %
  %   function [grpLvlCon, iStep] = getGrpLevelContrast(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns: - :grpLvlCon:
  %           - :iStep:
  %
  % (C) Copyright 2019 CPP_SPM developers

  model = spm_jsonread(opt.model.file);

  [node, iNode] = returnModelNode(model, 'dataset');

  grpLvlCon = node.DummyContrasts;

end