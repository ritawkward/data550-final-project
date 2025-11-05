library(here)
library(dplyr)
library(gt)
library(gtsummary)

here::i_am("code/01_table.R")

data <- readRDS(file = here("output/data_clean.rds"))

theme_gtsummary_journal(journal = "jama")

tab_data <- data %>%
  mutate(
    CANCER_DX = factor(CANCER_DX, levels = c(0,1), labels = c("No", "Yes")),
    AGE_GROUP = cut(AGE, breaks = c(20, 39, 59, 150), right = TRUE,
                    include.lowest = TRUE, labels = c("20-39", "40-59", "60+")),
    BMI_CAT = case_when(
      is.na(BMI)                 ~ NA_character_,
      BMI < 18.5                 ~ "Underweight",
      BMI >= 18.5 & BMI < 25.0   ~ "Normal",
      BMI >= 25.0 & BMI < 30.0   ~ "Overweight",
      BMI >= 30.0                ~ "Obese"
    ) %>%  factor(levels = c("Underweight","Normal","Overweight","Obese")),
    SMOKE = SMOKE_NOW_CAT,
    RACE_ETH = RACE_ETH6,
    EDUCATION = EDUC_FINAL,
    SLEEP_WK_CAT = SLEEP_WK_CAT,
    SLEEP_WE_CAT = SLEEP_WE_CAT,
    PIR_CAT = case_when(
      is.na(INDFMPIR)          ~ NA_character_,
      INDFMPIR < 1             ~ "<1.0 (Below poverty)",
      INDFMPIR >= 1 & INDFMPIR < 2 ~ "1.0-1.99",
      INDFMPIR >= 2 & INDFMPIR < 4 ~ "2.0-3.99",
      INDFMPIR >= 4            ~ "≥4.0"
    ) %>% factor(levels = c("<1.0 (Below poverty)", "1.0-1.99", "2.0-3.99", "≥4.0")))

table1 <-
  tbl_summary(data = tab_data, by = CANCER_DX, include = c( AGE_GROUP, SEX, RACE_ETH, EDUCATION, MARITAL, PIR_CAT, BMI_CAT, SMOKE, ALC_FREQ12M, SLEEP_WK_CAT, SLEEP_WE_CAT),
              statistic = list(
                all_continuous()  ~ "{mean} ({sd})",
                all_categorical() ~ "{n} ({p}%)"),
              missing = "ifany",
              label = list(
                AGE_GROUP ~ "Age group",
                SEX ~ "Sex",
                RACE_ETH ~ "Race/ethnicity",
                EDUCATION ~ "Education",
                MARITAL ~ "Marital status",
                PIR_CAT ~ "Income-to-poverty ratio",
                BMI_CAT ~ "BMI category",
                SMOKE ~ "Smoking status",
                ALC_FREQ12M ~ "Alcohol use, past 12 months (freq)",
                SLEEP_WK_CAT ~ "Weekday sleep duration",
                SLEEP_WE_CAT ~ "Weekend sleep duration")) %>%
  add_overall(last = TRUE) %>%  
  add_n() %>% 
  add_p(test = list(
      all_continuous() ~ "t.test",
      all_categorical() ~ "chisq.test"),
      pvalue_fun = ~ style_pvalue(.x, digits = 3)) %>%
  bold_labels() %>%
  modify_caption("**Table 1. Characteristics of participants by cancer diagnosis**") %>%
  modify_spanning_header(matches("^stat_[1-9]+$") ~ "**Cancer diagnosis**") %>%
  modify_spanning_header("stat_0" ~ "**Overall**") %>%
  as_gt() %>%
  tab_source_note(md("Notes: Values are mean (SD) for continuous variables and n (%) for categorical variables. No survey weights applied."))

saveRDS(table1, file = here("output/table1.rds"))
