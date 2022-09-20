/* Load xlsx file */
input_excels = Channel.fromPath("${params.input_dir}/*.xlsx")

/* gather inputs 2 */
Channel
  .fromPath("${params.volcano_script}")
  .combine( input_excels )
  // .view( )
  .set{ module_input_excels }

/* extract the regions individually */
process volcano {

  // echo true

  input:
  file materials from module_input_excels

  output:
  file "*"

  """
  Rscript --vanilla volcano.R *.xlsx
  """
}
