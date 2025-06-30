#!/bin/sh

#Bam file of t-nanoEM or nanoEM
BAM=$1

#Bed file of targets sites
BED=$2

#Name of output file
OUT=$3

bamToBed -i $BAM | bedtools intersect -a stdin -b $BED -wa | cut -f4 | sort | uniq | wc -l > $OUT
