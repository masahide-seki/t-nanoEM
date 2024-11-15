# t-nanoEM
Scripts for phasing analysis with long reads with base conversion.

# Requirement

Perl

Bioperl (https://metacpan.org/pod/BioPerl)

Java

Samtools (https://www.htslib.org/)

Picard (https://broadinstitute.github.io/picard/)

Whatshap (https://whatshap.readthedocs.io/en/latest/)

# Usage

## 1. SNP phasing using t-nanoEM or nanoEM reads and separation of the reads to each haplotype

The Workflow for phasing of heterozygous SNPs using t-nanoEM or nanoEM, considering the base conversion patterns of EM−seq.

A VCF file containing germline SNPs, typically generated using short-read whole-genome sequencing (WGS), is required.

## 1.1. Preparation of pseudo-reads containing reference or alternate bases
Prior to phasing analysis, a bam file of pseudo-reads containg reference or alternate base is prepared from a bam file of t-nanoEM or nanoEM.

### Conversion of vcf file to bed file of heteroSNP

```bash
perl vcf_hetero_bed.pl variant.vcf heteroSNP.bed
```

### Optional: Duplication removal from bamfile of t-nanoEM (or nanoEM) processed from the nanoEM pipeline (https://github.com/yos-sk/nanoEM)

```bash
picard MarkDuplicates -INPUT tnanoEM.bam -OUTPUT tnanoEM.rmdup.bam -REMOVE_DUPLICATES true -M tnanoEM.rmdup.metrics.txt

samtools index tnanoEM.rmdup.bam
```

### Marking supplementary alignment reads in bamfile of t-nanoEM (or nanoEM)

```bash
perl rename_supplementary.pl  tnanoEM.rmdup.bam (or tnanoEM.bam) | samtools view -bS | samtools sort -o tnanoEM_rn_sup.bam

samtools index tnanoEM_rn_sup.bam
```

### Extraction of bases of each read on positions with heteroSNP

```bash
samtools mpileup -q 0 -Q 0 -l heteroSNP.bed  -f reference_genome.fa --output-QNAME tnanoEM_rn_sup.bam > tnanoEM.heteroSNP.mpu.txt

perl read_names_per_SNV.pl heteroSNP.bed tnanoEM.heteroSNP.mpu.txt > read_names_per_heteroSNP.txt
```

### Generation of pseudo-bam file with base information on only positions with heteroSNP

```bash
perl pseudo_phasing_input_mod.pl -i read_names_per_heteroSNP.txt -o pseudo_read_without_header.sam -m 0 -s 0

samtools view -H tnanoEM.bam | cat pseudo_read_without_header.sam > pseudo_read.sam

samtools view -bS pseudo_read.sam | samtools sort -o pseudo_read.bam

samtools index pseudo_read.bam
```

## 1.2. SNP phasing using pseudo-reads

Using whatshap, phase heterozygous SNPs with pseudo-reads prepared as described.

This step is not necessary when using a pre-phased vcf file.

### Phasing heteroSNPS using pseudo-reads

```bash
whatshap phase -o phased.vcf --reference=reference_genome.fa variant.vcf pseudo_read.bam --ignore-read-group

bgzip phased.vcf

tabix -c vcf phased.vcf.gz
```


## 1.3. Phasing of nanoEM or t-nanoEM reads with phased SNPs

The workflow for phasing of t-nanoEM or nanoEM reads using pre-phased SNP information.

A VCF file containing pre-phased SNPs is required.

### Optional: Force unphased heteroSNPs to be assigned to either haplotype

```bash
perl force_phase.pl phased.vcf.gz force_phased.vcf

bgzip force_phased.vcf

tabix -c vcf force_phased.vcf.gz
```

### Phasing of nanoEM or t-nanoEM reads with phased SNPs

```bash
whatshap haplotag -o pseudo_read.tagged.bam --reference reference_genome.fa --ignore-read-groups force_phased.vcf.gz (or phased.vcf.gz) pseudo_read.bam

samtools sort pseudo_read.tagged.bam -o pseudo_read.tagged.bam

samtools index pseudo_read.tagged.bam

perl add_phase.pl tnanoEM_rn_sup.bam pseudo_read.tagged.bam tnanoEM.tagged.sam

samtools view -bS tnanoEM.tagged.sam | samtools sort -o tnanoEM.tagged.bam

samtools index tnanoEM.tagged.bam
```

### Phasing of nanoEM or t-nanoEM reads with phased SNPs

```bash
whatshap haplotag -o pseudo_read.tagged.bam --reference reference_genome.fa --ignore-read-groups force_phased.vcf.gz (or phased.vcf.gz) pseudo_read.bam

samtools sort pseudo_read.tagged.bam -o pseudo_read.tagged.bam

samtools index pseudo_read.tagged.bam

perl add_phase.pl tnanoEM_rn_sup.bam pseudo_read.tagged.bam tnanoEM.tagged.sam

samtools view -bS tnanoEM.tagged.sam | samtools sort -o tnanoEM.tagged.bam

samtools index pseudo_read.bam
```


## 2. Phasing of nanoEM or t-nanoEM reads with somatic SNVs
This workflow for separation of nanoEM or t-nanoEM reads based on the presence or absence of somatic single-nucleotide variants (SNVs).
A VCF file containing somatic SNVs, typically generated using short-read whole-genome sequencing (WGS).
Reads containing SNVs are tagged with "MU:i:1", while those without SNVs were tagged with "MU:i:0".
Grouping alignment results by the MU tag allows us to visualize reads with and without SNVs separately in IGV.


### Conversion of vcf file of somatic mutations to bed file of SNV

```bash
perl vcf_SNV_bed.pl mutation.vcf SNV.bed
```

### Optional: Duplication removal from bamfile of t-nanoEM (or nanoEM) processed by the nanoEM pipeline (https://github.com/yos-sk/nanoEM)

```bash
picard MarkDuplicates -Xmx80g -INPUT tnanoEM.bam -OUTPUT tnanoEM.rmdup.bam -REMOVE_DUPLICATES true -M tnanoEM.rmdup.metrics.txt

samtools index tnanoEM.rmdup.bam
```

### Marking supplementary alignment reads in bamfile of t-nanoEM (or nanoEM)

```bash
perl rename_supplementary.pl  tnanoEM.rmdup.bam (or tnanoEM.bam) | samtools view -bS | samtools sort -o tnanoEM_rn_sup.bam

samtools index tnanoEM_rn_sup.bam
```

### Extraction of bases of each read on positions with SNVs

```bash
samtools mpileup -q 0 -Q 0 -l SNV.bed  -f reference_genome.fa --output-QNAME tnanoEM_rn_sup.bam > tnanoEM.snv.mpu.txt

perl read_names_per_SNV.pl SNV.bed tnanoEM.snv.mpu.txt > tnanoEM.SNV_rn.txt
```

### Phasing t-nanoEM or nanoEM reads with somatic SNVs

```bash
perl tnanoEM.rmdup.bam (or tnanoEM.bam) tnanoEM.SNV_rn.txt tnanoEM.SNV.phased.bam

samtools view -bS tnanoEM.SNV.phased.sam | samtools sort -o tnanoEM.SNV.phased.bam

samtools index tnanoEM.SNV.phased.bam
```
