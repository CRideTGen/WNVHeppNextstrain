rule samtools_sort:
    input:
        # "{output_dir}/temp_dir/{sample_name}.bam"
        "{output_dir}/mapped/bwt_{sample_name}.bam"

    group: "align and sort"
    resources:
        memory=10000,
        time='00:15:00',
        cpus=4,
        ntasks=1
    output:
        "{output_dir}/mapped/{sample_name}.sorted.bam"
    threads: 4
    wrapper:
        # "module load asap; "
        # "samtools sort -O bam {input} > {output}"
        "v1.7.0/bio/samtools/sort"