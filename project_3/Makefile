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

veteran_plot.png: build-r analytic_first.tsv build-python
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerrtidy\
	Rscript /scripts/P3002_Create_Demographic_Plots.R

domestic_violence_plot.png: build-r analytic_first.tsv build-python
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerrtidy\
	Rscript /scripts/P3002_Create_Demographic_Plots.R

disab_plot.png: build-r analytic_first.tsv build-python
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerrtidy\
	Rscript /scripts/P3003_Create_Disability_Plot.R

health_ins_plot.png: build-r analytic_first.tsv build-python
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerrtidy\
	Rscript /scripts/P3004_Create_Health_Insurance_Plot.R

Project-3-Report.html: build-r analytic_first.tsv build-python demog_plot.png veteran_plot.png domestic_violence_plot.png disab_plot.png health_ins_plot.png
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir dockerrtidy\
	Rscript /scripts/Project 3 Report.Rmd