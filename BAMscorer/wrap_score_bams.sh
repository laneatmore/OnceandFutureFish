#!/bin/bash

module --quiet purge
module load VCFtools/0.1.16-intel-2018b-Perl-5.28.0
module load SAMtools/1.9-intel-2018b
module load Anaconda3/2019.03

#activate conda environment
export PS1=\$

source ${EBROOTANACONDA3}/etc/profile.d/conda.sh

conda deactivate &>/dev/null
conda activate /cluster/projects/nn9244k/python3

###$1 is VCF
###$2 is OUT
###$3 is CUT_OFF
###$4 is BAM dir
###$5 is IND

#for ind in $(less downsampled.list); do for c in $(less cut_offs.list);
#do sbatch WRAPbams_iter.sh $VCF $OUT $c
#/cluster/work/users/lanea/BAMs/modern/downsampled/downsampled_${ind} $ind; done; done

mkdir $SCRATCH/BAMS

##Copy all BAMfiles to scratch


cd $3

for f in $(ls *.bam)

do

echo $f

mkdir -p temp_$f

#Get list of readnames from the BAM file
samtools view $f |awk '{print $1}' > temp_$f/list_read_names_$f

#Get total number of reads BAM file
read_n=$(wc -l temp_$f/list_read_names_$f |cut -d " " -f 1)

if [[ 60000 -gt $read_n ]]; then echo "WARNING, SOURCE BAM has too few reads to score" ; else echo "BAM file contains a sufficient number of reads for scoring" ; fi

echo "Total read number is $read_n"

if ! [[ 60000 -gt $read_n ]]; then rsync -Lav $f $SCRATCH/BAMS ; fi

done

rsync -Lav $1 $SCRATCH

#set output name

VCF=$1
OUT=$2

cd $SUBMITDIR

#MAKE SURE YOU HAVE AA, BB, divergent_snps, freq, and db LISTS THAT MATCH THE NEW OUTPUT NAME

#ABS=$4 #if you were going to change the cut off in absolute difference between SNP frequencies
#we're still testing this parameter, it was not necessary for inversions

rsync -Lav $OUT* $SCRATCH

echo "List SCRATCH directory..."
ls $SCRATCH

echo "List BAM directory..."
ls $SCRATCH/BAMS

cd $SCRATCH

#BAMS=$3

python /cluster/home/lanea/BAMscorer_v1.6_linux score_bams $VCF $OUT BAMS --wg

mkdir -p $SUBMITDIR/OUTPUT_$2

cp $2_scores.txt $SUBMITDIR/OUTPUT_$2/${4}_spawning_scores.txt


### REPEAT for LG01, LG02, LG07 and LG12, plus WGS; NOTE that the cut_off scores should change correspondingly$

