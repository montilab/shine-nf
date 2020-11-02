process LEARN {
    publishDir "${params.outdir}/${task.process.split(':')[0]}/bdg/rds", pattern: '*.rds', mode: 'copy'
    publishDir "${params.outdir}/${task.process.split(':')[0]}/bdg/logs", pattern: '*.log', mode: 'copy'

    input:
    path(eset)

    output:
    file '*.rds'
    file '*.log'

    script:
    """
    learn.R \
    --eset $eset \
    --uprior ${params.bdg_uprior} \
    --mode ${params.bdg_mode} \
    --cores ${params.bdg_cores} \
    --iter ${params.bdg_iter} \
    --save ${eset.baseName} \
    """
}