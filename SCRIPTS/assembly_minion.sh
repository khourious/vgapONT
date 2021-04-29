#!/bin/bash

# modified CADDE/USP script

# author: Laise de Moraes <laisepaixao@live.com>
# institution: Universidade Federal da Bahia, Brazil
# URL: https://github.com/lpmor22
# date: 28 APR 2021

start=$(date +%s.%N)

csv="$1"

fast5="$2"

threads="$3"

cudacores="$4"

numcallers="$5"

library="$(basename "$csv" | cut -d. -f1)"

primerscheme="$(cat "$csv" | awk -F"," '{print $3}' | awk 'NR==1{print}')"

ref="$(cat "$csv" | awk -F"," '{print $3}' | awk 'NR==1{print}' | cut -d/ -f1)"

min=`cat "$ref".scheme.bed | awk -F"\t" '{print $2,$3}' | tr '\n' ' ' | awk '{for (i=1;i<=(NF/2);i=i+2) {print $(i*2+1)-$(i*2)}}' | awk '{for (i=1;i<=NF;i++) if ($i>=0) print $i} ' | sort -n | awk 'NR==1{print}' | awk '{print $1}'`

max=`cat "$ref".scheme.bed | awk -F"\t" '{print $2,$3}' | tr '\n' ' ' | awk '{for (i=1;i<=(NF/2);i=i+2) {print $(i*2+1)-$(i*2)}}' | awk '{for (i=1;i<=NF;i++) if ($i>=0) print $i} ' | sort -nr | awk 'NR==1{print}' | awk '{print $1+200}'`

[ ! -d $HOME/WGS/LIBRARIES ] && mkdir $HOME/WGS/LIBRARIES -v

[ -d $HOME/WGS/LIBRARIES/"$library" ] && rm -rfd $HOME/WGS/LIBRARIES/"$library"

mkdir $HOME/WGS/LIBRARIES/"$library" -v

mkdir $HOME/WGS/LIBRARIES/"$library"/ANALYSIS -v

mkdir $HOME/WGS/LIBRARIES/"$library"/CONSENSUS -v

cd $HOME/WGS/LIBRARIES/"$library"

guppy_basecaller -x auto --gpu_runners_per_device "$cudacores" --num_numcallers "$numcallers" -r -i "$fast5" -s HAC_BASECALL -c dna_r9.4.1_450bps_hac.cfg --verbose_logs

guppy_barcoder -t "$threads" -r -i HAC_BASECALL -s DEMUX --arrangements_files "barcode_arrs_nb12.cfg barcode_arrs_nb24.cfg" --require_barcodes_both_ends --trim_barcodes

cd ANALYSIS

source activate minion-qc

pycoQC -q -f ../HAC_BASECALL/sequencing_summary.txt -b ../DEMUX/barcoding_summary.txt -o "$library"_QC.html --report_title "$library"

cp ../../../PRIMER_SCHEMES/"$primerscheme"/"$ref".reference.fasta "$ref".reference.fasta -v

cp ../../../PRIMER_SCHEMES/"$primerscheme"/"$ref".scheme.bed "$ref".scheme.bed -v

echo "Sample@Nb of reads mapped@Average depth coverage@Bases covered >10x@Bases covered >25x@Reference covered (%)" | tr '@' '\t' > "$library".stats.txt

source activate minion

for i in $(find ../DEMUX -type d -name "barcode*"); do artic guppyplex --min-length "$min" --max-length "$max" --directory "$i" --prefix "$library" ; mv "$library"_"$(basename $i)".fastq BC"$(basename $i | cut -de -f2)"_"$library".fastq -v ; done

for i in `cat "$csv"`;
	do
		sample=`echo "$i" | awk -F"," '{print $1}' | sed '/^$/d'`
		barcode=`echo "$i"| awk -F"," '{print $2}' | sed '/^$/d'`
		barcodeNB=`echo "$barcode" | sed -e 's/BC//g'`
		if [ `echo "$barcode" | awk '{if ($0 ~ /-/) {print "yes"} else {print "no"}}'` == "yes" ] ; then for i in `echo "$barcode" | tr '-' '\n'` ; do cat "$i"_"$library".fastq ; done > "$barcode"_"$library".fastq ; fi
		artic minion --threads "$threads" --medaka --medaka-model r941_min_high_g360 --normalise 200 --read-file "$barcode"_"$library".fastq --scheme-directory ../../../PRIMER_SCHEMES "$primerscheme" "$sample"
		stats.sh "$sample" "$library" "$primerscheme"
	done

cat *.consensus.fasta > "$library".consensus.fasta

mv "$library".consensus.fasta ../CONSENSUS -v

mv "$library".stats.txt ../CONSENSUS -v

end=$(date +%s.%N)

runtime=$(python -c "print(${end} - ${start})")

echo "" && echo "Done. The runtime was $runtime seconds."