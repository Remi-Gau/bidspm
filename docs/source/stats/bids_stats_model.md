(bids_stats_model)=

# BIDS stats model

This file allows you to specify the GLM to run and which contrasts to compute.

It follows
[BIDS statistical model](https://bids-standard.github.io/stats-models/index.html).

This type of JSON file is a bit more complicated than the usual JSON files, you
might be acquainted with in BIDS. So make sure you have a read through the
[JSON 101](https://bids-standard.github.io/stats-models/json_101.html) page.

Then have a look at the
[walkthrough](https://bids-standard.github.io/stats-models/walkthrough-1.html)
that explains how to build a simple model.

<!-- ## Create a default BIDS model for a dataset
See this [section](general_information#bidspm)
 -->

## Validate your model

### In Visual Studio Code

You can add those lines to the `.vscode/settings.json` of your project to help
you validate BIDS stats models as you write them.

```{literalinclude} ../../../.vscode/settings.json
   :language: json
```

### In the browser

Otherwise you can use
[the online validator](https://bids-standard.github.io/stats-models/validator.html)
and copy paste your model in it.

### Using the BIDS stats model python package

Requires python and pip.

From within the bidspm folder open a terminal and install the bidspm package.

```bash
pip install .
```

Then you can validate your model with the following command.

```bash
validate_model path_to_your_model_json
```

## Loading and interacting with a BIDS stats model

You can use the `BidsModel` class to create a bids model instance and interact
with. This class inherits from bids-matlab {mat:class}`+bids.Model` class.

```{eval-rst}
.. autoclass:: src.bids_model.BidsModel
   :members:
```

There are also extra functions to interact with those models.

```{eval-rst}
- :func:`getContrastsList`
- :func:`getDummyContrastsList`
```

## bidspm implementation of the BIDS stats model

bidspm only implements a subset of what is currently theoretically possible with
the BIDS stats model.

For example, at the subject level the bidspm can only access variables, that are
in the `events.tsv` in that raw dataset or in the `regressors.tsv` or
`timeseries.tsv` generated by the preprocessing pipeline.

At the group level, it is only possible to access some variables from the
`participants.tsv` file.

### Transformation

The `Transformations` object allows you to define what you want to do to some
variables, before you put them in the design matrix.

Currently bidspm can only transform variables contained in `events.tsv` files.

It uses
[bids-matlab transformers](https://bids-matlab.readthedocs.io/en/main/variable_transformations.html)
to run those transformations. Please see this bids-matlab documentation to know
how to use them and call them in your JSON.

You can find a list of the available variables transformations in the
[bids matlab doc](https://bids-matlab.readthedocs.io/en/main/variable_transformations.html)
and on the
[variable-transforms repository](https://bids-matlab.readthedocs.io/en/main/variable_transformations.html)

The advantage of these bids-matlab transformers is that they allow you to
directly test them on tsv files to quickly see what outcome a series of
transformers will produce.

Below is an example on how to subtract 3 seconds from the event onsets of the
conditions `motion` listed in the `trial_type` columns of the `events.tsv` file,
and put the output in a variable called `motion`.

```json
"Transformations": {
    "Transformer": "bidspm",
    "Instructions": [
        {
            "Name": "Subtract",
            "Input": [
              "onset"
            ],
            "Query": "trial_type==motion",
            "Value": 3,
            "Output": [
                "motion"
            ]
        }
    ]
}
```

At the subject level, bidspm can only access apply transformation on the content
`events.tsv`.

You can find demo of how to design the transformers for your analysis
in the `demos/transformers` folder and
also in `demos/ds003717/code/04_transformation.m`.

### HRF

For a given `Node`, `Model.X` defines the variables that have to be put in the
design matrix.

Here `trans_?` means any of the translation parameters (in this case `trans_x`,
`trans_y`, `trans_z`) from the realignment that are stored in `_confounds.tsv`
files.

Similarly `*outlier*` means that ANY "scrubbing" regressors containing the word
`outlier` created by fMRIprep or bidspm to detect motion outlier or potential
dummy scans will be included.

```json
"Model": {
    "Type": "glm",
    "X": [
        "motion",
        "static",
        "trans_?",
        "rot_?",
        "*outlier*"
    ],
    "HRF": {
        "Variables": [
            "motion",
            "static"
        ],
        "Model": "spm"
    }
}
```

`HRF` specifies:

- which variables of `X` have to be convolved
- what HRF model to use to do so.

You can choose from:

- `"spm"`
- `"spm + derivative"`
- `"spm + derivative + dispersion"`

Not yet implemented:

- `"fir"`

<!--
```json
"Model": {
                            "Type": "glm",
                            "X": [
                                "motion", -------- Those 2 conditions will be convolved
                                "static", -------|   using the canonical HRF only.
Those 3 conditions      <-------"trans_?",       |
    will not            <-------"rot_?",         |
  be convolved.         <-------"*outlier*"      |
                            ],                   |
                            "HRF": {             |
                                "Variables": [   |
                                    "motion", <--|
                                    "static"  <--|
                                ],
                                "Model": "spm"
}
```
-->

```{image} ./images/gui_batch_model_hrf.png
:alt: Corresponding options in SPM batch
:align: center
```

### Software

<!-- markdown-link-check-disable -->
By default, bidspm will use SPM's FAST model for the [`SerialCorrelation` model](serial_correlation_model).
<!-- markdown-link-check-enable -->
It will also use a value of 0.8 for the `InclusiveMaskingThreshold`
to define the implicit inclusive mask
that is used by SPM to determine in which voxels the GLM will be estimated
(the value is taken from`defaults.mask.thresh` from SPM's defaults).

This corresponds to explicitly setting the following fields in the ``Model.Software.SPM``
object of a node in the BIDS stats model.

```json
{
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
      "Model": {
        "X": ["trial_type.listening"],
        "HRF": {
          "Variables": ["trial_type.listening"],
          "Model": "spm"
        },
        "Type": "glm",
        "Software": {
          "SPM": {
            "SerialCorrelation": "FAST",
            "InclusiveMaskingThreshold": 0.8
          }
        }
      }
    }
  ]
}
```

These values will explicitly be added to your your default BIDS stats model
if you use bidspm `'default_model'` action.

```matlab
bidspm(bids_dir, output_dir, 'dataset', ...
        'action', 'default_model')
```

Note that if you wanted to use the `AR(1)` model for the serial correlation
and to include all voxels in the implicit mask,
you would have to set the following:

```json
{
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
      "Model": {
        "X": ["trial_type.listening"],
        "HRF": {
          "Variables": ["trial_type.listening"],
          "Model": "spm"
        },
        "Type": "glm",
        "Software": {
          "SPM": {
            "SerialCorrelation": "AR(1)",
            "InclusiveMaskingThreshold": "-Inf"
          }
        }
      }
    }
  ]
}
```

```{figure} ./images/gui_batch_model_serialCorrelation_maskThresh.png
---
name: software_spm_batch
align: center
---
Corresponding options in SPM batch
```

#### Results

It is possible to specify the results you want to view directly
in the `Model.Software` object of any `Nodes` in the BIDS stats model.

See the help section of the {func}`bidsResults` function for more detail,
but here is an example how you could specify it in a JSON.

```json
"Model": {
    "Software": {
        "bidspm": {
          "Results": [
              {
                "name": [
                    "contrast_name", "other_contrast_name"
                ],
                "p": 0.05,
                "MC": "FWE",
                "png": true,
                "binary": true,
                "nidm": true,
                "montage": {
                    "do": true,
                    "slices": [
                    -4,
                    0,
                    4,
                    8,
                    16
                    ],
                    "background": {
                    "suffix": "T1w",
                    "desc": "preproc",
                    "modality": "anat"
                    }
                }
              },
              {
                "Description": "Note that you can specify multiple results objects, each with different parameters.",
                "name": [
                    "yes_another_contrast_name"
                ],
                "p": 0.01,
                "k": 10,
                "MC": "none",
                "csv": true,
                "atlas": "AAL"
              }
          ]
        }
    }
}
```

### Contrasts

#### Run level

To stay close to the way most SPM users are familiar with,
all runs are analyzed in one single GLM.

Contrasts are the run level
that are either specified using `DummyContrasts` or `Contrasts` will be computed.

##### Implicit contrast numbering

If a run label or session label cannot be inferred from the BIDS filenames
for example with a subject like this one (with trial type `listening`):

```
sub-01
└── func
    ├── sub-01_task-auditory_bold.nii
    └── sub-01_task-auditory_events.tsv
```

a number will be appended to their name (for example `listening_1`)
as shown in the SPM gui in {ref}`contrast_1`.

```{literalinclude} ./examples/model-NoRun_smdl.json
:language: json
:emphasize-lines: 22-39
```

```{figure} ./images/gui_contrast_no_run.png
---
name: contrast_1
align: center
---
Contrast naming when no explicit run or session can be inferred
```

##### Explicit contrast numbering

###### Run label

When possible the contrast name
will be containing the BIDS session and / or run label
from where it came from.
For example `cash_demean_run-1`, `cash_demean_run-2` if only run labels are available,
with a subject like this one (with trial type `cash_demean`):

```
sub-01
└── func
    ├── sub-01_task-balloonanalogrisktask_run-01_bold.nii.gz
    ├── sub-01_task-balloonanalogrisktask_run-01_events.tsv
    ├── sub-01_task-balloonanalogrisktask_run-02_bold.nii.gz
    ├── sub-01_task-balloonanalogrisktask_run-02_events.tsv
    ├── sub-01_task-balloonanalogrisktask_run-03_bold.nii.gz
    └── sub-01_task-balloonanalogrisktask_run-03_events.tsv
```

as shown in {ref}`contrast_run-1` and {ref}`contrast_run-2`.

```{literalinclude} ./examples/model-ContrastWithRuns_smdl.json
:language: json
:emphasize-lines: 29-37
```

```{figure} ./images/gui_contrast_run_1.png
---
name: contrast_run-1
align: center
---
Contrast for run-1
```

```{figure} ./images/gui_contrast_run_2.png
---
name: contrast_run-2
align: center
---
Contrast for run-2
```

###### Session label

For a subject likes this one (with trial type `Correct_Task`)

```
sub-01
├── ses-retest
│   └── func
│       ├── sub-01_ses-retest_task-linebisection_bold.nii.gz
│       └── sub-01_ses-retest_task-linebisection_events.tsv
└── ses-test
    └── func
        ├── sub-01_ses-test_task-linebisection_bold.nii.gz
        └── sub-01_ses-test_task-linebisection_events.tsv
```

contrasts would be named `Correct_Task_ses-test`, `Correct_Task_ses-retest`
since only session labels are available

#### Subject level

At the moment the only type of model supported at the subject level are:

- averaging of run level contrasts (fixed effect analysis)
- cross-session comparisons

##### fixed effect analysis

In this case the only the basename of the contrast being averaged is kept,
and any session or run label is removed.

```{literalinclude} ./examples/model-contrastsSubject_smdl.json
:language: json
```

```{figure} ./images/gui_contrast_subject_level.png
---
name: contrast_subject
align: center
---
Subject level contrast averaging beta across runs
```

##### cross-session comparisons

```{literalinclude} ./examples/model-crossSession_smdl.json
:language: json
```

```{figure} ./images/gui_contrast_cross_session.png
---
name: contrast_subject_cross_sessions
align: center
---
Subject level contrast averaging beta across runs
```

## Dataset level

At the moment only, the only type of models that are supported are:

### one sample t-test: averaging across all subjects

```{literalinclude} ./examples/model-datasetLevel_smdl.json
:language: json
```

### one sample t-test: averaging across all subjects of a specific group

```{literalinclude} ./examples/model_withinGroup_smdl.json
:language: json
:emphasize-lines: 5-8
```

### 2 samples t-test: comparing 2 groups

Participants are allocated to a group based on a the corresponding column
in the `participants.tsv` of in the raw dataset (`Group` in this case).

```{literalinclude} ./examples/model_betweenGroups_smdl.json
:language: json
:emphasize-lines: 8-28
```

### one way ANOVA: comparing several groups

Participants are allocated to a group based on a the corresponding column
in the `participants.tsv` of in the raw dataset (`Group` in this case).

```{literalinclude} ./examples/model_oneWayAnova_smdl.json
:language: json
:emphasize-lines: 64-108
```

```{note}
Contrast must be explicitly passed the `Edges.Filter.contrast`.
```

### Method section

It is possible to write a draft of method section based on a BIDS statistical model.

```matlab
opt.model.file = fullfile(pwd, ...
                          'models', ...
                          'model-faceRepetition_smdl.json');
opt.fwhm.contrast = 0;
opt = checkOptions(opt);

opt.designType = 'block';

outputFile = boilerplate(opt, ...
                        'outputPath', pwd, ...
                        'pipelineType', 'stats');
```

```{literalinclude} ../output/examples/stats.md
   :language: markdown
```

## Parametric modulation

Those are not yet fully implemented but there is an example of how to get
started in the face repetition demo folder.

```{literalinclude} ../../../demos/face_repetition/models/model-faceRepetitionParametric_smdl.json
   :language: json
```

See the help section of `convertOnsetTsvToMat` for more information.

## Examples

There are several examples of models
in the [model zoo](https://github.com/bids-standard/model-zoo)
along with links to their datasets.

<!-- markdown-link-check-disable -->

Several of the [demos](demos) have their own model
and you can find several "dummy" models (without corresponding data) used for testing
[in this folder](https://github.com/cpp-lln-lab/bidspm/tree/main/tests/data/models).

<!-- markdown-link-check-enable -->

An example of JSON file could look something like that:

```{literalinclude} ../../../tests/data/models/model-vislocalizer_smdl.json
   :language: json
```