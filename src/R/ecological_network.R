make_net <- function(ps, spiec_easi) {
  net_cor <- symBeta(getOptBeta(spiec_easi))
  net_cor[abs(net_cor) < 0.05] = 0
  otu <- t(otu_table(ps)@.Data)
  colnames(net_cor) <- rownames(net_cor) <- colnames(otu)
  # v_size <- log2(apply(otu, 2, mean))
  v_size <- sweep(otu, 1, rowSums(otu), FUN = "/") %>% colMeans()
  ig <- graph.adjacency(
    net_cor, mode = "undirected", 
    add.rownames = TRUE, weighted = TRUE
  )
  E(ig)[weight > 0]$color <- "red"
  E(ig)[weight < 0]$color <- "green"
  
  taxa <- tax_table(ps)@.Data
  
  for (rank in colnames(taxa)) {
    ig <- set_vertex_attr(ig, rank, value = taxa[, rank])
  }
  
  # net <- ig %>% 
  #   set_vertex_attr("Phylum", value = taxa[, "Phylum"]) %>% 
  #   set_vertex_attr("Family", value = taxa[, "Family"]) %>% 
  #   set_edge_attr("color", value = ifelse(E(.)$weight > 0, "red", "green"))
  
  # net <- intergraph::asNetwork(ig)
  # network::set.edge.attribute(net, "color",
  #   ifelse(net %e% "weight" > 0, "red", "green")
  # )
  # # phyla <- map_levels(colnames(otu), from = "Rank7", to = "Rank2", amgut.ctl)
  # net %v% "Phylum" <- tax_table(ps)@.Data[, 2]
  # net %v% "Family" <- tax_table(ps)@.Data[, 5]
  # net %v% "Genus" <- tax_table(ps)@.Data[, 6]
  # net %v% "nodesize" <- v_size
  
  return(ig)
}



# nc.attack <- function(ig) {
#   hubord <- order(rank(igraph::degree(ig)), decreasing=TRUE)
#   sapply(1:round(vcount(ig)*0.9), function(i) {
#     ind <- hubord[1:i]
#     tmp <- delete_vertices(ig, V(ig)$name[ind])
#     natcon(tmp)
#   }) }
#   
natcon <- function(ig) {
  N   <- vcount(ig)
  adj <- get.adjacency(ig)
  evals <- eigen(adj)$value
  nc  <- log(mean(exp(evals)))
  nc / (N - log(N))
}

component_size <- function(ig) {
  comp <- igraph::components(ig) %>% 
    igraph::groups()
  
  
  sub_ig <- induced_subgraph(ig, comp[[1]])
  
  vcount(sub_ig)
}

nc_attack <- function(ig, method = c("degree_betweenness", "degree", "betweenness", "random", "closeness")) {
  if (!method %in% c("degree_betweenness", "degree", "betweenness", "random", "closeness"))
    stop("method is one of degree_betweenness, degree, betweenness, random, closeness")
  oplan <- plan()
  on.exit(plan(oplan), add = TRUE)
  plan(multiprocess)
  if (method == "betweeness") {
    hubord <- order(rank(igraph::centr_betw(ig, directed = FALSE)$res), decreasing=TRUE)
  } else if (method == "closeness") {
    hubord <- order(rank(igraph::centr_clo(ig, mode = "all")$res), decreasing=TRUE)
  } else if (method == "degree_betweenness") {
    hubord <- order(rank(igraph::centr_betw(ig, directed = FALSE)$res), rank(igraph::degree(ig)), decreasing=TRUE)
  } else if (method == "degree") {
    hubord <- order(rank(igraph::degree(ig, normalized = TRUE)), decreasing = TRUE)
  } else {
    hubord <- sample(1:vcount(ig), vcount(ig))
  }
  net <- vector("list", round(vcount(ig)*0.8))
  a <- future_map_dbl(1:round(vcount(ig)*0.8), 
    function(i) {
      ind <- hubord[1:i]
      tmp <- delete_vertices(ig, V(ig)$name[ind])
      
      natcon(tmp)
    }, 
    .progress = TRUE)
  
  
  return(a)
}

component_attack <- function(ig, method = c("degree_betweenness", "degree", "betweenness", "random", "closeness")) {
  if (!method %in% c("degree_betweenness", "degree", "betweenness", "random", "closeness"))
    stop("method is one of degree_betweenness, degree, betweenness, random, closeness")
  oplan <- plan()
  on.exit(plan(oplan), add = TRUE)
  plan(multiprocess)
  if (method == "betweeness") {
    hubord <- order(rank(igraph::centr_betw(ig, directed = FALSE)$res), decreasing=TRUE)
  } else if (method == "closeness") {
    hubord <- order(rank(igraph::centr_clo(ig, mode = "all")$res), decreasing=TRUE)
  } else if (method == "degree_betweenness") {
    hubord <- order(rank(igraph::centr_betw(ig, directed = FALSE)$res), rank(igraph::degree(ig)), decreasing=TRUE)
  } else if (method == "degree") {
    hubord <- order(rank(igraph::degree(ig)), decreasing = TRUE)
  } else {
    hubord <- sample(1:vcount(ig), vcount(ig))
  }
  
  n_vertex <- vcount(ig)
  
  future_map_dbl(1:round(vcount(ig)*0.8), 
    function(i) {
      ind <- hubord[1:i]
      
      delete_vertices(ig, V(ig)$name[ind]) %>% 
        component_size()/n_vertex
    }) 
}

make_nc_tibble <- function(nc, state = "HA", method = "degree_betweenness") {
  tibble(
    x = seq(0, 0.8,  len = length(nc)), 
    y = nc,
    state = rep(state, length(nc)),
    method = rep(method, length(nc))
  )
}