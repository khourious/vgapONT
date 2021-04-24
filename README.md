## Assembly pipeline for WGS using Illumina and MinION

This repo contains scripts and files to run the bioinformatic analysis of whole genome sequencing using Illlumina or MinION platform, and was built based on the CADDE and ARTIC bioinformatics workflow.

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

Usage: ILLUMINA [-r RAWPATH] [-p PRIMERSCHEME] [-d] [-v]

Options:
-r  The PATH to the directory containing the raw sequencing data downloaded from Illumina BaseSpace Sequence Hub (fastq.gz files).
-s  The prime scheme information (example: nCoV-2019/FIOCRUZ_2kb_v1 or nCoV-2019/ARTIC_V3)
-d  Generates depth plots in sigle PDF file from multiple BAM files to briefly check coverages.
-h  Display this help message.
```

---

#### MinION pipeline

Requires to create the sample sheet (.csv) in ``SAMPLE_SHEETS`` directory;
	
The csv file name **corresponds to the library name** and contains this format: sample,barcode,virus_reference/version -- **NO HEADER!!**
	
You can combine pool A and B if they are on 2 different barcodes, by adding an extra line at the end of the csv file:
```sh
sample01A,BC01,nCoV-2019/ARTIC_V3
sample01B,BC02,nCoV-2019/ARTIC_V3
sample01,BC01-BC02,nCoV-2019/ARTIC_V3
```

```sh
Assembly pipeline for WGS using Illumina

Usage: ILLUMINA [-r RAWPATH] [-p PRIMERSCHEME] [-d] [-v]

Options:
-r  The PATH to the directory containing the raw sequencing data (fast5 files).
-s  The PATH to the sample sheet (.csv) file.
-d  Generates depth plots in sigle PDF file from multiple BAM files to briefly check coverages.
-h  Display this help message.
```
