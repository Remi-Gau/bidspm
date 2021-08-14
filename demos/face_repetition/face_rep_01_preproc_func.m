% (C) Copyright 2019 Remi Gau
%
% This script will download the face repetition dataset from the FIL
% and will run the basic preprocessing, FFX and contrasts on it.
%
%

clear;
clc;

downloadData = false;

run ../../initCppSpm.m;

%% Set options
opt = face_rep_get_option();

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  download_convert_face_rep_ds();

end

%% Run batches
% reportBIDS(opt);
bidsCopyInputFolder(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);

% DEBUG
% bidsResliceTpmToFunc(opt);

% DEBUG
% functionalQA(opt);

bidsSmoothing(opt);