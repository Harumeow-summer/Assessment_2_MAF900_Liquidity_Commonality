# Data Access Requirements

## CRSP through WRDS

The project uses daily CRSP Version 2 data from `crsp.dsf_v2`.

Required fields:

- `permno`: stable CRSP security identifier
- `dlycaldt`: trading date
- `ticker`: ticker recorded on that date
- `dlybid`: daily closing bid
- `dlyask`: daily closing ask

A valid institutional WRDS account with CRSP access is required.
Raw CRSP data are licensed and should not be uploaded to GitHub.
The repository therefore shares data-collection code rather than raw CRSP files.

## FRED VIX

The project uses daily VIX series `VIXCLS` from FRED.
The VIX data are downloaded by code and merged with CRSP by date.

## WRDS login used in this repository

The WRDS connection follows the same simple `DBI` / `RPostgres` style used in class:

```r
wrds <- dbConnect(
  Postgres(),
  host = "wrds-pgdata.wharton.upenn.edu",
  port = 9737,
  dbname = "wrds",
  sslmode = "require",
  user = "YOUR_WRDS_USERNAME"
)
```

Replace `YOUR_WRDS_USERNAME` with your own WRDS username before running the WRDS scripts.

The password is deliberately not written into the R script. The connection therefore relies on the WRDS/PostgreSQL authentication method available in the user's environment.


## Verified ETF identifiers

The repository already stores the verified CRSP PERMNO values in `config/etf_permnos.csv`.

No manual PERMNO entry is required to run the main workflow. The file `R/optional_check_permno.R` is provided only as an audit tool.
