# 16S Amplicon Analysis using Nextflow Pipeline


This pipeline performs **16S rRNA amplicon metagenomic analysis** using **Nextflow + Docker**.  
It covers all steps from raw FASTQ data to ASV tables and taxonomic classification with QIIME2.  
Goal: to provide a reproducible, lightweight, and easy-to-deploy microbiome analysis workflow.

---

## Workflow

    **Main steps:**

1. FASTQC– Quality control of raw reads.  
2. TRIMMOMATIC – Adapter trimming and low-quality read filtering.  
3.DADA2 – Construct Amplicon Sequence Variant (ASV) tables and remove chimeras.  
4. FASTA_FIX – Standardize FASTA headers (e.g., `seq1`, `seq2`, …).  
5. QIIME2 – Import data, build FeatureTable, and perform taxonomic classification using a classifier (Greengenes or SILVA).

    **Pipeline diagram:**

          FASTQC─> TRIMMOMATIC ─> DADA2 ─> FASTA_FIX ─> QIIME2
      (optional)FASTQC <─┘

## Requirements

- [Nextflow](https://www.nextflow.io/)
- [Docker](https://www.docker.com/)   
- QIIME2 classifier database (`gg_13_8_classifier.qza` or `silva-138-99-nb-classifier.qza`)

## Output
  results/fastqc/ → QC reports (HTML, ZIP)
  results/trimmomatic/ → Trimmed reads
  results/DADA2/ →
            ${sample}_ASV_table.txt – ASV table
            ${sample}_ASV.fasta – ASV sequences
  results/qiime2/ →
            ${sample}_ASV.qza – FeatureData[Sequence]
            ${sample}_taxonomy.qza – Taxonomic classification
