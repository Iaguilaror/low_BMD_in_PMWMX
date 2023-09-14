# load libs
library( "dplyr" )
library( "ggvenn" )
library( "ropls" )
library( "stringr" )
library( "tidyr" )
library( "openxlsx" )
library( "scatterplot3d" )
library( "purrr" )

# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- NONE

# put a name to args
ifile <- list.files( path = ".",
                     pattern = "Total_protein_PLSDA-PCA.xlsx",
                     recursive = TRUE )

# Read main data
maindata <- read.xlsx( xlsxFile = ifile )

# List genes found in each condition
maindata_long <- pivot_longer( data = maindata, 
                               cols = -c( sample_id, condicion ),
                               names_to = "protein",
                               values_to = "quant", values_drop_na = TRUE ) %>% 
  filter( quant != 0 )

genes_N <- maindata_long %>% 
  filter( condicion == "N" ) %>% 
  pull( protein ) %>% 
  unique( )

genes_OS <- maindata_long %>% 
  filter( condicion == "OS" ) %>% 
  pull( protein ) %>% 
  unique( )

genes_OP <- maindata_long %>% 
  filter( condicion == "OP" ) %>% 
  pull( protein ) %>% 
  unique( )

# create a venn diagram
protein_venn <- ggvenn( data = list( "Normal" = genes_N,
                                     "OS" = genes_OS,
                                     "OP" = genes_OP ),
                        show_percentage = FALSE,
                        fill_color = c( "#3399FF", "#FF6600", "#6633FF" ),
                        stroke_size = 0.1 ) +
  ggtitle( "Proteins shared among the three conditions" ) +
  theme( plot.title =  element_text( hjust = 0.5, size = 15, face = "bold" )  )

# save the venn
ggsave( filename = "VENN_shared.png",
        plot = protein_venn,
        bg = "white",
        height = 8,
        width = 8,
        dpi = 600 )

# Prepare data for PLSDA ====
#### PLSDA  #####
rownames( maindata ) <- maindata$sample_id

# calculate PLS-DA
# df.plsda <- opls( maindata[ , -c(1:2) ], maindata$condicion )
df.plsda <- maindata %>% 
  select( -1, -2 ) %>% 
  opls( x = ., maindata$condicion )

# plot(df.plsda, typeVc = "x-score")

# Get the values for each component
gsc_plsda <- getScoreMN( object = df.plsda,
                         orthoL = FALSE ) %>% 
  as.data.frame( )

colnames( gsc_plsda ) <- c( "t[1]", "t[2]", "t[3]", "t[4]", "t[5]" )

plsda <- maindata %>% 
  select( condicion ) %>% 
  bind_cols( gsc_plsda )

plsda$condicion <- as.factor( plsda$condicion )

# Prepare colors
colors_s <- c( "#3399FF", "#6633FF", "#FF6600" )

colors1 <- colors_s[ as.numeric( plsda$condicion ) ]

#Image
png( filename = "PLS-DA.png",
     width = 1500, 
     height = 1500, 
     units = "px", 
     #  compression = "lzw",
     pointsize = 12, 
     res = 350 )

#graphics
plsda %>% 
  select( `t[1]`:`t[3]` ) %>% 
  scatterplot3d( x = .,
                 color = colors1,
                 pch = 16,
                 grid = TRUE,
                 type = "h",
                 cex.symbols = 1.1,
                 cex.axis = 1,
                 main = "3D PLS-DA for proteome data" )

legend( "right", legend = levels( plsda$condicion ), cex = 0.9,
        col =  colors_s,
        pch = 16, inset = -0.1, xpd = TRUE, horiz = FALSE )

dev.off()

## Compare UP AND DOWN GENES ====
all_files <- list.files( path = ".",
                         pattern = "UP_and_DOWN_hits.xlsx",
                         recursive = TRUE )

# create a function to read a file an add a column for its origin
read_deg.f <- function( the_file, the_sheet ) {
  
  read.xlsx( xlsxFile = the_file,
             sheet = the_sheet ) %>% 
    mutate( condition =   str_remove_all( string = the_file, pattern = ".cleandata.UP_and_DOWN_hits.xlsx" ),
            DEG_state = the_sheet ) %>% 
    select( -c( 9:20, 26:37 ) )
  
}

# Load all up proteins
all_up  <- all_files %>% 
  map_df( ~ read_deg.f( the_file = .,
                        the_sheet = "Up_proteins" ) )

all_down  <- all_files %>% 
  map_df( ~ read_deg.f( the_file = .,
                        the_sheet = "Down_proteins" ) )

# Create a function to load a dataframe and create a venn diagram for a given id column ~ a given condition column
shared_venn.f <- function( the_data, the_title ) {
  
  data_tmp <- the_data %>% 
    select( ProteinID, condition, DEG_state ) %>% 
    mutate( DEG_state = TRUE ) %>% 
    unique( ) %>% 
    pivot_wider( id_cols = 1,
                 names_from = "condition",
                 values_from = "DEG_state" ) %>% 
    relocate( 4, 3, 2 )
  
  # replace NAs as FALSE
  data_tmp[ is.na( data_tmp ) ] <- FALSE
  
  # create a venn
  ggvenn( data = data_tmp,
          show_percentage = FALSE,
          fill_color = c( "gold", "brown4", "purple" ),
          stroke_size = 0.1 ) +
    ggtitle( the_title ) +
    theme( plot.title =  element_text( hjust = 0.5, size = 15, face = "bold" )  )
  
}

# Create plots to show Shared and Unique DEPs, UP and DOWN
shared_venn_up <- shared_venn.f( the_data = all_up,
                                 the_title = "Shared Up Regulated DEPs" )

# save the venn
ggsave( filename = "VENN_shared_DEP_UP.png",
        plot = shared_venn_up,
        bg = "white",
        height = 8,
        width = 8,
        dpi = 600 )

shared_venn_down <- shared_venn.f( the_data = all_down,
                                   the_title = "Shared Down Regulated DEPs" )

# save the venn
ggsave( filename = "VENN_shared_DEP_DOWN.png",
        plot = shared_venn_down,
        bg = "white",
        height = 8,
        width = 8,
        dpi = 600 )
