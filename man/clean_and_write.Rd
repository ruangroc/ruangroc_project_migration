% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_cleaning_functions.R
\name{clean_and_write}
\alias{clean_and_write}
\title{Clean historical data and write out as csv file}
\usage{
clean_and_write(data, name)
}
\arguments{
\item{data}{= tibble with columns origin_fips, dest_fips, and num_migrants pulled from state in and out flow files}

\item{name}{= name that write.csv should use when creating the file}
}
\value{
= no return value
}
\description{
Clean historical data and write out as csv file
}
