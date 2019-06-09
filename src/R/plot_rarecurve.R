#' plot rare cure using ggplot
#' 
#' @param phylo a phyloseq object
#' @param step integer, step size for sample sizes in rarefaction curves.
#' 
#' @return ggplot object

plot_rarecurve <- function(phylo, step = 100) {
  rarecurve_out <- rarefy_phyloseq(phylo, step = step)  # number of otus
  out_subsample <- map(rarecurve_out, ~ attr(.x, "Subsample")) # number of subsampled reads
  group_n <- length(out_subsample)
  samples <- sample_names(phylo)
  out_df_list <- pmap(list(out_subsample, rarecurve_out, 1:group_n, samples), 
    ~ data.frame(reads = ..1, otus = ..2, group = ..3, sample = ..4,
      stringsAsFactors = FALSE))
  
  out_df <- bind_rows(out_df_list) %>% 
    mutate(treatment = str_replace(sample, "\\d+(\\.)", "\\1"))
  
  p <- ggplot(out_df) + 
    geom_line(aes(reads, otus, group = factor(group), color = treatment)) +
    labs(x = "Number of Reads", y = "Number of OTU") +
    guides(color = guide_legend(title = NULL)) +
    theme_bw() +
    scale_color_npg()
  
  return(p)
}


#' Rarefaction species richness
#' 
#' @param phylo a phyloseq object
#' @param step step size for sample sizes in rarefaction curves.
#' 
#' The source code is orginated from the function rarefycurve in vegan
#' 
#' @return a list, each element represents the rarefaction data for each sample.

rarefy_phyloseq <- function(phylo, step = 100) 
{
  x <- t(otu_table(phylo))
  if (!identical(all.equal(x, round(x)), TRUE)) 
    stop("function accepts only integers (counts)")
  
  tot <- rowSums(x)
  species_number <- vegan::specnumber(x)
  if (any(species_number <= 0)) {
    message("empty rows removed")
    x <- x[species_number > 0, , drop = FALSE]
    tot <- tot[species_number > 0]
    species_number <- species_number[species_number > 0]
  }
  nr <- nrow(x)
  
  out <- lapply(seq_len(nr), function(i) {
    n <- seq(1, tot[i], by = step)
    if (n[length(n)] != tot[i]) 
      n <- c(n, tot[i])
    drop(vegan::rarefy(x[i, ], n))
  })
  
  out
}