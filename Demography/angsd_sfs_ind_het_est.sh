#!/bin/bash
#SBATCH --account=nn9244k
#SBATCH --time=8:00:00
#SBATCH --job-name=angsd_theta
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

set -o errexit

module --quiet purge
module load angsd/0.940-GCC-11.2.0

prefix=$1
REF=/cluster/projects/nn9244k/databases/herring/ref_genome/Ch_v2.0.2
PATH_TO_BAMs=/cluster/work/users/lanea/angsd/data/bam_files/

angsd -i $PATH_TO_BAMs/$prefix.Her_nu.bam -anc $REF.fasta -dosaf 1 \
-ref $REF.fasta -C 50 \
-minMapQ 30 -minQ 20 -rmTrans 1 -remove_bads 1 -only_proper_pairs 1 \
-trim 0 -setMinDepth 5 -setMaxDepth 60 \
-doMajorMinor 2 -doCounts 1 -doMaf 1 -gl 1 -out $prefix.folded

realSFS $prefix.folded.saf.idx -fold 1 > het_est/$prefix.folded.est.ml
