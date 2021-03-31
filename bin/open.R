#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(optparse))

option_list <- list(
    make_option(c("--modules"), type="character", default=NULL, help="path to modules")
)

# -------

# Parse arguments
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Extract data contents
modules <- readRDS(opt$modules)

# Name modules if none are provided
if (is.null(names(modules))) {
    names(modules) <- paste("M", seq(length(modules)), sep="")
}

# Save each module as an expression set
sh <- mapply(function(label, module) {
    saveRDS(module, paste(label, ".rds", sep=""))
}, names(modules), modules)
