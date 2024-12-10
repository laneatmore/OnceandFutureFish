#!/bin/bash

module load VCFtools/0.1.16-GCC-11.3.0

prefix=$1
maf=$2
miss=$3

vcftools --gzvcf ${prefix}_HF.vcf.gz \
--minGQ 15 --minDP 3 --remove-indels --maf $maf --max-missing $miss \
--recode --out ${prefix}_HF.maf$maf.miss$miss

mv ${prefix}_HF.maf$maf.miss$miss.recode.vcf \
${prefix}_HF.maf$maf.miss$miss.vcf

module load HTSlib/1.15.1-GCC-11.3.0

bgzip ${prefix}_HF.maf$maf.miss$miss.vcf
tabix ${prefix}_HF.maf$maf.miss$miss.vcf.gz

module --quiet purge
module load GATK/4.3.0.0-GCCcore-11.3.0-Java-11

java -version
which java

echo "initiating GATK on ${1}"

gatk --java-options "-Xmx8g" SelectVariants \
-R /cluster/projects/nn9244k/databases/herring/ref_genome/Ch_v2.0.2.fasta \
-V ${prefix}_HF.maf$maf.miss$miss.vcf.gz \
--restrict-alleles-to BIALLELIC \
-O ${prefix}_HF.maf$maf.miss$miss.bi.vcf.gz
