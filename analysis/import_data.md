Let’s Get the Data
================

I want to use more recent data, especially if I plan to predict
migration flows in the near future, so I have chosen to start with [US
Population Migration
Data](https://www.irs.gov/statistics/soi-tax-stats-migration-data),
which has state inflow and outflow CSVs from 2009-2018. I decided to
remove the .xls files from the unzipped folders because I won’t be using
them. I also had to download the 2017-18 state inflow csv because it
wasn’t included in the zip file for that year.

Should I have time to extend my models to capture global migration, I
plan to use CSV data from [the OECD’s International Migrantion
Database](https://stats.oecd.org/Index.aspx?DataSetCode=MIG), which has
data for the years 2000-2018. I renamed the CSV file
‘OECD\_migration\_data.csv’ in the data file.

(Might switch to doing US counties instead of international migration
actually if I have enough time after getting states working)

``` r
library(tidyverse)
library(here)
```

## Loading the Data

I’ll start by loading the most recent US migration dataset (2017-18) for
state
inflows.

``` r
load_US_1718 <- read.csv(here("data", "1718migrationdata", "stateinflow1718.csv"))
head(load_US_1718)
```

    ##   y2_statefips y1_statefips y1_state                     y1_state_name      n1
    ## 1            1           96       AL AL Total Migration-US and Foreign   47578
    ## 2            1           97       AL             AL Total Migration-US   46908
    ## 3            1           98       AL        AL Total Migration-Foreign     670
    ## 4            1           97       AL     AL Total Migration-Same State   59337
    ## 5            1            1       AL                   AL Non-migrants 1582765
    ## 6            1           13       GA                           Georgia    7914
    ##        n2       AGI
    ## 1   97703   2754842
    ## 2   96089   2714756
    ## 3    1614     40086
    ## 4  119622   2833824
    ## 5 3468405 104423723
    ## 6   16158    404454

And let’s compare it to the 2009-10 state inflow
data.

``` r
load_US_0910 <- read.csv(here("data", "state0910", "stateinflow0910.csv"))
head(load_US_0910)
```

    ##   State_Code_Dest County_Code_Dest State_Code_Origin County_Code_Origin
    ## 1               0                0                96                  0
    ## 2               0                0                97                  0
    ## 3               0                0                98                  0
    ## 4               1                0                96                  0
    ## 5               1                0                97                  0
    ## 6               1                0                98                  0
    ##   State_Abbrv              State_Name Return_Num Exmpt_Num  Aggr_AGI
    ## 1          US US Total Mig - US & For    2920977   5460987 132499511
    ## 2          US       US Total Mig - US    2836418   5282519 128371628
    ## 3          US  US Total Mig - Foreign      84559    178468   4127883
    ## 4          AL AL Total Mig - US & For      42627     89395   1761417
    ## 5          AL       AL Total Mig - US      41700     87143   1718268
    ## 6          AL  AL Total Mig - Foreign        927      2252     43148

We can see that the columns aren’t the same for these two tables. We
also probably want to put all of this information in the same tibble
format for each year so that we can later construct the migration
matrices we want.

``` r
# construct each tibble individually and write them out to files

# function for cleaning and writing after data has been loaded into a standardized format
clean_and_write <- function(data, name) {
  # write out the uncleaned version to be able to compare with cleaned version
  filename <- here("results", "data_cleaning_results", name)
  write.csv(data, file = filename, row.names = FALSE)
  
  # then remove duplicate rows in the tibble
  data <- distinct(data)
  
  # and remove rows that have the totals, not origin-dest pairs
  data <- subset(data, (data$origin_fips != 0 & data$dest_fips != 0))
  data <- subset(data, (data$origin_fips <= 57 & data$dest_fips <= 57))
  
  # and remove rows that count non-migrants (origin and dest states are the same)
  data <- subset(data, (data$origin_fips != data$dest_fips))
  
  # then write cleaned data to a csv
  filename <- here("results", "data_cleaning_results", "clean", name)
  write.csv(data, file = filename, row.names = FALSE)
}

#############################################################################################################
# 2009-2010 data

load_US_in_0910 <- read.csv(here("data", "state0910", "stateinflow0910.csv"))
load_US_out_0910 <- read.csv(here("data", "state0910", "stateoutflow0910.csv"))

# when loading, just ignore the county code column (all zeros)
US_0910 <- tibble(
  origin_fips = c(load_US_in_0910$State_Code_Origin, load_US_out_0910$State_Code_Origin),
  dest_fips = c(load_US_in_0910$State_Code_Dest, load_US_out_0910$State_Code_Dest),
  num_migrants = c(load_US_in_0910$Exmpt_Num, load_US_out_0910$Exmpt_Num)
)

clean_and_write(US_0910, "US_0910.csv")
#############################################################################################################

#############################################################################################################
# 2010-2011 data

load_US_in_1011 <- read.csv(here("data", "state1011", "stateinflow1011.csv"))
load_US_out_1011 <- read.csv(here("data", "state1011", "stateoutflow1011.csv"))

US_1011 <- tibble(
  origin_fips = c(load_US_in_1011$State_Code_Origin, load_US_out_1011$State_Code_Origin),
  dest_fips = c(load_US_in_1011$State_Code_Dest, load_US_out_1011$State_Code_Dest),
  num_migrants = c(load_US_in_1011$Exmpt_Num, load_US_out_1011$Exmpt_Num)
)

clean_and_write(US_1011, "US_1011.csv")
#############################################################################################################

#############################################################################################################
# 2011-2012 data
load_US_in_1112 <- read.csv(here("data", "1112migrationdata", "stateinflow1112.csv"))
load_US_out_1112 <- read.csv(here("data", "1112migrationdata", "stateoutflow1112.csv"))

US_1112 <- tibble(
  origin_fips = c(load_US_in_1112$y1_statefips, load_US_out_1112$y1_statefips),
  dest_fips = c(load_US_in_1112$y2_statefips, load_US_out_1112$y2_statefips),
  num_migrants = c(load_US_in_1112$n2, load_US_out_1112$n2)
)

clean_and_write(US_1112, "US_1112.csv")
#############################################################################################################

#############################################################################################################
# 2012-2013 data
load_US_in_1213 <- read.csv(here("data", "1213migrationdata", "stateinflow1213.csv"))
load_US_out_1213 <- read.csv(here("data", "1213migrationdata", "stateoutflow1213.csv"))

US_1213 <- tibble(
  origin_fips = c(load_US_in_1213$y1_statefips, load_US_out_1213$y1_statefips),
  dest_fips = c(load_US_in_1213$y2_statefips, load_US_out_1213$y2_statefips),
  num_migrants = c(load_US_in_1213$n2, load_US_out_1213$n2)
)

clean_and_write(US_1213, "US_1213.csv")
#############################################################################################################

#############################################################################################################
# 2013-2014 data
load_US_in_1314 <- read.csv(here("data", "1314migrationdata", "stateinflow1314.csv"))
load_US_out_1314 <- read.csv(here("data", "1314migrationdata", "stateoutflow1314.csv"))

US_1314 <- tibble(
  origin_fips = c(load_US_in_1314$y1_statefips, load_US_out_1314$y1_statefips),
  dest_fips = c(load_US_in_1314$y2_statefips, load_US_out_1314$y2_statefips),
  num_migrants = c(load_US_in_1314$n2, load_US_out_1314$n2)
)

clean_and_write(US_1314, "US_1314.csv")
#############################################################################################################

#############################################################################################################
# 2014-2015 data
load_US_in_1415 <- read.csv(here("data", "1415migrationdata", "stateinflow1415.csv"))
load_US_out_1415 <- read.csv(here("data", "1415migrationdata", "stateoutflow1415.csv"))

US_1415 <- tibble(
  origin_fips = c(load_US_in_1415$y1_statefips, load_US_out_1415$y1_statefips),
  dest_fips = c(load_US_in_1415$y2_statefips, load_US_out_1415$y2_statefips),
  num_migrants = c(load_US_in_1415$n2, load_US_out_1415$n2)
)

clean_and_write(US_1415, "US_1415.csv")
#############################################################################################################

#############################################################################################################
# 2015-2016 data
load_US_in_1516 <- read.csv(here("data", "1516migrationdata", "stateinflow1516.csv"))
load_US_out_1516 <- read.csv(here("data", "1516migrationdata", "stateoutflow1516.csv"))

US_1516 <- tibble(
  origin_fips = c(load_US_in_1516$y1_statefips, load_US_out_1516$y1_statefips),
  dest_fips = c(load_US_in_1516$y2_statefips, load_US_out_1516$y2_statefips),
  num_migrants = c(load_US_in_1516$n2, load_US_out_1516$n2)
)

clean_and_write(US_1516, "US_1516.csv")
#############################################################################################################

#############################################################################################################
# 2016-2017 data
load_US_in_1617 <- read.csv(here("data", "1617migrationdata", "stateinflow1617.csv"))
load_US_out_1617 <- read.csv(here("data", "1617migrationdata", "stateoutflow1617.csv"))

US_1617 <- tibble(
  origin_fips = c(load_US_in_1617$y1_statefips, load_US_out_1617$y1_statefips),
  dest_fips = c(load_US_in_1617$y2_statefips, load_US_out_1617$y2_statefips),
  num_migrants = c(load_US_in_1617$n2, load_US_out_1617$n2)
)

clean_and_write(US_1617, "US_1617.csv")
#############################################################################################################

#############################################################################################################
# 2017-2018 data
load_US_in_1718 <- read.csv(here("data", "1718migrationdata", "stateinflow1718.csv"))
load_US_out_1718 <- read.csv(here("data", "1718migrationdata", "stateoutflow1718.csv"))

US_1718 <- tibble(
  origin_fips = c(load_US_in_1718$y1_statefips, load_US_out_1718$y1_statefips),
  dest_fips = c(load_US_in_1718$y2_statefips, load_US_out_1718$y2_statefips),
  num_migrants = c(load_US_in_1718$n2, load_US_out_1718$n2)
)

clean_and_write(US_1718, "US_1718.csv")
#############################################################################################################
```

Let’s also create a tibble for matching state FIPS to state acronyms and
state names.

``` r
# 50 states + DC + foreign
# the data files don't include US territories
states_fips <- tibble(
  fips = c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:57),
  acronym = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", 
              "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", 
              "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", 
              "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", 
              "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", 
              "VT", "VA", "WA", "WV", "WI", "WY", "FR"),
  name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
           "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia",
           "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
           "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
           "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
           "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
           "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
           "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", 
           "Washington", "West Virginia", "Wisconsin", "Wyoming", "Foreign")
)

# write it out to a csv to save it
filename <- here("results", "data_cleaning_results", "states_fips.csv")
write.csv(states_fips, file = filename, row.names = FALSE)
```
