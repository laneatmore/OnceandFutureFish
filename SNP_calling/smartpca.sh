#!/bin/bash

module load PLINK/1.9b_6.13-x86_64
module load Anaconda3/2019.03

export PS1=\$

source ${EBROOTANACONDA3}/etc/profile.d/conda.sh

conda deactivate &>/dev/null
conda activate /cluster/projects/nn9244k/python3

prefix=$1

plink --vcf $prefix.vcf.gz --keep-allele-order \
--allow-extra-chr --set-missing-var-ids @:# \
--recode \
--double-id \
--out $prefix

plink --file $prefix \
--allow-extra-chr --set-missing-var-ids @:# \
--make-bed \
--double-id \
--out $prefix

sed -i -e 's/-9/1/g' $prefix.ped
sed -i -e 's/-9/1/g' $prefix.fam

module --quiet purge
module load EIGENSOFT/7.2.1-foss-2019a

echo "genotypename: $prefix.bed" > $prefix.params.txt
echo "snpname: $prefix.bim" >> $prefix.params.txt
echo "indivname: $prefix.fam">> $prefix.params.txt
echo "outputformat: PACKEDANCESTRYMAP" >> $prefix.params.txt
echo "genooutfilename: $prefix.geno" >> $prefix.params.txt
echo "snpoutfilename: $prefix.snp" >> $prefix.params.txt
echo "indoutfilename: $prefix.ind" >> $prefix.params.txt

echo "genotypename: $prefix.geno" > $prefix.par
echo "snpname: $prefix.snp" >> $prefix.par
echo "indivname: $prefix.ind" >> $prefix.par
echo "evecoutname: $prefix.pca.evec" >> $prefix.par
echo "evaloutname: $prefix.pca.eval" >> $prefix.par
echo "altnormstyle: NO" >> $prefix.par
echo "lsqproject: YES" >> $prefix.par
echo "snpweightoutname: $1.SNP.loadings" >> $prefix.par
echo "numoutevec: 2" >> $prefix.par
echo "numoutlieriter: 0" >> $prefix.par
echo "numoutlierevec: 10" >> $prefix.par
echo "outliersigmathresh: 2" >> $prefix.par
echo "qtmode: 0" >> $prefix.par
echo "numchrom: 26" >> $prefix.par

convertf -p $prefix.params.txt

smartpca -p $prefix.par > $prefix.log

python fix_evec.py $prefix

#DONE
