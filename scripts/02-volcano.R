# read libraries required
library("dplyr")
library("stringr")
library("ggplot2")
library("cowplot")
library("ggsci")
library("ggrepel")
library("openxlsx")

# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
# args[1] <- "test/data/OP_vs_Normal.cleandata.xlsx" ## "test/data/OP_Vs_Normal.cleandata.xlsx"

# put a name to args
ifile <- args[1]

# rename the file before exit
ofile <- str_replace( string = ifile,
                      pattern = "\\.xlsx",
                      replacement = "\\.volcano\\.png" )

# rename the file before exit
ofile2 <- str_replace( string = ofile,
                       pattern = "\\.png",
                       replacement = "\\.named\\.png" )

# rename the file before exit
ofile3 <- str_replace( string = ifile,
                       pattern = "\\.xlsx",
                       replacement = "\\.UP_and_DOWN_hits\\.xlsx" )

## Definir params
# General filtering for peptides
# limit for pvalue < X       # to define UP y DOWN, for volcano volcano, heatmap, etc
pvalue_threshold <- 0.05 

# FoldChange threshold to highlit peptides (UP or DOWN)
# limit ratio > log2(X) for UP
# limit ratio < log2(X) for DOWN
ratio_threshold <- 1.5 %>%               # un fold change de dos significa un cambio de el doble de expresion
  log2()

# limit for CV > X
cv_threshold <- 0

# limit peptide count >= X
peptide_count_threshold <- 2
# limit unique peptide >= X
unique_peptide_threshold <- 1

# limit for counts in cond1 y cond2 (samples with data)
# limit >= X
count_threshold <- 2

# for VOLCANO tag names for top N peptides ====
n_best <- 5    # number of peptides top UP and DOWN to name in the plot

# Get the name of both conditions
conditions <- basename( path = ifile ) %>%
  str_remove( string = ., pattern = ".*/") %>%
  str_remove( string = ., pattern = "\\.cleandata\\.xlsx") %>% 
  str_split( string = ., pattern = "_" ) %>% 
  unlist( )

cond_1 <- conditions[1]
cond_2 <- conditions[3]

# see sheet names
getSheetNames( file = ifile )

# Data handling ====
data_all <- read.xlsx( xlsxFile = ifile,
                       sheet = 7 )        # read the "for volcano" sheet from the cleaned.xlsx

# Create Volcano plot ====
# filter for all our thresholds
base_volcano <- data_all %>%
  filter( Anova..p. < pvalue_threshold,
          Peptide.count >= peptide_count_threshold,
          Unique.peptides >= unique_peptide_threshold,
          Count.cond1 >= count_threshold,
          Count.cond2 >= count_threshold,
          CV.cond1 > cv_threshold,
          CV.cond2 > cv_threshold )

# define values for plotting
# Prepare lines for log2 FoldChange
vertical_lines.v <- c( -ratio_threshold, ratio_threshold )

# get UP peptides
peptides_up <- base_volcano %>%
  filter( log2.Ratio > ratio_threshold )

# get DOWN peptides
peptides_down <- base_volcano %>%
  filter( log2.Ratio < -ratio_threshold )

# Prepare X axis
# define the max absolute value found for log2 ratio
absolute_max_x <- data_all$log2.Ratio %>%
  abs( ) %>%
  max() %>%
  ceiling()

# limits for X axis
x_limits <- c( -absolute_max_x, absolute_max_x )

# breaks for X axis
x_breaks <- data.frame( marks = -absolute_max_x:absolute_max_x) %>%
  mutate( fila = 1:nrow( . )  ) %>%
  mutate( espar = ifelse( test = fila %% 2 == 0,
                          yes = "par",
                          no = "non" ) ) %>%
  mutate( etiquetas = ifelse( test = espar == "par",
                              yes = marks,
                              no = "" ) )

# prepare titles and subs
subtitle <- paste( cond_2, "vs", cond_1)

x_title <- paste( "log2.Ratio(",
                  cond_2,
                  "/",
                  cond_1,
                  ")" )

# create base volcano
volcano1 <- ggplot( data = data_all,
                    mapping = aes( x = log2.Ratio,
                                   y = nlog10.Anova ) ) +
  geom_point( alpha = 0.3,                                      
              shape = 1,                                        
              color = "#2E294E" ) +
  geom_hline( yintercept = -log10( pvalue_threshold ),
              linetype="dashed" ) +
  geom_vline( xintercept = vertical_lines.v,
              linetype="dashed") +
  geom_point( data = peptides_up,
              color = "#336600",
              alpha = 0.7,
              size = 3 ) +
  geom_point( data = peptides_down,
              color = "#CC3333",
              alpha = 0.7,
              size = 3 ) +
  scale_x_continuous( limits = x_limits,
                      breaks = x_breaks$marks,
                      labels = x_breaks$etiquetas ) +
  labs(
    #title = " Differential Peptidome",
    subtitle = subtitle,
    x = x_title ,
    y = "-log10( corrected p-value )" ) +
  coord_flip( ) +
  # theme_half_open( font_size = 14.5 ) +
  theme_linedraw( base_size = 14.5 ) +
  theme(panel.grid.major = element_blank( ),
        panel.grid.minor = element_blank( ),
        plot.subtitle = element_text( hjust = 0.5 , size = 13,
                                      face="bold" ),
        axis.title.y=element_text( size = 13 ),
        axis.title.x=element_text( size = 13 ),
        axis.text.x= element_text( size = 12 ),
        axis.text.y= element_text( size = 12 ) )
  # theme( plot.background = element_rect( fill = "white" ),
  #        plot.title = element_text( hjust = 0.5 ),
  #        plot.subtitle = element_text( hjust = 0.5 ) )

# guardamos el plot
ggsave( filename = ofile,
        plot = volcano1,
        width = 10,
        height = 7,
        dpi = 600 )

# get top N UP
top_up <- peptides_up %>%
  arrange( log2.Ratio ) %>%
  tail( n = n_best )

# get top N DOWN
top_down <- peptides_down %>%
  arrange( log2.Ratio ) %>%
  head( n = n_best )

# add labels to plot
volcano2 <- volcano1 +
  geom_label_repel( data = top_up,
                    mapping = aes( label = str_remove( string = ProteinID,
                                                       pattern = ";.*$"  ) ),
                    max.overlaps = 50 ) +
  geom_label_repel( data = top_down,
                    mapping = aes( label = str_remove( string = ProteinID,
                                                       pattern = ";.*$"  ) ),
                    max.overlaps = 50 )

# Save labeled plot
ggsave( filename = ofile2,
        plot = volcano2,
        width = 10,
        height = 7,
        dpi = 600 )

# create a file for up and down peptides ====
# create a function to fix Acc ID
idfixer <- function( the_data ) {
  
  # fix the accession
  the_data$singleID <- str_remove_all( string = the_data$ProteinID,
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
upregs <- idfixer( the_data = peptides_up )

# fix downregulated
downregs <- idfixer( the_data = peptides_down )

# save the fixed DF's as different sheets in a new xlsx
write.xlsx( x = list( "Up_proteins" = upregs,
                      "Down_proteins" = downregs),
            file = ofile3,
            overwrite = TRUE )

# EOS
