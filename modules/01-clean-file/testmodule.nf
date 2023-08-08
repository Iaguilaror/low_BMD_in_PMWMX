/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { CLEANFILE }    from './main.nf'

/* declare input channel for testing */
// NONE

/* declare scripts channel for testing */
scripts_clean_file = Channel.fromPath( "scripts/01-dataclean.R" )

workflow {
  CLEANFILE ( scripts_clean_file )
}