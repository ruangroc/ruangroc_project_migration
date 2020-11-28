# ST441 Project: Radiation and Gravity Models for Simulating Human Migration Patterns

Anita Ruangrotsakun

## Background + Inspiration

This project is a much simpler, smaller version of of the work Caleb Robinson and Bistra Dilkina completed in ["A Machine Learning Approach to Modeling Human Migration"](https://doi.org/10.1145/3209811.3209868). They developed a machine learning framework to improve predictions for human migration patterns and compared it to several traditional migration models. Some of their implementation code can be found here: [Caleb Robinson's Python library for working with migration data](https://github.com/calebrob6/migration-lib).

The scope of this project was constrained to implementing only a radiation model and gravity model in R, as opposed to Python. I also make use of the  historical migration data from the IRS (as referenced in the article), though I use the in and out flow files for states instead of US counties, to make predictions about migration patterns within the US in the next few years.

## Repo Structure

A more complete project report can be found [/documentation/project_report](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/documentation/project_report). Notes I took while doing background research can be found in [/documentation/project_notes](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/documentation/project_notes)

The raw data can be found in [/data](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/data).The migration data files are grouped by year, whereas the population estimates for 2009-2019 can be found under [/ACStables](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/data/ACStables).


In [/R](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/R), you will find three files containing the functions I used. Unit tests for the most important functions can be found in [/tests/testthat](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/tests/testthat).

The [/analysis](https://github.com/ST541-Fall2020/ruangroc_project_migration/tree/main/analysis) folder contains the scripts I created to:

  * generate migration matrices using the gravity and radiation models 
  * clean up the historical data (put them all in a standard format)
  * compare the historical data to the models' predictions
  * fine tune the models and use them to simulate future migration flows (2018-2022) 


