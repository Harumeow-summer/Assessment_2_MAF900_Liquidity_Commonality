# 05_make_tables.R
# This script creates the planned summary tables for H1 and H2.
# All tables are generated from the processed analysis data.

# Run the common setup script first.
source("R/00_setup.R")

# Read the final analysis panel.
data <- read_rds(
  here("data", "processed", "analysis_panel.rds")
)

# TABLE 1A: VIX SUMMARY STATISTICS


# Keep one VIX value per date so VIX is not repeated once for every ETF.
vix_summary_data <- data %>%
  select(date, vix) %>%
  distinct()

# Calculate basic VIX summary statistics.
vix_summary <- data.frame(
  observations = sum(!is.na(vix_summary_data$vix)),
  mean = mean(vix_summary_data$vix, na.rm = TRUE),
  median = median(vix_summary_data$vix, na.rm = TRUE),
  standard_deviation = sd(vix_summary_data$vix, na.rm = TRUE),
  minimum = min(vix_summary_data$vix, na.rm = TRUE),
  maximum = max(vix_summary_data$vix, na.rm = TRUE)
)

# Save the VIX summary table.
write_csv(
  vix_summary,
  here("output", "tables", "table1a_vix_summary.csv")
)


# TABLE 1B: RELATIVE-SPREAD SUMMARY BY ETF


# Calculate spread summary statistics separately for each ETF.
spread_summary <- data %>%
  group_by(etf, asset_class) %>%
  summarise(
    observations = sum(!is.na(relative_spread)),
    mean_spread = mean(relative_spread, na.rm = TRUE),
    median_spread = median(relative_spread, na.rm = TRUE),
    standard_deviation = sd(relative_spread, na.rm = TRUE),
    .groups = "drop"
  )

# Save the spread summary table.
write_csv(
  spread_summary,
  here("output", "tables", "table1b_spread_summary.csv")
)

# TABLE 2: H1 HIGH-VIX VS LOW-VIX SPREAD COMPARISON

# Keep only High- and Low-VIX observations with a valid relative spread.
h1_data <- data %>%
  filter(
    vix_regime %in% c("Low", "High"),
    !is.na(relative_spread)
  )

# Create an empty list that will store one result table for each ETF.
h1_results <- list()

# Run the same H1 comparison for each of the eight ETFs.
for (this_etf in etf_info$etf) {

  # Keep only the observations for the current ETF.
  etf_data <- h1_data %>%
    filter(etf == this_etf)

  # Store the Low-VIX relative spreads for the current ETF.
  low_spread <- etf_data %>%
    filter(vix_regime == "Low") %>%
    pull(relative_spread)

  # Store the High-VIX relative spreads for the current ETF.
  high_spread <- etf_data %>%
    filter(vix_regime == "High") %>%
    pull(relative_spread)

  # Run a Welch two-sample t-test as an exploratory univariate comparison.
  t_test_result <- t.test(high_spread, low_spread)

  # Run a Wilcoxon rank-sum test as a non-parametric exploratory comparison.
  wilcoxon_result <- wilcox.test(
    high_spread,
    low_spread,
    exact = FALSE
  )

  # Create one result row for the current ETF.
  one_etf_result <- data.frame(
    etf = this_etf,
    mean_low = mean(low_spread),
    mean_high = mean(high_spread),
    mean_difference = mean(high_spread) - mean(low_spread),
    median_low = median(low_spread),
    median_high = median(high_spread),
    median_difference = median(high_spread) - median(low_spread),
    welch_t_p_value = t_test_result$p.value,
    wilcoxon_p_value = wilcoxon_result$p.value
  )

  # Add the current ETF result to the result list.
  h1_results[[this_etf]] <- one_etf_result
}

# Combine the eight ETF result rows into one H1 table.
h1_table <- bind_rows(h1_results)

# Save the H1 comparison table.
write_csv(
  h1_table,
  here("output", "tables", "table2_h1_high_low_spread.csv")
)

# TABLE 3A: H2 LOW-VIX CORRELATION MATRIX

# Keep Low-VIX dates and the daily spread change for each ETF.
low_data <- data %>%
  filter(vix_regime == "Low") %>%
  select(date, etf, delta_spread)

# Put the eight ETFs into separate columns so a correlation matrix can be calculated.
low_wide <- low_data %>%
  pivot_wider(
    names_from = etf,
    values_from = delta_spread
  )

# Keep only dates where delta_spread is available for all eight ETFs.
low_wide <- low_wide[
  complete.cases(low_wide[, etf_info$etf]),
]

# Calculate the Low-VIX correlation matrix.
low_correlation <- cor(
  low_wide[, etf_info$etf]
)

# Convert the correlation matrix to a data frame for saving.
low_correlation_table <- as.data.frame(low_correlation)

# Add the row ETF names as a normal column.
low_correlation_table$etf <- rownames(low_correlation_table)

# Move the ETF-name column to the first position.
low_correlation_table <- low_correlation_table %>%
  select(etf, everything())

# Save the Low-VIX correlation matrix.
write_csv(
  low_correlation_table,
  here("output", "tables", "table3a_h2_low_correlation.csv")
)

# TABLE 3B: H2 HIGH-VIX CORRELATION MATRIX

# Keep High-VIX dates and the daily spread change for each ETF.
high_data <- data %>%
  filter(vix_regime == "High") %>%
  select(date, etf, delta_spread)

# Put the eight ETFs into separate columns.
high_wide <- high_data %>%
  pivot_wider(
    names_from = etf,
    values_from = delta_spread
  )

# Keep only dates where delta_spread is available for all eight ETFs.
high_wide <- high_wide[
  complete.cases(high_wide[, etf_info$etf]),
]

# Calculate the High-VIX correlation matrix.
high_correlation <- cor(
  high_wide[, etf_info$etf]
)

# Convert the matrix to a data frame for saving.
high_correlation_table <- as.data.frame(high_correlation)

# Add the row ETF names as a normal column.
high_correlation_table$etf <- rownames(high_correlation_table)

# Move the ETF-name column to the first position.
high_correlation_table <- high_correlation_table %>%
  select(etf, everything())

# Save the High-VIX correlation matrix.
write_csv(
  high_correlation_table,
  here("output", "tables", "table3b_h2_high_correlation.csv")
)

# TABLE 3C: H2 28 ETF PAIRS AND 24 CROSS-ASSET-CLASS PAIRS

# Create an empty data frame that will store one row for each unique ETF pair.
pair_table <- data.frame()

# Loop through the eight ETFs without repeating the same pair twice.
for (i in 1:(nrow(etf_info) - 1)) {

  # Compare ETF i with every ETF that comes after it.
  for (j in (i + 1):nrow(etf_info)) {

    # Store the first ETF name.
    etf1 <- etf_info$etf[i]

    # Store the second ETF name.
    etf2 <- etf_info$etf[j]

    # Store the first ETF's asset class.
    class1 <- etf_info$asset_class[i]

    # Store the second ETF's asset class.
    class2 <- etf_info$asset_class[j]

    # Read this pair's Low-VIX correlation from the Low-VIX matrix.
    low_corr <- low_correlation[etf1, etf2]

    # Read this pair's High-VIX correlation from the High-VIX matrix.
    high_corr <- high_correlation[etf1, etf2]

    # Create one row for this ETF pair.
    one_pair <- data.frame(
      etf1 = etf1,
      etf2 = etf2,
      asset_class1 = class1,
      asset_class2 = class2,
      cross_asset_class = class1 != class2,
      low_correlation = low_corr,
      high_correlation = high_corr,
      high_minus_low = high_corr - low_corr
    )

    # Add the current pair to the full pair table.
    pair_table <- bind_rows(pair_table, one_pair)
  }
}

# Save all 28 unique ETF pairs.
write_csv(
  pair_table,
  here("output", "tables", "table3c_h2_all_28_pairs.csv")
)

# Keep only pairs where the two ETFs belong to different asset classes.
cross_asset_pairs <- pair_table %>%
  filter(cross_asset_class == TRUE)

# Calculate the average correlation across the 24 cross-asset-class pairs.
h2_summary <- data.frame(
  cross_asset_pairs = nrow(cross_asset_pairs),
  average_low_correlation = mean(cross_asset_pairs$low_correlation),
  average_high_correlation = mean(cross_asset_pairs$high_correlation),
  high_minus_low = mean(cross_asset_pairs$high_correlation) -
                   mean(cross_asset_pairs$low_correlation),
  low_common_dates = nrow(low_wide),
  high_common_dates = nrow(high_wide)
)

# Save the H2 summary table.
write_csv(
  h2_summary,
  here("output", "tables", "table3d_h2_cross_asset_summary.csv")
)
