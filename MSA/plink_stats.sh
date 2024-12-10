#!/bin/bash

module --quiet purge
module load PLINK/1.9b_6.13-x86_64

#calculate heterozygosity, Fst 
prefix=$1

plink --bfile $prefix \
--freq 'gz' --hardy 'gz' --het 'gz' --missing 'gz' --fst 'hudson '\
--family --chr-set 26 --double-id --out stats/$prefix

