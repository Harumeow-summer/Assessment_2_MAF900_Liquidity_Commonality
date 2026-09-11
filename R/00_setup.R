# 00_setup.R
# This script loads the packages used by the project.
# It also sets the sample start and end dates in one place.

# Load tidyverse for data cleaning, data manipulation, CSV files, and figures.
# tidyverse includes dplyr, tidyr, readr, and ggplot2.
library(tidyverse)

# Load DBI so R can connect to the WRDS database.
library(DBI)

# Load here so file paths are based on the RStudio project folder.
library(here)

# Load RPostgres so DBI can connect to the WRDS PostgreSQL database.
library(RPostgres)

# Set the first date used in the research sample.
start_date <- as.Date("2010-01-04")

# Set the last date used in the research sample.
end_date <- as.Date("2025-12-31")

# Read the ETF list and the verified PERMNO values from the config file.
etf_info <- read_csv(
  here("config", "etf_permnos.csv"),
  show_col_types = FALSE
)
