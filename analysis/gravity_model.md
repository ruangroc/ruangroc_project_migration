Gravity Model
================

## Background research

As seen in the image below and as explained in Caleb Robinson and Bistra
Dilkina’s paper, [“A Machine Learning Approach to Modeling Human
Migration”](https://doi.org/10.1145/3209811.3209868), the traditional
migration models can be written as the product of two parts:
\(T_{ij} = G_i * P_{ij}\).

  - \(T_{ij}\) is the number of people moving from every zone i to every
    other zone j
  - \(G_i = \alpha * m_i\) is the production function that estimates
    number of people leaving zone i
      - \(m_i\) is the population of zone i and \(\alpha\) is a
        parameter tuned using historical data
  - \(P_{ij}\) is the probability of a move occurring from i to j
      - Robinson and Dilkina note that the probability of moving from i
        to all other destinations j should sum to
1

<img src="C:/Users/anita/Documents/ST 441/ruangroc_project_migration/documentation/project_notes/Robinson_and_Dilkina_Table_1.PNG" width="75%" />

For now, I’ll be using the alpha value of 0.3 that Robinson and Dilkina
used in their paper to substitute for the beta variables in the gravity
model with power law equation, which is what they appeared to do in
their
[MigrationModels.py](https://github.com/calebrob6/migration-lib/blob/master/MigrationModels.py)
file.

## Create table for distances between states

Before we can run the gravity model, we need to know the distance
between state i and state j for all combinations of (i, j). If we
haven’t already done so, let’s create a table with this information
and write it out to a CSV.

``` r
if (!file.exists(here("results", "distances_between_states.csv"))) {
  create_distance_matrix()
}
```

## Using the gravity model

In
[/R/migration\_models.R](https://github.com/ST541-Fall2020/ruangroc_project_migration/blob/main/R/migration_models.R),
you’ll find a definition for two functions: `gravity_model()` and
`generate_gravity_matrices()`.

  - `gravity_model()` is the function containing all the mathematical
    calculations and returns a migration matrix, \(T_{ij}\).
  - `generate_gravity_matrices()` is the function that calls
    `gravity_model()` for each column (year) of data in the population
    estimates table we created earlier.

This allows us to more efficiently create and write out predicted
migration matrices for each of the years between 2009-2017 so that we
can visualize the differences between the historical data and the
predicted migration flow later
on.

``` r
pop_estimates <- read.csv(here("results", "data_cleaning_results", "population_estimates.csv"))
locations <- read.csv(here("results", "distances_between_states.csv"))
columns <- colnames(pop_estimates)
alpha <- 0.3

# create appropriate results directory if it doesn't already exist
if (!dir.exists(here("results", "gravity_model_results"))) {
  dir.create(here("results", "gravity_model_results"))
}

result <- map(columns, ~ generate_gravity_matrices(., pop_estimates, alpha, locations))
```
