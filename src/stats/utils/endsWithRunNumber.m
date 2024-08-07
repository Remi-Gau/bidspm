function value = endsWithRunNumber(contrastName)
  %
  % USAGE::
  %
  %   endsWithRunNumber(contrastName)
  %
  %
  % Returns true if the contrast name ends with an underscore
  % followed by some number.
  %

  % (C) Copyright 2024 bidspm developers
  result = regexp( ...
                  contrastName, ...
                  '.*(_[0-9]+\$?$|_(?:ses|run)-[0-9]*$|_ses-[0-9]*_run-[0-9]*$)', ...
                  'match');
  value =  ~isempty(result);
  return
