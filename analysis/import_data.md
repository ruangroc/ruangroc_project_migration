Let’s Get the Data
================

## US Migration and Population Data

For historical migration data, I referred to [US Population Migration
Data](https://www.irs.gov/statistics/soi-tax-stats-migration-data),
which has state inflow and outflow CSVs from 2009-2017. I downloaded the
zip files for each of those years (nine in total), though I decided to
remove the .xls files from the unzipped folders because I didn’t use
them. I also had to download the 2017-18 state inflow CSV separately
because it wasn’t included in the zip file for that year.

The population estimates CSV came from [the census.gov
website](https://www.census.gov/newsroom/press-kits/2020/subcounty-estimates.html)
(listed under the Dataset header). I also had to download a CSV for
population estimates from 2000-2009 from
[here](https://www.census.gov/data/tables/time-series/demo/popest/intercensal-2000-2010-state.html).

## 1\. States’ FIPS and locations

First, let’s create a tibble to store some important information about
each state (and Washington DC). Each state has a FIPS number to uniquely
identify them, so I’ve listed them all in the first column and attached
additional information to each row, such as the state acronym, state
name, the largest city in the state, and a latitude and longitude pair
that falls within the largest city.

I decided to add the state acronym and name information for easier
visualization later on. I decided to use the coordinates for the largest
city in each state because it seems likely that is where people who are
migrating into that state would move to.

``` r
states_fips <- tibble(
  fips = c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56),
  acronym = c("AL", "AK", "AZ", "AR", "CA", "CO", 
              "CT", "DE", "DC", "FL", "GA", "HI", 
              "ID", "IL", "IN", "IA", "KS", "KY", 
              "LA", "ME", "MD", "MA", "MI", "MN", 
              "MS", "MO", "MT", "NE", "NV", "NH", 
              "NJ", "NM", "NY", "NC", "ND", "OH", 
              "OK", "OR", "PA", "RI", "SC", "SD", 
              "TN", "TX", "UT", "VT", "VA", "WA", 
              "WV", "WI", "WY"),
  name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
           "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii",
            "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
           "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
           "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
           "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", 
           "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", 
           "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", 
           "West Virginia", "Wisconsin", "Wyoming"),
  largest_city = c("Birmingham", "Anchorage", "Phoenix", "Little Rock", "Los Angeles", "Denver",
                   "Bridgeport", "Wilmington", "Washington", "Jacksonville", "Atlanta", "Honolulu",
                   "Boise", "Chicago", "Indianapolis", "Des Moines", "Wichita", "Louisville",
                   "New orleans", "Portland", "Baltimore", "Boston", "Detroit", "Minneapolis", 
                   "Jackson", "Kansas City", "Billings", "Omaha", "Las Vegas", "Manchester",
                   "Newark", "Albuquerque", "New York City", "Charlotte", "Fargo", "Columbus", 
                   "Oklahoma City", "Portland", "Philadelphia", "Providence", "Charleston", "Sioux Falls", 
                   "Nashville", "Houston", "Salt Lake City", "Burlington", "Virginia Beach", "Seattle", 
                   "Charleston", "Milwaukee", "Cheyenne"),
  latitude = c(33.52, 61.22, 33.45, 34.75, 34.05, 39.74, 
               41.18, 39.74, 38.89, 30.33, 33.75, 21.30, 
               43.62, 41.88, 39.77, 41.58, 37.69, 38.21,
               29.98, 43.68, 39.31, 42.33, 42.36, 44.98,
               32.31, 39.03, 45.79, 41.26, 36.17, 42.99,
               40.74, 35.10, 40.67, 35.21, 46.89, 39.96,
               35.52, 45.52, 39.96, 41.82, 32.79, 43.54,
               36.15, 29.73, 40.77, 44.47, 36.81, 47.60,
               38.35, 43.04, 41.13),
  longitude = c(-86.81, -149.90, -112.07, -92.29, -118.24, -104.99, 
                -73.19, -75.55, -77.03, -81.66, -84.39, -157.86,
                -116.20, -87.63, -86.15, -93.61, -97.33, -85.65,
                -90.03, -70.30, -76.62, -71.08, -83.08, -93.27,
                -90.20, -94.56, -108.52, -96.02, -115.19, -71.45,
                -74.18, -106.66, -73.98, -80.84, -96.81, -82.99,
                -97.50, -122.67, -75.15, -71.41, -79.94, -96.73,
                -86.77, -95.39, -111.89, -73.21, -76.12, -122.33,
                -81.63, -87.91, -104.82)
)

# create the appropriate file structure if not already created
if (!dir.exists(here("results"))) {
  dir.create(here("results"))
}
if (!dir.exists(here("results", "data_cleaning_results"))) {
  dir.create(here("results", "data_cleaning_results"))
}

# write it out to a csv to save it
filename <- here("results", "data_cleaning_results", "states_fips.csv")
write.csv(states_fips, file = filename, row.names = FALSE)
```

## 2\. Annual population estimates

Now we’ll construct a table to hold all of the population estimates for
the years 2009 through 2017. The estimates are listed in order of
states’ FIPS, which makes it easy to copy over from the 2010-2019 CSV
file. However, I had to copy-paste the values by hand from the 2009
column of data in the Excel
file.

``` r
# Load the csv containing population estimates for each state for the years 2010 thru 2019
decade_2010s <- read.csv(here("data", "ACStables", "sub-est2019_all.csv"))
decade_2010s <- subset(decade_2010s, SUMLEV == 40)

# then load them in the population estimates tibble, with the exception
# of the 2009 year which is loaded in manually with data from an Excel sheet
pop_estimates <- tibble(
  fips = c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56),
  year_2009 = c(4757938, 698895, 6343154, 2896843, 36961229, 4972195, 
                3561807, 891730, 592228, 18652644, 9620846, 1346717, 
                1554439, 12796778, 6459325, 3032870, 2832704, 4317074, 
                4491648, 1329590, 5730388, 6517613, 9901591, 5281203, 
                2958774, 5961088, 983982, 1812683, 2684665, 1316102, 
                8755602, 2036802, 19307066, 9449566, 664968, 11528896, 
                3717572, 3808600, 12666858, 1053646, 4589872, 807067, 
                6306019, 24801761, 2723421, 624817, 7925937, 6667426, 
                1847775, 5669264, 559851),
  year_2010 = decade_2010s$POPESTIMATE2010,
  year_2011 = decade_2010s$POPESTIMATE2011,
  year_2012 = decade_2010s$POPESTIMATE2012,
  year_2013 = decade_2010s$POPESTIMATE2013,
  year_2014 = decade_2010s$POPESTIMATE2014,
  year_2015 = decade_2010s$POPESTIMATE2015,
  year_2016 = decade_2010s$POPESTIMATE2016,
  year_2017 = decade_2010s$POPESTIMATE2017,
)

# write it out to a csv to save it
if (!dir.exists(here("results", "data_cleaning_results"))) {
  dir.create(here("results", "data_cleaning_results"))
}
filename <- here("results", "data_cleaning_results", "population_estimates.csv")
write.csv(pop_estimates, file = filename, row.names = FALSE)
```

## 3\. Historical migration data

So a big problem I noticed when I started looking through the migration
data files was that the format of the data differed based on the year.

For example, the most recent US migration dataset (2017-18) for state
inflows looks
like:

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

Whereas the 2009-10 state inflow data looks
like:

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

The columns aren’t the same for these two tables, which can make it
tricky to work with later. This is why I decided to put all of the data
into a standard format containing only the information I need:
origin\_fips, dest\_fips, and num\_migrants.

Below, you’ll see that I loaded in the inflow and outflow files and
manually construct a tibble for each year of migration data because the
file names and column names differed between datasets. Then I used the
`clean_and_write()` function I wrote to remove duplicate and invalid
entries (e.g. negative number of
migrants).

``` r
pop_estimates <- read.csv(here("results", "data_cleaning_results", "population_estimates.csv"))

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
