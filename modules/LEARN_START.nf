process LEARN_START {
    publishDir "${params.outdir}/${task.process.split(':')[0]}/bdg/rds", pattern: '*.rds', mode: 'copy'
    publishDir "${params.outdir}/${task.process.split(':')[0]}/bdg/logs", pattern: '*.log', mode: 'copy'

    input:
    path(eset)
    file(start)

    output:
    file '*.rds'
    file '*.log'

    script:
    """
    learn.R \
    --eset $eset \
    --start $start \
    --mode ${params.bdg_mode} \
    --cores ${task.cpus} \
    --iter ${params.bdg_iter} \
    --save "${start.baseName}_${eset.baseName}"
    """
}