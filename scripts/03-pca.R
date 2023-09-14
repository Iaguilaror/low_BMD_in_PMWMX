# load libs
library( "factoextra" )
library( "dplyr" )
library( "stringr" )
library( "scales" )
library( "ggsci" )
library( "tidyr" )
library( "openxlsx" )
library( "cowplot" )

# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "OP_vs_OS.cleandata.UP_and_DOWN_hits.xlsx" ## "test/data/OP_Vs_Normal.cleandata.UP_and_DOWN_hits.xlsx"
# args[2] <- "sample_sheet.csv" ## "test/data/sample_sheet.csv"

# put a name to args
ifile <- args[1]
sample_sheet <- args[2]

# rename the files for outputs
ofile_pca1 <- str_replace( string = ifile,
                           pattern = "\\.xlsx",
                           replacement = "\\.PCA_diagnostic\\.png" )

ofile_pca2 <- str_replace( string = ifile,
                           pattern = "\\.xlsx",
                           replacement = "\\.PCA_main\\.png" )

# create a pattern to search for condition 1 and 2 ====
# Read samplesheet
samples <- read.csv( file = sample_sheet )

# get the names of both conditions
conditions <- basename( path = ifile ) %>%
  str_remove( string = ., pattern = ".*/") %>%
  str_remove( string = ., pattern = "\\.cleandata\\.UP_and_DOWN_hits\\.xlsx") %>%
  str_split( string = ., pattern = "_" ) %>%
  unlist( )

cond_1 <- conditions[1]
cond_2 <- conditions[3]

# get sample ids for condition 1
ids_cond_1 <- samples %>%
  filter( condition == cond_1 ) %>%
  pull( muestra )

# create a regular expresion to find every sample for condition 1
regex_1 <- paste( ids_cond_1,
                  collapse = "|" )

# get sample ids for condition 2
ids_cond_2 <- samples %>%
  filter( condition == cond_2 ) %>%
  pull( muestra )

# create a regular expresion to find every sample for condition 2
regex_2 <- paste( ids_cond_2,
                  collapse = "|" )

# Prepare data for PCA ====

# read up and down data
peptide_up <- read.xlsx( xlsxFile = ifile, sheet = 1 )

peptide_down <- read.xlsx( xlsxFile = ifile, sheet = 2 )

# gather up and down
base_pca <- bind_rows( peptide_up, peptide_down )

# put Acc as rownames
rownames( base_pca ) <- base_pca$Accession

# find column positions for condition 1
pos_cond_1 <- str_detect( string = colnames( base_pca ),
                          pattern = regex_1 ) %>%
  which()

# get dataframe only for samples from condirion 1
data_cond_1 <- base_pca %>%
  select( all_of( pos_cond_1 ) )

# find column positions for condition 2
pos_cond_2 <- str_detect( string = colnames( base_pca ),
                          pattern = regex_2 ) %>%
  which()

# get dataframe only for samples from condirion 1
data_cond_2 <- base_pca %>%
  select( all_of( pos_cond_2 ) )

# bound data for both conditions
base_pca_2 <- bind_cols( data_cond_1, data_cond_2 )

# transpose to make rows (peptides) the variables (columns)
trans_pca <- t( base_pca_2 ) %>%
  as.data.frame( )

# add a colum with the clean sample names and the condition for each
trans_pca_2 <- trans_pca %>%
  mutate( muestra = row.names(.) ) %>%
  left_join( x = .,
             y = samples,
             by = "muestra" )

# recreate the rownames (lost during the left_join)
rownames( trans_pca_2 ) <- trans_pca_2$muestra

## begin PCA ====

# what is the number of columns - This changes depending on the number of peptides in analysis
ultimate_col     <- ncol(trans_pca_2)
penultimate_col  <- ultimate_col - 1

# first remove last two columns, then calculate PCA (with prcom )
pca_results <- trans_pca_2 %>%
  select( -all_of( c(ultimate_col, penultimate_col) ) ) %>%
  prcomp( scale = TRUE )

# Overview on screeplot
# prepare axis Y
maxy     <- 100
marks_y  <- seq( from = 0, to = maxy, by = 10 )
labs_y   <- ( marks_y / 100 ) %>% percent( )

# plot the scree
screeplot <- fviz_eig( pca_results,
                       barfill = "gray50", barcolor = "black" ) +
  labs( title = paste0( "Overview of Principal Component Analysis \n",
                        cond_2, " vs ", cond_1 ),
        subtitle = "Scree Plot" ) +
  scale_y_continuous( breaks = marks_y,
                      labels = labs_y ) +
  theme_classic( base_size = 15 ) +
  theme( plot.title = element_text( face = "bold" ) )

# get coordinates for PC1 and PC2
# label sample name 
pca_ind_text.p <- fviz_pca_ind( pca_results,
                                axes = c( 1, 2 ),
                                geom = "text", repel = TRUE,
                                col.ind = as.factor( trans_pca_2[, ultimate_col] ),
                                invisible = "quali" ) +
  scale_color_d3() +
  theme_bw( base_size = 15 ) +
  theme( legend.title = element_blank() )

# now make the biplot
biplot.p <- fviz_pca_biplot( pca_results,
                             axes = c( 1, 2 ),
                             geom.ind = "point", pointsize = 3,
                             geom.var = "arrow", col.var = "black", alpha.var = 0.3,
                             col.ind = as.factor( trans_pca_2[, ultimate_col] ),
                             invisible = "quali" ) +
  scale_color_d3() +
  theme_bw( base_size = 15 ) +
  theme( legend.title = element_blank() )

# Plot PCA - no label
pca_ind.p <- fviz_pca_ind( pca_results,
                           axes = c( 1, 2 ),
                           geom = "point", pointsize = 3,
                           col.ind = as.factor( trans_pca_2[, ultimate_col] ),
                           ellipse.alpha = 0,
                           invisible = "quali",
                           addEllipses = TRUE ) +
  labs( title = "Principal Component Analysis",
        subtitle = paste0( cond_2, " vs ", cond_1) ) +
  scale_color_d3() +
  theme_bw( base_size = 15 ) +
  theme( legend.title = element_blank( ),
         plot.title = element_text( hjust = 0.5 ),
         plot.subtitle = element_text( hjust = 0.5 ) )

# Create a pcp.p to (parallel coordinate plot)
# Extract PC results for individuals
res_ind <- get_pca_ind( pca_results )

# extract coordinates for each sample
# then annotate condition by left_join
all_pc_coord <- res_ind$coord %>%
  as.data.frame( ) %>%
  mutate( muestra = row.names(.) ) %>%
  left_join( x = .,
             y = samples,
             by = "muestra" )

# get last and penultimate col
re_ultimate_col <- ncol( all_pc_coord )
re_penultimate  <- re_ultimate_col - 1

# get PC coord in long format
pc_long <- all_pc_coord %>%
  pivot_longer( cols = -all_of(re_penultimate:re_ultimate_col),
                names_to = "PC",
                values_to = "coordinate" ) %>% 
  mutate( PC = str_remove( string = PC, pattern = "Dim\\." ),
          PC = as.numeric( PC ) )

# Plot pcp.p as lines and points
pcp.p <- ggplot( data = pc_long,
                 mapping = aes( x = PC,
                                y = coordinate,
                                color = condition,
                                fill = condition) ) +
  geom_line( mapping = aes( group = muestra ), linewidth = 0.5 ) +
  geom_point( shape = 21, size = 2, color = "black" ) +
  scale_x_continuous( breaks = min( pc_long$PC):max( pc_long$PC ) ) +
  scale_color_d3() +
  scale_fill_d3() +
  labs( title = "Parallel Coordinate Plot",
        x = "Dim" ) +
  theme_light( base_size = 15 ) +
  theme( panel.grid.minor.y = element_blank( ),
         legend.position = "top",
         legend.title = element_blank( ) )

# Save the plots ====
diagnostic_plot <- plot_grid( screeplot,
                              pcp.p,
                              pca_ind_text.p,
                              biplot.p,
                              labels = c( "A", "B", "C", "D" ) )

# save diagnostic plot
ggsave( filename = ofile_pca1,
        plot = diagnostic_plot,
        width = 15,
        height = 15,
        dpi = 600 )

# save PCA for pub
ggsave( filename = ofile_pca2,
        plot = pca_ind.p,
        width = 10,
        height = 10,
        dpi = 600 )

# EOS