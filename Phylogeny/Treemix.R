library(dplyr)
library(ggplot2)
library(forcats)
library(tidyverse)

setwd("~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/treemix/treemix")
source("~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/treemix/treemix-1.13/src/plotting_funcs.R")

#optm will loop through to optimize the migration edge
setwd("~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/treemix/for_optm/")
folder <- system.file('../for_optm/', package = 'OptM')
library(OptM)
library(SiZer)
test.optM = optM('../for_optm/', tsv = "treemix.ALL_HF.maf0.01.miss1.bi.noInv.pruned.optM.tsv")

test.sizer = optM('../for_optm', tsv = "treemix.ALL_HF.maf0.01.miss1.bi.noInv.pruned.optm_sizer.tsv", method = "SiZer")

plot_optM(test.optM,
          method = "Evanno")

plot_optM(test.sizer, 
          method = "SiZer", pdf = "treemix.ALL_HF.maf0.01.miss1.bi.noInv.pruned.optm_sizer.pdf")

test.linear = optM('../for_optm', tsv = "treemix.ALL_HF.maf0.01.miss1.bi.noInv.pruned.optm_sizer.tsv", method = "linear")

plot_optM(test.linear,
          method = "linear", pdf = "treemix.ALL_HF.maf0.01.miss1.bi.noInv.pruned.optm_linear.pdf")

###Evanno method identified M=1 as the optimal M
library(BITEV2)

treemix.scripts()
setwd("~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/treemix/download")

pdf('~/OneDrive - UBC/Writing/Papers/GCB/Supplement/Treemix_updated.pdf')
treemix.bootstrap("treemix.m1.out.bootstrapped", 
                  out.file='treemix.consensus.pdf',
                  "treemix.m1.out.bootstrapped_outtree.newick", 
                  plotboot=FALSE,
                  pop.color.file = NULL,100)
dev.off()
