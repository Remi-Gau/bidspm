function outputNameSpec = roiGlmOutputName(opt, subLabel, roiFileName)

  % (C) Copyright 2022 bidspm developers

  bf = bids.File(roiFileName);
  fields = {'hemi', 'desc', 'label'};
  for iField = 1:numel(fields)
    if ~isfield(bf.entities, fields{iField})
      bf.entities.(fields{iField}) = '';
    end
  end
  outputNameSpec = struct('entities', struct( ...
                                             'sub', subLabel, ...
                                             'task', strjoin(opt.taskName, ''), ...
                                             'hemi', bf.entities.hemi, ...
                                             'space', bf.entities.space, ...
                                             'label', bf.entities.label, ...
                                             'desc', bf.entities.desc));

end
