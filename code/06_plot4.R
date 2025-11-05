library(here)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(scales)

here::i_am("code/06_plot4.R")

p_site_long <- readRDS(here("output/plots_data.rds"))$p_site_long

plot4 <- ggplot(p_site_long, aes(x = CANCER_SITE_CAT, fill = SLEEP_WK_CAT)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 15)) +
  coord_flip() +
  labs(title = "Weekday Sleep Duration by Self-Reported Cancer Site", x = "Cancer Site", y = "Percent within Site Group", fill = "Sleep Category") +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(size = 10), plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(here("output/plot4.png"), plot = plot4, width = 9, height = 5, dpi = 300, device = "png")