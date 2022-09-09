
rule trim_reads_bbduk:
    input:
        sample=get_sample_pairs,
        adapters=expand("{adapter_file}",adapter_file=adapter_file),
    #
    resources:
        memory=10000,
        time="00:15:00",
        cpus=7,
        ntasks=1,

    output:
        trimmed=["{output_dir}/trimmed_reads/{sample_name}_1.fastq",
                 "{output_dir}/trimmed_reads/{sample_name}_2.fastq"],
        singleton="{output_dir}/trimmed_reads/pe/{sample_name}.single.fastq",
        discarded="{output_dir}/trimmed_reads/pe{sample_name}.discarded.fastq",
        stats="{output_dir}/trimmed_reads/pe/{sample_name}.stats.txt",
    log:
        "{output_dir}/logs/BBDuk/{sample_name}.log"
    params:
        extra=lambda w, input: "ref={},adapters,artifacts ktrim=r k=23 mink=11 hdist=1 tpe tbo trimpolygright=10 minlen=25 maxns=30 entropy=0.5 entropywindow=50 entropyk=5".format(input.adapters),
    threads:
        7
    wrapper:
        "v1.7.0/bio/bbtools/bbduk"
