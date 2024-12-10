#!/bin/bash

set -o errexit #Make bash exit on any error
set -o nounset #Treat any unset variable as errors

#Set up the job environment
module purge

prefix=$1

touch $prefix.sample_map
cat $prefix.list | grep -v "RAZ" - | while read line; \
do echo ${line}; \
for i in {1..26}; \
do echo -e "${line}\t${line}.Her_nu.${i}.g.vcf.gz" >> $prefix.sample_map.${i}; \
done; done

#DONE
