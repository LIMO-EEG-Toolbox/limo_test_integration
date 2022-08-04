# limo_test_integration

Suite of functions designed to test a workflow for a standard hierarchical analysis - integrated with EEGLAB.

It requires the Wakeman and Henson data to be preprocessed using [limo_test_preprocess](https://github.com/LIMO-EEG-Toolbox/limo_test_integration/blob/main/limo_test_preprocess.m) which is the same as the tutorial, beside outputing erps, spectra, ersp and itc.

From these data, simply call [limo_test_integration](https://github.com/LIMO-EEG-Toolbox/limo_test_integration/blob/main/limo_test_integration.m) pointing to the STUDY file. It will then run some 1st level and test all 2nd level.

## 1st level analyses

Using the STUDY functions to make designs and pop_limo, it computes
- weighted mean spectrum across all trials (WLS) for channels and ICs
- estimates for a factorial 3 (faces) by 3 (repetition) design using OLS for channels and ICs
- estimates for a mixed design 3 (faces) by 2 'deæay' covariates (duration and number of trials between repetitions) design using WLS for channels and ICs

## 2nd level analyses

