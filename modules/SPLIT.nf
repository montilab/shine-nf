process SPLIT {
    publishDir "${params.outdir}/${task.process.split(':')[0]}/splits", mode: 'copy'

    input:
    path(eset)
    path(modules)

    output:
    file '*.rds'

    script:
    """
    split.R --eset $eset --modules $modules
    """
}