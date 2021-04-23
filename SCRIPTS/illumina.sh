#!/bin/bash

start=$(date +%s.%N)

primerscheme="$1"

raw="$2"

library="$(basename "$raw")"

ref="$(echo "$primerscheme" | cut -d/ -f1)"

primer="$(echo "$primerscheme" | cut -d/ -f2)"

threads="12"

echo "" && echo "ILLUMINA ASSEMBLY PIPELINE" && echo ""

[ ! -d $HOME/WGS/LIBRARIES ] && mkdir $HOME/WGS/LIBRARIES -v

[ -d $HOME/WGS/LIBRARIES/"$library" ] && rm -rf -d $HOME/WGS/LIBRARIES/"$library"

mkdir $HOME/WGS/LIBRARIES/"$library" -v

mkdir $HOME/WGS/LIBRARIES/"$library"/ANALYSIS -v

mkdir $HOME/WGS/LIBRARIES/"$library"/CONSENSUS -v

mkdir $HOME/WGS/LIBRARIES/"$library"/FASTQC -v

echo ""

cd $HOME/WGS/RAW/"$library"

for i in $(find ./ -type f -name "*.fastq.gz"); do cp "$i" ../../LIBRARIES/"$library"/ANALYSIS -v; done

cd ../../LIBRARIES/"$library"/ANALYSIS

echo ""

for i in $(find ./ -type f -name "*R1*.fastq.gz" -exec basename {} \;); do mv "$i" "$(echo "$i" | rev | cut -c 25- | rev)_R1.fastq.gz" -v; done

for i in $(find ./ -type f -name "*R2*.fastq.gz" -exec basename {} \;); do mv "$i" "$(echo "$i" | rev | cut -c 25- | rev)_R2.fastq.gz" -v; done

source activate illumina

echo "" && echo "FastQC analysis..."

fastqc -t "$threads" *.fastq.gz -o ../FASTQC

echo ""

cp ../../../PRIMER_SCHEMES/"$primerscheme"/"$ref".reference.fasta "$ref".reference.fasta -v

cp ../../../PRIMER_SCHEMES/"$primerscheme"/"$ref".score.bed "$ref".score.bed -v

echo "Sample@Nb of reads mapped@Average depth coverage@Bases covered >10x@Bases covered >25x@Reference covered (%)" | tr '@' '\t' > "$library".stats.txt

echo "" && echo "Building reference index..."

bwa index "$ref".reference.fasta

for i in $(find ./ -type f -name "*.fastq.gz" | while read o; do basename $o | cut -d_ -f1; done | sort | uniq)
	do
		echo "" && echo ""$i" assembly..."
		bwa mem -t "$threads" "$ref".reference.fasta "$i"_R1.fastq.gz "$i"_R2.fastq.gz | samtools sort -@ "$threads" | samtools view -@ "$threads" -bS -F 4 -o  "$i".mapped.sorted.bam
		samtools index -@ "$threads" "$i".mapped.sorted.bam
		ivar trim -e -i "$i".mapped.sorted.bam -b "$ref".score.bed -p "$i".trimmed
		samtools sort -@ "$threads" "$i".trimmed.bam -o "$i".trimmed.sorted.bam
		samtools index -@ "$threads" "$i".trimmed.sorted.bam
		samtools mpileup -A -B -Q 0 --reference "$ref".reference.fasta "$i".trimmed.sorted.bam | ivar consensus -p "$i" -n N -i "$i"
		samtools depth "$i".trimmed.sorted.bam > "$i".depth
		bcftools mpileup -A -B -Q 0 -f "$ref".reference.fasta "$i".trimmed.sorted.bam | bcftools call --threads "$threads" -mv --ploidy 1 -Oz -o "$i".vcf.gz
		zcat "$i".vcf.gz > "$i".vcf
		mafft --quiet --preservecase --thread "$threads" --6merpair --addfragments "$i".fasta "$ref".reference.fasta > "$i".mafft.fasta
		samtools faidx "$i".mafft.fasta
		samtools faidx "$i".mafft.fasta "$i" | sed '/^>/! s/[^ACTG]/N/g' >"$i".consensus.fasta
		stats.sh "$i" "$library" "$ref" # CADDE/USP script
	done

cat *.consensus.fasta > "$library".consensus.fasta

rm -rf "$ref".reference.fasta*

rm -rf "$ref".score.bed

echo ""

mv "$library".consensus.fasta ../CONSENSUS -v

mv "$library".stats.txt ../CONSENSUS -v

cd ../..

echo "" && echo "Tar GZ packaging..."

tar -czf "$library".tar.gz "$library"

end=$(date +%s.%N)

runtime=$(python -c "print(${end} - ${start})")

echo "" && echo "Done. The runtime was $runtime seconds."