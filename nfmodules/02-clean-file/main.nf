/* Load xlsx file */
input_excels = Channel.fromPath("${params.input_dir}/*.xlsx")
/* Load sample_sheet file */
input_sample_sheet = Channel.fromPath("${params.sample_sheet}")

/* gather inputs 2 */
Channel
  .fromPath("${params.cleaner_script}")
  .combine( input_excels )
  .combine( input_sample_sheet )
  // .view( )
  .set{ module_input_excels }

/* extract the regions individually */
process clean_excel {

  // echo true

  input:
  file materials from module_input_excels

  output:
  file "*.cleandata.xlsx"

  """
  Rscript --vanilla dataclean.R *.xlsx *.csv
  """
}
