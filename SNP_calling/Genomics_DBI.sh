#!/bin/bash

module load GATK/4.4.0.0-GCCcore-12.2.0-Java-17

prefix=$1
chr=$2

gatk --java-options "-Xmx8g -Xms8g" \
        GenomicsDBImport \
        --genomicsdb-workspace-path ${prefix}_${chr}_db \
  --sample-name-map ${prefix}.sample_map.${chr} \
  --L $chr

gatk --java-options "-Xmx8g -Xms8g" \
        GenotypeGVCFs \
  -R /cluster/projects/nn9244k/databases/herring/ref_genome/Ch_v2.0.2.fasta \
  -L $chr \
  -V gendb://${prefix}_${chr}_db \
  -O ${prefix}.${chr}.raw.vcf.gz
