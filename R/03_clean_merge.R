# 03_clean_merge.R
# This script checks the raw CRSP quotes and merges CRSP with VIX by date.
# Cleaning is necessary so invalid observations are not used to build liquidity measures.

# Run the common setup script first.
source("R/00_setup.R")

# Read the local CRSP file created by 01_collect_crsp.R.
crsp <- read_rds(
  here("data", "raw", "crsp_daily.rds")
)

# Read the local VIX file created by 02_collect_vix.R.
vix <- read_rds(
  here("data", "raw", "vix_daily.rds")
)

# Count how many rows exist for each PERMNO-date combination.
duplicate_check <- crsp %>%
  count(permno, date) %>%
  filter(n > 1)

# Save any duplicate rows for inspection.
write_csv(
  duplicate_check,
  here("logs", "duplicate_check.csv")
)

# Stop the workflow if duplicate PERMNO-date observations exist.
# Duplicates are not deleted automatically because that could hide a data problem.
if (nrow(duplicate_check) > 0) {
  stop("Duplicate PERMNO-date observations were found. Check logs/duplicate_check.csv.")
}

# Create simple flags for the two quote problems used in the project.
crsp <- crsp %>%
  mutate(
    missing_quote = is.na(bid) | is.na(ask),
    crossed_quote = !is.na(bid) & !is.na(ask) & ask < bid
  )

# Create cleaned bid values.
# A bid is set to missing if bid/ask is missing, ask is below bid, or a quote is non-positive.
crsp <- crsp %>%
  mutate(
    bid_clean = ifelse(
      missing_quote | crossed_quote | bid <= 0 | ask <= 0,
      NA,
      bid
    )
  )

# Create cleaned ask values using the same transparent rule.
crsp <- crsp %>%
  mutate(
    ask_clean = ifelse(
      missing_quote | crossed_quote | bid <= 0 | ask <= 0,
      NA,
      ask
    )
  )

# Merge the ETF observations with the daily VIX value using trading date as the key.
merged_data <- crsp %>%
  left_join(vix, by = "date")

# Find CRSP trading dates that did not receive a VIX value after the merge.
unmatched_dates <- merged_data %>%
  filter(is.na(vix)) %>%
  distinct(date) %>%
  arrange(date)

# Save the unmatched dates so the merge can be checked.
write_csv(
  unmatched_dates,
  here("logs", "unmatched_vix_dates.csv")
)

# Create a short cleaning and merge summary.
cleaning_summary <- data.frame(
  total_etf_days = nrow(merged_data),
  unique_dates = length(unique(merged_data$date)),
  missing_quotes = sum(merged_data$missing_quote),
  crossed_quotes = sum(merged_data$crossed_quote),
  unmatched_vix_rows = sum(is.na(merged_data$vix))
)

# Save the cleaning summary for the assessor and for later checking.
write_csv(
  cleaning_summary,
  here("logs", "cleaning_summary.csv")
)

# Save the cleaned and merged panel for variable construction.
write_rds(
  merged_data,
  here("data", "processed", "merged_panel.rds")
)
