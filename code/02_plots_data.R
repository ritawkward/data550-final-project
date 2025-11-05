library(here)
library(dplyr)
library(tidyr)
library(stringr)

here::i_am("code/02_plots_data.R")

data <- readRDS(file = here("output/data_clean.rds"))

# data for fig 1&3
tab_data <- data %>% mutate(
  CANCER_DX   = factor(CANCER_DX, levels = c(0, 1), labels = c("No", "Yes")),
  SLEEP_WK_CAT = factor(SLEEP_WK_CAT, levels = c("<7","7-9",">9")),
  SEX         = factor(SEX, levels = c("Male","Female")),
  SLEEP_WK_HRS = SLEEP_WK_HRS)

# Long cancer-site data for Fig 4 
p_site_long <- data %>%
  select(SEQN, SLEEP_WK_CAT, MCQ230A, MCQ230B, MCQ230C, MCQ230D) %>%
  pivot_longer(starts_with("MCQ230"), names_to = "SITE_VAR", values_to = "CANCER_SITE") %>%
  filter(!is.na(CANCER_SITE), !is.na(SLEEP_WK_CAT)) %>% mutate(
    CANCER_SITE = suppressWarnings(as.numeric(CANCER_SITE)),
    SLEEP_WK_CAT = factor(SLEEP_WK_CAT, levels = c("<7","7-9",">9")),
    CANCER_SITE_CAT = case_when(
      CANCER_SITE %in% 16:24 ~ "Digestive (stomach, colon, rectum, etc.)",
      CANCER_SITE == 30     ~ "Lung/Bronchus",
      CANCER_SITE == 32     ~ "Breast",
      CANCER_SITE == 39     ~ "Prostate",
      CANCER_SITE %in% 42:44 ~ "Female reproductive",
      TRUE ~ "Other"))

saveRDS(list(tab_data = tab_data, p_site_long = p_site_long), here("output/plots_data.rds"))
