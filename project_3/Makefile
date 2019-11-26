build-docker: Dockerfile
	docker build -t docker . -f Dockerfile && \
	touch $@

data/analytic_first.tsv: build-docker scripts/P3001_Create_Analytic_Dataset.py
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker \
		python scripts/P3001_Create_Analytic_Dataset.py

results/demog_plot.png: build-docker analytic_first.tsv scripts/P3002_Create_Demographic_Plots.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker \
		Rscript scripts/P3002_Create_Demographic_Plots.R

results/veteran_plot.png: build-docker analytic_first.tsv scripts/P3002_Create_Demographic_Plots.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker \
		Rscript /scripts/P3002_Create_Demographic_Plots.R

results/domestic_violence_plot.png: build-docker analytic_first.tsv scripts/P3002_Create_Demographic_Plots.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker\
		Rscript /scripts/P3002_Create_Demographic_Plots.R

results/disab_plot.png: build-docker analytic_first.tsv scripts/P3003_Create_Disability_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker\
		Rscript /scripts/P3003_Create_Disability_Plot.R

results/health_ins_plot.png: build-docker analytic_first.tsv scripts/P3004_Create_Health_Insurance_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker\
		Rscript /scripts/P3004_Create_Health_Insurance_Plot.R

results/Project-3-Report.html: data/analytic_first.tsv \
				results/Project-3-Report.Rmd \
				results/demog_plot.png \
				results/veteran_plot.png  \
				results/domestic_violence_plot.png \
				results/disab_plot.png \
				results/health_ins_plot.png
	docker run -it --rm \
	-v $(shell pwd):/workdir \
	-w /workdir rocker/tidyverse \
	Rscript -e "library(rmarkdown); rmarkdown::render('results/Project-3-Report.Rmd', 'html_document')"