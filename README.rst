Viral genome assembly pipeline for WGS using nanopore sequencing
===================================================================

This repository contains scripts and files to run the bioinformatic analysis of whole genome sequencing of viruses using ONT and was built based on the ARTIC bioinformatics workflow.

.. code:: bash

    Assembly pipeline for WGS using ONT

    Usage: MINION [-b BASECALL] [-g GPUMEM] [-r RAWPATH] [-s SAMPLESHEET] [-t THREADS]

    -b  The basecalling accuracy model to aply: 'fast' or 'hac' or 'sup'.
    -g  VRAM to determine the number of runners per GPU device (i.e.: RTX 2060='6'; RTX 2080='8').
    -r  Path containing the fast5 sequencing data.
    -s  Path containing the sample sheet in .csv.
    -t  Number of CPU worker threads (i.e.: i7-9750H='12').

=======================
Setting up the pipeline
=======================

Download and install the pipeline from the github repo:

.. code:: bash

    git clone --recursive https://github.com/khourious/vgapWGS-ONT.git; cd vgapWGS-ONT
    chmod 700 -R INSTALL SCRIPTS
    bash INSTALL

===================================
How to use the vgapWGS-ONT pipeline
===================================

Requires to create the sample sheet (.csv). You can create in ``SAMPLE_SHEETS`` directory.
	
The csv file name **corresponds to the library name** and contains: sample,barcode,reference/version -- **NO HEADER!!**

.. code:: bash

    sample01,BC01,nCoV-2019/V3
    sample02,BC02,nCoV-2019/V3

You can combine pool A and B if they are on 2 different barcodes:

.. code:: bash

    sample03,BC03-BC04,nCoV-2019/V3
