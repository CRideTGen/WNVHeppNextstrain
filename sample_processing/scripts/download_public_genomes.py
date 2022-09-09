from Bio import Entrez

def download_genomes():
    Entrez.email = 'clr96@nau.edu'

    handle = Entrez.efetch(db='nucleotide', id='JQ685904', rettype='fasta', retmode='text')

    print(handle)

    handle.close()