#!/bin/sh

#Bam file of t-nanoEM or nanoEM
BAM=$1

#Interval list converted from bed file
INTERVALS=$2

#Fasta file of reference genome
REF=$3

#Name of output file
OUT=$4

picard CollectHsMetrics -Xmx90g  -INPUT $BAM \
-BAIT_INTERVALS $INTERVALS \
-TARGET_INTERVALS $INTERVALS \
-NEAR_DISTANCE 5000 \
-OUTPUT $OUT \
-VALIDATION_STRINGENCY SILENT \
-REFERENCE_SEQUENCE  $REF
