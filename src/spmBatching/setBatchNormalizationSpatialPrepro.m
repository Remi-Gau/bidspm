% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, voxDim, opt)

    jobsToAdd = numel(matlabbatch) + 1;

    for iJob = jobsToAdd:(jobsToAdd + 4)

        deformationField = ...
            cfg_dep('Segment: Forward Deformations', ...
                    substruct( ...
                              '.', 'val', '{}', {opt.orderBatches.segment}, ...
                              '.', 'val', '{}', {1}, ...
                              '.', 'val', '{}', {1}), ...
                    substruct('.', 'fordef', '()', {':'}));

        % we set images to be resampled at the voxel size we had at acquisition
        matlabbatch = setBatchNormalize(matlabbatch, deformationField, voxDim);

    end

    matlabbatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = ...
        cfg_dep('Coregister: Estimate: Coregistered Images', ...
                substruct( ...
                          '.', 'val', '{}', {opt.orderBatches.coregister}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct('.', 'cfiles'));

    % NORMALIZE STRUCTURAL
    fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE STRUCTURAL\n');
    matlabbatch{jobsToAdd + 1}.spm.spatial.normalise.write.subj.resample(1) = ...
        cfg_dep('Segment: Bias Corrected (1)', ...
                substruct( ...
                          '.', 'val', '{}', {opt.orderBatches.segment}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct( ...
                          '.', 'channel', '()', {1}, ...
                          '.', 'biascorr', '()', {':'}));
    % size 3 allow to run RunQA / original voxel size at acquisition
    matlabbatch{jobsToAdd + 1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];

    % NORMALIZE GREY MATTER
    fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE GREY MATTER\n');
    matlabbatch{jobsToAdd + 2}.spm.spatial.normalise.write.subj.resample(1) = ...
        cfg_dep('Segment: c1 Images', ...
                substruct( ...
                          '.', 'val', '{}', {opt.orderBatches.segment}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct( ...
                          '.', 'tiss', '()', {1}, ...
                          '.', 'c', '()', {':'}));

    % NORMALIZE WHITE MATTER
    fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE WHITE MATTER\n');
    matlabbatch{jobsToAdd + 3}.spm.spatial.normalise.write.subj.resample(1) = ...
        cfg_dep('Segment: c2 Images', ...
                substruct( ...
                          '.', 'val', '{}', {opt.orderBatches.segment}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct( ...
                          '.', 'tiss', '()', {2}, ...
                          '.', 'c', '()', {':'}));

    % NORMALIZE CSF MATTER
    fprintf(1, ' BUILDING SPATIAL JOB : NORMALIZE CSF\n');
    matlabbatch{jobsToAdd + 4}.spm.spatial.normalise.write.subj.resample(1) = ...
        cfg_dep('Segment: c3 Images', ...
                substruct( ...
                          '.', 'val', '{}', {opt.orderBatches.segment}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct( ...
                          '.', 'tiss', '()', {3}, ...
                          '.', 'c', '()', {':'}));

end
