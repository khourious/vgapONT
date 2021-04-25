#!/bin/bash

# modified CADDE/USP script

samtools view -F 0x904 -c "$1"
