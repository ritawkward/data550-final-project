library(here)
library(dplyr)
library(ggplot2)

here::i_am("code/04_plot2.R")

data <- readRDS(file = here("output/data_clean.rds"))

tab_plot2 <- data %>% transmute(
  CANCER_DX   = factor(CANCER_DX, levels = c(0,1), labels = c("No","Yes")),
  SLEEP_WK_HRS = SLEEP_WK_HRS) %>%
  filter(!is.na(CANCER_DX), !is.na(SLEEP_WK_HRS), SLEEP_WK_HRS >= 3, SLEEP_WK_HRS <= 12)

plot2 <- ggplot(tab_plot2, aes(x = SLEEP_WK_HRS, color = CANCER_DX, fill = CANCER_DX)) +
  geom_density(alpha = 0.25, adjust = 1.0) +
  scale_x_continuous(breaks = 3:12) +
  scale_color_brewer(palette = "Dark2", name = "Cancer diagnosis") +
  scale_fill_brewer(palette = "Dark2", name = "Cancer diagnosis") +
  labs(x = "Weekday sleep hours", y = "Density", title = "Distribution of weekday sleep hours by cancer diagnosis") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave(here("output/plot2.png"), plot = plot2, width = 9, height = 5, dpi = 300, device = "png")
