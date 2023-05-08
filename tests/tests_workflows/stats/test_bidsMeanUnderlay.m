% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsMeanUnderlay %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsMeanUnderlay_basic()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch =  bidsMeanUnderlay(opt);

  assertEqual(fieldnames(matlabbatch{1}.spm.util), {'imcalc'});
  assertEqual(fieldnames(matlabbatch{2}.spm.util), {'imcalc'});
  assertEqual(fieldnames(matlabbatch{3}.spm.spatial), {'smooth'});
  assertEqual(fieldnames(matlabbatch{4}.spm.util), {'imcalc'});
  assertEqual(fieldnames(matlabbatch{5}), {'cfg_basicio'});
  assertEqual(fieldnames(matlabbatch{6}.spm.util), {'checkreg'});

  assertEqual(numel(matlabbatch), 6);

end
