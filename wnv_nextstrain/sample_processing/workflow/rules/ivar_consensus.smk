rule ivar_consensus:
    input:
        bam="{output_dir}/mapped/{sample_name}.sorted.bam"
    group: "consensus"
    resources:
        memory=10000,
        time='00:05:00',
        cpus=1,
        ntasks=1
    output:
        multiext("{output_dir}/consensus/{sample_name}",".fa",".qual.txt")
    shell:
        "samtools mpileup -aa -A -d 0 -Q 0 {input.bam} | ivar consensus -t 0.8 -n 'N' -q 10 -m 10 -p {wildcards.output_dir}/consensus/{wildcards.sample_name}"
