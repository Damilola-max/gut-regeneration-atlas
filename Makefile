.PHONY: all setup preprocess umap network pca clean

all: preprocess umap network pca

setup:
	Rscript R/00_setup.R

preprocess:
	Rscript -e 'source("R/01_preprocess_gff.R")'

umap:
	Rscript -e 'source("R/02_sparse_matrix_and_umap.R")'

network:
	Rscript -e 'source("R/03_network_cooccurrence.R")'

pca:
	Rscript -e 'source("R/04_pca_regenerative_gradient.R")'

clean:
	rm -rf data/processed/* figures/*
