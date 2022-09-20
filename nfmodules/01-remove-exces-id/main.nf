/* Load xlsx file */
input_excels = Channel.fromPath("${params.input_dir}/*.xlsx")

/* gather inputs 2 */
Channel
  .fromPath("${params.fixer_script}")
  .combine( input_excels )
  // .view( )
  .set{ module_input_excels }

/* extract the regions individually */
process fix_ids {

  // echo true

  input:
  file materials from module_input_excels

  output:
  file "*.singleID.xlsx"

  """
  Rscript --vanilla idcleaner.R *.xlsx
  """
}
