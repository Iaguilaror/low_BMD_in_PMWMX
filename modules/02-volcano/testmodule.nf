/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { VOLCANO }    from './main.nf'

/* declare input channel for testing */
all_cleaned = Channel.fromPath( "test/data/*.cleandata.xlsx" )

/* declare scripts channel for testing */
scripts_volcano = Channel.fromPath( "scripts/02-volcano.R" )

workflow {

  VOLCANO ( all_cleaned, scripts_volcano )
  
}