#' Clean historical data and write out as csv file
#'
#' @param data = tibble with columns origin_fips, dest_fips, and num_migrants pulled from state in and out flow files
#' @param name = name that write.csv should use when creating the file
#'
#' @return = no return value
#' @export
#'
#' @examples
clean_and_write <- function(data, name) {
  
  # remove duplicate rows in the tibble
  data <- distinct(data)
  
  # and remove rows that have the totals, not origin-dest pairs
  data <- subset(data, (data$origin_fips != 0 & data$dest_fips != 0 & num_migrants != -1))
  data <- subset(data, (data$origin_fips <= 56 & data$dest_fips <= 56))
  
  # and remove rows that count non-migrants (origin and dest states are the same)
  data <- subset(data, (data$origin_fips != data$dest_fips))
  
  # then write cleaned data to a csv
  filename <- here("results", "data_cleaning_results", "clean", name)
  write.csv(data, file = filename, row.names = FALSE)
}