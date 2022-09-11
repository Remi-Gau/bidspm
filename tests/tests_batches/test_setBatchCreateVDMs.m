% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchCreateVDMs %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchCreateVDMs_smoke_test()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);

  opt.query.acq = '';

  BIDS = getLayout(opt);

  matlabbatch = {};
  matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subLabel);

  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag;
  matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.session.epi{1};

end
