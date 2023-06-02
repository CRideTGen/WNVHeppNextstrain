import pathlib

from wnv_nextstrain.sample_processing.workflow.scripts.parse_sample_sheet import read_sample_sheet, FIELDNAMES

def get_sample_pairs(wildcards):
    forward_reads = next(sequence_dir.glob(f"VECTR*/*{wildcards.sample_name}*R1*fastq*")).resolve()
    reverse_reads = next(sequence_dir.glob(f"VECTR*/*{wildcards.sample_name}*R2*fastq*")).resolve()

    return [forward_reads, reverse_reads]


# configfile: "config/read_pipeline.yaml"

reference = config["reference_genome"]
sequence_dir = pathlib.Path(config["sequence_directory"])
output_dir = config["output_directory"]
adapter_file = config["adapter_file"]

sample_names = [name for name in read_sample_sheet(pathlib.Path(sequence_dir), fieldnames=FIELDNAMES)]
