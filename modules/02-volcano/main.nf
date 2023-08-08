/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process volcano {

	publishDir "${params.results_dir}/02-volcano/", mode:"copyNoFollow"

  input:
    path MATERIALS

  output:
    path "*.xlsx", emit: volcano_results
    path "*.png"

  script:
  """
  Rscript --vanilla 02-volcano.R *.cleandata.xlsx
  """

}

/* name a flow for easy import */
workflow VOLCANO {

  take:
  all_cleaned
  scripts_volcano

  main:

  all_cleaned
  .combine( scripts_volcano )
  | volcano
  
  emit:
    volcano.out[0]

}
