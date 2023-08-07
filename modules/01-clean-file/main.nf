/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process cleanfile {

	publishDir "${params.intermediates_dir}/clean-file/", mode:"copyNoFollow"

    input:
        path MATERIALS

    output:
        path "*.cleandata.xlsx", emit: cleanfile_results

  script:
  """
  ifile=\$( ls *.xlsx )
  samplesheet=\$( ls *.csv )
  Rscript --vanilla 01-dataclean.R \$ifile \$samplesheet
  """

}

/* name a flow for easy import */
workflow CLEANFILE {

  take:
    scripts_clean_file

  main:

    xlsx_ch = Channel.fromPath ( "${params.input_dir}/*.xlsx" )
    samplesheet_ch = Channel.fromPath( "${params.sample_sheet}" )

    xlsx_ch
    .combine(samplesheet_ch)
    .combine(scripts_clean_file)
    | cleanfile
 
  emit:
    cleanfile.out[0]

}
