rule bowtie2_build:
    input:
        ref=expand("{reference}", reference=reference),
    resources:
        memory=10000,
        time='00:15:00',
        cpus=1,
        ntasks=1,
    output:
        multiext(
            "{output_dir}/rerence_build/WNVLineage1",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        "{output_dir}/logs/bowtie2_build/build.log",
    params:
        extra="",# optional parameters
    threads: 1
    wrapper:
        "v1.7.0/bio/bowtie2/build"

rule bowtie2:
    input:
        sample=["{output_dir}/trimmed_reads/{sample_name}_1.fastq", "{output_dir}/trimmed_reads/{sample_name}_2.fastq"],
        idx=multiext(
            "{output_dir}/rerence_build/WNVLineage1",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    group: "align and sort"
    resources:
        memory=10000,
        time='00:15:00',
        cpus=4,
        ntasks=1,
    output:
        temp("{output_dir}/mapped/bwt_{sample_name}.bam"),
    log:
        "{output_dir}/logs/bowtie2/{sample_name}.log",
    params:
        extra="",# optional parameters
    threads: 4  # Use at least two threads
    wrapper:
        "v1.7.0/bio/bowtie2/align"
