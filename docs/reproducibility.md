# Reproducibility Notes

## What reproducibility means in this project

Another researcher with authorised WRDS access should be able to follow the numbered scripts and recreate the analysis data, tables, and figures.

## Main reproducibility risks and controls

| Risk | Control |
|---|---|
| CRSP is licensed | Share code and access instructions, not raw CRSP data |
| WRDS credentials | Ask for credentials when code runs; never save them in GitHub |
| Ticker changes | Verify and then use PERMNO |
| Duplicate ETF-date rows | Stop and inspect rather than silently deleting them |
| Missing or crossed quotes | Apply the same coded rule every time |
| Wrong lag after filtering | Calculate daily spread change before VIX regime filtering |
| Different correlation samples | Use common non-missing dates for all eight ETFs |
| Hard-coded paths | Use the RStudio project and `here()` |
| Manual edits | Generate cleaning, tables, and figures through code |
| Package changes | Record package versions before final submission |

## Package versions

After the full project works, `renv` can be used to record package versions:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

The generated `renv.lock` can then be committed to GitHub.
