# t-nanoEM
Scripts for t-nanoEM analysis

# Requirement

Perl

Bioperl

samtools

Java

picard

# Usage

## Construction of phase using nanoEM or t-nanoEM reads
### Conversion of vcf file to bed file of heteroSNP

```bash
perl vcf_hetero_bed.pl variant.vcf heteroSNP.bed
```

### Optional: Duplication removal from bamfile of t-nanoEM (or nanoEM) generated from the nanoEM pipeline (https://github.com/yos-sk/nanoEM)

```bash
picard MarkDuplicates -Xmx80g -INPUT tnanoEM.bam -OUTPUT tnanoEM.rmdup.bam -REMOVE_DUPLICATES true -M tnanoEM.rmdup.metrics.txt

samtools index tnanoEM.rmdup.bam
```

### Marking supplementary alignment reads in bamfile of t-nanoEM (or nanoEM)

```bash
perl rename_supplementary.pl  tnanoEM.rmdup.bam (or tnanoEM.bam) | samtools view -bS | samtools sort -o tnanoEM_rn_sup.bam

samtools index tnanoEM_rn_sup.bam
```
### Extraction of sequence of each read on positions with heteroSNP

```bash
samtools mpileup -q 0 -Q 0 -l heteroSNP.bed  -f reference_genome.fa --output-QNAME tnanoEM_rn_sup.bam > tnanoEM.mpu.txt

perl read_names_per_heteroSNP.pl heteroSNP.bed tnanoEM.mpu.txt >  > read_names_per_heteroSNP.txt
```

### Generation of pseudo-bam file with sequence information on only positions with heteroSNP

```bash
perl pseudo_phasing_input_mod.pl -i read_names_per_heteroSNP.txt -o pseudo_read_without_header.sam -m 0 -s 0

samtools view -H | cat pseudo_read_without_header.sam > pseudo_read.sam

samtools view -bS pseudo_read.sam | samtools sort -o pseudo_read.bam

samtools index pseudo_read.bam
```

### Phasing heteroSNPS using pseudo-reads

```bash
whatshap phase -o phased.vcf --reference=reference_genome.fa variant.vcf pseudo_read.bam --ignore-read-group

bgzip phased.vcf

tabix -c vcf phased.vcf.gz
```

### Optional: Force unphased heteroSNPs to be assigned to either haplotype

```bash
perl force_phase.pl phased.vcf.gz force_phased.vcf

bgzip force_phased.vcf

tabix -c vcf force_phased.vcf.gz
```

### Phasing of nanoEM or t-nanoEM reads with phased SNP

```bash
whatshap haplotag -o pseudo_read.tagged.bam --reference reference_genome.fa --ignore-read-groups force_phased.vcf.gz (or phased.vcf.gz) pseudo_read.bam

samtools sort pseudo_read.tagged.bam -o pseudo_read.tagged.bam

samtools index pseudo_read.tagged.bam

perl add_phase.pl tnanoEM_rn_sup.bam pseudo_read.tagged.bam tnanoEM.tagged.sam

samtools view -bS tnanoEM.tagged.sam | samtools sort -o tnanoEM.tagged.bam

samtools index pseudo_read.bam
```
