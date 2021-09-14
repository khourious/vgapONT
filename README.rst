Viral genome assembly pipeline for WGS using ILLUMINA and ONT platforms
===================================================================

This repository contains scripts and files to run the bioinformatic analysis of whole genome sequencing of viruses.

Until now, this workflow was developed and tested for working with CHIKV and ZIKV <ZIBRAproject> and SARS-CoV-2 <ARTICnetwork> <FIOCRUZ-IOC> primer schemes. **Tests with other primer schemes should be performed.**

=======================
Setting up the pipeline
=======================

Download and install the pipeline from the github repo:

.. code:: bash

    git clone --recursive https://github.com/khourious/vgap.git; cd vgapWGS
    chmod 700 -R INSTALL SCRIPTS
    bash INSTALL

===============================
How to use the vgapWGS pipeline
===============================

--------
ILLUMINA
--------

Only requires the raw path and the primer scheme at the command line:

.. code:: bash

    Viral genome assembly pipeline for WGS using ILLUMINA

    -> LIST OF AVAILABLE PRIMER SCHEMES IN THIS WORKFLOW:
    Usage: vgap-ILLUMINA -l

    -> ASSEMBLY:
    Usage: vgap-ILLUMINA -i <input path> -p <primer scheme> -t <number threads>

    -i  Path containing the fastq.gz sequencing data.
    -p  Set the primer scheme information.
    -t  Max number of threads (default: all cores).

---
ONT
---

It is necessary to create the sample sheet (.csv). You can create in ``SAMPLE_SHEETS`` directory.

The csv file name **corresponds to the library name** and contains: sample,barcode,primer scheme -- **NO HEADER!!**

.. code:: bash

    sample01,BC01,nCoV-2019/V3
    sample02,BC02,nCoV-2019/V3

You can combine pool A and B if they are on 2 different barcodes:

.. code:: bash

    sample03,BC03-BC04,nCoV-2019/V3

For use, requires the raw path, sample sheet path and VRAM at the command line:

.. code:: bash

    Viral genome assembly pipeline for WGS using ONT

    -> LIST OF AVAILABLE PRIMER SCHEMES IN THIS WORKFLOW:
    Usage: vgap-ONT -l

    -> BASECALLING + DEMULTIPLEXING:
    Usage: vgap-ONT -b <input path> -g <gpu memory> -t <number threads>

    -> BASECALLING + DEMULTIPLEXING + ASSEMBLY:
    Usage: vgap-ONT -i <input path> -g <gpu memory> -s <sample sheet> -t <number threads>

    -b  Path containing the fast5 sequencing data (only for basecalling + demultiplexing workflow).
    -g  VRAM to determine the number of runners per GPU device.
    -i  Path containing the fast5 sequencing data (only for complete workflow).
    -s  Path containing the sample sheet in csv (only for complete workflow).
    -t  Max number of threads (default: all cores).
