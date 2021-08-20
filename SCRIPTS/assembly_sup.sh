#!/bin/bash

CSV=$1

FAST5=$2

THREADS=$3

GPU_MEMORY=$4

VGAP=$(find $HOME -type d -name "vgapWGS-ONT")

LIBRARY_PATH="$VGAP"/LIBRARIES

LIBRARY_NAME=$(basename "$CSV" | awk -F. '{print $1}')

PRIMER_SCHEME=$(cat "$CSV" | awk -F, '{print $3}' | uniq)

REFSEQ=$(cat "$CSV" | awk -F, '{print $3}' | awk -F/ '{print $1}' | uniq)

MIN=$(paste <(awk -F"\t" '$4~/RIGHT|R|REVERSE|REV|RV|R/ {print $2}' "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".scheme.bed) \
<(awk -F"\t" '$4~/LEFT|L|FORWARD|FWD|FW|F/ {print $3}' "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".scheme.bed) | \
awk -F"\t" '{print $1-$2}' | awk '{if ($0>0) print $0}' | sort -n | sed -n '1p')

MAX=$(paste <(awk -F"\t" '$4~/RIGHT|R|REVERSE|REV|RV|R/ {print $2}' "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".scheme.bed) \
<(awk -F"\t" '$4~/LEFT|L|FORWARD|FWD|FW|F/ {print $3}' "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".scheme.bed) | \
awk -F"\t" '{print $1-$2}' | awk '{if ($0>0) print $0+200}' | sort -nr | sed -n '1p')

mkdir "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/SUMMARY -v

guppy_basecaller -r -x auto --verbose_logs --disable_pings \
-c dna_r9.4.1_450bps_fast.cfg -i "$FAST5" -s "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/BASECALL \
--gpu_runners_per_device "$GPU_MEMORY" --chunks_per_runner 300 --chunk_size 2000 \
--num_callers "$THREADS" --min_qscore 7

guppy_barcoder -r --require_barcodes_both_ends --trim_barcodes -t "$THREADS" -x auto \
-i "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/BASECALL -s "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/DEMUX

source activate ont_qc

pycoQC -q -f "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/BASECALL/sequencing_summary.txt \
-b "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/DEMUX/barcoding_summary.txt \
-o "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/SUMMARY/"$LIBRARY_NAME"_QC.html --report_title "$LIBRARY_NAME"

source activate ont_assembly

for i in $(find "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/DEMUX -type d -name "barcode*" | sort); do \
artic guppyplex --min-length "$MIN" --max-length "$MAX" --directory "$i" \
--output "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/BC"$(basename $i | awk -Fe '{print $2}')"_"$LIBRARY_NAME".fastq; done

echo "SampleId#NumberReadsMapped#AverageDepth#Coverage10x#Coverage20x#Coverage100x#Coverage1000x" | \
tr '#' '\t' > "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt

cd "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY

for i in $(cat "$CSV"); do
    SAMPLE=$(echo "$i" | awk -F, '{print $1}' | sed '/^$/d')
    BARCODE=$(echo "$i"| awk -F, '{print $2}' | sed '/^$/d')
    if [ $(echo "$BARCODE" | awk '{if ($0 ~ /-/) {print "yes"} else {print "no"}}') == "yes" ]; then \
        for i in $(echo "$BARCODE" | tr '-' '\n'); do cat "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$i"_"$LIBRARY_NAME".fastq; done \
        > "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$BARCODE"_"$LIBRARY_NAME".fastq; fi
    artic minion --normalise 0 --threads "$THREADS" --read-file "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$BARCODE"_"$LIBRARY_NAME".fastq \
    --fast5-directory "$FAST5" --sequencing-summary "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/BASECALL/sequencing_summary.txt \
    --scheme-directory "$VGAP"/PRIMER_SCHEMES "$PRIMER_SCHEME" "$SAMPLE"
    echo -n "$SAMPLE""#" | tr '#' '\t' >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
    samtools view -F 0x904 -c "$SAMPLE".primertrimmed.rg.sorted.bam | awk '{printf $1"#"}' | tr '#' '\t' \
    >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
    samtools depth "$SAMPLE".primertrimmed.rg.sorted.bam | awk '{sum+=$3} END {print sum/NR}' | awk '{printf $1"#"}' | tr '#' '\t' \
    >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
    paste <(samtools depth "$SAMPLE".primertrimmed.rg.sorted.bam | awk '{if ($3 > '"10"') {print $0}}' | wc -l) \
    <(fastalength "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".reference.fasta | awk '{print $1}') | \
    awk -F"\t" '{printf("%0.4f\n", $1/$2*100)}' | awk '{printf $1"#"}' | tr '#' '\t' \
    >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
    paste <(samtools depth "$SAMPLE".primertrimmed.rg.sorted.bam | awk '{if ($3 > '"20"') {print $0}}' | wc -l) \
    <(fastalength "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".reference.fasta | awk '{print $1}') | \
    awk -F"\t" '{printf("%0.4f\n", $1/$2*100)}' | awk '{printf $1"#"}' | tr '#' '\t' \
    >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
    paste <(samtools depth "$SAMPLE".primertrimmed.rg.sorted.bam | awk '{if ($3 > '"100"') {print $0}}' | wc -l) \
    <(fastalength "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".reference.fasta | awk '{print $1}') | \
    awk -F"\t" '{printf("%0.4f\n", $1/$2*100)}' | awk '{printf $1"#"}' | tr '#' '\t' \
    >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
    paste <(samtools depth "$SAMPLE".primertrimmed.rg.sorted.bam | awk '{if ($3 > '"1000"') {print $0}}' | wc -l) \
    <(fastalength "$VGAP"/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".reference.fasta | awk '{print $1}') | \
    awk -F"\t" '{printf("%0.4f\n", $1/$2*100)}' | awk '{printf $1"#"}' | tr '#' '\n' \
    >> "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$LIBRARY_NAME".stats.txt
done

source activate plot

for i in $(find "$VGAP"/LIBRARIES/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/ -type f -name "*.primertrimmed.rg.sorted.bam" | \
awk -F/ '{print $NF}' | awk -F. '{print $1}' | sort -u); do
    fastcov.py -l "$VGAP"/LIBRARIES/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$i".primertrimmed.rg.sorted.bam \
    -o "$VGAP"/LIBRARIES/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/"$i".coverage.pdf
done

gs -dSAFER -r3000 -sDEVICE=pdfwrite -dNOPAUSE -dBATCH \
-sOUTPUTFILE="$VGAP"/LIBRARIES/"$LIBRARY_NAME"_ANALYSIS/SUMMARY/"$LIBRARY_NAME".depth.pdf \
"$VGAP"/LIBRARIES/"$LIBRARY_NAME"_ANALYSIS/ASSEMBLY/*.pdf

cat *.consensus.fasta > "$LIBRARY_NAME".consensus.fasta

rm -rf *.reference.fasta*

cp "$CSV" ../ -v

mv "$LIBRARY_NAME".consensus.fasta ../SUMMARY -v

mv "$LIBRARY_NAME".stats.txt ../SUMMARY -v

tar -czf "$LIBRARY_PATH"/"$LIBRARY_NAME".tar.gz -P "$LIBRARY_PATH"/"$LIBRARY_NAME"_ANALYSIS/*
