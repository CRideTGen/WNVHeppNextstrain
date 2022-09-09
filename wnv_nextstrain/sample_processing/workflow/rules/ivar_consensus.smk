rule ivar_consensus:
    input:
        mpilup="{output_dir}/mpilup/{sample_name}.mpilup.gz",
        indexs="{output_dir}/mapped/{sample_name}.sorted.bam.bai"
    group: "consensus"
    resources:
        memory=10000,
        time='00:05:00',
        cpus=1,
        ntasks=1
    output:
        multiext("{output_dir}/consensus/{sample_name}",'.fa','.qual.txt')
    shell:
        "gunzip -c {input.mpilup} | ivar consensus -t 0.8 -n 'N' -q 10 -m 10 -p {wildcards.output_dir}/consensus/{wildcards.sample_name}"
