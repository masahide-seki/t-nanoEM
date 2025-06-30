# Scripts for benchmarking of t-nanoEM

# Usage

## Histogram of read length

```bash
./Nanoplot.sh read.fq output
```

## Estimation of bait coverage and fold enrichment

Interval list needs to be created from target.bed using picard BedToIntervalList.
```bash
./Picard_CollectHsMetrics.sh input.bam target.interval_list reference_genome.fa output.txt
```


## Estimation of number of reads overlapping with target regions

./Estimate_overlapped_Reads_with_targets.sh input.bam Target.bed output.txt



## Count of CpGs covered by reads at or above threshold 

frequency_methylation.tsv is output of nanoEM pipeline (https://github.com/yos-sk/nanoEM)

```bash
perl CpG_coverage.pl frequency_methylation.tsv output.tsv
```


## Create correlation plot of CpG methylation

```bash
perl prep_input_for_correlation_plot.pl Sample1.bedgraph Sample2.bedgraph Sample1_vs_Sample2.tsv

Rscript Methylation_correlation.R Sample1_vs_Sample2.tsv Output.pdf Sample1 Sample2
```
