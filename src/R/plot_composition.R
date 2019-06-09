plot_composition2 <- function(x, group = NULL, sample_sort = NULL, group_sort = NULL) {
  level <- rank_names(x)[1]  
  x_melt <- psmelt(x)
  abd <- group_by_(x_melt, level) %>% 
    summarise(sum = sum(Abundance)) %>% 
    arrange(sum)
  
  if (!is.null(group)) {
    x_melt <- group_by(x_melt, !!sym(group), !!sym(level)) %>% 
      summarise(m = mean(Abundance))
  }

  otu_sort <- as.character(abd[[level]])
  uk_idx <- which(otu_sort == "Unknown")
  otu_sort <- unique(c("Other", otu_sort[-uk_idx]))
  
  levels(x_melt[[level]])[levels(x_melt[[level]]) =="Unknown"] <- "Other"
  x_melt[[level]] <- factor(x_melt[[level]], levels = otu_sort)
  invisible(x_melt)
  
  if (!is.null(group)) {
    p <- ggplot(x_melt, aes(!!sym(group), m, fill = Phylum)) + 
      geom_bar(stat="identity", position = "stack")
    
    if (!is.null(group_sort))
      p <- p + scale_x_discrete(limits = group_sort)
   
    return(p)
  }
  
  p <- ggplot(x_melt, aes(Sample, Abundance, fill = !!sym(level))) +
    geom_bar(stat="identity", position = "stack")  +
    theme_bw() +
    theme(axis.text.x = element_text(size = 9, angle = 270, hjust = 0)) +
    scale_y_percent(breaks = seq(0, 1, 0.2), expand = c(0, 0))
  
  if (!is.null(sample_sort)) {
    p <- p + scale_x_discrete(limits = sample_sort)
  }

  
  return(p)
}
