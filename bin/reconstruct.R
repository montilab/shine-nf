#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(BDgraph))
suppressPackageStartupMessages(library(Biobase))
suppressPackageStartupMessages(library(Matrix))
suppressPackageStartupMessages(library(magrittr))

mat.symmetric <- function(mat) {
    as.matrix(forceSymmetric(mat, uplo="U"))
}

mat.reconstruct <- function(probes, adjs) {
    # Empty matrix
    mat <- matrix(0, nrow=length(probes), ncol=length(probes), dimnames=list(probes, probes))
    
    # Enumerate unique pairs
    pairs <- combn(colnames(mat), 2)
    
    # Log progress every break
    breaks <- round(length(pairs)/10)
    
    for (i in seq_len(ncol(pairs))) {
        # For each given pair
        g1 <- pairs[1,i]; g2 <- pairs[2,i]
        
        # Check edge in each module
        x <- sapply(adjs, function(adj) {
            tryCatch({
                adj[g1, g2] # If pair exists in module
            }, error = function(e) {
                return(NA)
            })
        })
        
        # Resolve edge
        if (all(is.na(x))) {
            # Pair never met within constraints
            edge <- 0
        } else {
            # If pair exists within one or more constraints
            edge <- min(x, na.rm=T)
        }
        
        mat[g1, g2] <- mat[g2, g1] <- edge
        
        # Logging progress
        if (i %% breaks == 0) cat(i, "\n")
    }
    return(mat)
}

# -------

# Parse arguments
args <- commandArgs(trailingOnly=TRUE)
stopifnot(args[[1]] == "--eset")
stopifnot(args[[3]] == "--cut")

# Data
eset <- readRDS(args[[2]])
probes <- rownames(eset)

# Cut
cut <- as.numeric(args[[4]])
stopifnot(cut >= 0 & cut <= 1)

# Modules
files <- args[5:length(args)]

# Convert bdgraph objects to symmetric adj matrices
adjs <- lapply(files, function(x) {
    readRDS(x) %>%
    BDgraph::select(cut=cut) %>%
    mat.symmetric()
})

# Reconstruct
mat <- mat.reconstruct(probes, adjs)
saveRDS(mat, "network.adj.rds")
