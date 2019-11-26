# ANY NONCASH PLOT
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first<-read.delim('./data/analytic_first.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

# bar chart noncash sources
noncash = first %>% select(EE.UID, Client.ID, Other.Source:Any.Noncash.Source)

noncash2 = data.frame(Yes=apply(select(noncash,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                     No=apply(select(noncash,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(x=='No', na.rm=TRUE)}),
                     Missing=apply(select(noncash,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(is.na(x))}))
noncash2 = rownames_to_column(noncash2, "Type")

noncash2 = noncash2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

noncash_plot = ggplot(data=noncash2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Noncash Income Source at Entry')+
  scale_fill_discrete(name = "Response")
noncash_plot

ggsave("./results/noncash_plot.png", noncash_plot)
