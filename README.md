# Final Project: NHANES Sleep and Cancer Analysis

## Code Description

### `code/00_clean_data.R`

-   Reads and merges multiple NHANES `.xpt` files from the `raw_data/` folder.\
-   Cleans and recodes variables (e.g., cancer diagnosis, sleep duration, sociodemographics).\
-   Saves the cleaned dataset as **`output/data_clean.rds`**.

### `code/01_table.R`

-   Reads `output/data_clean.rds`.\
-   Creates a descriptive summary table (Table 1) of participant characteristics by cancer diagnosis using **gtsummary**.\
-   Saves outputs as **`output/table1.rds`** and **`output/table1.html`**.

### `code/02_plots_data.R`

-   Reads the cleaned dataset.\
-   Prepares “plot-ready” data, including sleep and cancer site groupings.\
-   Saves as **`output/plots_data.rds`**.

### `code/03_plot1.R`

-   Reads `output/plots_data.rds`.\
-   Creates **Figure 1:** Weekday sleep duration by cancer diagnosis.\
-   Saves the figure as **`output/plot1.png`**.

### `code/04_plot2.R`

-   Reads `output/data_clean.rds`.\
-   Creates **Figure 2:** Density distribution of weekday sleep hours by cancer diagnosis.\
-   Saves as **`output/plot2.png`**.

### `code/05_plot3.R`

-   Reads `output/plots_data.rds`.\
-   Creates **Figure 3:** Cancer prevalence by weekday sleep duration and sex.\
-   Saves as **`output/plot3.png`**.

### `code/06_plot4.R`

-   Reads `output/plots_data.rds`.\
-   Creates **Figure 4:** Weekday sleep duration by self-reported cancer site.\
-   Saves as **`output/plot4.png`**.

### `code/07_render_report.R`

-   Uses **rmarkdown::render()** to compile the final R Markdown report (`final_project_report.Rmd`).\
-   Combines all tables and figures into a single reproducible HTML report.\
-   Output saved as **`output/final_project_report.html`**.

------------------------------------------------------------------------

## Report Description

### `final_project_report.Rmd`

-   Loads outputs from previous scripts (`table1.rds`, `plot1.png` to `plot4.png`).\
-   Displays the descriptive summary table and four figures.\
-   Summarizes data, methods, and key visualizations for the analysis.
