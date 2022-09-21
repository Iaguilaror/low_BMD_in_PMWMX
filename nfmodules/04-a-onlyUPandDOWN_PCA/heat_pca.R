# read libraries required
# cargar librerias
library( "factoextra" )
library( "dplyr" )
library( "stringr" )
library( "scales" )
library( "ggsci" )
library( "tidyr" )
library( "pheatmap" )
library( "openxlsx" )
library( "cowplot" )

# Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/OP_Vs_Normal.cleandata.UP_and_DOWN_hits.xlsx" ## "test/data/OP_Vs_Normal.cleandata.UP_and_DOWN_hits.xlsx"
# args[2] <- "../../real-data/sample_sheet.csv" ## "test/data/sample_sheet.csv"

# put a name to args
ifile <- args[1]
sample_sheet <- args[2]

# rename the file before exit
ofile_pca1 <- str_replace( string = ifile,
                           pattern = "\\.xlsx",
                           replacement = "\\.PCA_diagnostico\\.png" )

ofile_pca2 <- str_replace( string = ifile,
                           pattern = "\\.xlsx",
                           replacement = "\\.PCA_main\\.png" )

ofile_heat <- str_replace( string = ifile,
                           pattern = "\\.xlsx",
                           replacement = "\\.heatmap\\.png" )

# desactivamos toda la notacion cientifica
options( scipen = 666 )

# create a patter to search for condition 1 and 2 ====
# Leemos la hoja de muestras
muestras <- read.csv( file = sample_sheet )

# Sacamos los nombres de las condiciones...
condiciones <- basename( path = ifile ) %>%
  str_remove( string = ., pattern = ".*/") %>%
  str_remove( string = ., pattern = "\\.cleandata\\.UP_and_DOWN_hits\\.xlsx") %>%
  str_split( string = ., pattern = "_" ) %>%
  unlist( )

condicion1 <- condiciones[1]
# repetimos para la segunda condicion
condicion2 <- condiciones[3]

# Sacamos los identificadores de las muestras
ids_condicion1 <- muestras %>%
  filter( condition == condicion1 ) %>%
  pull( muestra )

# creamos una expresion regular para buscar todas las muestras de la condicion 1
expresion_1 <- paste( ids_condicion1,
                      collapse = "|" )

# Sacamos los identificadores de las muestras para la condicion 2
ids_condicion2 <- muestras %>%
  filter( condition == condicion2 ) %>%
  pull( muestra )

# creamos una expresion regular para buscar todas las muestras de la condicion 2
expresion_2 <- paste( ids_condicion2,
                      collapse = "|" )

# ====

# see sheet names
getSheetNames( file = ifile )

# read up and down data
proteinas_up <- read.xlsx( xlsxFile = ifile, sheet = 1 )

proteinas_down <- read.xlsx( xlsxFile = ifile, sheet = 2 )

# juntamos las protes up y down
base_pca <- bind_rows( proteinas_up, proteinas_down )

# ponemos los Acc como nombres de filas
rownames( base_pca ) <- base_pca$singleID

# volvemos a sacar lo siguiente:
# Vamos a buscar el numero de columnas que corresponden a las muestras de la condicion 1
re_posicion_muestras_1 <- str_detect( string = colnames( base_pca ),
                                      pattern = expresion_1 ) %>%
  which()

# vamos a extraer un dataframe que contenga solo las columnas de las inyecciones
re_data_condicion_1 <- base_pca %>%
  select( re_posicion_muestras_1 )

# volvemos a sacar lo siguiente:
# Vamos a buscar el numero de columnas que corresponden a las muestras de la condicion 1
re_posicion_muestras_2 <- str_detect( string = colnames( base_pca ),
                                      pattern = expresion_2 ) %>%
  which()

# vamos a extraer un dataframe que contenga solo las columnas de las inyecciones
re_data_condicion_2 <- base_pca %>%
  select( re_posicion_muestras_2 )

# Juntamos los datas que contienen SOLO las columnas de medicion de inyecciones
base2_pca <- bind_cols( re_data_condicion_1, re_data_condicion_2 )

# Hacemos un transpose de columnas a filas
trans_pca <- t( base2_pca ) %>%
  as.data.frame( )

# agregamos columna de nombre de muestra limpio, y condicion a la que pertenece
trans2_pca <- trans_pca %>%
  mutate( muestra = row.names(.) ) %>%
  left_join( x = .,
             y = muestras,
             by = "muestra" )

# el join pierde los nombres, asi que los recuperamos
rownames( trans2_pca ) <- trans2_pca$muestra

# comenzamos con el pca
# cual es el maximo de columnas en trans 2? - Esto camibara dependiendo del numero de proteinas que entran al analisis
ultima_col <- ncol(trans2_pca)
penultima_col <- ultima_col - 1

# haremos el pca con trans2 pero sin sus ultimas dos columnas
pca_resultados <- trans2_pca %>%
  select( -ultima_col, -penultima_col ) %>%
  prcomp( scale = TRUE )

# Visualizamos el screeplot
maxy <- 100
marcas_y <- seq( from = 0, to = maxy, by = 10 )
etiquetas_y <- ( marcas_y / 100 ) %>% percent( )

screeplot <- fviz_eig( pca_resultados,
                       barfill = "gray50", barcolor = "black",) +
  scale_y_continuous( breaks = marcas_y,
                      labels = etiquetas_y ) +
  theme_classic( base_size = 15 )

# Vis
screeplot

# Scamos el primer PCA
pca_ind_text <- fviz_pca_ind( pca_resultados,
                              axes = c( 1, 2 ),
                              geom = "text", repel = T,
                              col.ind = as.factor( trans2_pca[, ultima_col] ) ,
                              invisible = "quali" ) +
  scale_color_d3() +
  theme_bw( base_size = 15 ) +
  theme( legend.title = element_blank() )

# vis
pca_ind_text

# graficamos el biplot
bip <- fviz_pca_biplot( pca_resultados,
                        axes = c( 1, 2 ),
                        geom.ind = "point", pointsize = 3,
                        geom.var = "arrow", col.var = "black", alpha.var = 0.3,
                        col.ind = as.factor( trans2_pca[, ultima_col] ) ,
                        invisible = "quali" ) +
  scale_color_d3() +
  theme_bw( base_size = 15 ) +
  theme( legend.title = element_blank() )

# vis
bip

# Scamos el primer PCA
pca_ind <- fviz_pca_ind( pca_resultados,
                         axes = c( 1, 2 ),
                         geom = "point", pointsize = 3,
                         col.ind = as.factor( trans2_pca[, ultima_col] ) ,
                         invisible = "quali" ) +
  scale_color_d3() +
  theme_bw( base_size = 15 ) +
  theme( legend.title = element_blank() )

# vis
pca_ind

# Vamos a generar un PCP (parallel coordinate plot)
# Permite ver varios ejes del PCA al mismo tiempo
# Sacamos los resultados completos
# Results for individuals
resultados_individuales <- get_pca_ind( pca_resultados )

todos_pc <- resultados_individuales$coord %>%
  as.data.frame( ) %>%
  mutate( muestra = row.names(.) ) %>%
  left_join( x = .,
             y = muestras,
             by = "muestra" )

# volvemos a calcular la ultima columna
re_ultima_col <- ncol( todos_pc )
re_penultima <- re_ultima_col - 1

# pasamos los PC a formato largo
pc_largo <- todos_pc %>%
  pivot_longer( cols = -c(re_penultima:re_ultima_col),
                names_to = "PC",
                values_to = "coordinate" ) %>% 
  mutate( PC = str_remove( string = PC, pattern = "Dim\\." ),
          PC = as.numeric( PC ) )

# Hagamos el PCP con lineas y puntos
pcp <- ggplot( data = pc_largo,
               mapping = aes( x = PC,
                              y = coordinate,
                              color = condition,
                              fill = condition) ) +
  geom_line( mapping = aes( group = muestra ), size = 0.5 ) +
  geom_point( shape = 21, size = 2, color = "black" ) +
  scale_x_continuous( breaks = min( pc_largo$PC):max( pc_largo$PC) ) +
  scale_color_d3() +
  scale_fill_d3() +
  labs( title = "Parallel Coordinate Plot",
        x = "Dim" ) +
  theme_light( base_size = 15 ) +
  theme( panel.grid.minor.y = element_blank( ),
         legend.position = "top",
         legend.title = element_blank( ) )

# vis
pcp

# creamos un plot de diagnostico ====
diagnostic_plot <- plot_grid( screeplot, pcp, pca_ind_text, bip, labels = c( "A", "B", "C", "D" ) )

# guardar el plot diagnostico
ggsave( filename = ofile_pca1,
        plot = diagnostic_plot,
        width = 15,
        height = 15,
        dpi = 600 )
# ====

# guardar el PCA normal
# guardar el plot diagnostico
ggsave( filename = ofile_pca2,
        plot = pca_ind,
        width = 10,
        height = 10,
        dpi = 600 )

## HEATMAP ====
# convertimos a matriz
heat_data <- as.matrix( base2_pca  )

# escalamos los datos
heat_escalado <- scale( heat_data )

# hacemos el pheat
# vamos a etiqutear columnas y filas...
# Cargar el etiquetado de columnas
col_ids <- muestras %>%                # Solo dice el nombre de la columna, a que estado celular pertenece
  filter( condition == condicion1 | condition == condicion2  )

rownames( col_ids ) <- paste0(col_ids$muestra)

# dejar solo los nombres de etiquetas
# Lo requiere pheatmap
etiquetas_col <- col_ids %>%
  select( condition )

# etiquetamos protes
# Lo utilizara para ponerle color al gen
etiquetas_prote <- bind_rows( proteinas_up %>% mutate( state = "UP"),
                              proteinas_down %>% mutate( state = "DOWN") )

# ponemos los Acc como nombres de filas
rownames( etiquetas_prote ) <- etiquetas_prote$singleID

# solo nos quedamos con la etiqueta
etiquetas_prote2 <- etiquetas_prote %>%
  select( state )

# Se deben definir varias escalas de colores al mismo tiempo
# lo guarda en una lista
# que a su vez contiene dos vectores
mis_colores = list( condition = c( "gray80", "gold4" ),
                    state = c( "UP" = "limegreen", "DOWN" = "tomato" ) )

# aqui corregimos un bug donde no se puede pasar un objeto como nombre del elemento en vector condition
names( mis_colores[[1]] ) <- c( condicion1, condicion2 )

# creamos titulos, subs, etc
subtitulo <- paste0( "Differential peptides", "\n", condicion2, " vs ", condicion1)

heat1 <- pheatmap( mat = heat_escalado,
                   main = subtitulo,
                   scale = "row",
                   fontsize_row = 5,
                   fontsize_col = 5,
                   cutree_rows = 2,
                   cutree_cols = 2,
                   show_rownames = TRUE,
                   annotation_colors = mis_colores,
                   annotation_row = etiquetas_prote2,
                   annotation_col = etiquetas_col
                   )

# guardar el heatmap
ggsave( filename = ofile_heat,
        plot = heat1,
        width = 10,
        height = 10,
        dpi = 600 )

# FIN DEL SCRIPT