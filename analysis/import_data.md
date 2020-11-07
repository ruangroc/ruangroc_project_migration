Let’s Get the Data
================

I want to use more recent data, especially if I plan to predict
migration flows in the near future, so I have chosen to start with [US
Population Migration
Data](https://www.irs.gov/statistics/soi-tax-stats-migration-data),
which has data from 1990-2018, and [the UN’s Department of Economic and
Social Affairs’ International Migrant
Stock 2019](https://www.un.org/en/development/desa/population/migration/data/estimates2/estimates19.asp),
which has data for the years 1990, 1995, 2000, 2005, 2010, 2015 and
2019.

``` r
library(tidyverse)
library(here)
#devtools::load_all()
```
