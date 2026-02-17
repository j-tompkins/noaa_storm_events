pkgs <- c(
  "tidyverse", "janitor", "lubridate", "arrow",
  "httr", "rvest", "stringr", "readr", "scales"
)

to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)

invisible(lapply(pkgs, library, character.only = TRUE))