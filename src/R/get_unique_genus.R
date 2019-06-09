#' format the unique genus
#' 
#' @param ps, a phyloseq object, generally the output of the tax_glom
#' 
#' @return a phyloseq object, if the genus is unknown, it was corrected as the known upper 
#' level taxa and suffix with "Unkown", e.g.f__Coriobacteriaceae;Unkown
#' 
format_unique_genus <- function(genus) {
  levels <- c("Genus", "Family", "Order", 
    "Class", "Phylum", "Kingdom")
  names(levels) <- levels
  taxas <- tax_table(genus)@.Data %>% 
    as_tibble() %>% 
    select(one_of(levels))
  
  otus <- otu_table(genus)@.Data
  
  known_index <- map_df(levels, ~ !grepl("__$", taxas[[.]])) %>% 
    t() %>% 
    as_tibble(.name_repair = "unique") %>% 
    map_df(cumsum) %>% 
    map_dbl( ~ which(.x == 1))
  
  k_index <- which(known_index == 1)
  uk_index <- which(known_index != 1)
  k <- taxas[["Genus"]][k_index]
  uk <- map2_chr(uk_index, known_index[uk_index], ~ taxas[[.y]][.x])
  unique <- vector(length = length(known_index))
  unique[k_index] <- k
  unique[uk_index] <- paste(uk, "Unkown", sep = ";")
  
  taxas$unique <- unique
  taxas <- as.matrix(taxas)
  row.names(taxas) <- unique

  #tax_table(genus) <- taxas
  row.names(otus) <- unique
  #otu_table(genus) <- otus
  
  return(phyloseq(otu_table(otus, taxa_are_rows = TRUE), tax_table(taxas),
    sample_data(genus)))
}


