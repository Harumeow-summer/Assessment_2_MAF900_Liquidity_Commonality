# Step-by-Step RStudio Workflow

## Step 1 — Open the RStudio project

Open:

`MAF900_Liquidity_Commonality.Rproj`

Using the RStudio project keeps all file paths relative to the project folder.

Do not use `setwd()`.

## Step 2 — Install the required packages once

Run this once in the RStudio Console:

```r
install.packages(c(
  "tidyverse",
  "DBI",
  "here",
  "RPostgres",
  "knitr",
  "rmarkdown",
  "renv"
))
```

## Step 3 — Enter your WRDS username

Open:

- `R/01_collect_crsp.R`
- `R/optional_check_permno.R`

Find:

```r
user = "YOUR_WRDS_USERNAME"
```

Replace the placeholder with your own WRDS username.

Do not write your WRDS password into the script.

## Step 4 — Collect CRSP data

Run:

```r
source("R/01_collect_crsp.R")
```

The eight verified PERMNO values are already stored in:

`config/etf_permnos.csv`

The assessor does not need to enter them manually.

Expected local output:

`data/raw/crsp_daily.rds`

Also check the CRSP coverage file saved in `logs/`.

## Step 5 — Collect VIX data

Run:

```r
source("R/02_collect_vix.R")
```

Expected local output:

`data/raw/vix_daily.rds`

Also check the VIX coverage file saved in `logs/`.

## Step 6 — Clean and merge the data

Run:

```r
source("R/03_clean_merge.R")
```

This script:

- checks duplicate PERMNO-date observations;
- flags missing quotes;
- flags crossed quotes where Ask < Bid;
- does not manually correct invalid quotes;
- merges CRSP and VIX by trading date;
- records unmatched VIX dates.

Expected output:

`data/processed/merged_data.rds`

## Step 7 — Construct the research variables

Run:

```r
source("R/04_construct_variables.R")
```

This script constructs:

- midpoint;
- relative bid-ask spread;
- VIX quartile regimes;
- daily change in relative spread.

Important H2 rule:

Daily spread changes are calculated before the data are filtered into High- and Low-VIX regimes.

## Step 8 — Generate tables

Run:

```r
source("R/05_make_tables.R")
```

The script generates summary statistics, H1 comparison tables, H2 correlation matrices, and the cross-asset correlation summary.

## Step 9 — Generate figures

Run:

```r
source("R/06_make_figures.R")
```

The script generates:

- the High- versus Low-VIX spread boxplot;
- the Low-VIX correlation heatmap;
- the High-VIX correlation heatmap.

## Optional — Verify the PERMNO mapping

The repository already contains the verified PERMNO values, so this step is not required.

If you want to audit the mapping, run:

```r
source("R/optional_check_permno.R")
```

It writes the ticker/PERMNO candidates to the `logs/` folder.

## Step 10 — Record package versions before submission

After the project runs correctly:

```r
renv::init()
renv::snapshot()
```

Commit the generated `renv.lock`.

## Step 11 — Check GitHub before pushing

Run:

```bash
git status
```

Make sure that no WRDS credentials, raw CRSP files, or processed CRSP-derived data are staged.

Then commit the code and documentation.
