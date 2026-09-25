# Query spec — Salt Lake County, closing time, three years

**Source:** Utah's public crash data (Utah DPS / UDOT crash portal; FARS for fatal only). Public; no login.

| Filter | Value |
|---|---|
| County | Salt Lake (then Tooele for the rural proof) |
| Years | last three complete years |
| Days | Friday, Saturday, Sunday |
| Hours | 00:00–03:00 (closing window; the state's own peak runs 18:00–01:00 — pull both) |
| Alcohol flag | driver alcohol-involved (any positive), and ≥.05 separately |
| Outputs | crashes · injury crashes · fatal crashes · DUI arrests (from the Commission on Criminal and Juvenile Justice, by county) |

**Deliverable:** one table, county × year × window. This is the *baseline* row of the measurement contract. Save it here as `baseline.csv`.
