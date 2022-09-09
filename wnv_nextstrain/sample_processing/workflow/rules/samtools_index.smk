rule samtools_index:
    input:
        "{output_dir}/mapped/{sample_name}.sorted.bam",
    group: "align and sort"
    resources:
        memory=10000,
        time='00:15:00',
        cpus=4,
        ntasks=1
    output:
        "{output_dir}/mapped/{sample_name}.sorted.bam.bai",
    log:
        "{output_dir}/logs/samtools_index/{sample_name}.log",
    params:
        extra="",  # optional params string
    threads: 4  # This value - 1 will be sent to -@
    wrapper:
        "v1.7.0/bio/samtools/index"
