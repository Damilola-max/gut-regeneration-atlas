source("R/utils_io.R")
library(tidyverse); library(Matrix); library(proxyC); library(igraph); library(pheatmap)

ensure_dir(cfg$paths$network_dir)

ko_mat <- readRDS(ppath(cfg$paths$processed_dir, "ko_sparse_matrix.Rds"))
regen_kos <- read_tsv(cfg$paths$regen_kos, col_names = "kegg", show_col_types = FALSE) %>% pull(kegg)

# Filter matrix to regenerative KOs present
common_kos <- intersect(colnames(ko_mat), regen_kos)
stopifnot(length(common_kos) > 0)
regen_mat <- ko_mat[, common_kos, drop = FALSE]

# Drop ultra-rare KOs
ko_prev <- Matrix::colSums(regen_mat > 0)
keep <- which(ko_prev >= cfg$network$ko_min_prevalence)
regen_mat_trim <- regen_mat[, keep, drop = FALSE]
saveRDS(regen_mat_trim, ppath(cfg$paths$network_dir, "regen_mat_trim.Rds"))

# Jaccard similarity (sparse-aware)
regen_cor <- proxyC::simil(t(regen_mat_trim), method = "jaccard")
saveRDS(regen_cor, ppath(cfg$paths$network_dir, "regen_jaccard_sparse.Rds"))

# Edge list with threshold
S <- summary(regen_cor)
edges <- tibble(KO1 = colnames(regen_mat_trim)[S$i],
                KO2 = colnames(regen_mat_trim)[S$j],
                weight = S$x) %>%
  filter(KO1 != KO2, weight >= cfg$network$jaccard_threshold)

nodes <- tibble(KO = colnames(regen_mat_trim))
g <- graph_from_data_frame(edges, directed = FALSE, vertices = nodes)
saveRDS(g, ppath(cfg$paths$network_dir, "regen_network_graph.rds"))

# Heatmap (dense export for small K)
mat <- as.matrix(regen_cor)
diag(mat) <- NA; mat[is.na(mat)] <- 0
pheatmap::pheatmap(
  mat,
  color = colorRampPalette(c("#f7fbff","#6baed6","#08306b"))(100),
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "average",
  display_numbers = FALSE,
  fontsize = 8,
  border_color = "white",
  main = "Pairwise Co-occurrence Heatmap of Regenerative KOs",
  filename = ppath(cfg$paths$figures_dir, "Fig2_Regenerative_Cooccurrence_Heatmap.png"),
  width = 9, height = 8
)

# Top hub KOs (degree)
deg <- degree(g, mode = "all")
top_hubs <- sort(deg, decreasing = TRUE)[1:min(15, length(deg))]
write_tsv(tibble(KO = names(top_hubs), degree = as.integer(top_hubs)),
          ppath(cfg$paths$processed_dir, "network/top_hubs.tsv"))

message("✅ Network built, heatmap & hub list exported")
# network script placeholder
