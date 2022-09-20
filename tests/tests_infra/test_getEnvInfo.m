% (C) Copyright 2022 bidspm developers

function test_suite = test_getEnvInfo %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getEnvInfo_basic()

  opt.dryRun = false;
  opt.verbosity = 0;

  [OS, generatedBy] = getEnvInfo(opt);

  %   OS.platform
  %   OS.environmentVariables
  %   generatedBy

end
