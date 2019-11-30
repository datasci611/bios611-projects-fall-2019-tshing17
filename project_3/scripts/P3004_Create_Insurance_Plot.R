# Health Insurance Plots
library(tidyverse)

setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first_entry<-read.delim('./data/analytic_first_entry.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))
first_exit<-read.delim('./data/analytic_first_exit.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

####################
# ENTRY
# select insurance variables
health_ins_entry = first_entry %>% select(EE.UID, Client.ID, Employer...Provided.Health.Insurance:Any.Health.Insurance)

# calculate the number of each response ie number who responded Yes, number who responded No, and number that were missing
# for each column ie columns totals
health_ins_entry2 = data.frame(Yes=apply(select(health_ins_entry,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                    No=apply(select(health_ins_entry,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(x=='No', na.rm=TRUE)}),
                    Missing=apply(select(health_ins_entry,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(is.na(x))}))

# convert index from totals calculation to new variable called Type
health_ins_entry2 = rownames_to_column(health_ins_entry2, "Type")

# gather data so there are 3 rows for each insurance type
health_ins_entry2 = health_ins_entry2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

# create bar chart
health_ins_entry_plot = ggplot(data=health_ins_entry2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Health Insurance Covered at Entry', title='Figure 7. Health Insurance Reported at Entry')+
  scale_fill_discrete(name = "Response")+
  scale_x_discrete(labels=c('Employer',
                            'COBRA',
                            'Indian Health Services',
                            'Medicaid',
                            'Medicare',
                            'Other',
                            'Privately Paid',
                            'State CHIP',
                            'State Health Insurance',
                            'VA Medical Services'))+
  theme(plot.title = element_text(hjust = 1.15, vjust=1, size=12))
health_ins_entry_plot

ggsave("./results/health_ins_entry_plot.png", health_ins_entry_plot)

##############
# EXIT

# select insurance variables
health_ins_exit = first_exit %>% select(EE.UID, Client.ID, Employer...Provided.Health.Insurance:Any.Health.Insurance)

# calculate the number of each response ie number who responded Yes, number who responded No, and number that were missing
# for each column ie columns totals
health_ins_exit2 = data.frame(Yes=apply(select(health_ins_exit,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                               No=apply(select(health_ins_exit,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(x=='No', na.rm=TRUE)}),
                               Missing=apply(select(health_ins_exit,-EE.UID, -Client.ID, -Any.Health.Insurance),2, function(x){sum(is.na(x))}))

# convert index from totals calculation to new variable called Type
health_ins_exit2 = rownames_to_column(health_ins_exit2, "Type")

# gather data so there are 3 rows for each insurance type
health_ins_exit2 = health_ins_exit2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

# create bar chart
health_ins_exit_plot = ggplot(data=health_ins_exit2, aes(x=Type, y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Health Insurance Covered at Exit', title='Figure 8. Health Insurance Reported at Exit')+
  scale_fill_discrete(name = "Response")+
  scale_x_discrete(labels=c('Employer',
                            'COBRA',
                            'Indian Health Services',
                            'Medicaid',
                            'Medicare',
                            'Other',
                            'Privately Paid',
                            'State CHIP',
                            'State Health Insurance',
                            'VA Medical Services'))+
  theme(plot.title = element_text(hjust = 1.25, vjust=1, size=12))
health_ins_exit_plot

ggsave("./results/health_ins_exit_plot.png", health_ins_exit_plot)


# analysis
health_ins_entry3 = health_ins_entry2 %>% spread(key = Category, value = Freq) %>% mutate(time='Entry')
health_ins_exit3 = health_ins_exit2 %>% spread(key = Category, value = Freq) %>% mutate(time='Exit')
health_ins_anl = health_ins_entry3 %>% full_join(health_ins_exit3) %>% arrange(Type)

typelist = unique(health_ins_anl$Type)
chisq_stat = list()
chisq_pval = list()
for (type in typelist){
  chisq_stat[type] = chisq.test(health_ins_anl %>% filter(Type == type ) %>% select(Yes,No,Missing))$statistic
  print(chisq_stat[type])
  chisq_pval[type] = chisq.test(health_ins_anl %>% filter(Type == type ) %>% select(Yes,No,Missing))$p.value
  print(chisq_pval[type])
}
