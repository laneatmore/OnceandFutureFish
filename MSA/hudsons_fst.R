library(viridis)
library(ggplot2)
library(tidyverse)

setwd("~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/plink/data/download/fst_plink2/")
pairwise_fst <- read.csv("modern_HF.maf0.miss0.9.bi.split.fst.summary", sep = '\t', header = TRUE)
pairwise_fst <- read.csv("modern_HF.maf0.miss0.9.bi.split.OUTLIERS.fst.summary", sep = '\t', header = TRUE)
pairwise_fst$HUDSON_FST <- ifelse(pairwise_fst$HUDSON_FST < 0, 0, pairwise_fst$HUDSON_FST)

ggplot(pairwise_fst, aes(X.POP1, fct(POP2), 
                         fill = HUDSON_FST)) + 
  geom_tile() + 
  geom_text(aes(label = round(HUDSON_FST, 3))) +
  labs(x = NULL, y = NULL) +
  theme_bw()
