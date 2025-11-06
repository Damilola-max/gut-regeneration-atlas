source("R/utils_io.R")
library(tidyverse); library(Matrix); library(irlba); library(uwot)

gff_kegg <- read_tsv(ppath(cfg$paths$processed_dir, "gff_kegg_clean.tsv"), show_col_types = FALSE)

# Encode to indices
id_index   <- as.integer(factor(gff_kegg$id))
kegg_index <- as.integer(factor(gff_kegg$kegg))

# Sparse matrix (genes × KOs)
ko_mat <- sparseMatrix(
  i = id_index, j = kegg_index, x = 1,
  dims = c(length(unique(id_index)), length(unique(kegg_index))),
  dimnames = list(levels(factor(gff_kegg$id)), levels(factor(gff_kegg$kegg)))
)

ensure_dir(cfg$paths$processed_dir)
saveRDS(ko_mat, ppath(cfg$paths$processed_dir, "ko_sparse_matrix.Rds"))
message("✅ Saved sparse matrix")

# Subsample rows for UMAP
set.seed(123)
N <- min(cfg$umap$subsample_rows, nrow(ko_mat))
subset_rows <- sample(1:nrow(ko_mat), N)
ko_small <- ko_mat[subset_rows, ]

# Truncated SVD
svd_res <- irlba(ko_small, nv = cfg$umap$svd_components)
ko_svd <- svd_res$u %*% diag(svd_res$d)

# UMAP
set.seed(123)
umap_res <- umap(
  ko_svd,
  n_neighbors = cfg$umap$n_neighbors,
  min_dist = cfg$umap$min_dist,
  metric = cfg$umap$metric,
  n_threads = cfg$umap$n_threads,
  verbose = TRUE
)

umap_df <- tibble(UMAP1 = umap_res[,1], UMAP2 = umap_res[,2], idx = subset_rows)

# Add minimal metadata (feature type) for the sampled rows
meta_subset <- gff_kegg$type[subset_rows]
umap_df$type <- meta_subset

write_tsv(umap_df, ppath(cfg$paths$processed_dir, "umap_embedding_50k.tsv"))
message("✅ Saved UMAP embedding to data/processed/umap_embedding_50k.tsv")
# umap script placeholder
