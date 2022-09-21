/* Load xlsx file */
input_excels = Channel.fromPath("${params.input_dir}/*.xlsx")
/* Load sample_sheet file */
input_sample_sheet = Channel.fromPath("${params.sample_sheet}")

/* gather inputs 2 */
Channel
  .fromPath("${params.heatPCA_script}")
  .combine( input_excels )
  .combine( input_sample_sheet )
  // .view( )
  .set{ module_input_excels }

/* extract the regions individually */
process heatmap {

  // echo true

  input:
  file materials from module_input_excels

  output:
  file "*"

  """
  Rscript --vanilla heat_pca.R *.xlsx *.csv
  """
}
