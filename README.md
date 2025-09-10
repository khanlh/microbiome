# 🚀 16S Amplicon Analysis using nf-core/ampliseq

This repository provides a reproducible pipeline for analyzing 16S amplicon sequencing data using [`nf-core/ampliseq`](https://nf-co.re/ampliseq). The workflow is executed automatically via GitHub Actions.

---

## 📦 Pipeline Overview

- **Pipeline:** [`nf-core/ampliseq`](https://nf-co.re/ampliseq)
- **Version:** 2.14.0
- **Workflow engine:** [Nextflow](https://www.nextflow.io/)
- **Platform:** GitHub Actions (CI/CD)
- **Container support:** Docker / Singularity / Conda

---

## 📁 Repository Structure

```bash
.
├── .github/workflows/         # GitHub Actions CI/CD pipeline
│   └── ampliseq.yml
├── data/                      # Input data
│   ├── samplesheet.tsv        # Sample sheet (input metadata for FASTQ files)
│   ├── Metadata.tsv           # Sample-level metadata (e.g. group, environment)
│   └── fastq/                 # Folder containing FASTQ files
├── results/                   # Output directory (created after pipeline run)
└── README.md                  # This file
