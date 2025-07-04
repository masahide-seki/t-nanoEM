#!/bin/sh

INPUT=$1
CPG=$2
REF=$3


#Convert SAM to BAM and create index 
samtools view -bS $INPUT.CT.snv.sam -o $INPUT.CT.snv.bam
samtools view -bS $INPUT.GA.snv.sam -o $INPUT.GA.snv.bam
samtools view -bS $INPUT.CT.nosnv.sam -o $INPUT.CT.nosnv.bam
samtools view -bS $INPUT.GA.nosnv.sam -o $INPUT.GA.nosnv.bam

samtools index $INPUT.CT.snv.bam
samtools index $INPUT.GA.snv.bam
samtools index $INPUT.CT.nosnv.bam
samtools index $INPUT.GA.nosnv.bam

#Calculation of methylation status on allele with SNVs
sambamba mpileup $INPUT.CT.snv.bam -L $CPG -o ${INPUT}_pileup_CT_snv.tsv -t 8 --samtools -f $REF
sambamba mpileup $INPUT.GA.snv.bam -L $CPG -o ${INPUT}_pileup_GA_snv.tsv -t 8 --samtools -f $REF
python  call_methylation.py ${INPUT}_pileup_CT_snv.tsv ${INPUT}_pileup_GA_snv.tsv > ${INPUT}_frequency_methylation_snv.tsv  #call_methylation.py is a part of nanoEM pipeline

#Calculation of methylation status on allele without SNVs
sambamba mpileup $INPUT.CT.nosnv.bam -L $CPG -o ${INPUT}_pileup_CT_nosnv.tsv -t 8 --samtools -f $REF
sambamba mpileup $INPUT.GA.nosnv.bam -L $CPG -o ${INPUT}_pileup_GA_nosnv.tsv -t 8 --samtools -f $REF
python  call_methylation.py ${INPUT}_pileup_CT_nosnv.tsv ${INPUT}_pileup_GA_nosnv.tsv > ${INPUT}_frequency_methylation_nosnv.tsv

gzip frequency_methylation_snv.tsv
gzip frequency_methylation_nosnv.tsv
