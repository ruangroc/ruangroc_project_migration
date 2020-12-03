library(here)
library(tidyverse)

hist_2015 <- read.csv(here("ruangroc_project_migration", "results", "data_cleaning_results", "clean", "US_1516.csv"))
grav_2015 <- as.matrix(read.csv(here("ruangroc_project_migration", "results", "gravity_model_results", "alpha_0.3_year_2015.csv")), nrow = 51, ncol = 51)
hist_matrix_2015 <- create_historical_matrix(hist_2015)
hist_2017 <- read.csv(here("ruangroc_project_migration", "results", "data_cleaning_results", "clean", "US_1718.csv"))

test_that("create historical matrix lengths", {
  expect_equal(length(create_historical_matrix(hist_2017)), 51*51)
})

test_that("gravity heatmap", {
  expect_type(gravity_heatmap(grav_2015, hist_matrix_2015, "2015"), "list")
})