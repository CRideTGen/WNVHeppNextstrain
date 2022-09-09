import pathlib
from Bio import SeqIO, Seq


class ConSeq:
    def __init__(self, record: SeqIO):
        self.name = record.id
        self.length = len(record)

        self.A = record.seq.count('A')
        self.C = record.seq.count('C')
        self.T = record.seq.count('T')
        self.G = record.seq.count('G')
        self.N = record.seq.count('N')

        self.percent_sequenced = round(1 - (self.N / self.length), 2)
        self.output_string = '\t'.join([self.name, str(self.length), str(self.percent_sequenced)]) + '\n'


def get_sequence_file_path(dir_path: pathlib.Path) -> list:
    if not dir_path.is_dir():
        raise OSError(f"{dir_path} drectory not found")

    seq_list = [i for i in dir_path.rglob('*.fa*')]

    if seq_list:
        return seq_list

    else:
        raise FileNotFoundError("No Fasta Files ")


def combine_sequences(seq_directory: str, output_file: str) -> None:
    seq_path = pathlib.Path(seq_directory)
    sequences = get_sequence_file_path(dir_path=seq_path)

    sequences_combined = list()

    with open('consensus_data_summary.tsv', 'w') as ff:
        ff.write('\t'.join(['id', 'length', 'percent sequenced']) + '\n')
        for seq_file in sequences:
            record = SeqIO.read(seq_file, "fasta")

            record.id = record.id.split('_')[1]
            record.description = ''

            print(record.id)

            con_seq = ConSeq(record)

            if con_seq.length >= 10000 and con_seq.percent_sequenced > 0.35:
                sequences_combined.append(record)

            ff.write(con_seq.output_string)

    SeqIO.write(sequences_combined, output_file, "fasta")


def main():
    combine_sequences(
        "/home/chase/DissertationProjects/nextstrain/WNV_Nextstrain_Analysis/sample_processing/OutputDirectory/consensus",
        "/home/chase/DissertationProjects/nextstrain/WNV_Nextstrain_Analysis/sample_processing/OutputDirectory/consensus/combined_sequences.fasta")


if __name__ == "__main__":
    main()
