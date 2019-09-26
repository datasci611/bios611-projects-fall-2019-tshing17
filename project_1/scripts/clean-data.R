# ----------------------------------------------------------------------- #
# Title: clean-data.R
# Date:9/21/2019
# Programmer: tshing17
# Description: Perform an initial check and exploration of the data.
#   This includes checking the variables to determine the variable type,
#   determining what variables are in the dataset, and examining the
#   usefulness of these variables.
#
# Input: UMD_Services_Provided_20190719.tsv
# Output: Anl_UMD_Services_190921.tsv
# 
# ----------------------------------------------------------------------- #

library(tidyverse)

setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_1/data")
dat<-read.delim("UMD_Services_Provided_20190719.tsv", sep="\t", header=TRUE)

# Explore data and data types
summary(dat)
### the most populated fields are Food.Provided.for, Food.Pounds, Clothing.Items, Financial.Support
### More than 95% missing for Bus.Tickets..Number.of., Diapers, School.Kits, Hygiene.Kits, Referrals, Type.of.Bill.Paid, and Payer.of.Support

# Check those records in Field1-Field3
filter(dat, !is.na(Field2)|!is.na(Field3)|Field1=='`1')
### Field1-Field3 look like typos

# Check dates and missingness in variables by year
#### date is currently a character variable - separate into month, day, year
dat2 = dat %>%
  separate(Date, into = c("month", "day", "year"), sep = "/", convert=TRUE) %>%
  mutate(mthyr = as.Date(paste(sprintf("%d-%02d", year, month),"-01",sep="")))%>%
  mutate(mthdyyr = as.Date(paste(year, month, day,sep="-"), "%Y-%m-%d")) %>% 
  select(-(Field1:Field3)) %>%
  arrange(year, month, day)

chkmissing = dat2 %>%
  group_by(year) %>%
  summarise(
    total.records=n(),
    chk.Food.Provided.for=sum(!is.na(Food.Provided.for))/total.records*100,
    chk.Food.Pounds=sum(!is.na(Food.Pounds))/total.records*100,
    chk.Clothing.Items=sum(!is.na(Clothing.Items))/total.records*100,
    chk.Diapers=sum(!is.na(Diapers))/total.records*100,
    chk.School.Kits=sum(!is.na(School.Kits))/total.records*100,
    chk.Hygiene.Kits=sum(!is.na(Hygiene.Kits))/total.records*100,
    chk.Referrals=sum(!is.na(Referrals))/total.records*100,
    chk.Financial.Support=sum(!is.na(Financial.Support))/total.records*100
    )
chkmissing

## looks like started recording Clothing.Items sometime in 2002
## before that it was recording as "clothing" or "clothes" in the Notes of Service.  Sometimes there were frequencies of the number of items
## records of food in pounds likely 2006 onwards


### year >2019 are obvious data issues - no way to know what year these should be
### urban ministries was established in 2001 so records before then are incorrect
check=filter(dat2, year<2001|year>2019)

dat3 = dat2 %>%
  filter(mthyr>=as.Date('2001-01-01'), mthyr<as.Date('2019-07-01'))
### exclude partial months (July/Aug 2019)
### although these are the years of operation, we will focus on trends in the last 10 years (2009-present)

# Check Notes.of.Service
notesofservice = dat3 %>%
  filter(Notes.of.Service != "")
  
options(tibble.print_max = Inf)
notesofservice %>%
  group_by(year) %>%
  summarise( count=n() )
### looks like stopped recording notes of service in 2009, shift to other variables
### I will not use the Notes.of.Service variable to supplement the other columns.
## Instead I will focus on the later records, but it important to note these trends in data collection

# ----------------------------------------------------
check_outliers <- function(d, v, t){
  print(summary(v))
  print(quantile(v, probs=seq(0, 1, 0.05), na.rm=TRUE))
  print(quantile(v, probs=seq(0.95, 1, 0.01), na.rm=TRUE))
  ggplot(data=d, aes(y=v))+geom_boxplot()+labs(title=t)
}
# -----------------------------------------------------

# Check Food.Provided.for - could be some outliers, max = 1151?
check_outliers(dat3, dat3$Food.Provided.for, 'Distribution of Food Provided For')

dat4 = dat3 %>%
  mutate(Food.Provided.for.b = ifelse(Food.Provided.for>7, NA, Food.Provided.for)) #setting top 1% of data to missing

check_outliers(dat4, dat4$Food.Provided.for.b, 'Distribution of Food Provided For (excluding outliers)')


# Check Distribution of Food.Pounds - could be some outliers, max=450121
check_outliers(dat4, dat4$Food.Pounds, 'Distribution of Food in Pounds')

dat5 = dat4 %>%
  mutate(Food.Pounds.b = ifelse(Food.Pounds>60, NA, Food.Pounds)) #setting top 1% of data to missing

check_outliers(dat5, dat5$Food.Pounds.b, 'Distribution of Food in Pounds (excluding outliers)')

# Check Distribution of Clothing.Items - could be some outliers, max=247
check_outliers(dat5, dat5$Clothing.Items, 'Distribution of Clothing Items')

dat6 = dat5 %>%
  mutate(Clothing.Items.b = ifelse(Clothing.Items>28, NA, Clothing.Items))

check_outliers(dat6, dat6$Clothing.Items.b, 'Distribution of Clothing Items (excluding outliers)')



# Check Distribution of Diapers - could be some outliers, max=5303 - Not using so will not clean
# Check Distribution of School.Kits - Not using so will not clean
# Check Distribution of Hygiene.Kits - Not using so will not clean
# Check Financial.Support, Type.of.Bill.Paid, Payer.of.Support - Not using so will not clean

### Referrals don't seem usable
table(dat6$Referrals)

# Output data
dat7=dat6 %>% 
  arrange(Client.File.Number) %>%
  select(-Food.Provided.for, -Food.Pounds, -Clothing.Items) 
  
write_rds(dat7,'Anl_UMD_Services_190921.rds')


