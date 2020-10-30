
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shine-nf

[![Built
With](https://img.shields.io/badge/Built%20With-Nextflow-brightgreen.svg)](https://www.nextflow.io/)

## Requirements

### Nextflow

Workflows are built using [Nextflow](https://www.nextflow.io/). Nextflow
can be used on any POSIX compatible system (Linux, OS X, etc) and
requires BASH and Java 8 (or higher) to be installed. Download the
latest version of Nextflow:

``` bash
$ curl -s https://get.nextflow.io | bash
```

Once downloaded make the `nextflow` file accessible by your $PATH
variable so you do not have to specify the full path to nextflow each
time. e.g. `nextflow run` rather than `path/to/nextflow run`

### R Packages

We suggest R 3.6.0 but we also support up top R 4.0.0. Workflows will
expect the following R dependencies to be available:

``` r
library(BDgraph)
library(Biobase)
library(Matrix)
library(magrittr)
library(optparse)
```

### Docker (Optional)

You can alternatively run workflows with Docker to ensure dependencies
are available.

    docker pull montilab/shine:latest
    nextflow run wf.nf -with-docker montilab/shine

### Anaconda (Optional)

You can alterantive run workflows with a conda environment activated.

    module load anaconda3
    
    conda create -n shine python=3.7
    source activate shine
    
    conda install -c conda-forge r-base -y
    conda install -c conda-forge r-bdgraph -y
    conda install -c conda-forge r-optparse -y
    conda install -c conda-forge r-matrix -y
    conda install -c conda-forge r-magrittr -y
    
    conda install -c bioconda bioconductor-biobase -y
    
    nextflow run wf.nf
