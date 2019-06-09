# venn plot of otus between HA and CR
# get the venn diagram of a given time point
# 
# @param ps phyloseq object
# @return venn diagram
generate_venn_diagram <- function(ps) {
  if (class(ps) != "phyloseq") {
    stop("ps must be a phyloseq object")
  }
  ps_ha <- subset_samples(ps, Treatment == "HA") %>% 
    prune_taxa(taxa_sums(.) > 0, .)
  ps_cr <- subset_samples(ps, Treatment == "CR") %>% 
    prune_taxa(taxa_sums(.) > 0, .)
  
  ha_taxa <- taxa(ps_ha)
  cr_taxa <- taxa(ps_cr)

  venn <- venn(list(CR = cr_taxa, HA = ha_taxa))
  return(venn)
}
