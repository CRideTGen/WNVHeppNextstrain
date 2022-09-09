rule mpilup:
    input:
        # single or list of bam files
        bam="{output_dir}/mapped/{sample_name}.sorted.bam",
        indexs = "{output_dir}/mapped/{sample_name}.sorted.bam.bai",
        reference_genome={reference},
    output:
        "{output_dir}/mpilup/{sample}.mpilup.gz",
    log:
        "{output_dir}/logs/samtools/mpileup/{sample}.log",
    params:
        extra="-A -d 100000 -Q 0 -F 0"
    wrapper:
        "v1.12.2/bio/samtools/mpileup"
