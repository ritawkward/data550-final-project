# Final Project: NHANES Sleep and Cancer Analysis

## Building and Running the Docker Report

-   For Mac and Linux users, build the final HTML report directly by running `make report`, this will save the report HTML file to `report/final_project_report.html`.
-   For Windows users, build the final HTML report by running `make report_windows`.
-   If you wish, you can build the project image locally by running `make final_project_image`
-   **IMPORTANT:** docker files and its associated rules and images were written for Mac-OS.
-   Optional: the above make rule only mounts the report folder, so only the final HTML report is retrieved locally. If you wish to retrieve all intermediate output objects created during the analysis (such as .rds and .png files as well as the report.html, run `make docker_report_with_output_objects`.

## Instructions to run with "make" in your local R console with renv

-   Clone the repo to your desired local folder
-   `cd` to the "data550-final-project" directory
-   Synchronize the package repository by running `make install`
-   Run `make` to generate all output and report
-   **IMPORTANT:** if you running into an error after running `make`, make sure you create an R project with my final project directory. Then it should be free of error by run `make install` and `make` again.

## Code Description

### `code/00_clean_data.R`

-   Reads and merges multiple NHANES `.xpt` files from the `raw_data/` folder.
-   Cleans and recodes variables (e.g., cancer diagnosis, sleep duration, socio-demographics).
-   Saves the cleaned dataset as **`output/data_clean.rds`**.

### `code/01_table.R`

-   Reads `output/data_clean.rds`.
-   Creates a descriptive summary table (Table 1) of participant characteristics by cancer diagnosis using **gtsummary**.
-   Saves outputs as **`output/table1.rds`** and **`output/table1.html`**.

### `code/02_plots_data.R`

-   Reads the cleaned dataset.
-   Prepares plot-ready data, including sleep and cancer site groupings.
-   Saves as **`output/plots_data.rds`**.

### `code/03_plot1.R`

-   Reads `output/plots_data.rds`.
-   Creates **Figure 1:** Weekday sleep duration by cancer diagnosis.
-   Saves the figure as **`output/plot1.png`**.

### `code/04_plot2.R`

-   Reads `output/data_clean.rds`.
-   Creates **Figure 2:** Density distribution of weekday sleep hours by cancer diagnosis.
-   Saves as **`output/plot2.png`**.

### `code/05_plot3.R`

-   Reads `output/plots_data.rds`.
-   Creates **Figure 3:** Cancer prevalence by weekday sleep duration and sex.
-   Saves as **`output/plot3.png`**.

### `code/06_plot4.R`

-   Reads `output/plots_data.rds`.
-   Creates **Figure 4:** Weekday sleep duration by self-reported cancer site.
-   Saves as **`output/plot4.png`**.

### `code/07_render_report.R`

-   Uses **rmarkdown::render()** to compile the final R Markdown report (`final_project_report.Rmd`).
-   Combines all tables and figures into a single reproducible HTML report.
-   Output saved as **`output/final_project_report.html`**.

------------------------------------------------------------------------

## Report Description

### `final_project_report.Rmd`

-   Loads outputs from previous scripts (`table1.rds`, `plot1.png` to `plot4.png`).
-   Displays the descriptive summary table and four figures.
-   Summarizes data, methods, and key visualizations for the analysis.
