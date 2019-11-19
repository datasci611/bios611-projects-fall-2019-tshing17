# ANY INCOME PLOT
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first<-read.delim('../data/analytic_first.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

# bar chart income sources
income = first %>% select(EE.UID, Client.ID, Alimony.or.Other.Spousal.Support:Any.Income.Source)

income2 = data.frame(Yes=apply(select(income,-EE.UID, -Client.ID, -Any.Income.Source),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                    No=apply(select(income,-EE.UID, -Client.ID, -Any.Income.Source),2, function(x){sum(x=='No', na.rm=TRUE)}),
                    Missing=apply(select(income,-EE.UID, -Client.ID, -Any.Income.Source),2, function(x){sum(is.na(x))}))
income2 = rownames_to_column(income2, "Type")

income2 = income2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

income_plot = ggplot(data=income2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Income Source at Entry')+
  scale_fill_discrete(name = "Response")
income_plot

ggsave("../results/income_plot.png", income_plot)
