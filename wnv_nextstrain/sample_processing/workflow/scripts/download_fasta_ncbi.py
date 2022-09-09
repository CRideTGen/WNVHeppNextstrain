from Bio import Entrez, SeqRecord
from contextlib import closing
from urllib.error import HTTPError
import time

def download_genomes(accession_numbers: list, output_file: str) -> None:
    Entrez.email = 'clr96@nau.edu'
    with open(output_file, 'w') as public_file:
        for acc in accession_numbers:
            public_file.write(f">{acc}\n")

            try:
                with closing(Entrez.efetch(db='nucleotide', id=acc, rettype='fasta', retmode='text')) as handle:
                    handle.readline()
                    for line in handle:
                        public_file.write(line)
            except HTTPError:
                print(f"{acc} errored and will retry")
                time.sleep(5)
                with closing(Entrez.efetch(db='nucleotide', id=acc, rettype='fasta', retmode='text')) as handle:
                    handle.readline()
                    for line in handle:
                        public_file.write(line)


def get_gen_bank(accession_number: list, output_file: str) -> None:
    Entrez.email = 'clr96@nau.edu'
    with open(output_file, 'w') as gb_file:
        with closing(Entrez.efetch(db='nucleotide', id=accession_number, rettype='gb', retmode='text')) as handle:
            for line in handle:
                gb_file.write(line)
