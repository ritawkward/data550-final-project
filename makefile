report/final_project_report.html: code/07_render_report.R final_project_report.rmd \
  output/table1.rds output/plot1.png output/plot2.png output/plot3.png \
  output/plot4.png
	Rscript code/07_render_report.R

output/data_clean.rds: code/00_clean_data.R raw_data/*.xpt raw_data/*.dat
	Rscript code/00_clean_data.R

output/table1.rds: code/01_table.R output/data_clean.rds
	Rscript code/01_table.R
	
output/plots_data.rds: code/02_plots_data.R output/data_clean.rds
	Rscript code/02_plots_data.R
	
output/plot1.png: code/03_plot1.R output/plots_data.rds
	Rscript code/03_plot1.R
	
output/plot2.png: code/04_plot2.R output/data_clean.rds
	Rscript code/04_plot2.R
	
output/plot3.png: code/05_plot3.R output/plots_data.rds
	Rscript code/05_plot3.R
	
output/plot4.png: code/06_plot4.R output/plots_data.rds
	Rscript code/06_plot4.R
	
.PHONY: clean
clean:
	rm -f output/*.rds && rm -f output/*.png && rm -f report/*.html

.PHONY: install
install:
	Rscript -e "renv::restore(prompt = FALSE)"

# DOCKER-ASSOCIATED RULES
PROJECTFILES = final_project_report.rmd code/00_clean_data.R code/01_table.R code/02_plots_data.R code/03_plot1.R code/04_plot2.R code/05_plot3.R code/06_plot4.R code/07_render_report.R
RENVFILES = renv.lock renv/activate.R renv/settings.json

final_project_image: Dockerfile $(PROJECTFILES) $(RENVFILES)
	docker build -t final_project_image .
	touch $@
	
docker_report:
	docker run -v "$$(pwd)/report":/home/rstudio/project/report ritawkward/data550-final:latest

docker_report_windows:
	docker run -v "/$$(pwd)/report":/home/rstudio/project/report ritawkward/data550-final:latest

.PHONY: report report_windows
report: docker_report
report_windows: docker_report_windows

## docker for output objects
docker_report_with_output_objects:
	docker run -v "$$(pwd)/report":/home/rstudio/project/report -v "$$(pwd)/output":/home/rstudio/project/output ritawkward/data550-final:latest
	
docker_report_Mchips:
	docker run --platform=linux/amd64 -v "$(pwd)/report":/home/rstudio/project/report ritawkward/data550-final:latest