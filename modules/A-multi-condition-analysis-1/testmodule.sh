#!/usr/bin/env bash
## This small script runs a module test with the sample data

# remove previous tests
rm -rf .nextflow.log* work

# remove previous results
rm -rf test/results

# create a results dir
mkdir -p test/results

# run nf script
nextflow run testmodule.nf \
    --intermediate_file1 test/data/Total_protein_PLSDA-PCA.xlsx \
&& echo "[>>>] Module Test Successful" \
&& rm -rf work                                     # delete workdir only if final results were found
