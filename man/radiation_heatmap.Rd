% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare_to_historical.R
\name{radiation_heatmap}
\alias{radiation_heatmap}
\title{Create radiation model residuals heatmap}
\usage{
radiation_heatmap(rad_matrix, hist_matrix, year)
}
\arguments{
\item{rad_matrix}{= 51x51 radiation model migration matrix}

\item{hist_matrix}{= 51x51 historical data matrix}

\item{year}{= string, year to label the heatmap}
}
\value{
= ggplot visual of a heatmap
}
\description{
Create radiation model residuals heatmap
}
