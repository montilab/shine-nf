process RECONSTRUCT {
    publishDir "${params.outdir}/${task.process.split(':')[0]}/adj", mode: 'copy'

    input:
    path(eset)
    file(graphs)

    output:
    file('*.rds')

    script:
    """
    reconstruct.R \
    --eset $eset \
    --cut ${params.bdg_cut} \
    $graphs
    """
}