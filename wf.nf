#!/usr/bin/env nextflow
VERSION="1.0"
nextflow.enable.dsl=2

// Workflow parameters
params.indir  = "./data"
params.outdir = "./results"

// Learning parameters
params.bdg_mode = "bdgraph.mpl"
params.bdg_uprior = 0.5
params.bdg_cut = 0.9
params.bdg_iter = 5000

println()
params.help = ""
if (params.help) {
  log.info " "
  log.info "USAGE: "
  log.info " "
  log.info "nextflow run wf.nf -c configs/profiles.config -profile {profile}"
  log.info " "
  exit 1
}

log.info """
W O R K F L O W ~ Configuration
===============================
Profile            : ${workflow.profile}
Project Path       : ${workflow.projectDir}
Input Directory    : ${params.indir}
Output Directory   : ${params.outdir}
-------------------------------

Learning parameters
===============================
BDG Mode           : ${params.bdg_mode}
BDG Uniform Prior  : ${params.bdg_uprior}
BDG Cut            : ${params.bdg_cut}
BDG Iter           : ${params.bdg_iter}
-------------------------------\n
"""

include { SPLIT } from './modules/SPLIT'
include { LEARN } from './modules/LEARN'
include { LEARN_PRIOR } from './modules/LEARN_PRIOR'
include { RECONSTRUCT } from './modules/RECONSTRUCT'

workflow ABC {
    main:
      eset = "${params.indir}/esets/ABC.rds"
      modules = "${params.indir}/modules.rds"
      SPLIT( eset, modules )
      LEARN( SPLIT.out.flatten() )
      RECONSTRUCT( eset, LEARN.out[0].collect() )
    emit:
      LEARN.out[0]
}
workflow AB {
    take: 
      prior
    main:
      eset = "${params.indir}/esets/AB.rds"
      LEARN_PRIOR( eset, prior )
      RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
    emit:
      LEARN_PRIOR.out[0]
}
workflow A {
    take: 
      prior
    main:
      eset = "${params.indir}/esets/A.rds"
      LEARN_PRIOR( eset, prior )
      RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
}
workflow B {
    take: 
      prior
    main:
      eset = "${params.indir}/esets/B.rds"
      LEARN_PRIOR( eset, prior )
      RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
}
workflow C {
    take: 
      prior
    main:
      eset = "${params.indir}/esets/C.rds"
      LEARN_PRIOR( eset, prior )
      RECONSTRUCT( eset, LEARN_PRIOR.out[0].collect() )
}
workflow {
    ABC()
    AB(ABC.out)
    A(AB.out)
    B(AB.out)
    C(ABC.out)
}
