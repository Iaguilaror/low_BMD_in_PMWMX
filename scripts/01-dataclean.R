# read libraries required
library( "dplyr" )
library( "openxlsx" )
library( "stringr" )
library( "matrixStats" )

# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/OP_Vs_Normal.xlsx" ## "test/data/OP_Vs_Normal.xlsxf"
# args[2] <- "test/data/sample_sheet.csv" ## "test/data/sample_sheet.csv"

# put a name to args
ifile <- args[1]
sample_sheet <- args[2]

# rename the file before exit
ofile <- str_replace( string = ifile,
                      pattern = "\\.xlsx",
                      replacement = "\\.cleandata\\.xlsx" )

# see sheet names
getSheetNames( file = ifile )

# Cleaning rows. Eliminate Inf and such ====
data_all <- read.xlsx( xlsxFile = ifile,
                       sheet = 1 )

# Separate data with no unique peptide
only_ids <- data_all %>%
  filter( Unique.peptides == 0 )

# Separate peptides found exclusively in a sample
exclusive <- data_all %>%
  filter( Max.fold.change == "Infinity" )

# find rows tagged as reverse
index_reverse <- str_detect( string = data_all$Accession,
                             pattern = "REVERSE")

# Separate peptides tagged as reverse
reverse <- data_all %>%
  filter( index_reverse )

# Now get the useful peptides
quantified <- data_all %>%
  filter( Unique.peptides != 0,
          Max.fold.change != Inf,
          !index_reverse )

# Calculate values by condition (mean, cv, etc ) ====
# read the sample sheet
the_samples <- read.csv( file = sample_sheet )

# Get the names of each condition in the xlsx filename
the_conditions <- basename( path = ifile ) %>%
  str_remove( string = ., pattern = ".*/") %>%
  str_remove( string = ., pattern = "\\.xlsx") %>%
  str_split( string = ., pattern = "_" ) %>%
  unlist( )

# get name 1
cond_1 <- the_conditions[1]
# get name 2
cond_2 <- the_conditions[3]

# Lets calculate values for conditon 1 ====

# Get samples ids
ids_cond_1 <- the_samples %>%
  filter( condition == cond_1 ) %>%
  pull( muestra )

# Build a regexp that includes any of the samples in condition 1
regex_1 <- paste( ids_cond_1,
                  collapse = "|" )

# Find the colum position for each sample in condition 1
pos_samples_1 <- str_detect( string = colnames( quantified ),
                             pattern = regex_1 ) %>%
  which()

# Get a dataframe only for condition 1
data_cond_1 <- quantified %>%
  select( all_of( pos_samples_1 ) )

# Calculate values of interest for condition 1
final_cond_1 <- data_cond_1 %>%
  mutate( average.cond1 = rowMeans( . ) ) %>%
  mutate( log10.cond1 = log10( average.cond1 ) ) %>%
  mutate( sd.cond1 = as.matrix( data_cond_1 ) %>% rowSds( ) ) %>%
  mutate( CV.cond1 = sd.cond1 / average.cond1 ) %>%
  mutate( Count.cond1 = rowSums( data_cond_1 > 0 ) )

# Lets calculate values for conditon 2 ====

# Get samples ids
ids_cond_2 <- the_samples %>%
  filter( condition == cond_2 ) %>%
  pull( muestra )

# Build a regexp that includes any of the samples in condition 2
regex_2 <- paste( ids_cond_2,
                  collapse = "|" )

# Vamos a buscar el numero de columnas que corresponden a las the_samples de la condicion 1
pos_samples_2 <- str_detect( string = colnames( quantified ),
                             pattern = regex_2 ) %>%
  which()

# Get a dataframe only for condition 1
data_cond_2 <- quantified %>%
  select( all_of( pos_samples_2 ) )

# Calculate values of interest for condition 1
final_cond_2 <- data_cond_2 %>%
  mutate( average.cond2 = rowMeans( . ) ) %>%
  mutate( log10.cond2 = log10( average.cond2) ) %>%
  mutate( sd.cond2 = as.matrix( data_cond_2 ) %>% rowSds( ) ) %>%
  mutate( CV.cond2 = sd.cond2 / average.cond2 ) %>%
  mutate( Count.cond2 = rowSums( data_cond_2 > 0 ) )

# gather all of the calculated values ====
# prepare base columns from original dataframe
base_data <- quantified %>%
  rename( Anova..p. = "Anova.(p)" ) %>%
  select( Accession,
          Peptide.count,
          Unique.peptides,
          Anova..p.,
          Max.fold.change,
          Description )

# bind side by side the columns
# This works because we did NOT REARRANGE any Df previously
bound_data <- bind_cols( base_data,
                         final_cond_1,
                         final_cond_2 )

# Took a while, but niiiice :)

# We will filther by n of samples with Data in each condition ====
# get the max of samples in condition 1
n_samples_1 <- the_samples %>%
  filter( condition == cond_1 ) %>%
  nrow( )

# get the max of samples in condition 2
n_samples_2 <- the_samples %>%
  filter( condition == cond_2 ) %>%
  nrow( )

# remove rows (peptides) where data was missing in any replicate (injection) of any condition (1 or 2)
# IOW: number of samples with data must be equal to number of samples in experiment
filtered_data <- bound_data %>%
  filter( Count.cond1 == n_samples_1,
          Count.cond2 == n_samples_2 )

# Separate peptides with missing data in any of the samples (condition 1 or 2)
removed_by_missing <- bound_data %>%
  filter( Count.cond1 < n_samples_1 |
            Count.cond2 < n_samples_2 )

# Last calculations ====
final_data <- filtered_data %>%
  mutate( nlog10.Anova = -log10( Anova..p. ) ) %>%
  mutate( ratio = average.cond2 / average.cond1 ) %>%
  mutate( log2.Ratio = log2( ratio )  )

# Arrange and retag ID numbers by abundance in condition 1
final_data_a <- final_data %>%
  arrange( desc( log10.cond1 ) ) %>%
  mutate( id.cond1 = 1:nrow( . ) )

# Arrange and retag ID numbers by abundance in condition 2
final_data_b <- final_data_a %>%
  arrange( desc( log10.cond2 ) ) %>%
  mutate( id.cond2 = 1:nrow( . ) )

# Export data to excel
for_excel <- list( "all" = data_all,
                   "only ids" = only_ids,
                   "exclusive" = exclusive,
                   "reverse" = reverse,
                   "quantified" = quantified,
                   "missing in samples" = removed_by_missing,
                   "for volcano" = final_data_b )

# guardamos
write.xlsx( x = for_excel,
            file = ofile,         # file will be saved with "cleandata.xlsx" ext
            overwrite = TRUE )

## EOS: END OF SCRIPT
