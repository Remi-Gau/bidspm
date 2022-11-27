function test_suite = test_bugReport %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bugReport_output_dir()

  %%
  opt.dryRun = false;
  opt.verbosity = 0;
  opt.dir.output = fullfile(pwd, 'tmp');
  opt = checkOptions(opt);

  bugReport(opt);

  cleanUp('tmp');

end

function test_bugReport_basic()

  %%
  bugReport();

  %%
  opt.dryRun = false;
  opt.verbosity = 0;
  opt = checkOptions(opt);

  bugReport(opt);

  cleanUp('error_logs');

end

function test_bugReport_error()

  %%
  opt.dryRun = false;
  opt.verbosity = 0;
  opt = checkOptions(opt);

  try
    foo = {1} + 'a';
  catch ME
    bugReport(opt, ME);
  end

  cleanUp('error_logs');

end
