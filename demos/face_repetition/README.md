# Face repetition demo

This is based on the [event related design dataset of SPM](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri/event/).


## CLI commands

### Preprocessing

```bash
bidspm \
    $PWD/outputs/raw \
    $PWD/outputs/derivatives \
    subject \
    preprocess \
    --participant_label 01 \
    --space individual IXI549Space \
    --task facerepetition \
    --skip_validation \
    --dummy_scans 5
```

```bash
bidspm \
    $PWD/outputs/raw \
    $PWD/outputs/derivatives \
    subject \
    preprocess \
    --space individual IXI549Space \
    --anat_only \
    --skip_validation
```

### Create ROI

```bash
bidspm \
    $PWD/outputs/raw \
    $PWD/outputs/derivatives \
    subject \
    create_roi \
    --roi_atlas wang \
    --roi_name MST hMT
```

```bash
bidspm \
    $PWD/outputs/raw \
    $PWD/outputs/derivatives \
    subject \
    create_roi \
    --roi_atlas hpcex \
    --roi_name MST MT
```

## Docker

### Create ROI

```bash
docker run -it --rm \
    -v $PWD/outputs/raw:/raw \
    -v $PWD/outputs/derivatives:/derivatives \
    cpplab/bidspm:latest \
        /raw \
        /derivatives \
        subject \
        create_roi \
        --roi_atlas hcpex \
        --roi_name MST MT
```
