function [meanImg, stdImg] = computeImgBasics(varargin)
  %
  % Compute a mean and / or std of a BIDS time series.
  %
  % USAGE::
  %
  %   [meanimg, stdimg] = computeImgBasics(images, 'operators', {'mean', 'std'})
  %
  % :param images: 4D time series filename (can be gunzipped);
  % :type  images: char
  %
  % :param images: operators
  % :type  images: cellstr with 'mean' and / or 'std'
  %
  % The files will be saved in the folder of the first image
  % with an extra desc-mean or desc-std entity.
  %
  % Adapted from Cyril Pernet's spmup
  %

  % (C) Copyright 2017-2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  allowedOperator = {'mean', 'std'};

  args = inputParser;
  addRequired(args, 'images', @ischar);
  addParameter(args, 'operators', allowedOperator);

  parse(args, varargin{:});

  images = args.Results.images;

  hdr = spm_vol(images);
  Y = spm_read_vols(hdr);

  %% compute and write image
  operators = args.Results.operators;

  meanImg = [];
  if ismember('mean', operators)
    out = nanmean(Y, 4);
    meanImg = writeOutputFile(hdr(1), out, 'mean');
  end

  stdImg  = [];
  if ismember('std', operators)
    try
      out = nanstd(Y, 0, 4);
    catch
      msg = 'Serious issue: cannot get std! Trying voxel-wise.';
      logger('WARNING', msg, 'filename', mfilename(), 'id', 'cannotComputeStd');
      out = computeStdVoxelWize(Y);
    end
    stdImg = writeOutputFile(hdr(1), out, 'std');
  end

end

function outputFilename = writeOutputFile(hdr, content, operator)

  bf = bids.File(hdr.fname);
  bf.entities.desc = operator;
  bf.extension = '.nii';
  bf = bf.update;

  hdr.fname = spm_file(hdr.fname, 'filename', bf.filename);
  hdr.descrip = [operator ' image'];

  spm_write_vol(hdr, content);

  outputFilename = hdr.fname;

end

function out = computeStdVoxelWize(Y)
  out = zeros(size(Y, 1), size(Y, 2), size(Y, 3));
  for x = 1:size(Y, 1)
    for y = 1:size(Y, 2)
      for z = 1:size(Y, 3)
        try
          out(x, y, z) = nanstd(squeeze(Y(x, y, z, :)), 0);
        catch
          sprintf('serious issue voxel %g %g %g \n', x, y, z);
        end
      end
    end
  end
end
