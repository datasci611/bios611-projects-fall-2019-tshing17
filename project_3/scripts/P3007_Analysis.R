library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first_exit<-read.delim('./data/analytic_first_exit.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))
num_clients=nrow(first_exit)

# LOS
summary(first_exit$LOS)

los_dist=ggplot(data=first_exit, aes(LOS))+
  geom_histogram(color='black', fill='light blue', binwidth=10)+
  labs(x='Length of First Stay (in days)', y='Number of Clients',
       title='Figure 11. Length of First Stay at Shelter')+
  scale_x_continuous(breaks = seq(0, 515, 50), lim = c(0, 515))+
  theme(plot.title = element_text(size=14))
los_dist

ggsave("./results/los_dist.png", los_dist)

# Destination
# pie chart for living situation at exit
## calculate frequency of clients by prior living situation
destination = first_exit %>%
  group_by(Destination) %>%
  summarise(freq=n()) %>%
  mutate(pct=(freq/num_clients)*100)

## pie chart for prior living situation distribution
destination_plot = ggplot(data=destination, aes(x="", y=pct, fill=Destination))+
  geom_bar(stat="identity", width=1, color="white")+
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(label = round(pct,2)), position = position_stack(vjust = 0.5), color = "white", size=4)+
  labs(title="Figure 12. Percent Distribution of Destination at Exit", fill='Destination')+
  theme(plot.title = element_text(size=14))
destination_plot

## save prior living pie chart
ggsave("./results/destination_plot.png", destination_plot)

### 
returned_plot = ggplot(data=first_exit, aes(factor(returned), fill=factor(returned)))+
  geom_bar()+
  labs(x='Returned to Shelter?', y='Number of Clients',
       title="Figure 13. Frequency of Return to the Shelter")+
  theme(plot.title = element_text(size=14),
        legend.position = "none")+
    scale_x_discrete(labels = c('No', 'Yes'))

ggsave("./results/returned_plot.png", returned_plot)

#Log Transform
dat = first_exit %>%
  mutate(log_los=log(LOS+1)) %>% 
  mutate(Client.Primary.Race2 = ifelse(is.na(Client.Primary.Race)|
                                         Client.Primary.Race == 'Native Hawaiian or Other Pacific Islander'|
                                         Client.Primary.Race == 'American Indian or Alaska Native'|
                                         Client.Primary.Race == 'Asian','Other',Client.Primary.Race))

return_logit <- glm(data=dat, returned ~ log_los + Client.Age.at.Exit + Client.Gender + Client.Primary.Race2 +
                      Client.Veteran.Status + Destination + Domestic.violence.victim.survivor +Any.Disability + Any.Health.Insurance + 
                      Any.Income.Source + Any.Noncash.Source, family = "binomial")

summary(return_logit)
