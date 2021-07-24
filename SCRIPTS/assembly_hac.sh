#!/bin/bash

CSV=$1

FAST5=$2

THREADS=$3

VGAP=$(find $HOME -type d -name "vgapWGS-ONT")

LIBRARY_PATH=$VGAP/LIBRARIES

LIBRARY_NAME=$(basename "$CSV" | awk -F. '{print $1}')

PRIMER_SCHEME=$(cat "$CSV" | awk -F, '{print $3}' | uniq)

REFSEQ=$(cat "$CSV" | awk -F, '{print $3}' | awk -F/ '{print $1}')

[ -d $LIBRARY_PATH/$LIBRARY_NAME ] && rm -rfd $LIBRARY_PATH/$LIBRARY_NAME

mkdir $LIBRARY_PATH/$LIBRARY_NAME $LIBRARY_PATH/$LIBRARY_NAME/ANALYSIS $LIBRARY_PATH/$LIBRARY_NAME/CONSENSUS -v

guppy_basecaller -r -x auto --verbose_logs --disable_pings \
-c dna_r9.4.1_450bps_hac.cfg -i "$FAST5" -s $LIBRARY_PATH/$LIBRARY_NAME/BASECALL \
--num_callers "$THREADS"

#guppy_barcoder -r --require_barcodes_both_ends --trim_barcodes -t "$THREADS" -x auto \
#-i $LIBRARY_PATH/$LIBRARY_NAME/BASECALL -s $LIBRARY_PATH/$LIBRARY_NAME/DEMUX \
#--arrangements_files "barcode_arrs_nb12.cfg barcode_arrs_nb24.cfg"

#source activate ont_qc

#pycoQC -q \
#-f $LIBRARY_PATH/$LIBRARY_NAME/BASECALL/sequencing_summary.txt \
#-b $LIBRARY_PATH/$LIBRARY_NAME/DEMUX/barcoding_summary.txt \
#-o $LIBRARY_PATH/$LIBRARY_NAME/ANALYSIS/"$LIBRARY_NAME"_QC.html --report_title "$LIBRARY_NAME"

#cp $VGAP/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".reference.fasta \
#$LIBRARY_PATH/$LIBRARY_NAME/ANALYSIS/"$REFSEQ".reference.fasta -v

#cp $VGAP/PRIMER_SCHEMES/"$PRIMER_SCHEME"/"$REFSEQ".scheme.bed \
#$LIBRARY_PATH/$LIBRARY_NAME/ANALYSIS/"$REFSEQ".scheme.bed -v

#echo "SampleId@NumberReadsMapped@AverageDepth@Coverage10x@Coverage100x@Coverage1000x@ReferenceCovered" \
#tr '@' '\t' > "$LIBRARY_NAME".stats.txt

#source activate ont_assembly

#MIN=$(cat "$REFSEQ".scheme.bed | awk -F"\t" '{print $2,$3}' | tr '\n' ' ' | \
#awk '{for (i=1;i<=(NF/2);i=i+2) {print $(i*2+1)-$(i*2)}}' | \
#awk '{for (i=1;i<=NF;i++) if ($i>=0) print $i} ' | sort -n | awk 'NR==1{print}' | awk '{print $1}')

#MAX=$(cat "$REFSEQ".scheme.bed | awk -F"\t" '{print $2,$3}' | tr '\n' ' ' | \
#awk '{for (i=1;i<=(NF/2);i=i+2) {print $(i*2+1)-$(i*2)}}' | \
#awk '{for (i=1;i<=NF;i++) if ($i>=0) print $i} ' | sort -nr | awk 'NR==1{print}' | awk '{print $1+200}')

#for i in $(find $LIBRARY_PATH/$LIBRARY_NAME/DEMUX -type d -name "barcode*"); do
#    artic guppyplex --min-length "$MIN" --max-length "$MAX" --directory "$i" --prefix "$LIBRARY_NAME"
#    mv "$LIBRARY_NAME"_"$(basename $i)".fastq BC"$(basename $i | cut -de -f2)"_"$LIBRARY_NAME".fastq -v
#done
##trocar cut por awk

#for i in $(cat "$CSV"); do
#    SAMPLE=$(echo "$i" | awk -F, '{print $1}' | sed '/^$/d')
#    BARCODE=$(echo "$i"| awk -F, '{print $2}' | sed '/^$/d')
#    BARCODENB=$(echo "$BARCODE" | sed -e 's/BC//g')
#    if [ `echo "$BARCODE" | awk '{if ($0 ~ /-/) {print "yes"} else {print "no"}}'` == "yes" ]; \
#then for i in `echo "$BARCODE" | tr '-' '\n'`; do cat "$i"_"$LIBNAME".fastq; done > "$BARCODE"_"$LIBNAME".fastq ; fi
#    artic minion --threads "$THREADS" --medaka --medaka-model r941_min_high_g360 --normalise 200 --read-file "$BARCEODE"_"$LIBNAME".fastq --scheme-directory ../../../PRIMER_SCHEMES "$PRIMERSCHEME" "$SAMPLE"
#    stats.sh "$SAMPLE" "$LIBNAME" "$PRIMERSCHEME"
#done

#cat *.consensus.fasta > "$library".consensus.fasta

#mv "$library".consensus.fasta ../CONSENSUS -v

#mv "$library".stats.txt ../CONSENSUS -v

#rm -rf $VGAP/LIBRARIES/$(basename $RAWPATH)/ANALYSIS/*.reference.fasta*

#rm -rf $VGAP/LIBRARIES/$(basename $RAWPATH)/ANALYSIS/*.score.bed

#tar -czf $HOME/VirWGS/LIBRARIES/$(basename $RAWPATH).tar.gz -P $HOME/VirWGS/LIBRARIES/$(basename $RAWPATH)*
