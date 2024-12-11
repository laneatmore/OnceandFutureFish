#!/bin/bash

#first do pruning with Plink, output a new VCF, and then convert to treemix with vcf2treemix.sh (from Joana Meier)
#prep .clust file from populations

#run treemix for up to 5 migration edges

prefix=$1

for i {0..10}; do \
for m in {0..5}; do \
treemix -i $prefix.treemix.frq.gz -o $prefix.$i.$m -root pallasii -bootstrap -k 500 \
> treemix_${prefix}_${i}_${m}_log ; done ; done

#plot this in R 
