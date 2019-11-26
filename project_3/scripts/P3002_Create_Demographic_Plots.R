# DEMOGRAPHICS PLOTS
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
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
  labs(x='Age at First Entry', y='Number of Clients', title='Figure 1. Client Demographics at Entry')+
  scale_fill_discrete(name = "Race", labels = c("Black", "White", "Other"))

ggsave("./results/demog_plot.png", demog_plot)


# veteran status
veteran = first %>%
  group_by(Client.Veteran.Status) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/2102)*100)

veteran_plot = ggplot(data=veteran, aes(x="", y=pct, fill=Client.Veteran.Status))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 2. Percent Distribution of Veteran Status at Entry", fill='Veteran Status')
veteran_plot

ggsave("./results/veteran_plot.png", veteran_plot)

# domestic violence
domestic_violence = first %>%
  group_by(Domestic.violence.victim.survivor) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/2102)*100)

domestic_violence_plot = ggplot(data=domestic_violence, aes(x="", y=pct, fill=Domestic.violence.victim.survivor))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 3. Percent Distribution of Domestic Violence Survivors at Entry", fill='Survivor')
domestic_violence_plot

ggsave("./results/domestic_violence_plot.png", domestic_violence_plot)

# prior living situation
prior_living = first %>%
  group_by(Prior.Living) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/2102)*100)

prior_living_plot = ggplot(data=prior_living, aes(x="", y=pct, fill=Prior.Living))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 4. Percent Distribution of Living Situation Prior to Entry", fill='Living Situation')
prior_living_plot

ggsave("./results/prior_living_plot.png", prior_living_plot)
