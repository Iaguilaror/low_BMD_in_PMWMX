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
## Comment for production mode only
# args[1] <- "test/data/OP_Vs_Normal.cleandata.xlsx" ## "test/data/OP_Vs_Normal.cleandata.xlsx"

# put a name to args
ifile <- args[1]

# rename the file before exit
ofile <- str_replace( string = ifile,
                      pattern = "\\.xlsx",
                      replacement = "\\.volcano\\.png" )

# rename the file before exit
ofile2 <- str_replace( string = ofile,
                       pattern = "\\.png",
                       replacement = "\\.connombres\\.png" )

# rename the file before exit
ofile3 <- str_replace( string = ifile,
                      pattern = "\\.xlsx",
                      replacement = "\\.UP_and_DOWN_hits\\.xlsx" )

## Definir parametros
# FILTRADO GENERAL PARA ARCHIVO_PROTEINAS
# limite pvalue < X       # para definir lo UP y DOWN, del volcano, heatmap, etc
pvalue_limite <- 0.05 

# limite o threshold del fold change para destacar proteinas (tanto up, como down)
# limite ratio > log2(X) para lo up
# limite ratio < log2(X) para lo down
ratio_limite <- 1.5 %>%               # un fold change de dos significa un cambio de el doble de expresion
  log2()

# limte de CV > X
cv_limite <- 0

# limite peptide count >= X
peptide_count_limite <- 2
# limite unique peptide >= X
unique_peptide_limite <- 1
# limite de counts en cond1 y cond2
# limite >= X
count_limite <- 2

# para el VOLCANO etiquetamos los nombres de los top N ====
n_best <- 5    # numero de proteinas top up y down a resaltar con nombre

# Sacamos los nombres de las condiciones...
condiciones <- basename( path = ifile ) %>%
  str_remove( string = ., pattern = ".*/") %>%
  str_remove( string = ., pattern = "\\.cleandata\\.xlsx") %>% 
  str_split( string = ., pattern = "_" ) %>% 
  unlist( )

condicion1 <- condiciones[1]
# repetimos para la segunda condicion
condicion2 <- condiciones[3]

# see sheet names
getSheetNames( file = ifile )

# # Limpieza general de filas. Eliminar infinitos y asi ====
data_toda <- read.xlsx( xlsxFile = ifile, sheet = 7 )

# create an inter df
final_data_b <- data_toda

# Visualizar Volcano ====
# filtramos la data base del volcano
base_volcano <- final_data_b %>%
  filter( fdr_p < pvalue_limite,
          Peptide.count >= peptide_count_limite,
          Unique.peptides >= unique_peptide_limite,
          Count.cond1 >= count_limite,
          Count.cond2 >= count_limite,
          CV.cond1 > cv_limite,
          CV.cond2 > cv_limite )

# define values for plotting
# Dibujamos las lineas en los limites de pvalue y de log2
vertical_lines.v <- c( -ratio_limite, ratio_limite )

# Sacamos las proteinas up
proteinas_up <- base_volcano %>%
  filter( log2.Ratio >= ratio_limite )

# Sacamos las proteinas down
proteinas_down <- base_volcano %>%
  filter( log2.Ratio <  -ratio_limite )

# Agregamos mas dientes (breaks) al eje X
# definimos el valor maximo absoluto que encontramos log2 ratio
absolute_max_x <- final_data_b$log2.Ratio %>%
  abs( ) %>%
  max() %>%
  ceiling()

# creamos valores para el eje x
limites <- c( -absolute_max_x, absolute_max_x )

# marcas eje X
ejex <- data.frame( marcas = -absolute_max_x:absolute_max_x) %>%
  mutate( fila = 1:nrow( . )  ) %>%
  mutate( espar = ifelse( test = fila %% 2 == 0,
                          yes = "par",
                          no = "non" ) ) %>%
  mutate( etiquetas = ifelse( test = espar == "par",
                              yes = marcas,
                              no = "" ) )

# creamos titulos, subs, etc
subtitulo <- paste( condicion1, "vs.", condicion2)
### CORRECCION 
titulo_eje_x <- paste( "log2 (Fold Change)")

# Dibujamos el volcano base con todos los puntos
volcano1 <- ggplot( data = final_data_b,
                    mapping = aes( x = log2.Ratio,
                                   y = nlog10.pvalue ) ) +
  geom_point( alpha = 0.3,                                      # Usamos una transparencia del 10%
              shape = 1,                                        # la forma es de circulo hueco
              color = "#2E294E" ) +
  geom_hline( yintercept = -log10( pvalue_limite ),
              linetype="dashed" ) +
  geom_vline( xintercept = vertical_lines.v,
              linetype="dashed") +
  geom_point( data = proteinas_up,
              color = "#CC3333",
              alpha = 0.7,
              size = 3 ) +
  geom_point( data = proteinas_down,
              color = "#336600",
              alpha = 0.7,
              size = 3 ) +
  scale_x_continuous( limits = limites,
                      breaks = ejex$marcas,
                      labels = ejex$etiquetas ) +
  labs(subtitle = subtitulo,
       x = titulo_eje_x ,
       y = "-log10(corrected p-value)" ) +
  coord_flip( ) +
  theme_half_open( font_size = 14.5)+
  theme_linedraw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.subtitle = element_text( hjust = 0.5 ,size=13,
                                      face="bold"),
        axis.title.y=element_text(size=13),
        axis.title.x=element_text(size=13),
        axis.text.x= element_text(size=12),
        axis.text.y= element_text(size=12))
#theme( plot.background = element_rect( fill = "white" ) )

# guardamos el plot
ggsave( filename = ofile,
        plot = volcano1,
        width = 5,
        height = 10,
        dpi = 550 )

# # sacar los N mas up
top_up <- proteinas_up %>%
  arrange( log2.Ratio ) %>%
  tail( n = n_best )

# sacar los N mas down
top_down <- proteinas_down %>%
  arrange( log2.Ratio ) %>%
  head( n = n_best )

# agregamos las etiquetas al plot
volcano2 <- volcano1 +
  geom_label_repel( data = top_up,
                    mapping = aes( label = str_remove( string = ProteinID,
                                                       pattern = ";.*$"  ) ),
                    max.overlaps = 50 ) +
  geom_label_repel( data = top_down,
                    mapping = aes( label = str_remove( string = ProteinID,
                                                       pattern = ";.*$"  ) ),
                    max.overlaps = 50 )


# Guardamos el plot
# guardamos plot
# guardamos el plot
ggsave( filename = ofile2,
        plot = volcano2,
        width = 7,
        height = 5,
        dpi = 400 )

# create a file for up and down prots
# create a function to fix Acc ID
idfixer <- function( the_data ) {
  
  # fix the ProteinID
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

# fix ups and downs
# fix upregulated
upregs <- idfixer( the_data = proteinas_up )

# fix downregulated
downregs <- idfixer( the_data = proteinas_down )

# save the fixed DF's as different sheets in a new xlsx
write.xlsx( x = list( "Up_proteins" = upregs,
                      "Down_proteins" = downregs),
            file = ofile3,
            overwrite = TRUE )

# FIN DE SCRIPT