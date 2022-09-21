# remove previous tests
rm -rf .nextflow.log* work

# remove previous results
rm -rf test/results

# create a results dir
mkdir -p test/results

# run nf script
nextflow run main.nf \
  --input_dir test/data \
  --heatPCA_script heat_pca.R \
  --sample_sheet ../../real-data/sample_sheet.csv

# move module results and move to test/results
mv work/*/*/*.png test/results/ \
&& rm -rf work                # delete workdir only if final results were found
