FROM r-base:4.3.1

RUN Rscript -e "install.packages('pacman')" \
&& Rscript -e "pacman::p_load( 'cowplot','dplyr', 'factoextra', 'ggplot2', 'ggrepel', 'ggsci', 'matrixStats', 'openxlsx', 'scales', 'stringr', 'tidyr', 'ggvenn', 'ropls', 'scatterplot3d', 'purrr', try.bioconductor = TRUE )"
