process SPLIT {
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