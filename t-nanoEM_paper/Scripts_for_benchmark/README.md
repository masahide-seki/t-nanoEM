# Scripts for benchmarking of t-nanoEM

## Histogram of read length

./Nanoplot.sh FASTQ_file Output_name

## Estimation of bait coverage and fold enrichment

./Picard_CollectHsMetrics.sh Input.bam Target_interval_file Reference_FASTA_file Output.txt

## Estimation of number of reads overlapping with target regions

./Estimate_overlapped_Reads_with_targets.sh BAM_file Target_BED_file Output.txt

## Count of CpGs covered by reads at or above threshold

perl CpG_coverage.pl nanoEM_pipeline_TSV_file Output.tsv


## Create correlation plot of CpG methylation

perl prep_input_for_correlation_plot.pl Sample1.bedgraph Sample2.bedgraph Sample1_vs_Sample2.tsv

Rscript Methylation_correlation.R Sample1_vs_Sample2.tsv Output.pdf Sample1 Sample2
