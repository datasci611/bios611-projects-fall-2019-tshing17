# README for Project 2

Project 2 link: <https://tshing17.shinyapps.io/project_2/>

Urban Ministries of Durham is an organization that connects with the community to end homelessness and fight poverty.  Urban Ministries of Durham has three main programs: the Community Shelter, the Community Cafe, and the Food Pantry and Clothing Closet.

Over the years, Urban Ministries of Durham has collected data on their services provided at the Community Resource Center which consists of both the Community Cafe and the Food Pantry and Clothing Closet.  This includes a record of whether food, clothing, or items were received by an individual who visited the community center.

## Project Goals

The goal of this project is to provide useful a tool for Urban Ministries of Durham to view their records of services provided via a Shiny dashboard.

On the dashboard, Urban Ministries will be able to view:
1. Trends in the number of clients that have used the resource center
2. Trends in the number of visits to the resource center
3. Trends in the amount of food in pounds being consumed
4. Trends in the number of clothing items provided

## Data

The raw data is found in the **data** folder called *UMD_Services_Provided_20190719.tsv*.

In the Urban Ministries service records, the date of the services provided (*Date*) will be a key variable in exploring these questions.  Other variables of interest are food in pounds (*Food.Pounds*) and clothing items (*Clothing.Items*).  A listing of all variables in the raw data is found in the file *UMD_Services_Provided_metadata_20190719.tsv* in the **data** folder.

## Analyses

It is important to note that the data file consists of 1 record per visit, wherein a single client (identified by the *Client.File.Number*) may have multiple records.  Thus, all plots are aggregated totals of all resources used during the month.

Via a Shiny dashboard, users will be able to select the resource of interest, remove outliers, and view specific dates of interest for totals resource use over time.

Plots will be viewable with and without extreme values for an individual client visit.  Extreme values of food in pounds consisted of more than 60 pounds provided to a client during a single visit to the resource center.  Similarly, extreme values of clothing items consisted of providing more than 28 clothing items to a client during a single visit to the resource center.