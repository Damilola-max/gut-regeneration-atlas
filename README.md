# 🧬 The Regenerative Architecture of the Human Gut Microbiome
### *A Systems-Level Atlas of Functional Resilience and Gene Mobility*

---

## 📖 Overview
This repository contains all scripts, data structures, and figures associated with the manuscript:  
**“The Regenerative Architecture of the Human Gut Microbiome: A Systems-Level Atlas of Functional Resilience and Gene Mobility.”**

The study develops a **quantitative and visual framework** to map microbial regenerative capacity, functional gene networks, and ecological gradients using large-scale metagenomic datasets.

---

## 📂 Repository Structure
```
gut-regeneration-atlas/
│
├── data/                        # Example and raw input files
│   ├── Merged_GutMetaNet_Annotations.tsv
│   ├── Merged_GutMetaNet_MGE.tsv
│   └── DB.representative_genome.gff/
│
├── scripts/
│   ├── 01_Functional_Galaxy_Map.R
│   ├── 02_Regenerative_Cooccurrence_Network.R
│   ├── 03_Regenerative_Potential_Gradient.R
│   └── utilities.R
│
├── figures/
│   ├── Fig1_FunctionalGalaxyMap.png
│   ├── Fig2_Regenerative_Cooccurrence_Heatmap.png
│   ├── Fig3_Regenerative_GradientMap.png
│   └── featured_image.png
│
├── supplementary/
│   ├── KO_list_regeneration.csv
│   ├── Module_Associations.csv
│   ├── PCA_Loadings.csv
│   └── metadata_summary.tsv
│
├── README.md                    # Current file
└── LICENSE
```

---

## 🧩 Analyses Summary
| Analysis | Focus | Output | Script |
|-----------|--------|---------|---------|
| **1** | Functional Galaxy Map | UMAP-based functional embedding of genomes | `01_Functional_Galaxy_Map.R` |
| **2** | Regenerative Co-Occurrence Network | KO–KO functional coupling & modularity | `02_Regenerative_Cooccurrence_Network.R` |
| **3** | Regenerative Gradient Map | PCA-based ecological gradient analysis | `03_Regenerative_Potential_Gradient.R` |

---

## ⚙️ Requirements
- **R ≥ 4.3**

**Recommended Packages:**  
`tidyverse`, `Matrix`, `proxyC`, `igraph`, `ggplot2`, `plotly`, `viridis`, `ComplexHeatmap`, `FactoMineR`, `factoextra`, `MASS`.

Install dependencies:
```r
install.packages(c("tidyverse", "Matrix", "proxyC", "igraph", "ggplot2", 
                   "viridis", "MASS", "factoextra", "FactoMineR"))
```

---

## 🚀 How to Reproduce
1. Clone this repository:
   ```bash
   git clone https://github.com/Damilola-max/gut-regeneration-atlas.git
   cd gut-regeneration-atlas
   ```
2. Open **R** or **RStudio**.
3. Load the dataset from `/data/`.
4. Run analyses sequentially:
   ```r
   source("scripts/01_Functional_Galaxy_Map.R")
   source("scripts/02_Regenerative_Cooccurrence_Network.R")
   source("scripts/03_Regenerative_Potential_Gradient.R")
   ```
5. Generated figures will appear in `/figures/`.

---

## 📊 Outputs
- **Functional Galaxy Map:** Unsupervised embedding of genomes in functional space.  
- **Co-Occurrence Network:** Modular graph of co-adapted regenerative genes.  
- **Gradient Map:** PCA projection showing ecological distribution of regenerative potential.  
