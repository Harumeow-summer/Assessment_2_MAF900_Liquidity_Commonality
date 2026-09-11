# Data Dictionary

| Variable | Meaning | Source / construction |
|---|---|---|
| `etf` | Project ETF label | config file |
| `asset_class` | Equity, Treasury, Corporate credit, or Precious metals | config file |
| `permno` | Stable CRSP security identifier | CRSP / verified config |
| `date` | Trading date | CRSP / FRED |
| `source_ticker` | Ticker recorded by CRSP | CRSP |
| `bid` | Raw closing bid | CRSP `dlybid` |
| `ask` | Raw closing ask | CRSP `dlyask` |
| `missing_quote` | Bid or ask is missing | cleaning code |
| `crossed_quote` | Ask is lower than bid | cleaning code |
| `bid_clean` | Bid retained only when quote is usable | cleaning code |
| `ask_clean` | Ask retained only when quote is usable | cleaning code |
| `vix` | Daily VIX close | FRED `VIXCLS` |
| `midpoint` | Average of cleaned bid and ask | `(bid_clean + ask_clean)/2` |
| `relative_spread` | Main liquidity measure | `(ask_clean - bid_clean)/midpoint` |
| `vix_regime` | Low, Middle, or High volatility | VIX quartiles |
| `delta_spread` | Daily change in relative spread | `spread_t - spread_t-1` within ETF |

## H2 rule

`delta_spread` is calculated before the data are filtered into High and Low VIX regimes.
Within each regime, the correlation matrix uses only dates where all eight ETFs have a non-missing `delta_spread`.
