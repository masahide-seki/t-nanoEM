# Script for calculation of methylate frequencies for separated reads

# Requirement

Perl

Python

nanoEM pipeline (https://github.com/yos-sk/nanoEM)

Sambamba (https://lomereiter.github.io/sambamba/)

Samtools (https://www.htslib.org/)

Bed file of positions of CpG

metilene (http://legacy.bioinf.uni-leipzig.de/Software/metilene/)



# Usage



## Calculation of methylation frequency for each haplotype

Intermediate files (XXX.CT.sorted.bam and XXX.GA.sorted.bam) from the nanoEM pipeline and bam file harboring phase information are required.

```bash
perl methyl_phase.pl phased_reads.bam prefix_of_sorted_CT_GA_bam

./methyl_phase.sh prefix_of_sorted_CT_GA_bam CpG_sites.bed reference_genome.fa
```
Methylation frequency files for each haplotype are generated.



## Calculation of methylation frequency for allele with/without SNVs

Intermediate files (XXX.CT.sorted.bam and XXX.GA.sorted.bam) from the nanoEM pipeline and bam file whether harboring somatic SNVs are required.

```bash
perl methyl_snv.pl reads_info_SNV.bam prefix_of_sorted_CT_GA_bam

./methyl_phase.sh prefix_of_sorted_CT_GA_bam CpG_sites.bed reference_genome.fa
```

Methylation frequency files for allele with and without SNV are generated.



##Conversion from methylation frequency file to bedgraph file

```bash
perl nanoEM_tsv_To_bedgraph.pl input.tsv output.bedgraph coverage_threshold
```



##DMR calling using metilene

```bash
./DMR_call.sh input1.sorted.bedgraph input2.sorted.bedgraph name_of_input1 name_of_input2
```
