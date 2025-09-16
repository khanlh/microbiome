mkdir -p fastq_files  # Tạo thư mục nếu chưa có

for i in {17813193..17813247}; do
    echo "🔽 Downloading SRR$i.sra..."
    wget -q https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR$i/SRR$i -O SRR$i.sra

    echo "📦 Converting SRR$i.sra to FASTQ..."
    fastq-dump --split-files --outdir ./fastq_files SRR$i.sra

    echo "🧹 Cleaning up SRR$i.sra..."
    rm SRR$i.sra

    echo "🗜️ Compressing FASTQ files to .gz..."
    gzip ./fastq_files/SRR${i}_1.fastq
    gzip ./fastq_files/SRR${i}_2.fastq
done

