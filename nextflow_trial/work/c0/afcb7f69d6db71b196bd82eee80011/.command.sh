#!/bin/bash -ue
samtools view -@ 4 -b tiny.sam > tiny.bam
