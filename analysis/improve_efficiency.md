Improve Efficiency
================

# Improve efficiency of iterating over multiple datasets

When I first started this project, I didn’t know how to iterate over the
columns of the population estimates tibble, which resulted in me
manually selecting column names using the `$` operator in order to call
`gravity_model()`, `radiation_model()`, or `get_intervening_opps()` for
each year of data I wanted to compare to historical data (2009-2017).

Homework 9 provided the option of making something more efficient in my
project so I took that opportunity to learn how to make the repetitive
calls to `gravity_model()`, `radiation_model()`, and
`get_intervening_opps()` more efficient. I specifically focused on the
calls to `get_intervening_opps()` (as shown below) but the approach
holds for `gravity_model()` and `radiation_model()` as well.

### Original approach for generating S\_ij for each year of data I have

This approach required me to manually copy-paste the call to
`get_intervening_opps()` for every year of migration data I have
(2009-2017).

``` r
pop_estimates <- read.csv(here("results", "data_cleaning_results", "population_estimates.csv"))
locations <- read.csv(here("results", "distances_between_states.csv"))

if (!dir.exists(here("results", "improve_efficiency"))) {
  dir.create(here("results", "improve_efficiency"))
}

get_intervening_opps(locations, pop_estimates$year_2009, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2009_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2010, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2010_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2011, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2011_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2012, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2012_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2013, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2013_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2014, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2014_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2015, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2015_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2016, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2016_manual.csv"))

get_intervening_opps(locations, pop_estimates$year_2017, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2017_manual.csv"))
```

### More efficient approach

After a little more tinkering and after finding the `unlist()` function,
I managed to pass in columns of my population estimates tibble and wrap
the repeated `get_intervening_opps()` calls into a `map()` call. This
code still requires the use of a for loop basically but I can’t think of
a way to vectorize this right now.

At the very least, I’ve removed some potential for human error by
automating the calls for generating these intervening\_opportunities
files.

``` r
pop_estimates <- read.csv(here("results", "data_cleaning_results", "population_estimates.csv"))
locations <- read.csv(here("results", "distances_between_states.csv"))
columns <- colnames(pop_estimates)

generate_int_opp_files <- function(col_name, data, locations) {
  if (col_name != "fips") {
    filename <- here("results", "improve_efficiency", paste("intervening_opportunities_", col_name, ".csv", sep=''))
    get_intervening_opps(locations, unlist(subset(data, select = col_name)), unlist(data %>% select("fips")), filename)
  }
}

result <- map(columns, ~ generate_int_opp_files(., pop_estimates, locations))
```

This small timing test also showed that using the `subset()` function
would be faster, helping to improve the efficiency of using a function
like this even more.

``` r
timing <- bench::mark(
  unlist(pop_estimates %>% select("year_2009")),
  unlist(subset(pop_estimates, select = "year_2009"))
)
timing
```

    ## # A tibble: 2 x 6
    ##   expression                                              min  median `itr/sec`
    ##   <bch:expr>                                          <bch:t> <bch:t>     <dbl>
    ## 1 unlist(pop_estimates %>% select("year_2009"))        1.17ms  1.49ms      580.
    ## 2 unlist(subset(pop_estimates, select = "year_2009"))  65.8us    77us    10601.
    ## # ... with 2 more variables: mem_alloc <bch:byt>, `gc/sec` <dbl>

### Timing tests

``` r
pop_estimates <- read.csv(here("results", "data_cleaning_results", "population_estimates.csv"))
locations <- read.csv(here("results", "distances_between_states.csv"))

timing <- bench::mark(
  manual_calls = {
    
    get_intervening_opps(locations, pop_estimates$year_2009, pop_estimates$fips, 
                     here("results", "improve_efficiency", "intervening_opportunities_2009_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2010, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2010_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2011, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2011_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2012, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2012_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2013, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2013_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2014, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2014_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2015, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2015_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2016, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2016_manual.csv"))
    get_intervening_opps(locations, pop_estimates$year_2017, pop_estimates$fips, 
                         here("results", "improve_efficiency", "intervening_opportunities_2017_manual.csv"))
  },
  automated_calls = {
    columns <- colnames(pop_estimates)
    result <- map(columns, ~ generate_int_opp_files(., pop_estimates, locations))
  },
  check = FALSE
)
timing
```

    ## # A tibble: 2 x 6
    ##   expression           min   median `itr/sec` mem_alloc `gc/sec`
    ##   <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    ## 1 manual_calls       277ms    312ms      3.21    54.8MB     4.81
    ## 2 automated_calls    353ms    387ms      2.59    56.5MB     3.88

The automated loop sometimes takes more time to complete (hard to tell
when timing shows only one iteration in the timing results), but it
allowed for less human error and still produced the same results as the
original
approach.

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2009_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2009.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2010_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2010.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2011_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2011.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2012_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2012.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2013_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2013.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2014_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2014.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2015_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2015.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2016_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2016.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE

``` r
matrix1 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_2017_manual.csv"))
matrix2 <- read.csv(here("results", "improve_efficiency", "intervening_opportunities_year_2017.csv"))
all.equal(matrix1, matrix2)
```

    ## [1] TRUE
