process OPEN {
    input:
    path(modules)

    output:
    file '*.rds'

    script:
    """
    open.R --modules $modules
    """
}