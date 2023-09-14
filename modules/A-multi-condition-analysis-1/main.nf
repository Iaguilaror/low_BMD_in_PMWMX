/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process aanalysis1 {

  publishDir "${params.results_dir}/A-multi-condition-analysis-1/", mode:"copyNoFollow"

  input:
    path MATERIALS

  output:
    path "*.png", emit: pca_results

  script:
  """
  Rscript --vanilla A-1-multicondition-analysis.R
  """

}

/* name a flow for easy import */
workflow AANALYSIS1 {

  take:
  all_updown
  scripts_A_analysis_1

  main:

  all_protein_for_plsda = Channel.fromPath( "${params.intermediate_file1}" )

  all_updown
  .toList()
  .combine( scripts_A_analysis_1 )
  .combine( all_protein_for_plsda )
  | aanalysis1
  
  emit:
  aanalysis1.out[0]

}
