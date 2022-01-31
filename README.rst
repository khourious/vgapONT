*******************************************************************************
Viral genome assembly pipeline for WGS using Oxford Nanopore Technologies (ONT)
*******************************************************************************

This repository contains scripts and files to run the bioinformatic analysis of whole genome sequencing of viruses.

Until now, this workflow was developed and tested for working with CHIKV and ZIKV ``ZIBRAproject`` and SARS-CoV-2 ``ARTICnetwork`` and ``FIOCRUZ-IOC`` primer schemes. **Tests with other primer schemes should be performed.**

.. code-block:: text

    Viral genome assembly pipeline for WGS using Oxford Nanopore Technologies (ONT)

    -> UPDATE CONDA DEPENDENCIES:
    Usage: vgapONT -u

    -> LIST OF AVAILABLE PRIMER SCHEMES IN THIS WORKFLOW:
    Usage: vgapONT -l

    -> COMPLETE WORKFLOW (BASECALLING + DEMULTIPLEXING + ASSEMBLY):
    Usage: vgapONT -i <input path> -g <gpu memory> -p <primer scheme> -s <sample sheet> -t <number threads>

    -> ONLY BASECALLING + DEMULTIPLEXING:
    Usage: vgapONT -b <input path> -g <gpu memory> -t <number threads>

    -> ONLY ASSEMBLY:
    Usage: vgapONT -a <input path> -p <primer scheme> -s <sample sheet> -t <number threads>


    -a  Path containing the demultiplexed fastq files (only for assembly workflow).
    -b  Path containing the fast5 sequencing data (only for basecalling + demultiplexing workflow).
    -g  VRAM to determine the number of runners per GPU device.
    -i  Path containing the fast5 sequencing data.
    -p  Primer scheme panel user for generate amplicons.
    -s  Path containing the sample sheet in csv.
    -t  Max number of threads (default: all cores minus 2).
    -u  Update conda dependencies.

-----------------------
Setting up the pipeline
-----------------------

Download and install the pipeline from the github repo:

.. code:: bash

    git clone --recursive https://github.com/khourious/vgapONT.git; cd vgapONT
    chmod 700 -R INSTALL
    bash INSTALL

--------------------------------
How to use the complete workflow
--------------------------------

It is necessary to create the sample sheet (.csv). You can create in ``SAMPLE_SHEETS`` directory.

The csv file name **corresponds to the library name** and contains: sample,barcode -- **NO HEADER!!**

.. code-block:: text

    sample01,BC01
    sample02,BC02

You can combine pool A and B if they are on 2 different barcodes:

.. code-block:: text

    sample03,BC03-BC04

* For use, requires:
    * Path containing the fast5 sequencing data
    * Path containing the sample sheet in csv
    * Primer scheme panel user for generate amplicon
    * VRAM to determine the number of runners per GPU device
    * Max number of threads

.. code:: bash

    vgapONT -i /home/user/vgapONT/LIBRARRY_NAME -s /home/user/vgapONT/SAMPLE_SHEETS/LIBRARY_NAME.csv -p SARS-CoV-2_ARTIC/V4.1 -g 6 -t 12

----------------------------------------------------
How to use the basecalling + demultiplexing workflow
----------------------------------------------------

* For use, requires:
    * Path containing the fast5 sequencing data
    * VRAM to determine the number of runners per GPU device
    * Max number of threads

.. code:: bash

    vgapONT -b /home/user/vgapONT/LIBRARRY_NAME -g 6 -t 12

--------------------------------
How to use the assembly workflow
--------------------------------

* For use, requires:
    * Path containing the demultiplexed fastq files
    * Path containing the sample sheet in csv
    * Primer scheme panel user for generate amplicon
    * Max number of threads

.. code:: bash

    vgapONT -a /home/user/vgapONT/LIBRARRY_NAME/DEMUX_DIR -s /home/user/vgapONT/SAMPLE_SHEETS/LIBRARY_NAME.csv -p SARS-CoV-2_ARTIC/V4.1 -t 12
