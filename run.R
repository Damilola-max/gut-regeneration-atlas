source("R/utils_io.R")

message("=== Gut Regeneration Atlas ===")
message("Using config at: config/config.yml")

# 0) one-time setup (uncomment if first run)
# source("R/00_setup.R")

# 1) preprocess
source("R/01_preprocess_gff.R")

# 2) sparse matrix + UMAP
source("R/02_sparse_matrix_and_umap.R")

# 3) co-occurrence network + heatmap
source("R/03_network_cooccurrence.R")

# 4) PCA regenerative gradient map
source("R/04_pca_regenerative_gradient.R")

# 5) session info
source("R/05_export_sessioninfo.R")

message("✅ All analyses completed. Figures in ./figures")
# master runner script placeholder
