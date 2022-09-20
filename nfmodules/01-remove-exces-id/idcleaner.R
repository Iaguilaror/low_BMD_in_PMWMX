# read libraries required
library( "dplyr" )
library( "openxlsx" )
library( "stringr" )

# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/OP_Vs_Normal.xlsx" ## "test/data/OP_Vs_Normal.xlsxf"

# put a name to args
ifile <- args[1]

# rename the file before exit
ofile <- str_replace( string = ifile,
                      pattern = "\\.xlsx",
                      replacement = "\\.singleID\\.xlsx" )

# see sheet names
getSheetNames( file = ifile )


# create a function to fix Acc ID
idfixer <- function( the_file, the_sheet ) {
  
  # read the data
  the_data <- read.xlsx( xlsxFile = the_file,
                         sheet = the_sheet )
  
  # fix the accession
  the_data$singleID <- str_remove_all( string = the_data$Accession,
                                       pattern = ";.*$" )
  
  # last col
  lcol <- ncol( the_data )
  beforelast <- lcol - 1
  
  # new order
  norder <- c( lcol, 1:beforelast )
  
  # reorder columns
  reordered_data <- the_data[ , norder ]
  
  # return fixed df
  return( reordered_data )
  
}

# fix upregulated
upregs <- idfixer( the_file = ifile, the_sheet = 6 )

# fix downregulated
downregs <- idfixer( the_file = ifile, the_sheet = 7 )

# save the fixed DF's as different sheets in a new xlsx
write.xlsx( x = list( "Up_proteins" = upregs,
                      "Down_proteins" = downregs),
            file = ofile,
            overwrite = TRUE )
