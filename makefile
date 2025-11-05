final_project_report.html: code/07_render_report.R final_project_report.Rmd \
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
	rm -f output/*.rds && rm -f output/*.png && rm -f *.html

