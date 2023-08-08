/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process pca {

	publishDir "${params.results_dir}/03-pca/", mode:"copyNoFollow"

  input:
    path MATERIALS

  output:
    path "*.png", emit: pca_results

  script:
  """
  Rscript --vanilla 03-pca.R *.UP_and_DOWN_hits.xlsx *.csv
  """

}

/* name a flow for easy import */
workflow PCA {

  take:
  all_updown
  scripts_pca

  main:

  samplesheet_ch = Channel.fromPath( "${params.sample_sheet}" )

  all_updown
  .combine( scripts_pca )
  .combine( samplesheet_ch )
  | pca
  
  emit:
    pca.out[0]

}
