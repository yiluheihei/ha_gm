#' compare groups using anosim and mrpp method based on bray and unifrac distance
compare_groups <- function(ps, grouping = "Treatment", permutations = 999) {

  d_bray <- phyloseq::distance(ps, method = "bray")
  d_jaccard <- phyloseq::distance(ps, method = "jaccard")
  sample_grouping <- meta(ps)[[grouping]] 
  
  anosim_sig <- list(bray = anosim(d_bray, sample_grouping),
    jaccard = anosim(d_jaccard, sample_grouping)) %>% 
    map_dbl(~ .x$signif) # extract pvalue
  mrpp_sig <- list(bray = mrpp(d_bray, sample_grouping),
    jaccard = mrpp(d_jaccard, sample_grouping)) %>% 
    map_dbl(~ .x$Pvalue)
  
  return(list(Anosim = anosim_sig, MRPP = mrpp_sig))
}


