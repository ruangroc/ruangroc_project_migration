library(here)
library(tidyverse)

pop_estimates <- read.csv(here("ruangroc_project_migration", "results", "data_cleaning_results", "population_estimates.csv"))
locations <- read.csv(here("ruangroc_project_migration", "results", "distances_between_states.csv"))

### Gravity Models ###

g_verified_2017 <- as.matrix(read.csv(here("ruangroc_project_migration", "results", "gravity_model_results", "alpha_0.3_year_2017.csv")))
colnames(g_verified_2017) <- pop_estimates$fips

test_that("gravity model same lengths", {
  expect_equal(length(g_verified_2017), length(as.matrix(gravity_model(pop_estimates$year_2017, pop_estimates$fips, 0.3, locations))))
})

test_that("gravity model same values", {
  expect_equal(g_verified_2017, gravity_model(pop_estimates$year_2017, pop_estimates$fips, 0.3, locations))
})


### Radiation Models ###

r_verified_2017 <- as.matrix(read.csv(here("ruangroc_project_migration", "results", "radiation_model_results", "alpha_0.3_year_2017.csv")))
s_ij_2017 <- here("ruangroc_project_migration", "results", "radiation_model_results", "intervening_opportunities_year_2017.csv")
colnames(r_verified_2017) <- pop_estimates$fips

test_that("radiation model same lengths", {
  expect_equal(length(r_verified_2017), length(as.matrix(radiation_model(pop_estimates$year_2017, s_ij_2017, pop_estimates$fips, 0.3))))
})

test_that("radiation model same values", {
  expect_equal(r_verified_2017, radiation_model(pop_estimates$year_2017, s_ij_2017, pop_estimates$fips, 0.3))
})
