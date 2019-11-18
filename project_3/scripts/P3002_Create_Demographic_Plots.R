# DEMOGRAPHICS PLOTS
library(tidyverse)

setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first<-read.delim('./data/analytic_first.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

# bar chart for Age, colored by race, split by gender 
agebreaks <- c(18,25,35,45,55,65,500)
agelabels <- c("18-24","25-34","35-44","45-54","55-64","65+")
first$Client.Age.at.Entry.Cat <- cut(first$Client.Age.at.Entry, breaks = agebreaks, labels = agelabels, right = FALSE)

first = first %>% mutate(Client.Primary.Race2=
                           ifelse(is.na(Client.Primary.Race)|
                                    Client.Primary.Race=='Native Hawaiian or Other Pacific Islander'|
                                    Client.Primary.Race=='American Indian or Alaska Native'|
                                    Client.Primary.Race=='Asian','Other',Client.Primary.Race))


demog_plot=ggplot(filter(first, !is.na(Client.Gender), !is.na(Client.Primary.Race2)), 
       aes(x=Client.Age.at.Entry.Cat, fill=Client.Primary.Race2))+
  geom_bar(position="stack")+
  facet_wrap(~ Client.Gender)+
  labs(x='Age at First Entry', y='Number of Clients')+
  scale_fill_discrete(name = "Race", labels = c("Black", "White", "Other"))

ggsave("./results/demog_plot.png", demog_plot)

