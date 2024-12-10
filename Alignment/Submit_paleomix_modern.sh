#!/bin/bash

module restore R_paleomix

#then load the dependencies
module load Python/3.10.4-GCCcore-11.3.0
module load AdapterRemoval/2.3.3-GCC-11.3.0
module load BWA/0.7.17-GCCcore-11.3.0
module load SAMtools/1.16.1-GCC-11.3.0

#activate the paleomix environment
source ~/paleomix/bin/activate

echo "Paleomix env activated"

#create individual makefiles
#Don't forget to use the updated makefile format! Some options have been deprecated in new 
#version of paleomix
cat core_herring_make_modern.yaml $1 > core_yaml_${1}

echo "Running paleomix on ${1}"

#make sure you have used bwa to index your reference genome before running
#there seems to be a bug if you do it through paleomix

#run Paleomix
paleomix bam run core_yaml_${1} \
--max-threads 5 \
--bwa-max-threads 4 

echo "Paleomix run is done"
