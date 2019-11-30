# DEMOGRAPHICS PLOTS - this program create demographic plots for clients at their first entry to the shelter
library(tidyverse)

# read in data from first visit 
#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first_entry<-read.delim('./data/analytic_first_entry.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

# bar chart for distribution of age, colored by race, split by gender 
## create age cateogories
agebreaks <- c(18,25,35,45,55,65,500)
agelabels <- c("18-24","25-34","35-44","45-54","55-64","65+")
first_entry$Client.Age.at.Entry.Cat <- cut(first_entry$Client.Age.at.Entry, 
                                           breaks = agebreaks, labels = agelabels, right = FALSE)

## recode race - create "other race cateogory"
first_entry = first_entry %>% mutate(Client.Primary.Race2 =
                           ifelse(is.na(Client.Primary.Race)|
                                    Client.Primary.Race == 'Native Hawaiian or Other Pacific Islander'|
                                    Client.Primary.Race == 'American Indian or Alaska Native'|
                                    Client.Primary.Race == 'Asian','Other',Client.Primary.Race))

## age/race/gender bar plot
demog_plot=ggplot(filter(first_entry, !is.na(Client.Gender), !is.na(Client.Primary.Race2)), 
       aes(x = Client.Age.at.Entry.Cat, fill = Client.Primary.Race2))+
  geom_bar(position="stack")+
  facet_wrap(~ Client.Gender)+
  labs(x = 'Age at First Entry', y = 'Number of Clients', title = 'Figure 1. Client Demographics at Entry')+
  scale_fill_discrete(name = "Race", labels = c("Black", "White", "Other"))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = -.8, vjust=2.12, size=12))
demog_plot

## save age/race/gender bar plot
ggsave("./results/demog_plot.png", demog_plot)


# pie chart for percentage of clients' veteran status
## calculate frequency of clients by veteran status response
## I will explicitly define the missing because I think it's interesting to see how many do not respond
num_clients=nrow(first_entry)

veteran = first_entry %>% 
  mutate(Client.Veteran.Status = fct_explicit_na(Client.Veteran.Status, na_level="Missing")) %>%
  group_by(Client.Veteran.Status) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/num_clients)*100)

## pie chart for client veteran status
veteran_plot = ggplot(data=veteran, aes(x="", y=pct, fill=Client.Veteran.Status))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 2. Percent Distribution of Veteran Status at Entry", fill='Veteran Status')+
  theme(plot.title = element_text(size=12))
veteran_plot

## save veteran pie chart
ggsave("./results/veteran_plot.png", veteran_plot)


# pie chart for percentage of clients' domestic violence survivorship
## calculate frequency of clients by domestic violence response
## I will explicitly define the missing
domestic_violence = first_entry %>%
  mutate(Domestic.violence.victim.survivor = fct_explicit_na(Domestic.violence.victim.survivor, na_level="Missing")) %>%
  group_by(Domestic.violence.victim.survivor) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/num_clients)*100)

## pie chart for domestic violence survivorship
domestic_violence_plot = ggplot(data=domestic_violence, aes(x="", y=pct, fill=Domestic.violence.victim.survivor))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 3. Percent Distribution of Domestic Violence\n Survivors at Entry", fill='Survivor')+
  theme(plot.title = element_text(size=12))
domestic_violence_plot

## save domestic violence pie chart
ggsave("./results/domestic_violence_plot.png", domestic_violence_plot)


# pie chart for living situation prior to entry
## calculate frequency of clients by prior living situation
prior_living = first_entry %>%
  group_by(Prior.Living) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/num_clients)*100)

## pie chart for prior living situation distribution
prior_living_plot = ggplot(data=prior_living, aes(x="", y=pct, fill=Prior.Living))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 4. Percent Distribution of Living Situation\n Prior to Entry", fill='Living Situation')+
  theme(plot.title = element_text(size=12))
prior_living_plot


## save prior living pie chart
ggsave("./results/prior_living_plot.png", prior_living_plot)
