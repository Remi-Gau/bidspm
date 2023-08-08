% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

SMOOTH = false;

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000224');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000224-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000224', 'derivatives');

space = {'MNI152NLin2009cAsym'};
participant_label = {'MSC01'};
task = {'glasslexical'};

%% Smooth
if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'participant_label', participant_label, ...
         'action', 'smooth', ...
         'task', task, ...
         'space', space, ...
         'fwhm', 8, ...
         'verbosity', 2); %#ok<*UNRCH>
end

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

%% Subject level analysis
model_file = fullfile(root_dir, ...
                      'models', ...
                      'model-ds000224_desc-glasslexical_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', participant_label, ...
       'action', 'contrasts', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'roi_atlas', 'hcpex', ...
       'space', space, ...
       'fwhm', 8, ...
       'skip_validation', true, ...
       'verbosity', 1);
