library(here)
library(dplyr)
library(ggplot2)
library(scales)

here::i_am("code/05_plot3.R")

tab_data <- readRDS(here("output/plots_data.rds"))$tab_data

tab_plot3 <- tab_data %>%
  filter(!is.na(CANCER_DX), !is.na(SLEEP_WK_CAT), !is.na(SEX)) %>%
  count(SEX, SLEEP_WK_CAT, CANCER_DX) %>%
  group_by(SEX, SLEEP_WK_CAT) %>%
  mutate(p_cancer = n / sum(n)) %>%
  filter(CANCER_DX == "Yes")

plot3 <- ggplot(tab_plot3, aes(x = SLEEP_WK_CAT, y = p_cancer, fill = SEX)) +
  geom_col(position = position_dodge(width = 0.6), width = 0.55) +
  scale_y_continuous(labels = percent_format(accuracy = 1), limits = c(0, NA)) +
  scale_fill_brewer(palette = "Pastel1", name = "Sex") +
  labs(x = "Weekday sleep duration", y = "Percent with cancer diagnosis", title = "Cancer prevalence by sleep duration and sex") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "right", plot.title = element_text(face = "bold"))

ggsave(here("output/plot3.png"), plot = plot3, width = 8, height = 5, dpi = 300, device = "png")