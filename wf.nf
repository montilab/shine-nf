#!/usr/bin/env nextflow
VERSION="1.0"
nextflow.enable.dsl=2

// Workflow parameters
params.dir = null
params.data  = null
params.outdir = "/results"
params.email = ""

// Learning parameters
params.bdg_mode = "bdgraph.mpl"
params.bdg_uprior = 0.5
params.bdg_cut = 0.9
params.bdg_cores = 1
params.bdg_iter = 5000

println()

params.help = ""
if (params.help) {
  log.info " "
  log.info "USAGE: "
  log.info " "
  log.info "nextflow run workflow.nf -c workflow.config -profile {profile}"
  log.info " "
  exit 1
}

log.info """
W O R K F L O W ~ Configuration
===============================
Profile            : ${workflow.profile}
Project Path       : ${workflow.projectDir}
Input Data         : ${params.data}
Output Directory   : ${params.outdir}
-------------------------------

Learning parameters
===============================
BDG Mode           : ${params.bdg_mode}
BDG Uniform Prior  : ${params.bdg_uprior}
BDG Cut            : ${params.bdg_cut}
BDG Cores          : ${params.bdg_cores}
BDG Iter           : ${params.bdg_iter}
-------------------------------
"""

include { SPLIT } from './modules/SPLIT'
include { LEARN } from './modules/LEARN'
include { LEARN_PRIOR } from './modules/LEARN_PRIOR'
include { RECONSTRUCT } from './modules/RECONSTRUCT'

workflow ROOT {
    main:
      eset = "/data/eset.rds"
      modules = "/data/modules.rds"
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
      eset = "/data/eset_AB.rds"
      LEARN_PRIOR( eset, prior )
    emit:
      LEARN_PRIOR.out[0]
}
workflow A {
    take: 
      prior
    main:
      eset = "/data/eset_A.rds"
      LEARN_PRIOR( eset, prior )
}
workflow B {
    take: 
      prior
    main:
      eset = "/data/eset_B.rds"
      LEARN_PRIOR( eset, prior )
}
workflow {
    ROOT()
    AB( ROOT.out )
    A( AB.out)
    B( AB.out)
}
