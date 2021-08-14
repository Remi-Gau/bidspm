% (C) Copyright 2019 Remi Gau

% This script will run the FFX and contrasts on it of the MoAE dataset
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)

clear;
clc;

run ../../initCppSpm.m;

%% Set options
opt = moae_get_option_stats();

% The following crash on Travis I
bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);