# DISABILITY PLOTS
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first<-read.delim('../data/analytic_first.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

# bar chart disability 
disab = first %>% select(EE.UID, Client.ID, Alcohol.Abuse:Any.Disability)

disab2 = data.frame(Yes=apply(select(disab,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                    No=apply(select(disab,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(x=='No', na.rm=TRUE)}),
                    Missing=apply(select(disab,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(is.na(x))}))
disab2 = rownames_to_column(disab2, "Type")

disab2 = disab2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

disab_plot = ggplot(data=disab2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Disability Type at Entry', title='Disability Reported at Entry')+
  scale_fill_discrete(name = "Response")
disab_plot

ggsave("../results/disab_plot.png", disab_plot)
