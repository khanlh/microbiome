# 16S Amplicon Analysis using Nextflow Pipeline


- This pipeline performs **16S rRNA amplicon metagenomic analysis** using **Nextflow + Docker**.  
- It covers all steps from raw FASTQ data to ASV tables and taxonomic classification with QIIME2.  
- Goal: to provide a reproducible, lightweight, and easy-to-deploy microbiome analysis workflow.
      * _Note:_ Example datasets used in this pipeline are from [Zhou et al., 2024](https://journals.asm.org/doi/epdf/10.1128/spectrum.00965-24).

---

## Workflow

**Main steps:**

 1. **FASTQC**– Quality control of raw reads.  
 2. **TRIMMOMATIC** – Adapter trimming and low-quality read filtering.  
 3. **DADA2** – Construct Amplicon Sequence Variant (ASV) tables and remove chimeras.  
 4. **FASTA_FIX** – Standardize FASTA headers (e.g., `seq1`, `seq2`, …).  
 5. **QIIME2** – Import data, build FeatureTable, and perform taxonomic classification using a classifier (Greengenes or SILVA).

**Pipeline diagram:**

          FASTQC─> TRIMMOMATIC ─> DADA2 ─> FASTA_FIX ─> QIIME2
      (optional)FASTQC <─┘

## Requirements

- [Nextflow](https://www.nextflow.io/)
- [Docker](https://www.docker.com/)   
- QIIME2 classifier database (`gg_13_8_classifier.qza` or `silva-138-99-nb-classifier.qza`)

## Output
- results/fastqc/ → QC reports (HTML, ZIP)
- results/trimmomatic/ → Trimmed reads
- results/DADA2/ →
           1. {sample}_ASV_table.txt – ASV table
           2. {sample}_ASV.fasta – ASV sequences
- results/qiime2/ →
           1. {sample}_ASV.qza – FeatureData[Sequence]
           2.{sample}_taxonomy.qza – Taxonomic classification

## References
- Bolger AM, et al. (2014). Trimmomatic: a flexible trimmer for Illumina sequence data.
- Bolyen E, et al. (2019). QIIME 2: Reproducible, interactive, scalable, and extensible microbiome data science.
- Callahan BJ, et al. (2016). DADA2: High-resolution sample inference from Illumina amplicon data.
- Zhou Q, et al. (2024). Spectrum 12:e00965-24. https://journals.asm.org/doi/epdf/10.1128/spectrum.00965-24
