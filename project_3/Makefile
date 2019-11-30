build-docker: Dockerfile
	docker build -t docker . -f Dockerfile && \
	touch $@

data/analytic_first_entry.tsv: build-docker scripts/P3001_Create_Analytic_Dataset.py
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker \
		python scripts/P3001_Create_Analytic_Dataset.py

data/analytic_first_exit.tsv: build-docker scripts/P3001_Create_Analytic_Dataset.py
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir docker \
		python scripts/P3001_Create_Analytic_Dataset.py

results/demog_plot.png: build-docker data/analytic_first_entry.tsv scripts/P3002_Create_Demographic_Plots.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse \
		Rscript scripts/P3002_Create_Demographic_Plots.R

results/veteran_plot.png: build-docker data/analytic_first_entry.tsv scripts/P3002_Create_Demographic_Plots.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse \
		Rscript scripts/P3002_Create_Demographic_Plots.R

results/domestic_violence_plot.png: build-docker data/analytic_first_entry.tsv scripts/P3002_Create_Demographic_Plots.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3002_Create_Demographic_Plots.R

results/disab_entry_plot.png: build-docker data/analytic_first_entry.tsv scripts/P3003_Create_Disability_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3003_Create_Disability_Plot.R

results/disab_exit_plot.png: build-docker data/analytic_first_exit.tsv scripts/P3003_Create_Disability_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3003_Create_Disability_Plot.R

results/health_ins_entry_plot.png: build-docker data/analytic_first_entry.tsv scripts/P3004_Create_Insurance_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3004_Create_Insurance_Plot.R

results/health_ins_exit_plot.png: build-docker data/analytic_first_exit.tsv scripts/P3004_Create_Insurance_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3004_Create_Insurance_Plot.R

results/noncash_entry_plot.png: build-docker data/analytic_first_entry.tsv scripts/P3006_Create_Noncash_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3006_Create_Noncash_Plot.R

results/noncash_exit_plot.png: build-docker data/analytic_first_exit.tsv scripts/P3006_Create_Noncash_Plot.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3006_Create_Noncash_Plot.R

results/los_dist.png: build-docker data/analytic_first_exit.tsv scripts/P3007_Analysis.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3007_Analysis.R

results/destination_plot.png: build-docker data/analytic_first_exit.tsv scripts/P3007_Analysis.R
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse\
		Rscript scripts/P3007_Analysis.R

results/Project-3-Report.html: data/analytic_first_entry.tsv \
				data/analytic_first_exit.tsv \
				results/Project-3-Report.Rmd \
				results/demog_plot.png \
				results/veteran_plot.png  \
				results/domestic_violence_plot.png \
				results/prior_living_plot.png \
				results/disab_entry_plot.png \
				results/disab_exit_plot.png \
				results/health_ins_entry_plot.png\
				results/health_ins_exit_plot.png\
				results/noncash_entry_plot.png\
				results/noncash_exit_plot.png\
				results/los_dist.png\
				results/destination_plot.png
	docker run -it --rm -v $(shell pwd):/workdir -w /workdir rocker/tidyverse \
	Rscript -e "library(rmarkdown); rmarkdown::render('results/Project-3-Report.Rmd', 'html_document')"