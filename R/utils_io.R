# utility script placeholder
library(yaml)
cfg <- yaml::read_yaml("config/config.yml")

ensure_dir <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE)

ppath <- function(...) file.path(...)
