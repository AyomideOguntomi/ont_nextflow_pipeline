process data_QC {
    publishDir "${params.outdir}/data/interim/fastqc", mode: 'copy'
    input:
    path reads
    val stub

    output:
    path "*.fq"

    script:
    """
    fastqc "$reads" > ${stub}_R1.fq
    """
}

process ref_index {
    publishDir "${params.outdir}/data/external", mode: 'copy'
    input:
    path ref
    val ref_stub

    output:
    path "*", emit: fai

    script:
    """
    bwa index $ref
    """
}

process alignment_to_ref {
    publishDir "${params.outdir}/data/interim/alignment", mode: 'copy'
    input:
    path ref
    path reads
    path fai
    val ref_stub
    //path ref_index
    
    output:
    path "*.sam"

    script:
    """
    bwa mem $ref $reads > ${ref_stub}.sam
    """
}

process sam_to_bam {
    publishDir "${params.outdir}/data/interim/alignment", mode: 'copy'
    input:
    path sam
    val ref_stub

    output:
    path "*.bam"

    script:
    """
    samtools view -@ 4 -b $sam > ${ref_stub}.bam
    """
}

process sam_to_sorted_bam {
    publishDir "${params.outdir}/data/interim/alignment", mode: 'copy'
    input:
    path sam
    val ref_stub

    output:
    path "*.bam" 

    script:
    """
    samtools sort -@ 4 -o ${ref_stub}_sorted_.bam $sam
    """
}

process index_bam {
    publishDir "${params.outdir}/data/interim/alignment", mode: 'copy'
    input:
    path bam

    output:
    path "*.bai"

    script:
    """
    samtools index $bam
    """
}

process variant_calling {
    publishDir "${params.outdir}/data/processed/variant_calling", mode: 'copy'
    input:
    path bam
    path bai
    

    output:
    path "*.vcf"

    script:
    """
    sniffles\
        --input $bam\
        --vcf illumina_R1.vcf
    """
}
