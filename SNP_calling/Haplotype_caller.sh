#!/bin/bash

java -version
which java
echo "Initiating GATK on ${1}"

prefix=$1
chr=$2

#for i in {1..26}; do # for each chromosome in the list
#    {
gatk --java-options "-Xmx8g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" HaplotypeCaller \
-VS STRICT \
-R /cluster/projects/nn9244k/databases/herring/ref_genome/Ch_v2.0.2.fasta \
-I /cluster/work/users/lanea/new_BAMs/modern/$prefix.Her_nu.bam \
-ploidy 2 \
-ERC GVCF \
-L $chr \
-O /cluster/work/users/lanea/new_BAMs/all_gVCFs_nu/$prefix.$chr.g.vcf.gz \
2> /cluster/work/users/lanea/new_BAMs/all_gVCFs_nu/Haplotype_caller.$prefix.$chr.out
#    }; done
