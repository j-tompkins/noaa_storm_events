library(tidyverse)
library(httr)
library(rvest)
library(stringr)

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

base <- "https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/"
html <- read_html(base)

links <- html %>%
  html_elements("a") %>%
  html_attr("href") %>%
  tibble(href = .) %>%
  filter(str_detect(href, "^StormEvents_details-ftp_v1\\.0_d\\d{4}_c\\d{8}\\.csv\\.gz$")) %>%
  mutate(
    year = as.integer(str_match(href, "details-ftp_v1\\.0_d(\\d{4})_c")[,2]),
    created = as.integer(str_match(href, "_c(\\d{8})\\.csv\\.gz$")[,2])
  )

year_start <- 2015
year_end   <- 2024

latest <- links %>%
  filter(year >= year_start, year <= year_end) %>%
  group_by(year) %>%
  slice_max(created, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  arrange(year)

print(latest)

for (f in latest$href) {
  dest <- file.path("data/raw", f)
  if (file.exists(dest)) {
    message("Skip (exists): ", f)
    next
  }
  url <- paste0(base, f)
  message("Downloading: ", url)
  GET(url, write_disk(dest, overwrite = TRUE), progress())
}