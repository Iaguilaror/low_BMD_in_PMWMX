FROM r-base:4.3.1
# system("cat /etc/os-release")
# PRETTY_NAME="Debian GNU/Linux trixie/sid"
# NAME="Debian GNU/Linux"
# VERSION_CODENAME=trixie
# ID=debian

RUN apt update -y && apt upgrade -y && apt install -y cmake apt-utils \
&& Rscript -e "install.packages('pacman')" \
&& Rscript -e "pacman::p_load( 'BiocManager' )" \
&& Rscript -e "pacman::p_load( 'tidyr', 'dplyr', 'ggplot2', 'ggrepel', 'ggsci', 'cowplot', 'scales', 'stringr', 'ggvenn', 'factoextra', 'openxlsx', 'purrr', 'matrixStats', 'scatterplot3d' )"

RUN Rscript -e "system( 'apt install -y libssl-dev libcurl4-openssl-dev libxml2-dev' ) ; BiocManager::install( 'ropls', ask = FALSE, force = TRUE )"
