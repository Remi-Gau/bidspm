% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_createAndReturnOnsetFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createAndReturnOnsetFileBasic()

  subLabel = '01';
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);
  opt.space = {'MNI'};

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  sessions = getInfo(BIDS, subLabel, opt, 'sessions');
  runs = getInfo(BIDS, subLabel, opt, 'runs', sessions{iSes});

  query = struct( ...
                 'sub',  subLabel, ...
                 'task', opt.taskName, ...
                 'ses', sessions{iSes}, ...
                 'run', runs{iRun}, ...
                 'suffix', 'events', ...
                 'extension', '.tsv');
  tsvFile = bids.query(BIDS, 'data', query);

  onsetFileName = createAndReturnOnsetFile(opt, subLabel, tsvFile);

  expectedFileName = fullfile(getDummyDataDir('stats'), 'sub-01', 'stats', ...
                              'task-vislocalizer_space-MNI_FWHM-6', ...
                              'sub-01_ses-01_task-vislocalizer_onsets.mat');

  assertEqual(exist(onsetFileName, 'file'), 2);
  assertEqual(exist(expectedFileName, 'file'), 2);

  expected_content = load(fullfile(getDummyDataDir(), 'mat_files', 'onsets.mat'));

  actual_content = load(onsetFileName);

  assertEqual(actual_content, expected_content);

end