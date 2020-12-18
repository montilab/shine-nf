shine-nf
================

  - [Quick Start](#quick-start)
  - [Learning Methods](#learning-methods)
      - [Single Unconstrained Network](#single-unconstrained-network)
      - [Multiple Unconstrained
        Networks](#multiple-unconstrained-networks)
      - [Multiple Constrained Networks](#multiple-constrained-networks)
  - [Generative Nextflow](#generative-nextflow)
  - [Alternative Dependency Options](#alternative-dependency-options)

<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Nextflow](https://img.shields.io/badge/nextflow-DSL2-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with
conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with
docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

This is a collection of Nextflow modules (DSL2) for modeling
hierarchical biological regulatory networks. It wraps methods developed
in the [shine](https://github.com/montilab/shine) R package in Nextflow
modules for building hierarchical workflows. Structure learning is
computationally expensive, particularly when learning multiple networks
in a dependent fashion. Many computation-intensive workflows for
genomics data have adopted the Nextflow framework. Nextflow is a
language for building and deploying reactive workflows. It’s convenient
because it integrates seamlessly with software containers and abstracts
away the parallelization of processes on commonly used high performance
computing architectures.

# Quick Start

In genomics data often has a hierarchical structure, image we want to
learn networks within a hierarchical structure. For example, ABC needs
to be learned first before AB. Once AB is finished, A and B can be
computed in parallel etc. If we needed to do this repetitively for the
same data and structure, we might define a workflow. But what if we want
to apply the same method to a dataset with a different structure? We
would want to make defining these workflows to highly efficient.

``` 
    ABC
    / \
   AB  \ 
  /  \  \
 A    B  C 
```

**Nextflow**  
Workflows are built using [Nextflow](https://www.nextflow.io/). Nextflow
can be used on any POSIX compatible system (Linux, OS X, etc) and
requires BASH and Java 8 (or higher) to be installed. Download the
latest version of Nextflow compatible with DSL2:

``` bash
$ curl -s https://get.nextflow.io | bash
```

|                                                                                                                                                                                                      |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *Hint*                                                                                                                                                                                               |
| Once downloaded make the `nextflow` file accessible by your $PATH variable so you do not have to specify the full path to nextflow each time. e.g. `nextflow run` rather than `path/to/nextflow run` |

**Clone Directory**

``` bash
$ git clone https://github.com/montilab/shine-nf
```

**Docker**

``` bash
$ docker pull montilab/shine:latest
```

**Run**

``` bash
$ nextflow run wf.nf -with-docker montilab/shine
```

    N E X T F L O W  ~  version 20.07.1
    Launching `wf.nf` [happy_koch] - revision: c2526aec9e
    
    executor >  local (51)
    [f4/c715fd] process > ABC:SPLIT          [100%] 1 of 1 ✔
    [1b/37cc11] process > ABC:LEARN (9)      [100%] 9 of 9 ✔
    [99/23dcba] process > ABC:RECONSTRUCT    [100%] 1 of 1 ✔
    [1b/4e3537] process > AB:LEARN_PRIOR (9) [100%] 9 of 9 ✔
    [2a/42f4df] process > AB:RECONSTRUCT     [100%] 1 of 1 ✔
    [da/17bb2f] process > A:LEARN_PRIOR (9)  [100%] 9 of 9 ✔
    [59/d209b2] process > A:RECONSTRUCT      [100%] 1 of 1 ✔
    [26/65e7a0] process > B:LEARN_PRIOR (9)  [100%] 9 of 9 ✔
    [7e/b65391] process > B:RECONSTRUCT      [100%] 1 of 1 ✔
    [58/721e46] process > C:LEARN_PRIOR (9)  [100%] 9 of 9 ✔
    [99/517354] process > C:RECONSTRUCT      [100%] 1 of 1 ✔
    Completed at: 21-Nov-2020 16:00:29
    Duration    : 2m 16s
    CPU hours   : 0.1
    Succeeded   : 51

**Networks**

    /results
    ├── /A
    │   └── /network.adj.rds
    ├── /B
    │   └── /network.adj.rds
    └── /C
        └── /network.adj.rds

# Learning Methods

## Single Unconstrained Network

Single networks without constraints are relatively simple. All that is
required is an Expression Set object containing the features and samples
the network will be built on. One can optionally include a prior in the
form of matrix of probabilities or a singular value.

``` r
eset <- readRDS("data/esets/ABC.rds")
dim(eset)
```

    #> Features  Samples 
    #>      150       30

``` sh
eset = "data/esets/ABC.rds"

workflow {
    LEARN( eset )
}

workflow {
    LEARN_PRIOR( eset, prior )
}
```

## Multiple Unconstrained Networks

A network can also be used as a prior for learning another network.

``` sh
workflow A {
    main:
      eset = "data/esets/A.rds"
      LEARN( eset )
    emit:
      LEARN.out[0]
}
workflow B {
    take: 
      prior
    main:
      eset = "data/esets/B.rds"
      LEARN_PRIOR( eset, prior )
}
workflow {
    A()
    B(A.out)
}
```

## Multiple Constrained Networks

In [shine](https://github.com/montilab/shine) we apply modular
structural constraints when learning networks. These take the form of a
list of modules containing intersecting sets of features. Please see our
[documentation](https://montilab.github.io/shine/articles/docs/constraints.html)
of the method for more details.

``` r
modules <- readRDS("data/modules.rds")
head(modules[[1]])
```

    #> [1] "1"  "2"  "8"  "30" "44" "45"

``` sh
workflow A {
    main:
      eset = "data/esets/A.rds"
      modules = "data/modules.rds"
      SPLIT( eset, modules )
      LEARN( SPLIT.out.flatten() )
      RECONSTRUCT( eset, LEARN.out[0].collect() )
    emit:
      LEARN.out[0]
}
workflow B {
    take: 
      prior
    main:
      eset = "data/esets/B.rds"
      LEARN_PRIOR( eset, prior )
      RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
}
workflow {
    A()
    B(A.out)
}
```

# Generative Nextflow

While this modular framework greatly reduces the amount of work required
to write large workflows, it can still be burdensome to learn networks
within a large hierarchy with many branch points. We wrote a small
Python utility for dynamically generating these workflows.

This requires a file defining the hierarchy of processes and workflow
components that are pieced together to form the total workflow.
Additionally, you will specify required parameters for each module
separated by the ‘|’ character. This is highly flexible and is suitable
to the needs of most workflows.

``` python
import gnf

df = gnf.read_data("data/data.csv")
```

1.  Outputs can be used as inputs to one or more processes
      - Parent nodes can have multiple children
      - Child nodes have a single parent
2.  Modules can be repeated or different
3.  Modules can take one or more keyword arguments

<!-- end list -->

``` 
      process label       module  params
0      -> ABC   ABC        LEARN  eset=data/esets/ABC.rds|mods=data/modules.rds
1   ABC -> AB    AB  LEARN_PRIOR                         eset=data/esets/AB.rds 
2    ABC -> C     C  LEARN_PRIOR                          eset=data/esets/C.rds 
3    AB  -> A     A  LEARN_PRIOR                          eset=data/esets/A.rds 
4    AB  -> B     B  LEARN_PRIOR                          eset=data/esets/B.rds 
```

Each line would be a process in the workflow. You start by reading in
the data and building a rooted tree that represents the dependencies of
the workflow. The tree starts at the root and can be traversed.

``` python
# Build tree
tree = gnf.build_tree(df)

# View tree
gnf.print_tree(tree)
```

Here the dependency structure is defined, the module required for each
process, as well as the keyword arguments that module may take. All of
this information is stored as object properties representing the node.

    ABC [LEARN]
    eset: data/esets/ABC.rds
    mods: data/modules.rds
    
    |-- AB [LEARN_PRIOR]
    |   eset: data/esets/AB.rds
    |   
    |   |-- A [LEARN_PRIOR]
    |   |   eset: data/esets/A.rds
    |   |   
    |   +-- B [LEARN_PRIOR]
    |       eset: data/esets/B.rds
    |       
    +-- C [LEARN_PRIOR]
        eset: data/esets/C.rds

We also need a representation of the individual workflow components that
are pieced together. Workflow components can be simple multi-line
strings that are not modified (e.g. the workflow header) or they are
modules with placeholders (e.g. workflow processes). Modules are
essentially reusable templates for Nextflow processes. Workflow modules
are templates of Nextflow processes that are populated by the node
properties (`kwargs`). Modules take any number of keyword arguments
through the elegant string formatting ability of Python.

``` python
class Modules():

    @gnf.pretty_format
    def LEARN(self, **kwargs):
        return('''\
        workflow {child} {{
            main:
              eset = "${{params.indir}}/{eset}"
              modules = "${{params.indir}}/{mods}"
              SPLIT( eset, modules )
              LEARN( SPLIT.out.flatten() )
              RECONSTRUCT( eset, LEARN.out[0].collect() )
            emit:
              LEARN.out[0]
        }}
        '''.format(**kwargs))

    @gnf.pretty_format
    def LEARN_PRIOR(self, **kwargs):
        return('''\
        workflow {child} {{
            take: 
              prior
            main:
              eset = "${{params.indir}}/{eset}"
              LEARN_PRIOR( eset, prior )
              RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
            emit:
              LEARN_PRIOR.out[0]
        }}
        '''.format(**kwargs))
```

When traversing the tree, for each node, we find the object method
described for the specific module, and pass the parent, child, and
keyword arguments to the method, writing the filled template to the
workflow file. This is a very basic example, but this simple design can
scale up to very large workflows.

``` python
m = Modules()
for node in gnf.traverse_tree(tree):
    module = getattr(m, node.module)
    print(module(**node.kwargs))
```

# Alternative Dependency Options

**R Packages**  
We suggest R \>= 3.6.0 and workflows will expect the following R
dependencies to be available.

``` r
library(BDgraph)
library(Biobase)
library(Matrix)
library(magrittr)
library(optparse)
```

**Conda**  
You can alternatively run workflows with a conda environment activated.

    conda create -n shine python=3.7
    source activate shine
    
    conda install -c conda-forge r-base -y
    conda install -c conda-forge r-bdgraph -y
    conda install -c conda-forge r-optparse -y
    conda install -c conda-forge r-matrix -y
    conda install -c conda-forge r-magrittr -y
    conda install -c bioconda bioconductor-biobase -y
