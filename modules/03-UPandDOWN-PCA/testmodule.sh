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
  --sample_sheet ../../real-data/sample_sheet.csv \
&& echo "[>>>] Module Test Successful" \
&& rm -rf work                                     # delete workdir only if final results were found
