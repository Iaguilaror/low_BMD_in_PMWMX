# author: iaguilaror@gmail.com
# date:   2023-oct-08

# This dir contains the Dockerfile for building the image with the reqs to replicate analysis in the paper
# the image is only to build locally, but the final image will be in iaguilaror/lowbmd:0.9iaguilaror/lowbmd:0.9
# to run the analysis with docker, just go to cd .. and run bash docker-replicate-analysis.sh

# useful commands
docker tag lowbmd:0.9 iaguilaror/lowbmd:0.9
docker push iaguilaror/lowbmd:0.9                 # to upload the image for NF

# dir structure
Dockerfile <- dockerfile to build iaguilaror/lowbmd image
