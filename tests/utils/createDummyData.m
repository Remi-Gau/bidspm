function createDummyData()
  %

  % (C) Copyright 2022 bidspm developers

  startDir = pwd;

  script = fullfile(getTestDir(), 'createDummyDataSet.sh');

  cd(fileparts(script));
  system('sh createDummyDataSet.sh');
  cd(startDir);

end
