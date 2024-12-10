##het

library(ggplot2)
library(ggpubr)
library(tidyverse)
library(broom)
library(AICcmodavg)

het_est <- read.csv('het_est.csv')
head(het_est)
metadata <- read.csv('het_est.metadata.csv')
head(metadata)

one.way <- aov(Heterozygosity ~ Population, data = metadata)
summary(one.way)
par(mfrow=c(2,2))
plot(one.way)

one.way2 <- aov(Heterozygosity ~ Year, data = metadata)
summary(one.way2)

one.way3 <- aov(Heterozygosity ~ Time, data = metadata)
summary(one.way3)
par(mfrow=c(2,2))
pdf('~/OneDrive - UBC/Writing/Papers/GCB/Supplement/residuals_het.pdf')
par(mfrow=c(2,2))
plot(one.way3)
dev.off()

two.way <- aov(Heterozygosity ~ Population * Year, data = metadata)
summary(two.way)

two.way2 <- aov(Heterozygosity ~ Population + Year, data = metadata)

two.way3 <- aov(Heterozygosity ~ Population:Year, data = metadata)
AIC(one.way, one.way2, one.way3, two.way3, two.way, two.way2)

tukeyOW <- TukeyHSD(one.way3)
tukeyOW
par(mfrow=c(1,1))
pdf('~/OneDrive - UBC/Writing/Papers/GCB/Supplement/tukey_posthoc_het.pdf')
plot(tukeyOW)
dev.off()


#####ROH
roh <- read.csv('final_roh.txt', sep = '\t', header = TRUE)
head(roh) 
library(tidyverse)
library(ggplot2)

NorthSea <- roh %>%
  filter(FID == 'NorthSea')
IsleOfMan <- roh %>%
  filter(FID == 'IsleOfMan')
CelticDowns <- roh %>%
  filter(FID == 'CelticDowns')
Lyminge <- roh %>%
  filter(FID == 'Lyminge')

head(roh)
roh$YBP <- as.numeric(roh$YBP)

roh$YBP[roh$FID == "NorthSea"] <- roh$YBP[roh$FID == "NorthSea"] + 50

roh <- roh %>%
  mutate(new_bin = cut(YBP, breaks = c(40,50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900, 950, 1000))) %>% drop_na()

head(roh)

bin_counts <- roh %>% 
  group_by(new_bin, FID) %>% drop_na()


mean_length <- roh %>% group_by(FID) %>%
  summarize(Mean_Length = mean(KB)) %>% drop_na()
head(mean_length)


total_length <- roh %>% group_by(FID) %>%
  summarize(total_length = sum(KB)) %>% drop_na()

num_roh <- roh %>% group_by(FID) %>%
  tally()

mean_length_ind <- roh %>% group_by(IID) %>%
  summarize(Mean_Length = mean(KB))
head(mean_length_ind)

total_length_ind <- roh %>% group_by(IID) %>%
  summarize(total_length = sum(KB))

num_roh_ind <- roh %>% group_by(IID) %>%
  tally()

total_num <- cbind(total_length, num_roh)
total_num_ind <- cbind(total_length_ind, num_roh_ind)

total_length_ind <- total_length_ind %>%
  mutate(FROH = (total_length/730000000))
head(total_length_ind)

total_num <- total_num %>%
  dplyr::select('FID', 'total_length', 'n')
head(mean_length)

total_num_ind <- total_num_ind %>%
  dplyr::select('IID','total_length', 'n')
total_num_ind

mean_length <- mean_length %>% mutate(FID = fct_reorder(FID, Mean_Length))

roh_dist <- ggplot(roh, aes(FID, KB)) + geom_boxplot() +
  ylab('Length (KB)') + theme_bw() + 
  xlab('FID') + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

roh_dist

num_roh <- ggplot(roh, aes(FID)) +
  geom_bar() + theme_bw() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ggtitle('Number ROH') + theme(plot.title = element_text(hjust = 0.5))
num_roh

roh.lm <- lm(n ~ total_length, total_num)
summary(roh.lm)

total_cov <- total_length_ind %>%
  mutate(Coverage = c(11.4,23.4,12.1,11,16.6,16.4,17.2,12.3))

total_cov

roh_cov.lm <- lm(FROH ~ Coverage, total_cov)
summary(roh_cov.lm)

roh_cov_length.lm <- lm(total_length ~ Coverage, total_cov)
summary(roh_cov_length.lm)

roh_vs_cov <- ggplot(total_cov, aes(Coverage, n, color = IID)) +
  geom_point() + 
  theme_bw() +
  geom_smooth()

roh_vs_cov

roh_vs_cov_length <- ggplot(total_cov, aes(Coverage, total_length, color = IID)) +
  geom_point() +
  theme_bw()

roh_vs_cov_length

num_vs_total <- ggplot(total_num, aes(total_length, n, color = FID)) +
  geom_point() +
  theme_bw() +
  xlab("Sum ROH") +
  ylab('Number of ROH')
num_vs_total + geom_smooth(method='lm')

num_vs_total_ind <- ggplot(total_num_ind, aes(total_length, n, color = IID)) +
  geom_point() +
  theme_bw() +
  xlab("Sum ROH") +
  ylab('Number of ROH')

#head(total_num_ind)
#head(total_length_ind)
num_vs_total_ind + geom_smooth(method='lm')
