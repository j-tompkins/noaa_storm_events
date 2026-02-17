library(tidyverse)
library(arrow)
library(scales)

dir.create("reports/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("reports/tables", recursive = TRUE, showWarnings = FALSE)

df <- read_parquet("data/processed/storm_events_analysis.parquet") %>% as_tibble()

event types
top_n <- 20
top_types <- df %>% count(event_type, sort = TRUE) %>% slice_head(n = top_n) %>% pull(event_type)

df <- df %>%
  mutate(event_type_group = if_else(event_type %in% top_types, event_type, "OTHER"))

by_type <- df %>%
  group_by(event_type_group) %>%
  summarise(
    events = n(),
    injuries = sum(injuries, na.rm = TRUE),
    fatalities = sum(fatalities, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    injuries_per_1000 = 1000 * injuries / events,
    fatalities_per_10000 = 10000 * fatalities / events
  ) %>%
  arrange(desc(fatalities))

write_csv(by_type, "reports/tables/by_event_type.csv")

by_state <- df %>%
  group_by(state) %>%
  summarise(
    events = n(),
    injuries = sum(injuries, na.rm = TRUE),
    fatalities = sum(fatalities, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    injuries_per_1000 = 1000 * injuries / events,
    fatalities_per_10000 = 10000 * fatalities / events
  ) %>%
  arrange(desc(fatalities))

write_csv(by_state, "reports/tables/by_state.csv")

# Plots
p1 <- by_type %>%
  slice_max(fatalities, n = 15) %>%
  mutate(event_type_group = fct_reorder(event_type_group, fatalities)) %>%
  ggplot(aes(event_type_group, fatalities)) +
  geom_col() +
  coord_flip() +
  labs(title = "Top event types by total fatalities", x = NULL, y = "Fatalities")

ggsave("reports/figures/top_event_types_fatalities.png", p1, width = 9, height = 6, dpi = 200)

p2 <- by_type %>%
  slice_max(injuries, n = 15) %>%
  mutate(event_type_group = fct_reorder(event_type_group, injuries)) %>%
  ggplot(aes(event_type_group, injuries)) +
  geom_col() +
  coord_flip() +
  labs(title = "Top event types by total injuries", x = NULL, y = "Injuries")

ggsave("reports/figures/top_event_types_injuries.png", p2, width = 9, height = 6, dpi = 200)

p3 <- by_type %>%
  filter(events >= 500) %>%  # avoid tiny denominators for ship-first
  slice_max(fatalities_per_10000, n = 15) %>%
  mutate(event_type_group = fct_reorder(event_type_group, fatalities_per_10000)) %>%
  ggplot(aes(event_type_group, fatalities_per_10000)) +
  geom_col() +
  coord_flip() +
  labs(title = "Top event types by fatalities per 10,000 events (events ≥ 500)", x = NULL, y = "Fatalities per 10,000 events")

ggsave("reports/figures/top_event_types_fatality_rate.png", p3, width = 9, height = 6, dpi = 200)

# Results markdown starter
results_path <- "reports/results.md"
total_inj <- sum(df$injuries, na.rm = TRUE)
total_fat <- sum(df$fatalities, na.rm = TRUE)

writeLines(c(
  "# NOAA Storm Events — Results (Draft)",
  "",
  paste0("- Rows analyzed: ", comma(nrow(df))),
  paste0("- Total injuries: ", comma(total_inj)),
  paste0("- Total fatalities: ", comma(total_fat)),
  "",
  "## Key outputs",
  "- Tables: `reports/tables/by_event_type.csv`, `reports/tables/by_state.csv`",
  "- Figures:",
  "  - `reports/figures/top_event_types_fatalities.png`",
  "  - `reports/figures/top_event_types_injuries.png`",
  "  - `reports/figures/top_event_types_fatality_rate.png`",
  "",
  "## Notes on interpretation",
  "- This analysis is descriptive and associational (not causal, not forecasting).",
  "- Rates are event-based (per number of recorded events), not population rates.",
  "- Reporting practices and event definitions may vary by time and location."
), results_path)

message("Wrote: ", results_path)