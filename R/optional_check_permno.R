# optional_check_permno.R
# This is a one-time checking script.
# It helps identify the CRSP PERMNO for each ETF before the main data collection.
# Tickers are used only for this initial identity check.
# The final analysis should use verified PERMNO values.

# Run the common setup script first.
source("R/00_setup.R")

# Connect to the WRDS PostgreSQL database.
# Replace YOUR_WRDS_USERNAME with your own WRDS username before running the script.
# The password is not written in the script.
wrds <- dbConnect(
  Postgres(),
  host = "wrds-pgdata.wharton.upenn.edu",
  port = 9737,
  dbname = "wrds",
  sslmode = "require",
  user = "YOUR_WRDS_USERNAME"
)

# List the ETF tickers used for the one-time identity check.
# QQQQ is included because QQQ used that historical ticker before 2011.
tickers_to_check <- c(
  "SPY", "QQQ", "QQQQ", "IEF", "TLT",
  "LQD", "HYG", "GLD", "SLV"
)

# Convert the ticker list into text that can be used inside the SQL query.
ticker_text <- paste0("'", tickers_to_check, "'", collapse = ", ")

# Build a simple SQL query that returns each ticker and its candidate PERMNO values.
permno_query <- paste0(
  "SELECT DISTINCT permno, ticker ",
  "FROM crsp.dsf_v2 ",
  "WHERE dlycaldt BETWEEN '2010-01-04' AND '2025-12-31' ",
  "AND UPPER(ticker) IN (", ticker_text, ") ",
  "ORDER BY ticker, permno"
)

# Run the SQL query on WRDS.
permno_candidates <- dbGetQuery(wrds, permno_query)

# Save the candidate PERMNO list for manual checking.
write_csv(
  permno_candidates,
  here("logs", "permno_candidates.csv")
)

# Disconnect from WRDS after the query is finished.
dbDisconnect(wrds)

# IMPORTANT NEXT STEP:
# The output can be used to verify that the PERMNO values in config/etf_permnos.csv still match the intended ETFs.
