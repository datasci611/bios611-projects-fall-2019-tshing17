# ANY NONCASH PLOT
library(tidyverse)

#setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first_entry<-read.delim('./data/analytic_first_entry.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))
first_exit<-read.delim('./data/analytic_first_exit.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

################
#ENTRY
# select noncash variables
noncash_entry = first_entry %>% select(EE.UID, Client.ID, Other.Source:Any.Noncash.Source)

# calculate the number of each response ie number who responded Yes, number who responded No, and number that were missing
# for each column ie columns totals
noncash_entry2 = data.frame(Yes=apply(select(noncash_entry,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                     No=apply(select(noncash_entry,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(x=='No', na.rm=TRUE)}),
                     Missing=apply(select(noncash_entry,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(is.na(x))}))

# convert index from totals calculation to new variable called Type
noncash_entry2 = rownames_to_column(noncash_entry2, "Type")

# gather data so there are 3 rows for each noncash type
noncash_entry2 = noncash_entry2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

# create bar chart
noncash_entry_plot = ggplot(data=noncash_entry2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Noncash Income Source at Entry',
       title='Figure 9. Noncash Income Source at Entry')+
  scale_fill_discrete(name = "Response")+
  scale_x_discrete(labels=c('Other',
                            'Other TANF',
                            'Public Housing',
                            'WIC',
                            'SNAP',
                            'TANF Child Care',
                            'TANF Transportation',
                            'Rental Assistance'))+
  theme(plot.title = element_text(size=14))
noncash_entry_plot

ggsave("./results/noncash_entry_plot.png", noncash_entry_plot)


################
#EXIT

# select noncash variables
noncash_exit = first_exit %>% select(EE.UID, Client.ID, Other.Source:Any.Noncash.Source)

# calculate the number of each response ie number who responded Yes, number who responded No, and number that were missing
# for each column ie columns totals
noncash_exit2 = data.frame(Yes=apply(select(noncash_exit,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                            No=apply(select(noncash_exit,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(x=='No', na.rm=TRUE)}),
                            Missing=apply(select(noncash_exit,-EE.UID, -Client.ID, -Any.Noncash.Source),2, function(x){sum(is.na(x))}))

# convert index from totals calculation to new variable called Type
noncash_exit2 = rownames_to_column(noncash_exit2, "Type")

# gather data so there are 3 rows for each noncash type
noncash_exit2 = noncash_exit2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

# create bar chart
noncash_exit_plot = ggplot(data=noncash_exit2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Noncash Income Source at Exit',
       title='Figure 10. Noncash Income Source at Exit')+
  scale_fill_discrete(name = "Response")+
  scale_x_discrete(labels=c('Other',
                            'Other TANF',
                            'Public Housing',
                            'WIC',
                            'SNAP',
                            'TANF Child Care',
                            'TANF Transportation',
                            'Rental Assistance'))+
  theme(plot.title = element_text(size=14))
noncash_exit_plot

ggsave("./results/noncash_exit_plot.png", noncash_exit_plot)


# analysis
noncash_entry3 = noncash_entry2 %>% spread(key = Category, value = Freq) %>% mutate(time='Entry')
noncash_exit3 = noncash_exit2 %>% spread(key = Category, value = Freq) %>% mutate(time='Exit')
noncash_anl = noncash_entry3 %>% full_join(noncash_exit3) %>% arrange(Type)

typelist = unique(noncash_anl$Type)
chisq_stat = list()
chisq_pval = list()
for (type in typelist){
  chisq_stat[type] = chisq.test(noncash_anl %>% filter(Type == type ) %>% select(Yes,No,Missing))$statistic
  print(chisq_stat[type])
  chisq_pval[type] = chisq.test(noncash_anl %>% filter(Type == type ) %>% select(Yes,No,Missing))$p.value
  print(chisq_pval[type])
}
