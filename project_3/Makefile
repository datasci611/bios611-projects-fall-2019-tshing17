build-python: Dockerfile.dpython
	docker build -t dockerpy . -f Dockerfile.dpython && \
	touch $@

analytic_first.tsv: build-python
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerpy\
	python /scripts/P3001_Create_Analytic_Dataset.py

build-r: Dockerfile.rtidyverse
	docker build -t dockerrtidy . -f Dockerfile.rtidyverse && \
	touch $@

demog_plot.png: build-r analytic_first.tsv build-python
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerrtidy\
	Rscript /scripts/P3002_Create_Demographic_Plots.R