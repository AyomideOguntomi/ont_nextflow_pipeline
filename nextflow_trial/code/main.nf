#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// -----------------
// Parameter defaults
// -----------------
params.stub       = params.stub ?: false
params.reads      = params.reads ?: ""
params.reference  = params.reference ?: ""
params.ref_index  = params.ref_index ?: ""
params.ref_stub   = params.ref_stub ?: "tiny"
params.outdir     = params.outdir ?: "results"

// -----------------
// Print info to terminal
// -----------------
println " "
println "Profile: $workflow.profile"
println " "
println "Current User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Outdir:"
println "  $params.outdir"
println "Workdir location:"
println "  $workflow.workDir"
println "Project directory:"
println "  $projectDir"
println "Stub mode: $params.stub"
println " "

// -----------------
// Input channels
// -----------------
raw_ch       = Channel.fromPath(params.reads, checkIfExists: true)
ref_ch       = Channel.fromPath(params.reference, checkIfExists: true)
ref_index_ch = params.ref_index ? Channel.fromPath(params.ref_index, checkIfExists: true) : Channel.empty()

// -----------------
// Include modules
// -----------------
include {
    data_QC;
    ref_index;
    alignment_to_ref;
    sam_to_bam;
    sam_to_sorted_bam;
    index_bam;
    variant_calling
} from "../code/modules.nf"

// -----------------
// Workflow definition
// -----------------
workflow REF_PIPE {
    main:
        data_QC(
            raw_ch.collect(),
            params.stub
        )

        ref_index(
            ref_ch.collect(),
            params.ref_stub
        )

        alignment_to_ref(
            ref_ch.collect(),
            raw_ch.collect(),
            ref_index.out,
            params.ref_stub
        )

        sam_to_bam(
            alignment_to_ref.out,
            params.ref_stub
        )

        sam_to_sorted_bam(
            alignment_to_ref.out,
            params.ref_stub
        )

        index_bam(
            sam_to_sorted_bam.out
        )

        variant_calling(
            sam_to_sorted_bam.out,
            index_bam.out
        )

    emit:
        bam = sam_to_bam.out
        bai = index_bam.out
        vcf = variant_calling.out
}

// -----------------
// Entry point
// -----------------
workflow {
    REF_PIPE()
}
