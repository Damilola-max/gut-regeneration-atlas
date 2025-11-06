source("R/utils_io.R")
library(tidyverse); library(janitor)

gff_path <- cfg$paths$gff_merged
stopifnot(file.exists(gff_path))

gff <- read_tsv(gff_path, show_col_types = FALSE) %>% clean_names()

# Keep KEGG rows
gff_kegg <- gff %>%
  filter(!is.na(kegg), kegg != "") %>%
  select(seqid, type, start, end, strand, id, name, product, kegg)

ensure_dir(cfg$paths$processed_dir)
write_tsv(gff_kegg, ppath(cfg$paths$processed_dir, "gff_kegg_clean.tsv"))

message("✅ Preprocessed GFF with KEGG saved to data/processed/gff_kegg_clean.tsv")
# preprocess script placeholder
