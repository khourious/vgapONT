## Viral genome assembly pipeline for WGS using nanopore sequencing

This repository contains scripts and files to run the bioinformatic analysis of whole genome sequencing of viruses using ONT and was built based on the CADDE and ARTIC bioinformatics workflow.

```sh
Assembly pipeline for WGS using ONT

Usage: MINION [-r RAWPATH] [-s SAMPLESHEET] [-t THREADS]

-r  The FULL PATH to the directory containing the raw sequencing data (fast5 files).
-s  The FULL PATH to the sample sheet (.csv) file.
-t  Number of tasks to process concurrently.
```
---

### Setting up the pipeline

Download and install the pipeline from the github repo:
```sh
git clone --recursive https://github.com/lpmor22/vgapWGS-ONT.git; cd vgapWGS-ONT
chmod 700 -R INSTALL SCRIPTS
bash INSTALL
```
---

### How to use the vgapWGS-ONT pipeline

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
