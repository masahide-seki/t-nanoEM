#!/bin/sh

INPUT=$1
CPG=$2
REF=$3

#Convert SAM to BAM and create index 
samtools view -bS $INPUT.CT.h1.sam -o $INPUT.CT.h1.bam
samtools view -bS $INPUT.GA.h1.sam -o $INPUT.GA.h1.bam
samtools view -bS $INPUT.CT.h2.sam -o $INPUT.CT.h2.bam
samtools view -bS $INPUT.GA.h2.sam -o $INPUT.GA.h2.bam

samtools index $INPUT.CT.h1.bam
samtools index $INPUT.GA.h1.bam
samtools index $INPUT.CT.h2.bam
samtools index $INPUT.GA.h2.bam

#Calculation of methylation status on haplotype1
sambamba mpileup $INPUT.CT.h1.bam -L $CPG -o ${INPUT}_pileup_CT_h1.tsv -t 8 --samtools -f $REF
sambamba mpileup $INPUT.GA.h1.bam -L $CPG -o ${INPUT}_pileup_GA_h1.tsv -t 8 --samtools -f $REF
python  call_methylation.py ${INPUT}_pileup_CT_h1.tsv ${INPUT}_pileup_GA_h1.tsv > ${INPUT}_frequency_methylation_h1.tsv #call_methylation.py is a part of nanoEM pipeline

#Calculation of methylation status on haplotype2
sambamba mpileup ${INPUT}.CT.h2.bam -L $CPG -o ${INPUT}_pileup_CT_h2.tsv -t 8 --samtools -f $REF
sambamba mpileup ${INPUT}.GA.h2.bam -L $CPG -o ${INPUT}_pileup_GA_h2.tsv -t 8 --samtools -f $REF
python  call_methylation.py ${INPUT}_pileup_CT_h2.tsv ${INPUT}_pileup_GA_h2.tsv > ${INPUT}_frequency_methylation_h2.tsv #call_methylation.py is a part of nanoEM pipeline


gzip ${INPUT}_frequency_methylation_h1.tsv
gzip ${INPUT}_frequency_methylation_h2.tsv
