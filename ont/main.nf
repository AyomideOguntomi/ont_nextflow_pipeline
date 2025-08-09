#!/usr/bin/env nextflow

params.reads = "$baseDir/data/*.fastq.gz"
params.ref   = "$baseDir/data/reference.fasta"

process ALIGN {
    container 'ont-ngs-tools:latest'
    input:
    path reads
    path ref

    output:
    path "aligned.sam"

    """
    minimap2 -ax map-ont $ref $reads > aligned.sam
    """
}

workflow {
    Channel.fromPath(params.reads)
        .set { read_files }

    Channel.fromPath(params.ref)
        .set { reference }

    ALIGN(read_files, reference)
}
