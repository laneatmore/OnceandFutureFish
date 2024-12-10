library(pcadapt)
library(devtools)
######https://bcm-uga.github.io/pcadapt/articles/pcadapt.html
#PCAdapt v4

setwd("~/OneDrive - Universitetet i Oslo/Bioinformatics/Papers/North_Sea/plink/data/download/")

path_to_file <- 'modern_HF.maf0.miss0.9.bi.split.renamed.bed'
filename <- read.pcadapt(path_to_file, type = 'bed')
x <- pcadapt(input = filename, K = 10)
plot(x, option = 'screeplot')

poplist.names <- c(rep("CelticSea", 2), rep("Downs", 3), rep("WBAS", 3), rep("CBAS", 2),
                   rep("NEAS", 1), rep("NorthSea", 3), rep("IsleOfMan", 2), rep("NEAS", 7),
                   rep("Transition", 7), rep("GSS", 3), rep("CBSS", 3), rep("Transition", 3),
                   rep("CBSS", 3), rep("Transition", 12), rep("CBSS",1), rep("NEAS", 1),
                   rep("GSS",3), rep("CBSS", 3), rep("Transition",6))
plot(x, option = "scores", pop = poplist.names)

plot(x, option = "scores", i = 3, j = 4, pop = poplist.names)
plot(x, option = "scores", i = 2, j = 3, pop = poplist.names)

#K=2 seems the best option
#look at the manhattan plot
##have to make sure the choice of K is biologically significant to get
#meaningful results

x <- pcadapt(filename, K=2, min.maf=0.01)
summary(x)
pdf('manhattan.pdf')
plot(x, option = 'manhattan')
dev.off()

##Looking for outliers
plot(x, option = 'qqplot')
hist(x$pvalues, xlab = "P-Values", main = NULL, breaks = 50, col = "orange")
plot(x, option = "stat.distribution")


##How do we choose a cut-off value for the outliers?
##1. Q-Values
library(qvalue)
#We want to use a potential false discovery rate of less than 10% (alpha)
qval <- qvalue(x$pvalues)$qvalues
alpha <- 0.1
outliers <- which(qval < alpha)
non_outliers <- which(qval > alpha)
head(non_outliers)
length(outliers)
#there are 239462 outliers (whoa)


#alternatively, use the Bonferroni correction
padj <- p.adjust(x$pvalues, method = 'bonferroni')
alpha <- 0.1
outliers <- which(padj < alpha)
non_outliers <- which(padj > alpha)
head(non_outliers)
length(outliers)
#Now at 68718

####LD-thinning (do we want to do this?)
#just to check it out...
par(mfrow = c(1,2))
for (i in 1:2)
  plot(x$loadings[,i], pch=19, cex = .3, ylab = paste0("Loadings PC", i))

#well, there are a couple of inversions that show up, so let's just see
x <- pcadapt(filename, K=2, LD.clumping = list(size = 200, thr=0.1))
plot(x, option = 'screeplot')
#K=2 still
#check what PC loadings look like after LD pruning
for (i in 1:2)
  plot(x$loadings[,i], pch=19, cex = .3, ylab = paste0("Loadings PC", i))
#there is still a bigger chunk right around chr12, but we know there are 
#lots of SNPs under adaptation there anyways
plot(x)
#FAR fewer SNPs here, we can still see the inversions in the plot

#now do a bonferroni correction
padj <- p.adjust(x$pvalues, method = 'bonferroni')
alpha <- 0.1
outliers <- which(padj < alpha)
outliers_pc <- get.pc(x, outliers)
head(outliers_pc)
length(outliers)
#with the bonferroni correction there are 10,874 SNPs as outliers
head(outliers)
length(padj)

write.table(outliers, "outliers_list.txt", col.names = FALSE, row.names = FALSE)
