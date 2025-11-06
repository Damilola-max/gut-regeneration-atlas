# Gut Regeneration Atlas

Reproducible R workflows to quantify and visualize microbial **regenerative capacity** from metagenomic annotations.

## Requirements
- R ≥ 4.3
- Linux/macOS (tested on macOS Intel)
- `renv` to lock packages

## Quick start
```bash
git clone <this-repo>
cd gut-regeneration-atlas
Rscript -e 'renv::restore()'   # if renv.lock present
Rscript run.R
