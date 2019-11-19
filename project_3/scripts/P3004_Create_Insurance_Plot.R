# Health Insurance Plots
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first<-read.delim('../data/analytic_first.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

# bar chart health insurance 
health_ins = first %>% select(EE.UID, Client.ID, Employer...Provided.Health.Insurance:Any.Health.Insurance)

health_ins2 = data.frame(Yes=apply(select(health_ins,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                    No=apply(select(health_ins,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(x=='No', na.rm=TRUE)}),
                    Missing=apply(select(health_ins,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(is.na(x))}))
health_ins2 = rownames_to_column(health_ins2, "Type")

health_ins2 = health_ins2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

health_ins_plot = ggplot(data=health_ins2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Health Insurance Covered at Entry', title='Health Insurance Reported at Entry')+
  scale_fill_discrete(name = "Response")
health_ins_plot

ggsave("../results/health_ins_plot.png", health_ins_plot)
