build-image: 
	docker pull datascienceschool/rpython && touch $@

analytic_first.tsv: build-image
	docker run -it --rm -v $(pwd):/unc -w /unc build-image\
	python ./scripts/3001_Create_Analytic_Dataset.py

demog_plot.png: analytic_first.tsv
	docker run -it --rm -v $(pwd):/unc -w /unc build-image\
	Rscript ./scripts/P3002_Create_Demographic_Plots.R



.PHONY: run_make2graph
run_make2graph: build-image
	docker run -it --rm -v $(pwd):/unc -w /unc mf2g \
	"make -f Makefile.hw7 rename -Bnd | make2graph | dot -Tpng -o hw7_out.png" 

.PHONY: rename
rename: run_make2graph
	mv out.png graph.png