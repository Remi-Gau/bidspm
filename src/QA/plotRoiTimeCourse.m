function figureFile = plotRoiTimeCourse(varargin)
  %
  % Plots the peristimulus histogram from a ROI based GLM
  %
  % USAGE::
  %
  %   plotRoiTimeCourse(tsvFile)
  %
  % :param tsvFile: obligatory argument.
  % :type tsvFile: path
  %
  % See also: bidsRoiBasedGLM(varargin)
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  isFile = @(x) exist(x, 'file') == 2;

  addRequired(p, 'tsvFile', isFile);
  addOptional(p, 'verbose', true, @islogical);

  parse(p, varargin{:});

  visible = 'off';
  if p.Results.verbose
    visible = 'on';
  end

  tsvFile = p.Results.tsvFile;
  timeCourse = bids.util.tsvread(tsvFile);
  conditionNames = fieldnames(timeCourse);

  for i = 1:numel(conditionNames)
    tmp(:, i) = timeCourse.(conditionNames{i});
  end
  timeCourse = tmp;

  jsonFile = bids.internal.file_utils(tsvFile, 'ext', '.json');
  content = bids.util.jsondecode(jsonFile);

  secs = [0:size(timeCourse, 1) - 1] * content.SamplingFrequency;

  bf = bids.File(tsvFile);

  if isGithubCi()
    return
  end

  figName = ['ROI: ' bf.entities.label];
  if isfield(bf.entities, 'hemi')
    figName = [figName ' - ' bf.entities.hemi];
  end
  spm_figure('Create', 'Tag', figName, visible);

  hold on;

  l = plot(secs, timeCourse, 'linewidth', 2);
  colors = repmat(twelveClassesColorMap(), 2, 1);
  for i = 1:numel(l)
    set(l(i), 'color', colors(i, :));
  end

  plot([0 secs(end)], [0 0], '--k');

  title(['Time courses for ' figName], ...
        'Interpreter', 'none');

  xlabel('Seconds');
  ylabel('Percent signal change');

  legend_content = regexprep(conditionNames, '_', ' ');

  axis tight;

  for i = 1:numel(conditionNames)
    legend_content{i} = sprintf('%s ; max(PSC)= %0.2f', ...
                                legend_content{i}, ...
                                content.(conditionNames{i}).percentSignalChange.max);
  end

  legend(legend_content);

  figureFile = bids.internal.file_utils(tsvFile, 'ext', '.png');
  print(gcf, figureFile, '-dpng');

end

function colors = twelveClassesColorMap()

  % from color brewer
  % https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12

  colors = [
            166, 206, 227
            31, 120, 180
            178, 223, 138
            51, 160, 44
            251, 154, 153
            227, 26, 28
            253, 191, 111
            255, 127, 0
            202, 178, 214
            106, 61, 154
            255, 255, 153
            177, 89, 40] / 256;

end