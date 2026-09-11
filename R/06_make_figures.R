# 06_make_figures.R
# This script creates the three planned figures.
# Figure 1 supports H1 and Figures 2-3 support H2.

# Run the common setup script first.
source("R/00_setup.R")

# Read the final analysis panel.
data <- read_rds(
  here("data", "processed", "analysis_panel.rds")
)

# FIGURE 1: RELATIVE SPREAD BY ETF AND VIX REGIME

# Keep only valid relative spreads from the Low- and High-VIX regimes.
boxplot_data <- data %>%
  filter(
    vix_regime %in% c("Low", "High"),
    !is.na(relative_spread)
  )

# Create the H1 boxplot.
figure1 <- ggplot(
  boxplot_data,
  aes(
    x = etf,
    y = relative_spread,
    fill = vix_regime
  )
) +
  geom_boxplot() +
  labs(
    title = "Relative Bid-Ask Spread by VIX Regime",
    x = "ETF",
    y = "Relative bid-ask spread",
    fill = "VIX regime"
  ) +
  theme_minimal()

# Save Figure 1 as a PNG file.
ggsave(
  here("output", "figures", "figure1_spread_boxplot.png"),
  figure1,
  width = 9,
  height = 6,
  dpi = 300
)


# FIGURE 2: LOW-VIX CORRELATION HEATMAP

# Read the Low-VIX correlation table created by 05_make_tables.R.
low_corr_table <- read_csv(
  here("output", "tables", "table3a_h2_low_correlation.csv"),
  show_col_types = FALSE
)

# Convert the Low-VIX correlation table from wide format to long format.
low_corr_long <- low_corr_table %>%
  pivot_longer(
    cols = -etf,
    names_to = "etf2",
    values_to = "correlation"
  )

# Create the Low-VIX correlation heatmap.
figure2 <- ggplot(
  low_corr_long,
  aes(
    x = etf2,
    y = etf,
    fill = correlation
  )
) +
  geom_tile() +
  geom_text(
    aes(label = round(correlation, 2))
  ) +
  scale_fill_gradient2(
    limits = c(-1, 1),
    midpoint = 0
  ) +
  labs(
    title = "Daily Spread-Change Correlation: Low-VIX Regime",
    x = "ETF",
    y = "ETF",
    fill = "Correlation"
  ) +
  theme_minimal()

# Save Figure 2 as a PNG file.
ggsave(
  here("output", "figures", "figure2_low_vix_heatmap.png"),
  figure2,
  width = 8,
  height = 7,
  dpi = 300
)

# FIGURE 3: HIGH-VIX CORRELATION HEATMAP

# Read the High-VIX correlation table created by 05_make_tables.R.
high_corr_table <- read_csv(
  here("output", "tables", "table3b_h2_high_correlation.csv"),
  show_col_types = FALSE
)

# Convert the High-VIX correlation table from wide format to long format.
high_corr_long <- high_corr_table %>%
  pivot_longer(
    cols = -etf,
    names_to = "etf2",
    values_to = "correlation"
  )

# Create the High-VIX correlation heatmap.
figure3 <- ggplot(
  high_corr_long,
  aes(
    x = etf2,
    y = etf,
    fill = correlation
  )
) +
  geom_tile() +
  geom_text(
    aes(label = round(correlation, 2))
  ) +
  scale_fill_gradient2(
    limits = c(-1, 1),
    midpoint = 0
  ) +
  labs(
    title = "Daily Spread-Change Correlation: High-VIX Regime",
    x = "ETF",
    y = "ETF",
    fill = "Correlation"
  ) +
  theme_minimal()

# Save Figure 3 as a PNG file.
ggsave(
  here("output", "figures", "figure3_high_vix_heatmap.png"),
  figure3,
  width = 8,
  height = 7,
  dpi = 300
)
