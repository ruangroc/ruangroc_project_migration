join_with_pop_ests <- function(data, year) {
  data <- left_join(data, pop_estimates %>% select(fips, year), by = c("origin_fips" = "fips"))
  data <- rename(data, m_i = year)
  data <- left_join(data, pop_estimates %>% select(fips, year), by = c("dest_fips" = "fips"))
  data <- rename(data, m_j = year)
  data
}

clean_and_write <- function(data, name, year) {
  
  # remove duplicate rows in the tibble
  data <- distinct(data)
  
  # and remove rows that have the totals, not origin-dest pairs
  data <- subset(data, (data$origin_fips != 0 & data$dest_fips != 0 & num_migrants != -1))
  data <- subset(data, (data$origin_fips <= 56 & data$dest_fips <= 56))
  
  # and remove rows that count non-migrants (origin and dest states are the same)
  data <- subset(data, (data$origin_fips != data$dest_fips))
  
  # and attach population estimates according to origin and destination fips
  data <- join_with_pop_ests(data, year)
  
  # then write cleaned data to a csv
  filename <- here("results", "data_cleaning_results", "clean", name)
  write.csv(data, file = filename, row.names = FALSE)
}