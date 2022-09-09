import pathlib
import re

def get_sequence_reads(dir_path: str) -> tuple:
    path = pathlib.Path(dir_path)

    reads = sorted([i for i in path.rglob("*.fastq*")])

    forward_reads = [i for i in reads if re.match('.*_R1_.*',i.name)]
    reverse_reads = [i for i in reads if re.match('.*_R2_.*',i.name)]

    return (
        forward_reads,
        reverse_reads
    )



def make_symbolic_links(seq_reads: list, symbolic_dir: str) -> None:
    sym_dir = pathlib.Path(symbolic_dir)
    sym_dir.mkdir(parents=True, exist_ok=True)
    for seq in seq_reads:
        short_name = seq.name.split('_')[0]

        if re.match('.*_R1_.*.fastq',seq.name):
            sym_name = f"{short_name}.R1.fastq"
        elif re.match('.*_R2_.*.fastq',seq.name):
            sym_name = f"{short_name}.R2.fastq"
        else:
            raise NameError(f"{seq.name} was not found")


        sym_path = sym_dir.joinpath(sym_name)

        if not sym_path.is_symlink():
            sym_path.symlink_to(seq.resolve())