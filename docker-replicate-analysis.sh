#/bin/bash

input_dir="real-data/"
output_directory="paper-results"
samplesheet="real-data/sample_sheet.csv"

echo -e "======\n Testing NF execution \n======" \
&& rm -rf $output_directory \
&& nextflow run main.nf \
    --input_dir $input_dir \
    --sample_sheet $samplesheet \
    --intermediate_file1 real-data/pre-made-intermediate-files/Total_protein_PLSDA-PCA.xlsx \
    -with-docker r-base \
    -resume \
    -with-report $output_directory/`date +%Y%m%d_%H%M%S`_report.html \
    -with-dag $output_directory/`date +%Y%m%d_%H%M%S`.DAG.html \
&& mv proteomics-comparer-results $output_directory/ \
&& echo -e "======\n Basic pipeline TEST SUCCESSFUL \n======"
