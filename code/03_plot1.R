library(here)
library(dplyr)
library(ggplot2)
library(scales)

here::i_am("code/03_plot1.R")

tab_data <- readRDS(here("output/plots_data.rds"))$tab_data

tab_plot1 <- tab_data %>%
  filter(!is.na(CANCER_DX), !is.na(SLEEP_WK_CAT)) %>%
  count(CANCER_DX, SLEEP_WK_CAT) %>%
  group_by(CANCER_DX) %>%
  mutate(pct = n / sum(n))

plot1 <- ggplot(tab_plot1, aes(x = CANCER_DX, y = pct, fill = SLEEP_WK_CAT)) +
  geom_col(width = 0.7) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set2", name = "Weekday sleep") +
  labs(x = "Cancer diagnosis", y = "Percent of participants", title = "Weekday sleep duration by cancer diagnosis") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "right", plot.title = element_text(face = "bold"))

ggsave(here("output/plot1.png"), plot = plot1, device = "png")
