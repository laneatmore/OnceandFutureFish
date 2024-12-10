#!/bin/bash

module load plink/1.9b_6.21-x86_64

prefix=$1

plink --vcf $prefix.vcf.gz \
--recode --allow-extra-chr --chr-set 26 no-xy no-mt \
--double-id \
--allow-no-sex \
--set-missing-var-ids @:# \
--out ../PLINK/$prefix

plink --file ../PLINK/$prefix \
--make-bed --allow-extra-chr --chr-set 26 no-xy no-mt \
--double-id \
--set-missing-var-ids @:# \
--allow-no-sex \
--out ../PLINK/$prefix

plink --bfile ../PLINK/$prefix \
--chr-set 26 no-xy no-mt --double-id \
--exclude range ../PLINK/inversions.list \
--allow-no-sex \
--make-bed --out ../PLINK/$prefix.noInv

plink --bfile ../PLINK/$prefix.noInv \
--chr-set 26 no-xy no-mt --double-id \
--indep-pairwise 100 10 0.5 \
--allow-no-sex \
--out ../PLINK/$prefix.noInv

plink --bfile ../PLINK/$prefix.noInv \
--extract ../PLINK/$prefix.noInv.prune.in \
--make-bed --chr-set 26 no-xy no-mt --double-id \
--allow-no-sex \
--out ../PLINK/$prefix.noInv.pruned

plink --bfile ../PLINK/$prefix \
--chr-set 26 no-xy no-mt --double-id \
--indep-pairwise 100 10 0.5 \
--allow-no-sex \
--out ../PLINK/$prefix \

plink --bfile ../PLINK/$prefix \
--extract ../PLINK/$prefix.prune.in \
--make-bed --chr-set 26 no-xy no-mt --double-id \
--allow-no-sex \
--out ../PLINK/$prefix.pruned

sort -R ../PLINK/$prefix.noInv.pruned.bim | head -50000 | awk '{print$2}' > ../PLINK/$prefix.noInv.pruned.50k.snps

plink --bfile ../PLINK/$prefix.noInv.pruned \
--chr-set 26 --double-id \
--extract ../PLINK/$prefix.noInv.pruned.50k.snps \
--allow-no-sex --recode-structure --out ../PLINK/$prefix.noInv.pruned.50k

for fam in $(awk '{print $1}' ../PLINK/$prefix.noInv.fam | sort | uniq); do echo $fam | plink \
--bfile ../PLINK/$prefix.noInv --keep-fam /dev/stdin --make-bed --chr-set 26 no-xy no-mt --double-id \
--allow-no-sex --recode --out ../PLINK/for_gone/$fam.$prefix.noInv; done 

