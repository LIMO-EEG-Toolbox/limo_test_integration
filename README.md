# limo_test_integration

Suite of functions designed to test an analysis workflow - integrated with EEGLAB.

It requires the Wakeman and Henson data to be preprocessed using [limo_test_preprocess](https://github.com/LIMO-EEG-Toolbox/limo_test_integration/blob/main/limo_test_preprocess.m) which is the same as the tutorial, beside outputing erps, spectra, ersp and itc.

From these data, simply call [limo_test_integration](https://github.com/LIMO-EEG-Toolbox/limo_test_integration/blob/main/limo_test_integration.m) pointing to the STUDY file. It will then run some 1st level and test all 2nd level.
