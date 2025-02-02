library(bain)

# pbf moet ook werken voor meerdere hypotheses en de posterior model probabilities
# moeten gereturned worden.
# zodra functie compleet is, fork bain en implementeer
pbf <- function(x, ...){
  if(!all(sapply(x, inherits, what = "bain"))){ 
    cl <- match.call()
    cl[[1L]] <- quote(bain)  
    for(i in (1:length(x))){
      cl[['x']] <- x[[i]]
      x[[i]] <- eval.parent(cl)
    }
    # cl[['x']] <- lapply(x, eval.parent, cl)
    cl[['x']] <- x
    cl[[1L]] <- quote(pbf)
    eval.parent(cl)
  }

  # Merge the hypotheses from list item 1 and 2 into object merged
  if(length(x) > 1){
    hyps <- x[[1]]$hypotheses
    for(i in length(x)-1){
      hyps <- c(hyps, x[[i+1]]$hypotheses)
      # Drop all non-duplicated hypotheses from merged
      hyps <- hyps[duplicated(hyps)]
      # If merged now has length 0, throw error
      if(length(hyps) == 0){
        stop("The objects passed to pbf() have no hypotheses in common.")
      }
      # Else, go back to step 1, but now merge merged with list item 3
    }
  }
  BFs <- do.call(cbind, lapply(x, function(y){y$fit$BF.c[match(hyps, y$hypotheses)]}))
  colnames(BFs) <- paste0("Sample ", 1:ncol(BFs))
  res <- data.frame(PBF = apply(BFs, 1, prod), BFs)# obtain pbf ic, might need to change dependent on alternative hyp
  rownames(res) <- paste0(sprintf('H%d: ', 1:length(hyps)),hyps) # give names
  class(res) <- c("pbf", class(res))
  return(res)
}
