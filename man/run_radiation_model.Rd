% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulation_functions.R
\name{run_radiation_model}
\alias{run_radiation_model}
\title{Run the gravity model and return the sum of squared residuals
(used in combination with optimize() to find the most appropriate alpha value)}
\usage{
run_radiation_model(alpha, year_data, S_ij_file, hist_data_file)
}
\arguments{
\item{alpha}{= hyperparameter used in calculations}

\item{year_data}{= a vector containing population estimates for each state for a specific year (states listed in fips order)}

\item{S_ij_file}{= string, path to where appropriate intervening opportunities csv can be found}

\item{hist_data_file}{= string, path to the appropriate csv containing historical data on the recorded number of migrants}
}
\value{
= the sum of squared residuals (residual = recorded num_migrants - radiation model prediction)
}
\description{
Run the gravity model and return the sum of squared residuals
(used in combination with optimize() to find the most appropriate alpha value)
}
