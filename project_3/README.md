# Project 3

This data is from the shelter side of Urban Ministries of Durham (UMD). It includes a lot of data about clients upon entry to and exit from the shelter, including age, gender, race, mental health, income, insurance, and many other variables spread across many tables.

The overall objective of this project is to characterize the clients who use the shelter.  Of interest, this project intends to determine:

1. Who uses the shelter?
2. How long do clients stay at the shelter?
3. What predicts how long clients stay at the shelter?
4. What predicts a return to the shelter?

The results of this project is intended for use by the staff of UMD.  It is important to discover who is using the shelter and how the shelter can improve client outcomes.  Ideally, the results of this project will provide recommendations that guide interventions to end homelessness.

There are a variety of data tables from the shelter side of UMD.  These datasets are found in the *data* folder.

For study question 1-3, this analysis will focus on a client's **first** visit to the shelter.  Characteristics at entry will be used to predict how long a client stays at the center. *This analysis is in progress as of 11/18/19.*

For study question 4, the analysis will focus on whether a client had a second visit to the shelter or not as of 11/2/2019.  Characteristics at a client's first exit from the center will be used to predict return. *This analysis is in progress as of 11/18/19.*

Data cleaning and wrangling was performed in Python.  Analytic datasets were created and also output to the *data* folder.  Tables, descriptive analyses, and regression analyses were performed in R using the Tidyverse and Caret packages.  A Docker container will be provided to facilitate reproducibility.  Finally, the entire project will be documented using Make. *Dockerfiles and Makefile is not yet completed as of 11/18/19.*