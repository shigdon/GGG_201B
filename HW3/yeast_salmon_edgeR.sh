#! /usr/bin/env bash
# GGG201B - Laboratory Homework Assignment #3 Author: Shawn Higdon
#
# This shell script was written to perform a differential gene expression analysis of yeast RNAseq libraries from the work
# of Schurch et al., 2016 using fastq files from the EBI SRA archive. The program will install the Salmon Program for
# quantitation of transcript counts from each of 10 SRA fastq files, 5 RNAseq libraries from WT yeast lines of bioreplicate
# 1, and 5 RNAseq libraries from the same bioreplicate of the SNF2 mutant yeast line. After counting all of the transcripts
# aligned to the Salmon-indexed yeast-transcriptome, the script downloads a python script from github and calls on it to
# re-format the .count files generated by Salmon for analysis using EdgeR. The final stage of this script will perform a
# differential gene expression analysis for the experimental data in which an MDS plot and an MA plot are generated to
# demonstrate intersample variation and the degree of differentiation among the two genotypes

# Install edge R using the R script from IGG201B lab 7

cd

git clone https://github.com/ctb/2017-ucdavis-igg201b.git

sudo Rscript --no-save ~/2017-ucdavis-igg201b/lab7/install-edgeR.R

# Install Salmon

cd

curl -L -O https://github.com/COMBINE-lab/salmon/releases/download/v0.8.0/Salmon-0.8.0_linux_x86_64.tar.gz
tar xzf Salmon-0.8.0_linux_x86_64.tar.gz

export PATH=$PATH:$HOME/Salmon-latest_linux_x86_64/bin

# Create Yeast Directory

cd

mkdir yeast

cd yeast

# Download the previous SRA Files used in lab 8, with the addition of the following four SRA files, 2 WT and 2 SNF2:

# ERR458498 6 WT 1
# ERR458499 7 WT 1
# ERR458504 5 SNF2 1
# ERR458505 6 SNF2 1

curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458500/ERR458500.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458501/ERR458501.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458502/ERR458502.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458493/ERR458493.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458494/ERR458494.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458495/ERR458495.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458498/ERR458498.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458499/ERR458499.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458504/ERR458504.fastq.gz
curl -O ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR458/ERR458505/ERR458505.fastq.gz

# Download the yeast transcriptome file we are using for mapping

 curl -O http://downloads.yeastgenome.org/sequence/S288C_reference/orf_dna/orf_coding.fasta.gz
# Index the transcriptome with Salmon

salmon index --index yeast_orfs --type quasi --transcripts orf_coding.fasta.gz

# Run Salmon on all 10 files

for i in *.fastq.gz
 do
     salmon quant -i yeast_orfs --libType U -r $i -o $i.quant --seqBias --gcBias
 done

# Compile all of the gene counts from each salmon output file

 curl -L -O https://github.com/ngs-docs/2016-aug-nonmodel-rnaseq/raw/master/files/gather-counts.py
 python2 gather-counts.py

# Run the updated edgeR script that includes all 10 fastq files (5 mutant and 5 wt yeast libraries)

Rscript --no-save ~/GGG_201B/HW3/smh_edgeR.R

# Count the number of genes that were identified from the edgeR analysis using the lab 8 dataset with an FDR level of 0.2 or less

echo "The number of genes with an FDR p-value less than 0.2 from the RNAseq libraries included in the lab 8 analysis is:"

awk 'BEGIN {FS = ","} ; {if ($5 <= 0.2) print $0}' ~/GGG_201B/HW3/yeast-edgeR-lab8.csv | grep -cv ",\"FDR"

# Count the number of genes that were identified from the edgeR analysis using the HW3 dataset with an FDR level of 0.2 or less

echo "The number of genes with an FDR p-value less than 0.2 from the RNAseq libraries included in the HW3 analysis is:"

awk 'BEGIN {FS = ","} ; {if ($5 <= 0.2) print $0}' ~/yeast/smh-hw3-yeast-edgeR.csv | grep -cv ",\"FDR"

# Count the number of genes that were identified as differentially expressed using an FDR level of 0.05 form the lab8 edgeR output

echo "The number of genes with an FDR p-value less than 0.05 from the RNAseq libraries included in the lab 8 analysis is:"

awk 'BEGIN {FS = ","} ; {if ($5 <= 0.05) print $0}' ~/GGG_201B/HW3/yeast-edgeR-lab8.csv | grep -cv ",\"FDR"

# Count the number of genes that were identified as differentially expressed using an FDR level of 0.05 form the HW3 edgeR output

echo "The number of genes with an FDR p-value less than 0.05 from the RNAseq libraries included in the HW 3 analysis is:"

awk 'BEGIN {FS = ","} ; {if ($5 <= 0.05) print $0}' ~/yeast/smh-hw3-yeast-edgeR.csv | grep -cv ",\"FDR"

# SH: There are 4,030 genes that were identified as differentially expressed with an FDR p-value less than or equal to 0.05 from
# the analysis of 3 wt and 3 mutant yeast RNAseq libraries, while there are 4,445 genes that were identified as differentially
# expressed form running the same analysis on a dataset that contained two additional technical replicates from biological
# replicate 1 of both the wt and the mutant yeast lines. All libraries included in this analysis consisted of technical
# replicates from the same biological replicate. The edge R script generates a table that keeps all genes with an FDR p-value
# lower than 0.2, but using a single line of awk code one may probe the edgeR csv file for gene counts within the edgeR output
# table at lower FDR p-values. Using the same awk code to count the number of dge records in the .csv table output from edgeR,
# it is easy to see that using a more stringent FDR p-value threshold decreases the number of differentially expressed genes
# reported. The Number of genes reported in the tables from the edgeR output from both datasets at the FDR = 0.2 level show a
# similar difference in the number of differentially expressed genes compared to the difference at the FDR = 0.05 level.
# Because the number of differentially expressed genes identified increased with the increase in RNAseq library replications, 
# increasing replication seems to be a good strategy for detecting more differential gene expression events, which is implied by
# the similar difference in number of genes identified across both analyses at both FDR levels.
