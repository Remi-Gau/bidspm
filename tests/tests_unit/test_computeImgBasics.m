function test_suite = test_computeImgBasics %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_computeImgBasics_basic()

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('nanmean / nanstd required.');
  end

  inputFile = fullfile(getMoaeDir(), 'inputs', 'fmriprep', 'sub-01', 'func', ...
                       'sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz');

  [meanimg, stdimg] = computeImgBasics(inputFile, 'operators', {'mean', 'std'});

  delete(meanimg);
  delete(stdimg);
end
