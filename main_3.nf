#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// ---- INPUT ----
params.reads = "/Users/khanlehoang/Documents/microbiome/nextflow/16S_metagenomic/US/*_{1,2}.fastq.gz"

// ---- PROCESSES ----
process FASTQC {
    publishDir "results/fastqc", mode: 'copy'

    input:
    tuple val(sample), path(reads1), path(reads2)

    output:
    tuple val(sample), path("*_fastqc.zip"), path("*_fastqc.html")

    script:
    """
    fastqc ${reads1} ${reads2} -o .
    """
}

process TRIMMOMATIC {
    publishDir "results/trimmomatic", mode: 'copy'
    container 'staphb/trimmomatic:0.39'

    input:
    tuple val(sample), path(reads1), path(reads2)

    output:
    tuple val(sample), path("${sample}_1.trimmed.fastq.gz"), path("${sample}_2.trimmed.fastq.gz")

    script:
    """
    trimmomatic PE -threads 2 \
        ${reads1} ${reads2} \
        ${sample}_1.trimmed.fastq.gz ${sample}_1.unpaired.fastq.gz \
        ${sample}_2.trimmed.fastq.gz ${sample}_2.unpaired.fastq.gz \
        SLIDINGWINDOW:4:20 MINLEN:50
    """
}

process DADA2 {
    tag "$sample_id"
    publishDir "results/DADA2", mode: 'copy'

    input:
    tuple val(sample_id), path(reads1), path(reads2)

    output:
    tuple val(sample_id), path("${sample_id}_ASV_table.txt"), path("${sample_id}_ASV.fasta")

    script:
    """
    Rscript -e '
      library(dada2)
      library(Biostrings)

      fnFs <- "${reads1}"
      fnRs <- "${reads2}"
      filtFs <- "filtered_${sample_id}_1.fastq.gz"
      filtRs <- "filtered_${sample_id}_2.fastq.gz"

      out <- filterAndTrim(fnFs, filtFs,
                           fnRs, filtRs,
                           maxN=0,
                           maxEE=c(2,2),
                           truncQ=2,
                           compress=TRUE,
                           multithread=TRUE)

      errF <- learnErrors(filtFs, multithread=TRUE)
      errR <- learnErrors(filtRs, multithread=TRUE)

      derepF <- derepFastq(filtFs)
      derepR <- derepFastq(filtRs)

      dadaF <- dada(derepF, err=errF, multithread=TRUE)
      dadaR <- dada(derepR, err=errR, multithread=TRUE)

      mergers <- mergePairs(dadaF, derepF, dadaR, derepR)

      seqtab <- makeSequenceTable(mergers)
      seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE)

      # export ASV table (TSV)
      asv_table_file <- paste0("${sample_id}_ASV_table.txt")
      write.table(t(seqtab.nochim),
                  file = asv_table_file,
                  sep = "\\t", quote = FALSE, col.names = NA)

      # export fasta
      seqs <- colnames(seqtab.nochim)
      writeXStringSet(DNAStringSet(seqs), "${sample_id}_ASV.fasta")
    '
    """
}


process FASTA_FIX {
    tag { sample_id }
    input:
    tuple val(sample_id), path(table), path(fasta)

    output:
    tuple val(sample_id), path(table), path("${fasta.baseName}_fixed.fasta")

    script:
    """
    awk '/^>/{print ">seq" ++i; next} {print}' ${fasta} > ${fasta.baseName}_fixed.fasta
    """
}


process QIIME2 {
    container "quay.io/qiime2/amplicon:2025.7"
    publishDir "results/qiime2", mode: 'copy'

    input:
    tuple val(sample_id), path(asv_table), path(asv_fasta)

    output:
    path "qiime2_output/${sample_id}_taxonomy.qza"
    path "qiime2_output/${sample_id}_ASV.qza"

    script:
    """
    mkdir -p qiime2_output

    # chuyển txt -> biom
    biom convert \
      -i ${asv_table} \
      -o ${sample_id}_ASV_table.biom \
      --to-hdf5 \
      --table-type="OTU table"

    # import ASV fasta
    qiime tools import \
      --input-path ${asv_fasta} \
      --output-path qiime2_output/${sample_id}_ASV.qza \
      --type 'FeatureData[Sequence]'

    # import table (biom)
    qiime tools import \
      --input-path ${sample_id}_ASV_table.biom \
      --type 'FeatureTable[Frequency]' \
      --output-path qiime2_output/${sample_id}_table.qza

    # taxonomy classification
    qiime feature-classifier classify-sklearn \
  	--i-classifier ${params.database} \
 	--i-reads qiime2_output/${sample_id}_ASV.qza \
  	--o-classification qiime2_output/${sample_id}_taxonomy.qza
    """
}

// ---- Workflow ----
workflow {
    reads_ch = Channel.fromFilePairs(params.reads, flat: true)

    trimmed_ch = TRIMMOMATIC(reads_ch)
    FASTQC(reads_ch)

    asv_ch = DADA2(trimmed_ch)
    fixed_ch = FASTA_FIX(asv_ch)

    QIIME2(fixed_ch)
}