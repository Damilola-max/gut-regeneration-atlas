# setup script placeholder
# Install & lock environment
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
renv::init(bare = TRUE)

pkgs <- c(
  "tidyverse","janitor","Matrix","irlba","uwot","ggplot2","viridis",
  "MASS","ggrepel","proxyC","igraph","ggraph","pheatmap","RColorBrewer",
  "ggnewscale","cowplot","yaml","data.table","readr"
)
install.packages(setdiff(pkgs, rownames(installed.packages())), Ncpus = max(1, parallel::detectCores()-1))
renv::snapshot()
