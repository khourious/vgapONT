#!/bin/bash

# modified CADDE/USP script

samtools depth "$1" | awk '{sum+=$3} END {print sum/NR}'
