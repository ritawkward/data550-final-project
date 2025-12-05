FROM rocker/tidyverse:4.5.1 AS base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cmake \
      libnode-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/rstudio/project/renv /home/rstudio/project/code /home/rstudio/project/raw_data /home/rstudio/project/output /home/rstudio/project/report
WORKDIR /home/rstudio/project

COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE=renv/.cache

RUN Rscript -e "renv::restore(prompt = FALSE)"

# Second stage
FROM rocker/tidyverse:4.5.1

RUN mkdir /home/rstudio/project
WORKDIR /home/rstudio/project
COPY --from=base /home/rstudio/project .

RUN mkdir -p output report
COPY makefile .
COPY final_project_report.rmd .
COPY raw_data/ raw_data/
COPY code/ code/

CMD ["make", "report/final_project_report.html"]