rule mpilup:
    input:
        # single or list of bam files
        bam="{output_dir}/mapped/{sample_name}.sorted.bam",
        # indexs = "{output_dir}/mapped/{sample_name}.sorted.bam.bai",
        reference_genome={reference},
    group: "consensus"
    resources:
        memory=10000,
        time='00:05:00',
        cpus=1,
        ntasks=1
    output:
        "{output_dir}/mpilup/{sample_name}.mpilup.gz",
    log:
        "{output_dir}/logs/samtools/mpileup/{sample_name}.log",
    params:
        extra="-aa -A -d 0 -Q 0"
    wrapper:
        "v1.12.2/bio/samtools/mpileup"
