get_diff_feature <- function(mset, vip_th = 1, p_th = 0.05, fc_th = 2) {
  vip <- mset$analSet$plsda$vip.mat[, 1]
  p_value <- mset$analSet$tt$p.value
  t_score <- mset$analSet$tt$t.score
  fc <- mset$analSet$fc$fc.all
  
  ordered_names <- names(vip)
  p_value <- p_value[match(ordered_names, names(p_value))]
  t_score <- t_score[match(ordered_names, names(t_score))]
  fc <- fc[match(ordered_names, names(fc))]
  
  feature_table <- tibble(
    name = names(vip),
    vip = vip,
    p_value = p_value,
    t_score = t_score,
    fc = fc
  )
  
  diff_feature <- filter(feature_table,
    vip > vip_th,
    p_value < p_th,
    fc > fc_th | fc < 1/fc_th
  )
  
  diff_feature
  
}
  