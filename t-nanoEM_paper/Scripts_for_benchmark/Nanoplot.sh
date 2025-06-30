#!/bin/sh

#Fastq file of t-nanoEM or nanoEM reads
FASTQ=$1

#Name of output directory
OUT=$2

mkdir $OUT

NanoPlot --fastq 1d_pass.fq.gz --maxlength 20000 --no-N50 -o $OUT
