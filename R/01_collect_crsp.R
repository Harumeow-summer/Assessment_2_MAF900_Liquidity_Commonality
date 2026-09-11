# 01_collect_crsp.R
# This script collects the daily CRSP data used in the project.
# The verified PERMNO values are already stored in config/etf_permnos.csv.
# The final collection uses verified PERMNO values instead of ticker names.

# Run the common setup script first.
source("R/00_setup.R")

# Check that the config file contains a PERMNO for every ETF.
# The eight verified PERMNO values are already included in the repository.
if (any(is.na(etf_info$permno))) {
  stop("A PERMNO is missing from config/etf_permnos.csv.")
}

# Connect to WRDS.
# Replace YOUR_WRDS_USERNAME with your own WRDS username before running the script.
# The password is not written in the script.
# Create a fresh WRDS connection
wrds <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "wrds-pgdata.wharton.upenn.edu",
  port = 9737,
  dbname = "wrds",
  sslmode = "require",
  user = "YOUR_WRDS_USERNAME",
  password = rstudioapi::askForPassword("Enter your WRDS password")
)

# Test whether the connection can execute a query
DBI::dbGetQuery(wrds, "SELECT 1 AS connection_test")

# Turn the eight PERMNO values into text for the SQL query.
permno_text <- paste(etf_info$permno, collapse = ", ")

# Build the SQL query for the required CRSP variables and dates.
crsp_query <- paste0(
  "SELECT permno, dlycaldt, ticker, dlybid, dlyask ",
  "FROM crsp.dsf_v2 ",
  "WHERE dlycaldt BETWEEN '2010-01-04' AND '2025-12-31' ",
  "AND permno IN (", permno_text, ") ",
  "ORDER BY permno, dlycaldt"
)

# Download the CRSP observations from WRDS.
crsp_raw <- dbGetQuery(wrds, crsp_query)

# Disconnect from WRDS as soon as the download is finished.
dbDisconnect(wrds)

# Rename the CRSP variables to shorter names that are easier to use later.
crsp_raw <- crsp_raw %>%
  rename(
    date = dlycaldt,
    source_ticker = ticker,
    bid = dlybid,
    ask = dlyask
  )

# Convert the date variable to R Date format.
crsp_raw$date <- as.Date(crsp_raw$date)

# Convert PERMNO to numeric so it matches the config file.
crsp_raw$permno <- as.numeric(crsp_raw$permno)

# Convert bid and ask to numeric values.
crsp_raw$bid <- as.numeric(crsp_raw$bid)
crsp_raw$ask <- as.numeric(crsp_raw$ask)

# Add the project ETF label and asset class using the verified PERMNO mapping.
crsp_raw <- crsp_raw %>%
  left_join(etf_info, by = "permno")

# Sort the data by ETF and trading date.
crsp_raw <- crsp_raw %>%
  arrange(etf, date)

# Save the downloaded CRSP data locally as an RDS file.
# This file is ignored by Git because CRSP is licensed data.
write_rds(
  crsp_raw,
  here("data", "raw", "crsp_daily.rds")
)

# Create a simple coverage check for each ETF.
crsp_coverage <- crsp_raw %>%
  group_by(etf, asset_class, permno) %>%
  summarise(
    first_date = min(date),
    last_date = max(date),
    observations = n(),
    missing_bid = sum(is.na(bid)),
    missing_ask = sum(is.na(ask)),
    .groups = "drop"
  )

# Save the coverage check so it can be inspected before the next step.
write_csv(
  crsp_coverage,
  here("logs", "crsp_coverage.csv")
)
