#' Create tibble containing distances between states i and j for all combinations of (i, j)
#'
#' @return = no return value
#' @export
#'
#' @examples
create_distance_matrix <- function() {
  states_fips <- read.csv(here("results", "data_cleaning_results", "states_fips.csv"))
  
  locations <- tibble(
    origin = rep(states_fips$fips, each = 51),
    origin_lon = rep(states_fips$longitude, each = 51),
    origin_lat = rep(states_fips$latitude, each = 51),
    dest = rep(states_fips$fips, times = 51),
    dest_lon = rep(states_fips$longitude, times = 51),
    dest_lat = rep(states_fips$latitude, times = 51)
  )
  
  locations <- locations %>% mutate(
    distance = pmap_dbl(list(origin_lon, origin_lat, dest_lon, dest_lat, units = "miles"), gdist)
  )
  
  filename <- here("results", "distances_between_states.csv")
  write.csv(locations, file = filename, row.names = FALSE)
}


#' Gravity model to produce a migration matrix (a prediction)
#'
#' @param data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param names = list of states' FIPS id
#' @param alpha = hyperparameter used in calculations (can be fine tuned using historical data)
#' @param locations = tibble containing distances between each (i, j) state combination
#'
#' @return = migration matrix with values estimating number of migrants from states i to j for all combinations of (i, j)
#' @export
#'
#' @examples
gravity_model <- function(data, names, alpha, locations) {
  
  # load population estimates for each state for the given year
  m_i <- matrix(rep(data, times = 51), nrow = 51, ncol = 51)
  colnames(m_i) <- names
  m_j <- matrix(rep(data, times = 51), nrow = 51, ncol = 51, byrow = TRUE)
  rownames(m_j) <- names
  
  # it was filling with negative values for some reason, hence the negative locations$distance
  distances <-- matrix(-locations$distance, nrow = 51, ncol = 51, byrow = TRUE)
  colnames(distances) <- names
  rownames(distances) <- names
  
  d_alpha <- distances^(-alpha)
  d_alpha[!is.finite(d_alpha)] <- 0
  
  G_i <- alpha * m_i
  
  part1 <- d_alpha * m_j
  numerator <- m_i * part1
  numerator[!is.finite(numerator)] <- 0
  
  denom <- matrix(rep(rowSums(part1), times = 51), nrow = 51, ncol = 51)
  
  P_ij <- numerator / denom
  
  normalize <- matrix(rep(rowSums(P_ij), times = 51), nrow = 51, ncol = 51)
  P_ij <- P_ij / normalize
  
  T_ij <- G_i * P_ij
  T_ij[T_ij < 0] <- 0
  
  return(T_ij)
}


#' Generate a gravity model migration matrix for each column in the population estimates tibble
#' (used in combination with map() for more efficient file generation)
#'
#' @param col_name = string, name of a column in the population estimates tibble (ex: "year_2009")
#' @param data = the population estimates tibble (pop_estimates)
#' @param alpha = hyperparameter used in calculations (can be fine tuned using historical data)
#' @param locations = tibble containing distances between each (i, j) state combination
#'
#' @return = a list of migration matrices calculated for each column of data in pop_estimates
#' @export
#'
#' @examples
generate_gravity_matrices <- function(col_name, data, alpha, locations) {
  if (col_name != "fips") {
    T_ij <- gravity_model(unlist(subset(data, select = col_name)), unlist(subset(data, select = "fips")), alpha, locations)
    gravity_filename <- here("results", "gravity_model_results", paste("alpha_", as.character(alpha), "_", col_name, ".csv", sep=''))
    write.csv(T_ij, gravity_filename, row.names = FALSE)
    return(T_ij)
  }
}


##############################################################################################

#' Calculate an intervening opportunities matrix and write it out as a csv
#'
#' @param locations = tibble containing distances between each (i, j) state combination
#' @param year_data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param fips = list of states' FIPS id
#' @param filename = filename to use when writing data out to a csv
#'
#' @return = no return value
#' @export
#'
#' @examples
get_intervening_opps <- function(locations, year_data, fips, filename) {
  
  # pair distances and population estimates together in a tibble
  all_data <- locations %>% mutate(
    pop = rep(year_data, times = 51)
  )
  all_data <- all_data %>% select(origin, dest, distance, pop)
  all_data <- arrange(all_data, origin, distance)
  
  # calculate cumulative sums of populations in intervening zones for each i (origin state)
  results <- map(fips, ~ c(0, cumsum(subset(all_data, origin == . & dest != 1)$pop)))
  all_data <- all_data %>% mutate(
    sums = unlist(results, recursive = FALSE)
  )
  
  # rearrange the tibble to be in matrix order again, then store sum results as S_ij
  all_data <- arrange(all_data, origin, dest)
  S_ij <- matrix(as.vector(all_data$sums), nrow = 51, ncol = 51)
  colnames(S_ij) <- fips
  rownames(S_ij) <- fips
  
  write.csv(S_ij, filename, row.names = FALSE)
}


#' Generate intervening opportunity files
#'
#' @param col_name = string, name of a column in the population estimates tibble (ex: "year_2009")
#' @param data = the population estimates tibble (pop_estimates)
#' @param locations = tibble containing distances between each (i, j) state combination
#'
#' @return = no return value
#' @export
#'
#' @examples
generate_int_opp_files <- function(col_name, data, locations) {
  if (col_name != "fips") {
    filename <- here("results", "radiation_model_results", paste("intervening_opportunities_", col_name, ".csv", sep=''))
    get_intervening_opps(locations, unlist(subset(data, select = col_name)), unlist(data %>% select("fips")), filename)
  }
}


#' Radiation model to produce a migration matrix (a prediction)
#'
#' @param pop_data = a vector containing population estimates for each state for a specific year (states listed in fips order)
#' @param intervening_data = string, path to where appropriate intervening opportunities csv can be found
#' @param names = a list of states' FIPS id
#' @param alpha = hyperparameter used in calculations (can be fine tuned using historical data)
#'
#' @return = migration matrix with values estimating number of migrants from states i to j for all combinations of (i, j)
#' @export
#'
#' @examples
radiation_model <- function(pop_data, intervening_data, names, alpha) {
  
  # load population estimates for each state for the given year
  m_i <- matrix(rep(pop_data, times = 51), nrow = 51, ncol = 51)
  colnames(m_i) <- names
  m_j <- matrix(rep(pop_data, times = 51), nrow = 51, ncol = 51, byrow = TRUE)
  rownames(m_j) <- names
  
  S_ij <- as.matrix(read.csv(intervening_data), nrow = 51, ncol = 51)
  
  G_i <- alpha * m_i
  
  # Calculate P_ij in parts (have to handle computation with very large numbers)
  num <- matrix(as.double(Rmpfr::mpfr(m_i, precBits = 4) * Rmpfr::mpfr(m_j, precBits = 4)), nrow = 51, ncol = 51)
  
  denom1 <- as.matrix(m_i + S_ij)
  denom2 <- as.matrix(m_i + m_j + S_ij)
  denom <- (Rmpfr::mpfr(denom1, precBits = 4) * Rmpfr::mpfr(denom2, precBits = 4))
  d <- matrix(as.double(denom), nrow = 51, ncol = 51)
  
  
  P_ij <- num / d
  normalize <- matrix(rep(rowSums(P_ij), times = 51), nrow = 51, ncol = 51)
  P_ij <- P_ij / normalize
  
  # Then calculate the migration matrix T_ij
  T_ij <- round(G_i * P_ij, 4)
  return(T_ij)
}


#' Generate a radiation model migration matrix for each column in the population estimates tibble
#' (used in combination with map() for more efficient file generation)
#'
#' @param col_name = string, name of a column in the population estimates tibble (ex: "year_2009")
#' @param data = the population estimates tibble (pop_estimates)
#' @param alpha = hyperparameter used in calculations (can be fine tuned using historical data)
#'
#' @return = a list of migration matrices calculated for each column of data in pop_estimates
#' @export
#'
#' @examples
generate_radiation_matrices <- function(col_name, data, alpha) {
  if (col_name != "fips") {
    S_ij_file <- here("results", "radiation_model_results", paste("intervening_opportunities_", col_name, ".csv", sep=''))
    T_ij <- radiation_model(unlist(subset(data, select = col_name)), S_ij_file, unlist(subset(data, select = "fips")), alpha)
    radiation_filename <- here("results", "radiation_model_results", paste("alpha_", as.character(alpha), "_", col_name, ".csv", sep=''))
    write.csv(T_ij, radiation_filename, row.names = FALSE)
    return(T_ij)
  }
}