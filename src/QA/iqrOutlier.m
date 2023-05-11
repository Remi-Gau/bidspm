function [I] = iqrOutlier(varargin)
  %
  % Return a logical vector that flags outliers as 1s based
  % on the IQR (interquantile range) methods described in Wilcox 2012 p 96-97.
  %
  % USAGE::
  %
  %   [I] = iqrOutlier(a, out)
  %
  %
  % :param a: vector of data;
  % :type  a: array
  %
  % :param out: determines the thresholding:
  %             - 1 bilateral
  %             - 2 unilateral
  % :type  out: int
  %
  % Uses Carling's modification of the boxplot rule.
  %
  % An observation Xi is declared an outlier if:
  %
  %   Xi<M-k(q2-q1) or Xi>M+k(q2-q1)
  %
  % where:
  %  - M is the sample median
  %  - k = (17.63n - 23.64) / (7.74n - 3.71),
  %   - where n is the sample size.
  %
  %
  % Adapted from Cyril Pernet's spmup
  %

  % (C) Copyright 2016-2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  args = inputParser;
  addRequired(args, 'a', @isnumeric);
  addOptional(args, 'out', 1, @(x) ismember(x, [1, 2]));

  parse(args, varargin{:});

  a = args.Results.a;
  out = args.Results.out;

  a = a(:);
  n = length(a);

  % inter-quartile range
  y = sort(a);
  j = floor(n / 4 + 5 / 12);
  g = (n / 4) - j + (5 / 12);
  k = n - j + 1;

  lowerQuartile = (1 - g) .* y(j) + g .* y(j + 1);
  upperQuartile = (1 - g) .* y(k) + g .* y(k - 1);
  value = upperQuartile - lowerQuartile;

  % outliers
  M = median(a);
  CarlinK = (17.63 * n - 23.64) / (7.74 * n - 3.71);
  if out == 1
    I = a < (M - CarlinK * value) | a > (M + CarlinK * value);
  else
    I = a > (M + CarlinK * value); % only reject data with a too high value
  end
  I = I + isnan(a);

end
