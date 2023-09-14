/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { AANALYSIS1 }    from './main.nf'

/* declare input channel for testing */
all_protein_for_plsda = Channel.fromPath( "test/data/Total_protein_PLSDA-PCA.xlsx" )
all_updown = Channel.fromPath( "test/data/*.UP_and_DOWN_hits.xlsx" )

/* declare scripts channel for testing */
scripts_A_analysis_1 = Channel.fromPath( "scripts/A-1-multicondition-analysis.R" )

workflow {

  AANALYSIS1 ( all_protein_for_plsda, all_updown, scripts_A_analysis_1 )
  
}