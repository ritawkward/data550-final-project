here::i_am("code/07_render_report.R")

library(rmarkdown)
render(input = here::here("final_project_report.rmd"), 
       output_file = here::here("report/final_project_report.html"))