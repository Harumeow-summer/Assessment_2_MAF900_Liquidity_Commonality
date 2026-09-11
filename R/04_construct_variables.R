# 04_construct_variables.R
# This script constructs the research variables used for H1 and H2.
# It creates relative spread, VIX regimes, and the daily change in relative spread.

# Run the common setup script first.
source("R/00_setup.R")

# Read the cleaned and merged ETF-VIX panel.
data <- read_rds(
  here("data", "processed", "merged_panel.rds")
)

# Keep one VIX observation per date before calculating VIX quartiles.
# This prevents the same daily VIX value from being counted eight times because there are eight ETFs.
vix_by_date <- data %>%
  select(date, vix) %>%
  distinct() %>%
  filter(!is.na(vix))

# Calculate the 25th percentile of VIX for the Low-volatility regime.
vix_low_cutoff <- quantile(
  vix_by_date$vix,
  0.25,
  na.rm = TRUE
)

# Calculate the 75th percentile of VIX for the High-volatility regime.
vix_high_cutoff <- quantile(
  vix_by_date$vix,
  0.75,
  na.rm = TRUE
)

# Create a complete list of dates that have a VIX observation.
analysis_dates <- vix_by_date %>%
  select(date)

# Create all combinations of the eight ETFs and the common analysis dates.
# This keeps the daily calendar complete before lagged spread changes are calculated.
complete_panel <- expand_grid(
  etf = etf_info$etf,
  date = analysis_dates$date
)

# Add each ETF's asset class and PERMNO to the complete ETF-date grid.
complete_panel <- complete_panel %>%
  left_join(etf_info, by = "etf")

# Add the cleaned CRSP quote information to the complete ETF-date grid.
complete_panel <- complete_panel %>%
  left_join(
    data %>%
      select(
        etf, date, source_ticker,
        bid_clean, ask_clean,
        missing_quote, crossed_quote
      ),
    by = c("etf", "date")
  )

# Add the daily VIX value to every ETF observation on the same date.
complete_panel <- complete_panel %>%
  left_join(vix_by_date, by = "date")

# Calculate the bid-ask midpoint for each valid ETF-day quote.
complete_panel <- complete_panel %>%
  mutate(
    midpoint = (bid_clean + ask_clean) / 2
  )

# Calculate the relative bid-ask spread.
# This scales the bid-ask gap by the ETF price level.
complete_panel <- complete_panel %>%
  mutate(
    relative_spread = (ask_clean - bid_clean) / midpoint
  )

# Classify each date into Low, Middle, or High volatility using the VIX quartiles.
complete_panel <- complete_panel %>%
  mutate(
    vix_regime = case_when(
      vix <= vix_low_cutoff ~ "Low",
      vix >= vix_high_cutoff ~ "High",
      TRUE ~ "Middle"
    )
  )

# Sort observations by ETF and date before calculating lagged spread changes.
complete_panel <- complete_panel %>%
  arrange(etf, date)

# Group by ETF so each lag uses the same ETF rather than another ETF.
complete_panel <- complete_panel %>%
  group_by(etf)

# Calculate the daily change in relative spread on the complete daily panel.
# This step is intentionally done BEFORE filtering to High or Low VIX regimes.
complete_panel <- complete_panel %>%
  mutate(
    delta_spread = relative_spread - lag(relative_spread)
  )

# Remove the temporary ETF grouping after the lag has been created.
complete_panel <- complete_panel %>%
  ungroup()

# Save the two VIX cut-off values for documentation.
vix_cutoffs <- data.frame(
  low_cutoff = as.numeric(vix_low_cutoff),
  high_cutoff = as.numeric(vix_high_cutoff)
)

# Save the VIX cut-off file.
write_csv(
  vix_cutoffs,
  here("data", "processed", "vix_cutoffs.csv")
)

# Save the final analysis panel.
write_rds(
  complete_panel,
  here("data", "processed", "analysis_panel.rds")
)
