# README for Project 2

Urban Ministries of Durham is an organization that connects with the community to end homelessness and fight poverty.  Urban Ministries of Durham has three main programs: the Community Shelter, the Community Cafe, and the Food Pantry and Clothing Closet.

Over the years, Urban Ministries of Durham has collected data on their services provided at the Community Resource Center which consists of both the Community Cafe and the Food Pantry and Clothing Closet.  This includes a record of whether food, clothing, or items were received by an individual who visited the community center.

## Project Goals

The goal of this project is to provide useful a tool for Urban Ministries of Durham to view their records of services provided via a Shiny dashboard.

On the dashboard, Urban Ministries will be able to view:
1. The number of clients that have used the resource center
2. The number of visits to the resource center each month and year
3. The amount of food in pounds being consumed each month and year
4. Trends in number of clothing items provided each month and year
5. Yearly cash and non-cash contributions to Urban Ministries

## Data

The raw data is found in the **data** folder called *UMD_Services_Provided_20190719.tsv*.

In the Urban Ministries service records, the date of the services provided (*Date*) will be a key variable in exploring these questions.  Other variables of interest are food provided for (*Food.Provided.for), food in pounds (*Food.Pounds*) and clothing items (*Clothing.Items*).  A listing of all variables in the raw data is found in the file *UMD_Services_Provided_metadata_20190719.tsv* in the **data** folder.

Publicly available tax return data will be used to describe contributions to Urban Ministries.  The IRS requires all tax-exempt non-profits to make their annual returns publically available.  IRS Form 990 for Urban Ministries of Durham can be found on [ProPublica](https://projects.propublica.org/nonprofits/organizations/581505891).  For calendar years 2004-2017, Part VIII, line 1h was used to find the total contributions and grants and Part VIII, line 1g was used to find non-cash contributions.  For calendar years 2000-2003, Part 1 question 1d was used for contributions. The file *UMD IRS 990.txt* consolidates the relevant lines from the 990 tax returns from 2000-2017.