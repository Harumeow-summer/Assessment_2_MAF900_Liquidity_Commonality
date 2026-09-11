# 02_collect_vix.R
# This script downloads the daily VIX series from FRED.
# VIX is the market-volatility variable used to define High and Low regimes.

# Run the common setup script first.
source("R/00_setup.R")

# Store the direct FRED CSV link for the VIXCLS series.
vix_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=VIXCLS"

# Download the VIX CSV directly into R.
vix_raw <- read_csv(
  vix_url,
  na = c(".", "NA", ""),
  show_col_types = FALSE
)

# Copy the downloaded FRED data into the object used by the project.
vix <- vix_raw

# Rename the first two FRED columns to simple project names.
# This avoids depending on the exact label used for the FRED date column.
names(vix)[1:2] <- c("date", "vix")

# Convert the FRED date column to R Date format.
vix$date <- as.Date(vix$date)

# Convert the VIX values to numeric format.
vix$vix <- as.numeric(vix$vix)

# Keep only the research sample period.
vix <- vix %>%
  filter(date >= start_date, date <= end_date)

# Sort the VIX data by date.
vix <- vix %>%
  arrange(date)

# Save the raw VIX sample locally.
write_rds(
  vix,
  here("data", "raw", "vix_daily.rds")
)

# Create a simple VIX coverage check.
vix_coverage <- data.frame(
  first_date = min(vix$date),
  last_date = max(vix$date),
  observations = nrow(vix),
  missing_vix = sum(is.na(vix$vix))
)

# Save the VIX coverage check for inspection.
write_csv(
  vix_coverage,
  here("logs", "vix_coverage.csv")
)
