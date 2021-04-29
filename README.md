## Viral genome assembly pipeline for WGS using Illumina and MinION

This repo contains scripts and files to run the bioinformatic analysis of whole genome sequencing of viruses using Illlumina or MinION platform, and was built based on the CADDE and ARTIC bioinformatics workflow.

---

### Setting up the pipeline

Download and install the pipeline from the github repo:
```sh
git clone --recursive https://github.com/lpmor22/WGS.git; cd WGS
chmod 700 -R INSTALL SCRIPTS
bash INSTALL
```
---

#### Illumina pipeline

```sh
Assembly pipeline for WGS using Illumina

Usage: ILLUMINA [-r RAWPATH] [-s PRIMERSCHEME] [-t THREADS]

-r  The PATH to the directory containing the raw sequencing data downloaded from Illumina BaseSpace Sequence Hub (fastq.gz files).
-s  The prime scheme information (example: nCoV-2019/FIOCRUZ_2kb_v1 or nCoV-2019/ARTIC_V3)
-t  Number of tasks to process concurrently.
```

---

#### MinION pipeline

Requires to create the sample sheet (.csv). You can create in ``SAMPLE_SHEETS`` directory.
	
The csv file name **corresponds to the library name** and contains: sample,barcode,reference/version -- **NO HEADER!!**
```sh
sample01,BC01,nCoV-2019/ARTIC_V3
sample02,BC02,nCoV-2019/ARTIC_V3
```
	
You can combine pool A and B if they are on 2 different barcodes:
```sh
sample01,BC01-BC02,nCoV-2019/ARTIC_V3
```
	
```sh
Assembly pipeline for WGS using MinION

Usage: MINION [-r RAWPATH] [-s SAMPLESHEET] [-t THREADS] [-g CUDACORES] [-c NUMCALLERS]

-r  The PATH to the directory containing the raw sequencing data (fast5 files).
-s  The PATH to the sample sheet (.csv) file.
-t  Number of tasks to process concurrently.
-g  Number of GPU cuda cores [for guppy_basecaller].
-c  Number of parallel basecallers to FAST5 file [for guppy_basecaller].
```
