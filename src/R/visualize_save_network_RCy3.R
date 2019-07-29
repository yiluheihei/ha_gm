# visualization i cytoscape
library(RCy3)
library(igraph)
library(stringr)

# set the unkown phylum to Unclassified
phylum_ha <- vertex_attr(net_ha28, "Phylum")
phylum_ha[is.na(phylum_ha)] <- "Unclassified"
net_ha28 <- set_vertex_attr(net_ha28, "Phylum", value = phylum_ha)
phylum_cr <- vertex_attr(net_cr28, "Phylum")
phylum_cr[is.na(phylum_cr)] <- "Unclassified"
net_cr28 <- set_vertex_attr(net_cr28, "Phylum", value = phylum_cr)

createNetworkFromIgraph(net_ha28,"ha28")
createNetworkFromIgraph(net_cr28, "cr28")
setVisualStyle("Solid", "ha28")
setVisualStyle("Solid", "cr28")
setEdgeLabelDefault(NA, "Solid")

# set node color according to phylum
cols <- ggsci::pal_npg(palette = c("nrc"), alpha = 1)(10) %>% 
  stringr::str_sub(1, 7) %>% 
  rev

phylums <- unique(vertex_attr(net_ha28, "Phylum"))
phylums <- c(setdiff(phylums, "Unclassified"), "Unclassified") %>% 
  sort()

setNodeColorMapping(
  'Phylum',
  phylums,
  cols,
  mapping.type = "discrete",
  style.name = "Solid",
  network = "ha28"
)

setNodeColorMapping(
  'Phylum',
  phylums,
  cols,
  mapping.type = "discrete",
  style.name = "Solid",
  network = "cr28"
)

setEdgeColorMapping(
  'color',
  mapping.type = "p",
  style.name = "Solid",
  network = "ha28"
)

setEdgeColorMapping(
  'color',
  mapping.type = "p",
  style.name = "Solid",
  network = "cr28"
)

# two networks in the same scale to keep the node in the same size
# https://groups.google.com/forum/#!topic/cytoscape-helpdesk/6d8FayfJbZg
net_scale <- min(
  c(getNetworkProperty("NETWORK_SCALE_FACTOR", "ha28"),
    getNetworkProperty("NETWORK_SCALE_FACTOR", "cr28")
  )
)
setNetworkPropertyBypass(net_scale, "NETWORK_SCALE_FACTOR", network = "ha28")
setNetworkPropertyBypass(net_scale, "NETWORK_SCALE_FACTOR", network = "cr28")

# remove the labels of nodes and edges using cytoscape, then export to svg
# don't know how to remove the labels of nodes and edges using RCy3 ?
# exportImage("output/net_cytoscape/ha28", type = "SVG", network = "ha28")