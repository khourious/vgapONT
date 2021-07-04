#!/bin/bash

CSV="$1"
FAST5="$2"
THREADS="$3"
CUDACORES="$4"
NUMCALLERS="$5"

VGAP=$(find $HOME -type d -name "vgapWGS-ONT")

LIBPATH="$VGAP/LIBRARIES"

LIBNAME=$(basename "$CSV" | awk -F. '{print $1}')

PRIMERSCHEME=$(cat "$CSV" | awk -F, '{print $3}' | sed -n '1p')

REFSEQ=$(cat "$CSV" | awk -F, '{print $3}' | awk -F/ '{print $2}')

[ ! -d $LIBPAH ] && mkdir $LIBPATH -v

[ -d $LIBPATH/"$LIBNAME" ] && rm -rfd $LIBPATH/"$LIBNAME"

mkdir $LIBPATH/"$LIBNAME" $LIBPATH/"$LIBNAME"/ANALYSIS $LIBPATH/"$LIBNAME"/CONSENSUS -v

cd $LIBPATH/"$LIBNAME"

guppy_basecaller -r -x auto --verbose_logs \
-c dna_r9.4.1_450bps_sup.cfg \
-i "$FAST5" -s BASECALL \
-q 1 --min_qscore 9 \
--chunk_size 1000 \
--num_callers 6 \
--gpu_runners_per_device 2

guppy_barcoder -r --require_barcodes_both_ends --trim_barcodes -t "$THREADS" \
-i BASECALL -s DEMUX \
--arrangements_files "barcode_arrs_nb12.cfg barcode_arrs_nb24.cfg"

cd ANALYSIS

source activate ont_qc

#pycoQC -q \
#-f ../BASECALL/sequencing_summary.txt -b ../DEMUX/barcoding_summary.txt -o "$library"_QC.html --report_title "$library"

#cp ../../../PRIMER_SCHEMES/"$primerscheme"/"$ref".reference.fasta "$ref".reference.fasta -v

#cp ../../../PRIMER_SCHEMES/"$primerscheme"/"$ref".scheme.bed "$ref".scheme.bed -v

#min=`cat "$ref".scheme.bed | awk -F"\t" '{print $2,$3}' | tr '\n' ' ' | awk '{for (i=1;i<=(NF/2);i=i+2) {print $(i*2+1)-$(i*2)}}' | awk '{for (i=1;i<=NF;i++) if ($i>=0) print $i} ' | sort -n | awk 'NR==1{print}' | awk '{print $1}'`

#max=`cat "$ref".scheme.bed | awk -F"\t" '{print $2,$3}' | tr '\n' ' ' | awk '{for (i=1;i<=(NF/2);i=i+2) {print $(i*2+1)-$(i*2)}}' | awk '{for (i=1;i<=NF;i++) if ($i>=0) print $i} ' | sort -nr | awk 'NR==1{print}' | awk '{print $1+200}'`

#echo "Sample@Nb of reads mapped@Average depth coverage@Bases covered >10x@Bases covered >25x@Reference covered (%)" | tr '@' '\t' > "$library".stats.txt

#source activate ont_assembly

#for i in $(find ../DEMUX -type d -name "barcode*"); do artic guppyplex --min-length "$min" --max-length "$max" --directory "$i" --prefix "$library" ; mv "$library"_"$(basename $i)".fastq BC"$(basename $i | cut -de -f2)"_"$library".fastq -v ; done

#for i in `cat "$csv"`;
#	do
#		sample=`echo "$i" | awk -F"," '{print $1}' | sed '/^$/d'`
#		barcode=`echo "$i"| awk -F"," '{print $2}' | sed '/^$/d'`
#		barcodeNB=`echo "$barcode" | sed -e 's/BC//g'`
#		if [ `echo "$barcode" | awk '{if ($0 ~ /-/) {print "yes"} else {print "no"}}'` == "yes" ] ; then for i in `echo "$barcode" | tr '-' '\n'` ; do cat "$i"_"$library".fastq ; done > "$barcode"_"$library".fastq ; fi
#		artic minion --threads "$threads" --medaka --medaka-model r941_min_high_g360 --normalise 200 --read-file "$barcode"_"$library".fastq --scheme-directory ../../../PRIMER_SCHEMES "$primerscheme" "$sample"
#		stats.sh "$sample" "$library" "$primerscheme"
#	done

#cat *.consensus.fasta > "$library".consensus.fasta

#mv "$library".consensus.fasta ../CONSENSUS -v

#mv "$library".stats.txt ../CONSENSUS -v

#rm -rf $VGAP/LIBRARIES/$(basename $RAWPATH)/ANALYSIS/*.reference.fasta*

 #   rm -rf $VGAP/LIBRARIES/$(basename $RAWPATH)/ANALYSIS/*.score.bed

#    tar -czf $HOME/VirWGS/LIBRARIES/$(basename $RAWPATH).tar.gz -P $HOME/VirWGS/LIBRARIES/$(basename $RAWPATH)*
