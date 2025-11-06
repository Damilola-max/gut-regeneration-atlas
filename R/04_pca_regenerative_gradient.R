source("R/utils_io.R"); source("R/utils_plots.R")
library(tidyverse); library(MASS); library(ggrepel); library(viridis); library(ggnewscale)

# 1) Regenerative scores per genome from GFF directory + curated KO list
gff_dir  <- cfg$paths$gff_dir
stopifnot(dir.exists(gff_dir))
regen_kos <- read_tsv(cfg$paths$regen_kos, col_names = "kegg", show_col_types = FALSE) %>% pull(kegg)

# Read *.gff or *.gff.gz and count regenerative KOs per genome
files <- list.files(gff_dir, pattern = "\\.gff(\\.gz)?$", full.names = TRUE)
read_one <- function(f){
  suppressWarnings({
    df <- tryCatch({
      read_tsv(f, comment = "#", col_names = FALSE, show_col_types = FALSE)
    }, error = function(e) NULL)
    if (is.null(df) || ncol(df) < 9) return(NULL)
    colnames(df)[1:9] <- c("seqid","source","type","start","end","score","strand","phase","attributes")
    # parse attributes: look for KEGG or ko:Kxxxxx
    df |>
      mutate(kegg = str_extract(attributes, "ko:K\\d{5}|K\\d{5}"),
             genome = str_remove(basename(f), "\\.gff(\\.gz)?$")) |>
      filter(!is.na(kegg)) |>
      select(genome, kegg)
  })
}
message("Scanning GFFs for KOs …")
x <- purrr::map_dfr(files, read_one)
stopifnot(nrow(x) > 0)

regen_scores <- x |>
  filter(kegg %in% regen_kos) |>
  count(genome, name = "Regenerative_Score")

# 2) Bring in ImmeDB mobile elements metadata (optional but recommended)
imme_dir <- cfg$paths$imme_dir
if (dir.exists(imme_dir)){
  meta_files <- list.files(imme_dir, pattern = "\\.tsv$", full.names = TRUE)
  get_meta <- function(f){
    m <- suppressWarnings(tryCatch(read_tsv(f, show_col_types = FALSE), error = function(e) NULL))
    if (is.null(m) || nrow(m) == 0) return(NULL)
    m <- m %>% mutate(genome = str_remove(basename(f), "\\.tsv$"))
    m %>% select(genome, Category = tidyselect::any_of(c("Category","Type","Class")),
                 Completeness = tidyselect::any_of(c("Completeness","completeness")))
  }
  imme_meta <- purrr::map_dfr(meta_files, get_meta) %>% distinct()
} else {
  imme_meta <- tibble(genome = regen_scores$genome,
                      Category = "Unknown", Completeness = NA_character_)
}

env_df <- regen_scores %>%
  left_join(imme_meta, by = "genome") %>%
  mutate(
    Completeness_num = readr::parse_number(Completeness),
    ICEs = as.integer(Category == "ICEs"),
    IMEs = as.integer(Category == "IMEs"),
    Transposons = as.integer(Category == "Transposons"),
    Prophages = as.integer(Category == "Prophages")
  ) %>% replace_na(list(Completeness_num = 0))

# 3) PCA input
pca_input <- env_df %>% select(genome, Regenerative_Score, Completeness_num, ICEs, IMEs, Transposons, Prophages, Category)
num <- pca_input %>% select(Regenerative_Score, Completeness_num, ICEs, IMEs, Transposons, Prophages)
pca_res <- prcomp(num, scale. = TRUE)

pca_df <- as.data.frame(pca_res$x[, 1:2]) %>%
  dplyr::rename(PC1 = PC1, PC2 = PC2) %>%
  bind_cols(pca_input %>% select(genome, Regenerative_Score, Completeness_num, Category))

# 4) Clusters & contours
pca_df <- pca_df %>%
  mutate(
    Cluster = case_when(
      PC1 > quantile(PC1, 0.66) & PC2 < quantile(PC2, 0.66) ~ "Core Regenerators",
      PC2 > quantile(PC2, 0.66)                              ~ "Adaptive Regenerators",
      TRUE                                                   ~ "Peripheral Specialists"
    ),
    Category = fct_lump_n(fct_explicit_na(Category, "Unknown"), n = cfg$pca$top_categories_keep)
  )

dens <- kde2d(pca_df$PC1, pca_df$PC2, n = 250)
dens_df <- expand.grid(PC1 = dens$x, PC2 = dens$y); dens_df$z <- as.vector(dens$z)
centroids <- pca_df %>% group_by(Cluster) %>% summarise(PC1 = mean(PC1), PC2 = mean(PC2), .groups = "drop")
pc_var <- summary(pca_res)$importance["Proportion of Variance", 1:2]
sub_txt <- sprintf("PC1: Integrity Axis (%.1f%%)  |  PC2: Mobility Axis (%.1f%%)", pc_var[1]*100, pc_var[2]*100)

# 5) Plot (compact, no clipping)
cat_pal <- scales::hue_pal()(nlevels(pca_df$Category))
cluster_colors <- c("Core Regenerators"="#21908CFF","Adaptive Regenerators"="#440154FF","Peripheral Specialists"="#FDE725FF")

p <- ggplot(pca_df, aes(PC1, PC2)) +
  geom_contour(data = dens_df, aes(z = z), color = "grey90", size = 0.3, alpha = 0.6) +
  stat_ellipse(aes(group = Cluster, color = Cluster), type = "norm", level = 0.95,
               linewidth = 0.6, linetype = "dashed", alpha = 0.8, show.legend = TRUE) +
  scale_color_manual(values = cluster_colors, name = "Functional Cluster") +
  ggnewscale::new_scale_color() +
  geom_point(aes(color = Regenerative_Score, fill = Category, size = Completeness_num),
             shape = 21, stroke = 0.25, alpha = 0.9) +
  geom_text_repel(data = centroids, aes(x = PC1, y = PC2, label = Cluster), size = 4.8,
                  fontface = "bold", color = "black", box.padding = 0.5, point.padding = 0.5,
                  segment.color = "grey70", seed = 123, inherit.aes = FALSE) +
  scale_color_viridis_c(option = "plasma", direction = -1, name = "Regenerative Score") +
  scale_fill_manual(values = cat_pal, name = "MGE Category") +
  scale_size_continuous(name = "Genome Completeness (%)", range = c(2.3, 6)) +
  facet_wrap(~Cluster, ncol = 3) +
  labs(title = "Two-Dimensional PCA Regenerative Gradient Map", subtitle = sub_txt,
       x = "PC1 — Genome Integrity", y = "PC2 — Gene Mobility") +
  theme_pub() +
  guides(
    color = guide_colorbar(title = "Regenerative Score", title.position = "top",
                           title.hjust = 0.5, barwidth = unit(3.5, "cm"),
                           barheight = unit(0.3, "cm"), label.theme = element_text(size = 8)),
    fill  = guide_legend(title = "MGE Category", title.position = "top", title.hjust = 0.5,
                         nrow = 1, byrow = TRUE, override.aes = list(size = 3)),
    size  = guide_legend(title = "Genome Completeness (%)", title.position = "top",
                         title.hjust = 0.5, nrow = 1, byrow = TRUE, override.aes = list(shape = 21, fill = "grey60"))
  ) +
  coord_cartesian(clip = "off", expand = TRUE)

save_wide(p, ppath(cfg$paths$figures_dir, "Figure7_Regenerative_Gradient_Map_FINAL.png"),
          width = cfg$pca$export_width, height = cfg$pca$export_height, dpi = cfg$pca$dpi)
message("✅ PCA gradient map exported")
# pca gradient script placeholder
