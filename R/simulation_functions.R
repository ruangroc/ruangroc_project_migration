#' Run the gravity model and return the sum of squared residuals
#' (used in combination with optimize() to find the most appropriate alpha value)
#'
#' @param alpha = hyperparameter used in calculations
#' @param year_data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param hist_data_file = string, path to the appropriate csv containing historical data on the recorded number of migrants
#' @param locations = tibble containing distances between each (i, j) state combination
#'
#' @return = the sum of squared residuals (residual = recorded num_migrants - gravity model prediction)
#' @export
#'
#' @examples
run_gravity_model <- function(alpha, year_data, hist_data_file, locations) {
  fips <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  T_ij <- gravity_model(year_data, fips, alpha, locations)
  
  compare = compare <- tibble(
    origin = rep(fips, each = 51),
    dest = rep(fips, times = 51),
    gravity = as.vector(t(T_ij)),
  )
  
  historical <- read.csv(hist_data_file)
  historical <- rename(historical, origin = origin_fips, dest = dest_fips)
  
  compare <- left_join(compare, subset(historical, select = c(num_migrants, origin, dest)), by = c("origin", "dest"))
  compare <- subset(compare, origin != dest)
  compare <- subset(compare, is.finite(num_migrants))
  
  compare <- compare %>% mutate(
    gravity_residuals = num_migrants - gravity
  )
  
  sum_sq_res <- sum(compare$gravity_residuals^2)
  return(as.double(sum_sq_res))
}


#' Run the gravity model and return the estimated population for the following year
#'
#' @param pop_data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param year = the specific year of data which will be used in the name of the resulting csv file
#' @param gravity_alpha = historically tuned hyperparameter value
#' @param locations = tibble containing distances between each (i, j) state combination
#'
#' @return = a vector containing predicted population estimates for the following year given the gravity model's prediction
#' @export
#'
#' @examples
get_gravity_prediction <- function(pop_data, year, gravity_alpha, locations) {
  fips <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  mig_matrix <- gravity_model(pop_data, fips, gravity_alpha, locations)
  diag(mig_matrix) <- 0
  
  filename <- here("results", "simulation_results", paste("gravity_", as.character(year), ".csv", sep = ''))
  write.csv(mig_matrix, filename, row.names = FALSE)
  
  # sum up the values in each destination column and add to population estimates to serve as next year's baseline
  column_sums <- colSums(mig_matrix)
  new_pop_data <- pop_data + column_sums
  return(new_pop_data)
}

##############################################################################################

#' Run the gravity model and return the sum of squared residuals
#' (used in combination with optimize() to find the most appropriate alpha value)
#'
#' @param alpha = hyperparameter used in calculations
#' @param year_data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param S_ij_file = string, path to where appropriate intervening opportunities csv can be found
#' @param hist_data_file = string, path to the appropriate csv containing historical data on the recorded number of migrants
#'
#' @return = the sum of squared residuals (residual = recorded num_migrants - radiation model prediction)
#' @export
#'
#' @examples
run_radiation_model <- function(alpha, year_data, S_ij_file, hist_data_file) {
  fips <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  T_ij <- radiation_model(year_data, S_ij_file, fips, alpha)
  
  compare = compare <- tibble(
    origin = rep(fips, each = 51),
    dest = rep(fips, times = 51),
    radiation = as.vector(t(T_ij)),
  )
  
  historical <- read.csv(hist_data_file)
  historical <- rename(historical, origin = origin_fips, dest = dest_fips)
  
  compare <- left_join(compare, subset(historical, select = c(num_migrants, origin, dest)), by = c("origin", "dest"))
  compare <- subset(compare, origin != dest)
  compare <- subset(compare, is.finite(num_migrants))
  
  compare <- compare %>% mutate(
    radiation_residuals = num_migrants - radiation
  )
  
  sum_sq_res <- sum(compare$radiation_residuals^2)
  return(as.double(sum_sq_res))
}


#' Run the radiation model and return the estimated population for the following year
#'
#' @param pop_data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param s_ij_file = string, path to where appropriate intervening opportunities csv can be found
#' @param new_s_ij_file = string, name to use for a newly calculated intervening opportunities csv file
#' @param year = the specific year of data which will be used in the name of the resulting radiation matrix csv file
#' @param radiation_alpha = historically tuned hyperparameter value
#'
#' @return = a vector containing predicted population estimates for the following year given the radiation model's prediction
#' @export
#'
#' @examples
get_radiation_prediction <- function(pop_data, s_ij_file, new_s_ij_file, year, radiation_alpha) {
  locations <- read.csv(here("results", "distances_between_states.csv"))
  fips <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  mig_matrix <- radiation_model(pop_data, S_ij_file, fips, radiation_alpha)
  diag(mig_matrix) <- 0
  
  filename <- here("results", "simulation_results", paste("radiation_", as.character(year), ".csv", sep = ''))
  write.csv(mig_matrix, filename, row.names = FALSE)
  
  column_sums <- colSums(mig_matrix)
  new_pop_data <- pop_data + column_sums
  
  get_intervening_opps(locations, new_pop_data, fips, new_s_ij_file)
  return(new_pop_data)
}


#' Graph predicted population change 2018-2022
#'
#' @param pop_over_time = tibble containing predicted population counts for all states for 2018-2022
#' @param state_name = the name of the state you want to see the population change graph for
#' @param model = name of the model you used (Gravity of Radiation)
#'
#' @return = ggplot line graph of predicted population change in the state between 2018-2022
#' @export
#'
#' @examples
graph_population_change <- function(pop_over_time, state_name, model) {
  one_state <- tibble(
    year = c(2017, 2018, 2019, 2020, 2021, 2022),
    population = as.numeric(filter(pop_over_time, state == state_name) %>% select("year_2017", "year_2018", "year_2019", "year_2020", "year_2021", "year_2022"))
  )
  
  ggplot(data=one_state, aes(x=year, y=population)) +
    geom_line(color = "midnightblue") +
    geom_point() +
    labs(title = paste(model, "Model Predicted Population Change in", state_name, "2018-2022"))
}