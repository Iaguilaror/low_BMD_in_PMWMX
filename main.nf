#!/usr/bin/env nextflow

/*================================================================
The AGUILAR LAB presents...
  The proteomics condition comparer
- A tool for comparing conditions in Synapt G2-Si Mass Spectrometer data

- This pipeline is meant to reproduce the results in: TO-DO-add url and doi after paper is published

==================================================================
Version: 0.0.1

==================================================================
Authors:
- Bioinformatics Design
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)
- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)
- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)
=============================
Pipeline Processes In Brief:

Pre-processing:

Core-processing:
_001_clean_file
_002_volcano
_003_UPandDOWN_PCA

Pos-processing

Anlysis
_A_multicondition_analysis_1

ENDING

================================================================*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PREPARE PARAMS DOCUMENTATION AND FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
params.ver = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
params.pipeline_name = "proteomics-comparer"

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at JAN 2023
*/
params.nextflow_required_version = '22.10.4'

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.help     = false   //default is false to not trigger help message automatically at every run
params.version  = false   //default is false to not trigger version message automatically at every run

params.input_dir     =	false	//if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.sample_sheet  =	false	//if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.intermediate_file1  =	false	//if no inputh path is provided, value is false to provoke the error during the parameter validation block

/* read the module with the param init and check */
include { } from './modules/doc_and_param_check.nf'

// /* load functions for testing env */
include { get_fullParent }  from './modules/useful_functions.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     INPUT PARAMETER VALIDATION BLOCK
  TODO (iaguilar) check the extension of input queries; see getExtension() at https://www.nextflow.io/docs/latest/script.html#check-file-attributes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
Output directory definition
Default value to create directory is the parent dir of --input_dir
*/
params.output_dir = get_fullParent( params.input_dir )

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script
  This directories will be automatically created by the pipeline to store files during the run
*/

params.results_dir       =  "${params.output_dir}/${params.pipeline_name}-results/"
params.intermediates_dir =  "${params.output_dir}/${params.pipeline_name}-intermediate/"

/*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/* load workflows */
include { CLEANFILE }    from  './modules/01-clean-file'
include { VOLCANO }      from  './modules/02-volcano'
include { PCA }          from  './modules/03-UPandDOWN-PCA'
include { AANALYSIS1 }   from  './modules/A-multi-condition-analysis-1'

/* load scripts to send to workdirs */
/* declare scripts channel from modules */
scripts_clean_file   = Channel.fromPath( "scripts/01-dataclean.R" )
scripts_volcano      = Channel.fromPath( "scripts/02-volcano.R" )
scripts_pca          = Channel.fromPath( "scripts/03-pca.R" )
scripts_A_analysis_1 = Channel.fromPath( "scripts/A-1-multicondition-analysis.R" )

workflow mainflow {

  main:

    all_cleaned = CLEANFILE ( scripts_clean_file )
    
    all_updown = VOLCANO ( all_cleaned, scripts_volcano )

    PCA ( all_updown, scripts_pca )

    AANALYSIS1 ( all_updown, scripts_A_analysis_1 )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {

    mainflow( )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/