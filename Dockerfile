FROM bioconductor/bioconductor_docker:latest

WORKDIR /home/rstudio

COPY --chown=rstudio:rstudio . /home/rstudio/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    libglpk-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e \
   'options(repos=c(CRAN="https://cran.r-project.org", BiocManager::repositories())); \
    install.packages("Matrix", lib="/usr/local/lib/R/site-library"); \
    install.packages("BDgraph", lib="/usr/local/lib/R/site-library"); \
    install.packages("optparse", lib="/usr/local/lib/R/site-library"); \
    install.packages("magrittr", lib="/usr/local/lib/R/site-library"); \
    install.packages("BiocManager", lib="/usr/local/lib/R/site-library"); \
    BiocManager::install(); \
    BiocManager::install("Biobase");'