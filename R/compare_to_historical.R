#' Create matrix from the historical data
#'
#' @param hist_data = tibble containing historical data
#'
#' @return = 51x51 matrix of historical data
#' @export
#'
#' @examples
create_historical_matrix <- function(hist_data) {
  fips <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  # make sure all 51x51 matrix combinations are accounted for
  # even if they aren't in the historical dataset
  hist_matrix <- tibble(
    origin_fips = rep(fips, each = 51),
    dest_fips = rep(fips, times = 51)
  )
  hist_matrix <- left_join(hist_matrix, hist_data, by = c("origin_fips", "dest_fips"))
  
  # create a matrix out of the historical data
  hist_matrix <- matrix(hist_matrix$num_migrants, nrow = 51, ncol = 51, byrow = TRUE)
  diag(hist_matrix) <- 0
  
  return(hist_matrix)
}


#' Create gravity model residuals heatmap
#'
#' @param grav_matrix = 51x51 gravity model migration matrix
#' @param hist_matrix = 51x51 historical data matrix
#' @param year = string, year to label the heatmap
#'
#' @return = ggplot visual of a heatmap
#' @export
#'
#' @examples
gravity_heatmap <- function(grav_matrix, hist_matrix, year) {
  diag(grav_matrix) <- 0
  
  # compute residuals
  residuals <- hist_matrix - grav_matrix
  
  # set invalid values to 0
  residuals[!is.finite(residuals)] <- 0
  
  # make sure column names are states' fips
  colnames(residuals) <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  data_melt <- reshape::melt.array(residuals)
  ggp <- ggplot(data_melt, aes(X1, X2)) + geom_tile(aes(fill = value))
  ggp + scale_fill_gradient(low = "dodgerblue", high = "darkseagreen2") 
}


#' Create radiation model residuals heatmap
#'
#' @param rad_matrix = 51x51 radiation model migration matrix
#' @param hist_matrix = 51x51 historical data matrix
#' @param year = string, year to label the heatmap
#'
#' @return = ggplot visual of a heatmap
#' @export
#'
#' @examples
radiation_heatmap <- function(rad_matrix, hist_matrix, year) {
  diag(rad_matrix) <- 0
  
  # compute residuals
  residuals <- hist_matrix - rad_matrix
  
  # set invalid values to 0
  residuals[!is.finite(residuals)] <- 0
  
  # make sure column names are states' fips
  colnames(residuals) <- c(1, 2, 4, 5, 6, 8:13, 15:42, 44:51, 53:56)
  
  data_melt <- reshape::melt.array(residuals)
  ggp <- ggplot(data_melt, aes(X1, X2)) + geom_tile(aes(fill = value))
  ggp + scale_fill_gradient(low = "mediumorchid", high = "mistyrose")
}