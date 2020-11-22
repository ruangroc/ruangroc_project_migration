Migration Models
================

``` r
library(tidyverse)
library(here)
library(Imap)
#devtools::load_all()
```

## Load the data

``` r
US_0910 <- read.csv(here("results", "data_cleaning_results", "clean", "US_0910.csv"))
US_1011 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1011.csv"))
US_1112 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1112.csv"))
US_1213 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1213.csv"))
US_1314 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1314.csv"))
US_1415 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1415.csv"))
US_1516 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1516.csv"))
US_1617 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1617.csv"))
US_1718 <- read.csv(here("results", "data_cleaning_results", "clean", "US_1718.csv"))
```

## Background research

As seen in the image below and as explained in Caleb Robinson and Bistra
Dilkina’s paper, [“A Machine Learning Approach to Modeling Human
Migration”](https://doi.org/10.1145/3209811.3209868), the traditional
migration models can be written as the product of two parts:
\(T_{ij} = G_i * P_{ij}\). \* \(T_{ij}\) is the number of people moving
from every zone i to every other zone j \* \(G_i = \alpha * m_i\) is the
production function that estimates number of people leaving zone i \*
\(m_i\) is the population of zone i and alpha is a parameter tuned using
historical data \* \(P_{ij}\) is the probability of a move occurring
from i to j \* Robinson and Dilkina note that the probability of moving
from i to all other destinations j should sum to 1

[Table 1 showing equations for traditional migration
models](documentation/project_notes/Robinson_and_Dilkina_Table_1.PNG)

## Gravity model with power law

## Gravity model with exponential decay

## Radiation model
