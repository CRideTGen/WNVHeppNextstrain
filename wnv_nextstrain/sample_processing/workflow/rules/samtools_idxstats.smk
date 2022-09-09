rule samtools_idxstats:
    input:
        bam="{output_dir}/mapped/{sample_name}.sorted.bam",
        idx="{output_dir}/mapped/{sample_name}.sorted.bam.bai",
    group: "align and sort"
    resources:
        memory=10000,
        time='00:15:00',
        cpus=1,
        ntasks=1,
    output:
        "{output_dir}/stats/{sample_name}.idxstat.out",
    log:
        "{output_dir}/logs/samtools/stats/{sample_name}.log",
    params:
        extra="",# optional params string
    wrapper:
        "v1.7.0/bio/samtools/idxstats"

    # rule samtools_idxstats:
    #     input:
    #         "{output_dir}/bamfiles/{sample_name}.sorted.bam.bai"

    #
    #     params:
    #         output_directory="{output_dir}/bamfiles"
    #
    #     output:
    #         "{output_dir}/stats/{sample_name}.idx.out"
    #     shell:
    #         # "module load asap;"
    #         "inputs=$(basename -s .bai {input});"
    #         "samtools idxstats {params.output_directory}/$inputs > {output}"
