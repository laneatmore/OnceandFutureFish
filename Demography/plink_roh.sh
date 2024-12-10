#!/bin/bash

module load PLINK/1.9b_6.13-x86_64

prefix=$1

plink --bfile $prefix.cleaned --chr-set 26 --double-id \
--homozyg-snp 50 --homozyg-kb 90 --homozyg-density 50 \
--homozyg-gap 1000 --homozyg-window-snp 50 \
--homozyg-window-het 3 --homozyg-window-missing 10 \
--homozyg-window-threshold 0.05 --out $prefix.pval1e6.final.100kb

