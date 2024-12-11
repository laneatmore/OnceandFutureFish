#!/bin/bash

cat *.MT.fasta > ALL_Herring.MT.fasta

module load MAFFT/7.453-GCC-8.3.0-with-extensions
module load IQ-TREE/1.6.12-foss-2018b

mafft --quiet ALL_Herring.MT.fasta > ALL_Herring.MT.aligned.fasta

iqtree -s ALL_Herring.MT.aligned.fasta

#DONeE
