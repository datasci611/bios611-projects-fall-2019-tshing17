# Project 3
### Tracie Shing

## Instructions
To create the final report, Project-3-Report.html, do the following:

1. git clone https://github.com/datasci611/bios611-projects-fall-2019-tshing17
2. Navigate into the folder project_3
3. Type "make results/Project-3-Report.html"

The final output is found in the *results* folder.  A html preview of this report can also be viewed [here](http://htmlpreview.github.io/?https://github.com/datasci611/bios611-projects-fall-2019-tshing17/blob/master/project_3/results/Project-3-Report.html).


## Description
This data is from the shelter side of [Urban Ministries of Durham (UMD)](https://www.umdurham.org/). It includes a lot of data about clients upon entry to and exit from the shelter, including age, gender, race, mental health, income, insurance, and many other variables spread across many tables.

The overall objective of this project is to characterize the clients who use the shelter.  Of interest, this project intends to determine:

1. Who uses the shelter?
2. Are clients the same at entry and exit to the shelter?
3. What predicts a return to the shelter?

The results of this project are intended for use by the staff of UMD.  It is important to discover who is using the shelter and how the shelter can improve client outcomes.  Ideally, the results of this project will provide recommendations that guide interventions to end homelessness.

There are a variety of data tables from the shelter side of UMD.  These datasets are found in the *data* folder.

Study questions 1 and 2 are descriptive and focus on a client's **first** visit to the shelter.  For study question 3, the analysis will focus on whether a client had a second visit to the shelter or not as of 11/2/2019.  Characteristics at a client's first exit from the center will be used to predict return.

Data cleaning and wrangling was performed in Python.  Analytic datasets were created and also output to the *data* folder.  Tables, descriptive analyses, and regression analyses were performed in R using the Tidyverse package.  A Docker container will be provided to facilitate reproducibility.  Finally, the entire project will be documented using Make.  See instructions above.