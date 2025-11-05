library(here)
library(haven)
library(readr)
library(dplyr)
library(purrr)

here::i_am("code/00_clean_data.R")


# Load separate dataset and select desired variable

## Sleep Disorders Questionnaire 
slq <- read_xpt("raw_data/SLQ_J.xpt")
slq_sel <- slq %>%
  select(SEQN, SLQ300, SLQ310, SLD012, SLQ320, SLQ330, SLD013) %>%
  distinct(SEQN, .keep_all = TRUE)

## Medical Conditions Questionnaire 
mcq <- read_xpt("raw_data/MCQ_J.xpt")
mcq_sel <- mcq %>%
  select(SEQN, MCQ220, MCQ230A, MCQ230B, MCQ230C, MCQ230D) %>%
  distinct(SEQN, .keep_all = TRUE)

## Demographic information Questionnaire
demo <- read_xpt("raw_data/DEMO_J.xpt")
demo_sel <- demo %>%
  select(SEQN, RIDAGEYR, RIAGENDR, RIDRETH1, RIDRETH3, DMDEDUC3, DMDEDUC2, 
         DMDMARTL, RIDEXPRG, INDFMPIR, WTMEC2YR, SDMVPSU, SDMVSTRA) %>%
  distinct(SEQN, .keep_all = TRUE)

## Smoking & tobacco use Questionnaire 
smq <- read_xpt("raw_data/SMQ_J.xpt")
smq_sel <- smq %>%
  select(SEQN, SMQ020, SMQ040) %>%
  distinct(SEQN, .keep_all = TRUE)

## Body measures Examination 
bmx <- read_xpt("raw_data/BMX_J.xpt")
bmx_sel <- bmx %>%
  select(SEQN, BMXBMI) %>%
  distinct(SEQN, .keep_all = TRUE)

## Alcohol use Questionnaire
alq <- read_xpt("raw_data/ALQ_J.xpt")
alq_sel <- alq %>%
  select(SEQN, ALQ121, ALQ130, ALQ151) %>%
  distinct(SEQN, .keep_all = TRUE)

## Linked-Mortality Dataset
srvyin <- here("raw_data", "NHANES_2017_2018_MORT_2019_PUBLIC.dat")
srvyout <- "<NHANES_2017_2018>"
dsn <- read_fwf(file = srvyin, 
                col_types = "iiiiiiii", 
                fwf_cols(seqn = c(1,6), 
                         eligstat = c(15,15), 
                         mortstat = c(16,16), 
                         ucod_leading = c(17,19), 
                         diabetes = c(20,20), 
                         hyperten = c(21,21), 
                         permth_int = c(43,45), 
                         permth_exm = c(46,48)),
                na = c("", "."))
dsn_sel <- dsn %>%
  select(seqn, mortstat, ucod_leading) %>%
  distinct(seqn, .keep_all = TRUE)


# Merge Data
dedup <- function(df) distinct(df, SEQN, .keep_all = TRUE)
dsn_sel <- dsn_sel %>%
  rename(SEQN = seqn, MORTSTAT = mortstat, UCOD_LEADING = ucod_leading) %>%
  dedup()

analysis <- slq_sel %>%
  inner_join(mcq_sel, by = "SEQN") %>%
  left_join(demo_sel, by = "SEQN")

confounder_list <- list(smq_sel, alq_sel, bmx_sel)
analysis <- reduce(confounder_list, ~ left_join(.x, .y, by = "SEQN"), .init = analysis)

# Mortality subgroup data
analysis_mort <- analysis %>%
  inner_join(dsn_sel, by = "SEQN")

# Variable recode
recode_cancer_site <- function(x) {
  recode(as.integer(x),
         `10`="Bladder", `11`="Blood", `12`="Bone", `13`="Brain", `14`="Breast", 
         `15`="Cervix", `16`="Colon", `17`="Esophagus", `18`="Gallbladder", `19`="Kidney", 
         `20`="Larynx/windpipe", `21`="Leukemia", `22`="Liver", `23`="Lung", 
         `24`="Lymphoma/Hodgkin's", `25`="Melanoma", `26`="Mouth/tongue/lip", `27`="Nervous system", 
         `28`="Ovary", `29`="Pancreas", `30`="Prostate", `31`="Rectum", `32`="Skin (non-melanoma)", 
         `33`="Skin (unknown kind)", `34`="Soft tissue", `35`="Stomach", `36`="Testis", `37`="Thyroid", 
         `38`="Uterus", `39`="Other", `66`="More than 3 kinds",
         `77`=NA_character_, `99`=NA_character_, .default = NA_character_)
}

analysis_recode <- analysis %>% mutate(
  CANCER_DX = case_when(MCQ220 == 1 ~ 1L, MCQ220 == 2 ~ 0L, MCQ220 %in% c(7, 9) ~ NA_integer_, TRUE ~ NA_integer_),
  CANCER_SITE_A = recode_cancer_site(MCQ230A),
  CANCER_SITE_B = recode_cancer_site(MCQ230B),
  CANCER_SITE_C = recode_cancer_site(MCQ230C),
  CANCER_SITE_D = recode_cancer_site(MCQ230D),
  
  AGE = RIDAGEYR,
  
  SEX = factor(RIAGENDR, levels = c(1, 2), labels = c("Male", "Female")),
  FEMALE = case_when(RIAGENDR == 2 ~ 1L, RIAGENDR == 1 ~ 0L, TRUE ~ NA_integer_),
  
  RACE_ETH5 = factor(RIDRETH1, levels = c(1,2,3,4,5),
                     labels = c("Mexican American", "Other Hispanic", "Non-Hispanic White", "Non-Hispanic Black", "Other/Multi")),
  RACE_ETH6 = factor(RIDRETH3, levels = c(1,2,3,4,6,7),
                       labels = c("Mexican American", "Other Hispanic", "Non-Hispanic White", "Non-Hispanic Black", "Non-Hispanic Asian", "Other/Multiracial")),
  EDUC_ADULT = factor(na_if(na_if(DMDEDUC2, 7), 9), levels = c(1,2,3,4,5),
                        labels = c("<9th grade", "9-11th (no diploma)", "HS/GED", "Some college/AA", "College+")),
  
  EDUC_CHILD_COLLAPSED = case_when(
      DMDEDUC3 %in% c(55, 0:12, 66) ~ "<HS",
      DMDEDUC3 %in% c(13, 14) ~ "HS/GED",
      DMDEDUC3 == 15 ~ "Some college+", TRUE ~ NA_character_),
  
  EDUC_FINAL = coalesce(as.character(EDUC_ADULT), EDUC_CHILD_COLLAPSED) %>% factor(
      levels = c("<9th grade","9-11th (no diploma)","HS/GED","Some college/AA","College+", "<HS","Some college+")),
  
  MARITAL = factor(recode(DMDMARTL,`1`="Married", `2`="Widowed", `3`="Divorced", `4`="Separated", `5`="Never married", `6`="Living with partner", `77`=NA_character_, `99`=NA_character_, .default=NA_character_)),
  
  PREGNANT_EXAM = case_when(
      RIAGENDR == 2 & RIDEXPRG == 1 ~ 1L,
      RIAGENDR == 2 & RIDEXPRG == 2 ~ 0L,
      RIAGENDR == 2 & RIDEXPRG == 3 ~ NA_integer_, TRUE ~ NA_integer_),
  
  PIR = INDFMPIR,  
  
  SMOKED_100 = case_when(
      SMQ020 == 1 ~ 1L,
      SMQ020 == 2 ~ 0L,
      SMQ020 %in% c(7,9) ~ NA_integer_, TRUE ~ NA_integer_),
  
  SMOKE_NOW_CAT = factor(recode(SMQ040, `1`="Every day", `2`="Some days", `3`="Not at all", `7`=NA_character_, `9`=NA_character_, .default=NA_character_)),
  
  ALC_FREQ12M = factor(recode(ALQ121, `0`="Never last year", `1`="Every day", `2`="Nearly every day", `3`="3-4/week", `4`="2/week", `5`="Once/week", `6`="2-3/month", `7`="Once/month", `8`="7-11/year", `9`="3-6/year", `10`="1-2/year", `77`=NA_character_, `99`=NA_character_, .default=NA_character_)),
  
  ALC_HEAVY_EVERYDAY_EVER = case_when(
      ALQ151 == 1 ~ 1L,
      ALQ151 == 2 ~ 0L,
      ALQ151 %in% c(7,9) ~ NA_integer_, TRUE ~ NA_integer_),
  
  BMI = BMXBMI,
  
  SLEEP_WK_HRS = suppressWarnings(as.numeric(SLD012)),
  SLEEP_WK_HRS = ifelse(SLEEP_WK_HRS %in% c(77, 99), NA, SLEEP_WK_HRS),
  SLEEP_WK_CAT = case_when(
    !is.na(SLEEP_WK_HRS) & SLEEP_WK_HRS < 7 ~ "<7",
    !is.na(SLEEP_WK_HRS) & SLEEP_WK_HRS <= 9 ~ "7-9",
    !is.na(SLEEP_WK_HRS) & SLEEP_WK_HRS > 9 ~ ">9", TRUE ~ NA_character_) %>% 
    factor(levels = c("<7","7-9",">9")),
  
  SLEEP_WE_HRS = suppressWarnings(as.numeric(SLD013)),
  SLEEP_WE_HRS = ifelse(SLEEP_WE_HRS %in% c(77, 99), NA, SLEEP_WE_HRS),
  SLEEP_WE_CAT = case_when(
    !is.na(SLEEP_WE_HRS) & SLEEP_WE_HRS < 7 ~ "<7",
    !is.na(SLEEP_WE_HRS) & SLEEP_WE_HRS <= 9 ~ "7-9",
    !is.na(SLEEP_WE_HRS) & SLEEP_WE_HRS > 9 ~ ">9", TRUE ~ NA_character_) %>%
    factor(levels = c("<7","7-9",">9")))

# save recoded data
saveRDS(analysis_recode, file = here::here("output/data_clean.rds"))
