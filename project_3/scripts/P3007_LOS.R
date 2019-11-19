# LOS
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first<-read.delim('../data/analytic_first.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

summary(first$LOS)

los_dist=ggplot(data=first, aes(LOS))+
  geom_histogram(color='black', fill='white')+
  labs(x='Length of First Stay (in days)', y='Number of Clients')
los_dist

ggsave("../results/los_dist.png", los_dist)

#Log Transform
dat = first %>% mutate(log_los=log(LOS))

ggplot(data=dat, aes(log_los))+
  geom_histogram(color='black', fill='white')

#Regression


