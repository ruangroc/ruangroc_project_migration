library(here)
library(tidyverse)

pop_estimates <- read.csv(here("ruangroc_project_migration", "results", "data_cleaning_results", "population_estimates.csv"))
locations <- read.csv(here("ruangroc_project_migration", "results", "distances_between_states.csv"))

hist_data_file <- here("ruangroc_project_migration","results", "data_cleaning_results", "clean", "US_1718.csv")
S_ij_file <- here("ruangroc_project_migration","results", "radiation_model_results", "intervening_opportunities_year_2017.csv")

test_that("run_gravity_model returns sum squared residuals", {
  expect_type(run_gravity_model(0.15, pop_estimates$year_2017, hist_data_file, locations), "double")
})

test_that("run_radiation_model returns sum squared residuals", {
  expect_type(run_radiation_model(0.15, pop_estimates$year_2017, S_ij_file, hist_data_file), "double")
})

