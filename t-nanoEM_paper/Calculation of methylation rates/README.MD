# Script for calculation of methylate frequencies for separated reads

# Requirement

Perl

Python

nanoEM pipeline (https://github.com/yos-sk/nanoEM)

Sambamba (https://lomereiter.github.io/sambamba/)

Samtools (https://www.htslib.org/)



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
