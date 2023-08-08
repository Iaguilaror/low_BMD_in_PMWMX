/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { PCA }    from './main.nf'

/* declare input channel for testing */
all_updown = Channel.fromPath( "test/data/*.UP_and_DOWN_hits.xlsx" )

/* declare scripts channel for testing */
scripts_pca = Channel.fromPath( "scripts/03-pca.R" )

workflow {

  PCA ( all_updown, scripts_pca )
  
}