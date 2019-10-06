# README for Project 1

Urban Ministries of Durham is an organization that connects with the community to end homelessness and fight poverty.  Urban Ministries of Durham has three main programs: the Community Shelter, the Community Cafe, and the Food Pantry and Clothing Closet.

Over the years, Urban Ministries of Durham has collected data on their services provided at the Community Resource Center which consists of both the Community Cafe and the Food Pantry and Clothing Closet.  This includes a record of whether food, clothing, or items were received by an individual who visited the community center.

## Project Goals

The goal of this project is to provide useful practice recommendations for Urban Ministries of Durham based on their records of services provided.

Therefore, this project seeks to answer the following questions:
1. How often is the Community Resource Center being used?
* How many people visit the Community Resource Center each year? each month?
* On average, how often do people visit the Community Resource Center each year? each month?
2. What resources are being used and when?
* How much food in pounds is being consumed each year? each month?
* How many clothing items are provided each year? each month?
3. Is there any correlation between the resources being used (food and clothing) and the amount of funding or donations?

## Data

The raw data is found in the **data** folder called *UMD_Services_Provided_20190719.tsv*.  Some data cleaning was performed to subset the data service records between January 2001 and June 2019 as the combined Durham Community Shelter for HOPE, St. Philip’s Community Cafe, and the United Methodist Mission Society merged to form Urban Ministries of Durham in 2001.  The data from July and August 2019 were partial.  Additionally, some extreme values were set to missing.  Data cleaning methods can be found in the **scripts** folder called *clean-data.R*.  The final analytic dataset used is in the **data** folder called *Anl_UMD_Services_190921.rds*.  This is also included as a text file called *Anl_UMD_Services_190921.txt*.

In the Urban Ministries service records, the date of the services provided (*Date*) will be a key variable in exploring these questions.  Other variables of interest are food provided for (*Food.Provided.for), food in pounds (*Food.Pounds*) and clothing items (*Clothing.Items*).  A listing of all variables in the raw data is found in the file *UMD_Services_Provided_metadata_20190719.tsv* in the **data** folder.

To examine the relationship between resources and donations, publicly available tax return data will be used.  The IRS requires all tax-exempt non-profits to make their annual returns publically available.  IRS Form 990 for Urban Ministries of Durham can be found on [ProPublica](https://projects.propublica.org/nonprofits/organizations/581505891).  For calendar years 2004-2017, Part VIII, line 1h was used to find the total contributions and grants and Part VIII, line 1g was used to find non-cash contributions.  For calendar years 2000-2003, Part 1 question 1d was used for contributions. The file *UMD IRS 990.txt* consolidates the relevant lines from the 990 tax returns from 2000-2017.

## Analyses

This project is an exploratory analysis of the services provided by Urban Ministries of Durham.  Yearly and monthly frequencies of people who used service will be tabulated.  Similarly, the total number of visits per person per year will be calculated then averaged across all persons for each year.  Yearly and monthly averages of food in pounds and clothing items will be tabulated.  Plots over time will be generated from these estimates.  Trends over time for total visits, food, and clothing will be evaluated.  Finally, contributions based on IRS 990 forms will be plotted.  Correlations between funding and resources used will be assessed.

## How to use this repository

This repository is organized into three folders called **data**, **results**, and **scripts**.  All data used in this project is contained in the **data** folder. These files are used in the programs in the **scripts** folder.  The **scripts** folder contains all code used to generate the files in the **results** folder.  The *clean-data.R* file should be read first to understand how the data was cleaned.  Next the *UMD_results.RMD* was used to generate the final report called *UMD_results.html* found in the **results** folder.  All code for the plots are generated directly in the RMD file.
