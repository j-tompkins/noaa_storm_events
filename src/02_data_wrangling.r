library(tidyverse)
library(janitor)
library(lubridate)
library(arrow)
library(readr)

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

files <- list.files("data/raw", pattern = "StormEvents_details-ftp_v1\\.0_.*\\.csv\\.gz$", full.names = TRUE)
stopifnot(length(files) > 0)

read_one <- function(path) {
  read_csv(path, show_col_types = FALSE, progress = FALSE) %>%
    clean_names()
}

df <- files %>%
  set_names() %>%
  map_dfr(read_one)

# Parse begin date-time (format like "14-JAN-50 00:00:00")
df <- df %>%
  mutate(
    begin_datetime = parse_date_time(begin_date_time, orders = "d-b-y H:M:S", tz = "UTC"),
    injuries_direct   = as.integer(replace_na(as.numeric(injuries_direct), 0)),
    injuries_indirect = as.integer(replace_na(as.numeric(injuries_indirect), 0)),
    deaths_direct     = as.integer(replace_na(as.numeric(deaths_direct), 0)),
    deaths_indirect   = as.integer(replace_na(as.numeric(deaths_indirect), 0)),
    injuries   = injuries_direct + injuries_indirect,
    fatalities = deaths_direct + deaths_indirect,
    any_injury   = as.integer(injuries > 0),
    any_fatality = as.integer(fatalities > 0),
    event_type = str_squish(event_type),
    state = str_squish(state),
    month = month(begin_datetime),
    season = case_when(
      month %in% c(12, 1, 2) ~ "Winter",
      month %in% c(3, 4, 5) ~ "Spring",
      month %in% c(6, 7, 8) ~ "Summer",
      month %in% c(9,10,11) ~ "Fall",
      TRUE ~ NA_character_
    )
  )

# Keep a tight set of fields for ship-first
keep <- c(
  "event_id","year","event_type","state","begin_datetime",
  "injuries","fatalities","any_injury","any_fatality",
  "month","season","cz_name","cz_type","begin_lat","begin_lon"
)
keep <- keep[keep %in% names(df)]
df <- df %>% select(all_of(keep))

write_parquet(df, "data/processed/storm_events_analysis.parquet")
message("Wrote: data/processed/storm_events_analysis.parquet")