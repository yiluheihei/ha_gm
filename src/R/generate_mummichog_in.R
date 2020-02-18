generate_mummichog_in <- function(neg_novo, mset) {
  p_value <- mset$analSet$tt$p.value
  t_score <- mset$analSet$tt$t.score
  m.z <- neg_novo$`Molecular Weight`[match(names(p_value), neg_novo$ID)]
  t_score <- t_score[match(names(p_value), names(t_score))]
  
  return(tibble(
    m.z = m.z,
    p.value = p_value,
    t.score = t_score
  ))
}
