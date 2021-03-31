#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(Biobase))
suppressPackageStartupMessages(library(BDgraph))
suppressPackageStartupMessages(library(optparse))

bdg.estimate <- function(data, mpl=FALSE, ...) {
    if (mpl) {
        return(BDgraph::bdgraph.mpl(data=data, method="ggm", ...))
    }
    else {
        return(BDgraph::bdgraph(data=data, method="ggm", ...))
    }
}

bdg.prior <- function(eset, prior) {
    if (is(prior, "numeric")) {
        stopifnot(prior >= 0 & prior <= 1)
        return(prior)
    }
    else if (is(prior, "bdgraph")) {
        prior <- BDgraph::plinks(prior, round=10)
        rownames(prior) <- colnames(prior)
        stopifnot(colnames(prior) %in% rownames(eset))
        stopifnot(is(prior, "matrix"))
        return(prior)
    }
    else if (is(prior, "matrix")) {
        stopifnot(!is.null(colnames(prior)))
        stopifnot(colnames(prior) == rownames(prior))
        stopifnot(colnames(prior) %in% rownames(eset))
        stopifnot(!any(prior < 0 | prior > 1))
        return(prior)
    }
    else  {
        stop(paste("Invalid prior type: \n", paste(is(prior), collapse="\n"), sep=""))
    }
}

bdg.start <- function(eset, start) {
    if (is(start, "matrix")) {
        stopifnot(!is.null(colnames(start)))
        stopifnot(colnames(start) == rownames(start))
        stopifnot(colnames(start) %in% rownames(eset))
        stopifnot(start == 0 | start == 1)
        return(start)
    }
    else  {
        stop(paste("Invalid start type: \n", paste(is(start), collapse="\n"), sep=""))
    }
}

bdg.eset <- function(eset, prior, start) {
    if (is(prior, "matrix") & is(start, "matrix")) {
        stopifnot(colnames(prior) == colnames(start))
        eset <- eset[colnames(prior),]
    }
    if (is(prior, "matrix") & !is(start, "matrix")) {
        eset <- eset[colnames(prior),]
    }
    if (!is(prior, "matrix") & is(start, "matrix")) {
        eset <- eset[colnames(start),]
    }
    return(eset)
}

option_list <- list(
    make_option(c("--eset"), type="character", default=NULL, help="path to eset"),
    
    make_option(c("--prior"), type="character", default=NULL, help="path to prior"),
    make_option(c("--uprior"), type="numeric", default=0.5, help="uniform prior"),
    
    make_option(c("--start"), type="character", default=NULL, help="path to start"),
    make_option(c("--ustart"), type="character", default="empty", help="uniform start"),

    make_option(c("--mode"), type="character", default="bdgraph", help="bdgraph or bdgraph.mpl"),
    make_option(c("--cores"), type="numeric", default=1, help="number of cores"),
    make_option(c("--iter"), type="numeric", default=1000, help="number of iterations"),
    make_option(c("--save"), type="character", default=NULL, help="save file name")
)

# -------
# Parse arguments
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Load data and parameters
eset  <- readRDS(opt$eset)
label <- ifelse(is.null(opt$save), basename(opt$eset), opt$save)

# Start logging
log <- paste(label, ".log", sep="") 
sink(log, append=FALSE, split=TRUE)

# Load prior
if (is.null(opt$prior)) {
    prior <- opt$uprior
    stopifnot(prior >= 0 & prior <= 1)
} else {
    prior <- readRDS(opt$prior)
    prior <- bdg.prior(eset, prior)
}

# Load start
if (is.null(opt$start)) {
    start <- opt$ustart
    stopifnot(start == "empty" | start == "full")
} else {
    start <- readRDS(opt$start)
    start <- bdg.start(eset, start)
}

# Check eset
eset <- bdg.eset(eset, prior, start)

mpl <- opt$mode == "bdgraph.mpl"
cores <- opt$cores
iter <- opt$iter

# Log data
cat(paste("Processing...", label, "\n"))
cat(paste("\n[Data]\n"))
print(eset)
cat(paste("\n[Prior]\n"))
if (is(prior, "numeric")) print(prior)
if (is(prior, "matrix")) print(dim(prior))
cat(paste("\n[Start]\n"))
if (is(start, "character")) print(start)
if (is(start, "matrix")) print(dim(start))
cat("\n[Parameters]")  
cat(paste("\n- mpl:", mpl))
cat(paste("\n- cores:", cores))
cat(paste("\n- iter:", iter))

cat("\n\n[Iterations]\n")  
bdg <- bdg.estimate(data=t(Biobase::exprs(eset)), 
                    mpl=mpl,
                    g.prior=prior,
                    g.start=start,
                    iter=iter, 
                    cores=cores-1, 
                    save=FALSE)

saveRDS(bdg, paste(label, ".bdg.rds", sep=""))
