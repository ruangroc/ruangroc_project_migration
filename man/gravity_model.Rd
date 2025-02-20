% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/migration_models.R
\name{gravity_model}
\alias{gravity_model}
\title{Gravity model to produce a migration matrix (a prediction)}
\usage{
gravity_model(data, names, alpha, locations)
}
\arguments{
\item{data}{= a vector containing population estimates for each state for a specific year (states listed in fips order)}

\item{names}{= list of states' FIPS id}

\item{alpha}{= hyperparameter used in calculations (can be fine tuned using historical data)}

\item{locations}{= tibble containing distances between each (i, j) state combination}
}
\value{
= migration matrix with values estimating number of migrants from states i to j for all combinations of (i, j)
}
\description{
Gravity model to produce a migration matrix (a prediction)
}
