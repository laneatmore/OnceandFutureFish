library(tidyverse)
library(dartR)
library("adegenet")
library("ape")
library("pegas")
library("seqinr")
library("ggplot2")
library("vcfR")

#First look at missingness per individual for the diagnostic SNPs
setwd('~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/MSA_binsa/binsa_sites/')

ind_miss <- read_delim('stats/binsa_only_filtered.imiss', delim = "\t",
                       col_names = c("ind", "ndata", 
                                     "nfiltered", "nmiss", "fmiss"), skip = 1)
a <- ggplot(ind_miss, aes(ind, nmiss)) + geom_point() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
a

dev.off()
#convert vcf to genlight object
vcf <- read.vcfR("binsa_diagnostic_MODERN.recode.vcf")
vcf

genlight_binsa <- vcfR2genlight(vcf)
genlight_binsa
head(genlight_binsa)
genlight_binsa$ind.names
pop(genlight_binsa)

##here NorthSea3 is coded as Downs 
pop(genlight_binsa) <- as.factor(c("IsleOfMan",
                                   "IsleOfMan",
                                   "Downs",
                                   "Downs",
                                   "Downs",
                                   "CelticSea",
                                   "CelticSea",
                                   "NorthSea",
                                   "Downs",
                                   "NorthSea"))

popNames(genlight_binsa)
ploidy(genlight_binsa) <- 2

toRemove <- is.na(glMean(genlight_binsa, alleleAsUnit = FALSE)) # TRUE where NA
which(toRemove) # position of entirely non-typed loci
genlight_binsa <- genlight_binsa[, !toRemove]
glPca(b)
#create distance matrix
dist <- dist(genlight_binsa)

###DAPC ANALYSIS 
#First use find.clusters to see what it looks like
grp <- find.clusters(genlight_binsa)
names(grp)
#visualized clusters by population labels/ind
table(pop(genlight_binsa), genlight_binsa$pop)
table(pop(genlight_binsa), grp$grp)
table.value(table(pop(genlight_binsa), grp$grp), col.lab=paste("inf", 1:6),
            row.lab=paste("ori", 1:19))
#Then optimize the PCs and discriminate functions for DAPC (1 each apparently)
dapc1 <- dapc(genlight_binsa, n.da=100, n.pca=15)

temp <- a.score(dapc1)
temp <- optim.a.score(dapc1)
dapc1 <- dapc(genlight_binsa, n.da=2, n.pca=2)
#Now plot the density function (no scatterplot for k=2)
pdf("../../PLOTS/COMBINED_SNPs_northsea_asDowns.pdf")
dapc1 <- dapc(genlight_binsa, n.da=1, n.pca=1)
scatter(dapc1, legend=TRUE)
dapc1 <- dapc(genlight_binsa, n.da=2, n.pca=2)
scatter(dapc1, legend=TRUE)
#Now plot a STRUCTURE-like plot to look at percent assignment to each population
par(mar=c(5.1,4.1,1.1,1.1), xpd=TRUE)
lab <- indNames(genlight_binsa)
compoplot(dapc1, show.lab=TRUE, lab=lab, lab.cex=0.3, posi=list(x=2,y=1.1), cleg=.7)
dev.off()

####Time to add the ancient individuals

##first create a second object
vcf2 <- read.vcfR("binsa_diagnostic_ANCIENT.recode.vcf")

ind_miss <- read_delim('stats/binsa_diagnostic_sites_filtered.ALL.imiss', delim = "\t",
                       col_names = c("ind", "ndata", 
                                     "nfiltered", "nmiss", "fmiss"), skip = 1)
a <- ggplot(ind_miss, aes(ind, nmiss)) + geom_point() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ylim(0,20)
a

vcf2
genlight_binsa2 <- vcfR2genlight(vcf2)
genlight_binsa2
head(genlight_binsa2)
genlight_binsa2$ind.names
pop(genlight_binsa2)

pop(genlight_binsa2) <- as.factor(c("HuysdenStruys",
                                   "HuysdenStruys",
                                   "Coppergate",
                                   "Coppergate",
                                   "BBL",
                                   "Lyminge",
                                   "Lyminge",
                                   "Lyminge"))

popNames(genlight_binsa2)
ploidy(genlight_binsa2) <- 2
toRemove <- is.na(glMean(genlight_binsa2, alleleAsUnit = FALSE)) # TRUE where NA
which(toRemove) # position of entirely non-typed loci
genlight_binsa2 <- genlight_binsa2[, !toRemove]
#glPca(b)
genlight_binsa
genlight_binsa2
###Now predict where they come from
pred.sup <- predict.dapc(dapc1, newdata=genlight_binsa2)
names(pred.sup)
head(pred.sup$assign)
pred.sup$ind.scores
pred.sup$posterior

par(mar=c(5.1,4.1,1.1,1.1), xpd=TRUE)
lab <- indNames(genlight_binsa)
compoplot(dapc1, show.lab=TRUE, lab=lab, lab.cex=0.3, posi=list(x=2,y=1.1), cleg=.7)
pdf("../../PLOTS/binsa_ANCIENT_assigned_probs.pdf")
lab2 <- indNames(genlight_binsa2)

pdf('~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/PLOTS/FINAL/ancient_assignment.pdf')
compoplot(pred.sup$posterior, show.lab=TRUE, lab=lab2, lab.cex=0.3, posi=list(x=2,y=1.1), cleg=.7)
dev.off()

scatter(dapc1, col=col, legend=TRUE)
par(xpd=TRUE)
#col.sup <- col[as.integer(pop(genlight_binsa2))]
col <- rainbow(length(levels(pop(genlight_binsa))))

col.points <- transp(col[as.integer(pop(genlight_binsa))],.2)
col.sup <- col[as.integer(pop(genlight_binsa2))]
points(pred.sup$ind.scores[,1], pred.sup$ind.scores[,2], pch=15, col=col.sup, cex=2)
plot(pred.sup$ind.scores[,1], pred.sup$ind.scores[,2], pch=15, col=col.sup, cex=2)

####Jost's D and dXY for diagnostic loci
dev.off()
library(mmod)
library(reshape2)
vcf <- read.vcfR("binsa_diagnostic_MODERN.recode.vcf")
vcf <- read.vcfR("binsa_diagnostic_ONLY.vcf")
x <- vcfR2genind(vcf)
x2 <- vcfR2genlight(vcf)
x@hierarchy

#create distance matrix
dist <- dist(x2)

#genlight_binsa2$ind.names
pop(x) <- as.factor(c("Z14_IsleOfMan",
                                   "Z4_IsleOfMan",
                                   "AK1_Downs",
                                   "AK2_Downs",
                                   "AK3_Downs",
                                   "AAL2_CelticSea",
                                   "AAL3_CelticSea",
                                   "NorthSea34",
                                   "NorthSea13_Downs",
                                   "NorthSea19",
                                   "HER065_HuisdenStruys",
                                   "HER067_HuisdenStruys",
                                   "HER102_Coppergate",
                                   "HER109_Coppergate",
                                   "HER127_BBL",
                                   "HER132_Lyminge",
                                   "HER133_Lyminge",
                                   "HER135_Lyminge"))
pop(x) <- as.factor(c("IsleOfMan",
                      "IsleOfMan",
                      "Downs",
                      "Downs",
                      "Downs",
                      "CelticSea",
                      "CelticSea",
                      "NorthSea",
                      "Downs",
                      "NorthSea"))

pop(x) <- as.factor(c("21st","21st","21st", "21st","21st",
               "21st","21st","20th","21st","20th",
               "16th","16th","11th","10th","14th",
               "8th","8th","8th"))

Population <- as.data.frame(pops_list)
strata(x) <- Population
x@strata

pop(x) <- as.factor(c("Modern","Modern","Modern", "Modern","Modern",
                      "Modern","Modern","Modern","Modern","Modern",
                      "Ancient","Ancient","Ancient","Ancient","Ancient",
                      "Ancient","Ancient","Ancient"))

x@pop
all_jost <- D_Jost(x, hsht_mean = "arithmetic")
all_jost

diff_stats(x, phi_st = FALSE)

genetic_diff(vcf, x$pop, method = "jost")
####sort out which column is which and also calculate fst

colMeans(all_jost[,c(3:8,11)], na.rm = TRUE)

jost <- as.matrix(pairwise_D(x, hsht_mean= "arithmetic"))
jost

library(graph4lg)
jost <- as.matrix(jost)
jost.order <- c('IsleOfMan', 'IsleOfMan 14th', 'IsleOfMan 8th',
              'Downs', "Downs 16th", 'Downs 11th', 'Downs 10th', 'Downs 8th',
              'CelticSea', 'NorthSea', 'NorthSea 16th')
jost <- reorder_mat(jost, jost.order)

jost <- pmax(jost, 0)

get_upper_tri <- function(jost){
  jost[lower.tri(jost)] <- NA
  return(jost)
}  

get_lower_tri <- function(jost){
  jost[upper.tri(jost)] <- NA
  return(jost)
}  

upper <- get_upper_tri(jost)
lower <- get_lower_tri(jost)

meltNum <- melt(lower, na.rm = T)
meltColor <- melt(upper, na.rm = T)
head(meltNum)

pdf('~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/PLOTS/JostsD_diagnosticSNPs_individual.pdf')
ggplot()+ labs(x=NULL, y=NULL) +
  geom_tile(data=meltColor,
            mapping = aes(Var2, Var1, fill=value)) +
  geom_text(data=meltNum,mapping=aes(Var2,Var1, label=round(value, digit=2))) +
              scale_x_discrete() +
              scale_fill_gradient(low="white", high = "red",
                                  limit=c(0,0.5), name = "Jost's D") +
               theme(plot.title = element_text(hjust = 0.5, face = "bold"),
                     panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     panel.background = element_blank()) +
               coord_fixed() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

dev.off()

