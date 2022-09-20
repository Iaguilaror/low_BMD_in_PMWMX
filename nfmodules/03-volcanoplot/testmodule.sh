# remove previous tests
rm -rf .nextflow.log* work

# remove previous results
rm -rf test/results

# create a results dir
mkdir -p test/results

# run nf script
nextflow run main.nf \
  --input_dir test/data \
  --volcano_script volcano.R

# move module results and move to test/results
mv work/*/*/*.volcano*.png work/*/*/*.UP_and_DOWN_hits.xlsx test/results/ \
&& rm -rf work                # delete workdir only if final results were found
