# MAF900 Reproducible Data Analysis

## Project title

Liquidity Co-movement Across Asset Classes Under High- and Low-Volatility Market Conditions

## Research question

How does liquidity co-movement among U.S.-listed ETF proxies for different asset classes differ between high-volatility and low-volatility market conditions?

## Sample

- Period: 4 January 2010 to 31 December 2025
- Unit of observation: ETF-day
- Equity: SPY, QQQ
- Treasury: IEF, TLT
- Corporate credit: LQD, HYG
- Precious metals: GLD, SLV

## Main variables

- Relative spread = (Ask - Bid) / ((Ask + Bid) / 2)
- Low volatility = bottom 25% of sample VIX dates
- High volatility = top 25% of sample VIX dates
- Daily spread change = Spread_t - Spread_t-1

## Hypotheses

- H1: Relative spreads are wider during High-VIX than Low-VIX conditions.
- H2: Daily changes in relative spread show stronger cross-asset-class co-movement during High-VIX conditions.

## Data sources

### CRSP through WRDS

The repository uses CRSP daily Version 2 data from `crsp.dsf_v2`.
The required fields are `permno`, `dlycaldt`, `ticker`, `dlybid`, and `dlyask`.
A valid WRDS account with CRSP permission is required.

Raw CRSP data are licensed and are therefore not uploaded to GitHub.
The repository contains the code needed for an authorised WRDS user to rebuild the sample.

### FRED VIX

Daily VIX is downloaded from FRED series `VIXCLS`.
The CRSP and VIX datasets are merged by trading date.

## Packages

Install the required packages once in the RStudio Console:

```r
install.packages(c(
  "tidyverse", "DBI", "here", "RPostgres",
  "knitr", "rmarkdown", "renv"
))
```

The R scripts load only four main packages for the analysis workflow:

```r
library(tidyverse)
library(DBI)
library(here)
library(RPostgres)
```

`tidyverse` already includes `dplyr`, `tidyr`, `readr`, and `ggplot2`, so they do not need to be loaded separately.

## WRDS login

The WRDS scripts use the following this connection format (if you have already setup your access):

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
Or
# Create a fresh WRDS connection
```r
wrds <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "wrds-pgdata.wharton.upenn.edu",
  port = 9737,
  dbname = "wrds",
  sslmode = "require",
  user = "YOUR_WRDS_USERNAME",
  password = rstudioapi::askForPassword("Enter your WRDS password")
)
```
Replace the placeholder with your own WRDS username. The password is not stored in the script.

## Project structure

```text
MAF900_Liquidity_Commonality_Repo_Beginner/
├── MAF900_Liquidity_Commonality.Rproj
├── README.md
├── .gitignore
├── config/
│   └── etf_permnos.csv
├── R/
│   ├── 00_setup.R
│   ├── optional_check_permno.R
│   ├── 01_collect_crsp.R
│   ├── 02_collect_vix.R
│   ├── 03_clean_merge.R
│   ├── 04_construct_variables.R
│   ├── 05_make_tables.R
│   └── 06_make_figures.R
├── docs/
│   ├── RStudio_step_by_step.md
│   ├── data_access.md
│   ├── data_dictionary.md
│   └── reproducibility.md
├── report/
│   └── short_report.Rmd
├── data/
│   ├── raw/
│   └── processed/
├── output/
│   ├── tables/
│   └── figures/
└── logs/
```

## The scripts are numbered

The numbers show the exact order in which the project should be run.
This makes the workflow easy to follow and easy to reproduce.

## First-time run order

1. Open `MAF900_Liquidity_Commonality.Rproj` in RStudio.
2. Install the required packages listed in `docs/RStudio_step_by_step.md`.
3. Run `R/optional_check_permno.R` once.
4. Check `logs/permno_candidates.csv` and enter the eight verified PERMNO values in `config/etf_permnos.csv`.
5. Run `R/01_collect_crsp.R`.
6. Run `R/02_collect_vix.R`.
7. Run `R/03_clean_merge.R`.
8. Run `R/04_construct_variables.R`.
9. Run `R/05_make_tables.R`.
10. Run `R/06_make_figures.R`.

## Important reproducibility rules

- Do not use hard-coded local paths such as `C:/Users/...`.
- Do not manually edit observations to improve results.
- Do not delete duplicate observations without checking why they exist.
- Crossed quotes are flagged and excluded from spread construction.
- Daily spread changes are calculated before High/Low VIX filtering.
- H2 correlations use the same common dates for all eight ETFs within each regime.
- Do not upload WRDS credentials or raw CRSP data to GitHub.
- Report null or opposite findings instead of changing the design after seeing results.

## Main outputs

### H1

- VIX summary statistics
- Relative-spread summary statistics
- High vs Low spread comparison
- Welch t-test and Wilcoxon rank-sum test as exploratory comparisons
- Relative-spread boxplot

### H2

- Low-VIX correlation matrix
- High-VIX correlation matrix
- All 28 ETF pairs
- Average correlation across the 24 cross-asset-class pairs
- Low vs High average-correlation comparison

## AI use

AI may be used for design discussion, R-code support, debugging, and writing refinement.
All AI suggestions must be checked by the student.
No WRDS credentials or raw licensed CRSP data should be shared with AI.
