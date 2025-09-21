#!/bin/bash -ue
samtools sort -@ 4 -o tiny_sorted_.bam tiny.sam
