#!/bin/bash

# modified CADDE/USP script

samtools depth "$1" | awk '{if ($3 > '"$2"') {print $0}}' | wc -l | sed -e 's/^ *//g'
