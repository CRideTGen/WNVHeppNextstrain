#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

module load bbmap

#variables to ensure all options were given
forward_check=false
reverse_check=false
primer_check=false
output_check=false

Help() {
  # Display Help
  echo "Trims all sequence reads in folder"
  echo
  echo "Syntax: scriptTemplate [-h|d|p|o]"
  echo "options:"
  echo "-d     Path to dictory containing paired-end reads"
  echo "-p     Path to fasta file containing primers to be trimmed"
  echo "-o     Output directory"
  echo "V     Print software version and exit."
  echo
}

check_if_option_exists() {

  if [ "$1" = false ]; then
    echo "Missing argument $2"
    exit 1

  fi
}

while getopts ":h:f:r:p:o:" option; do
  case $option in
  h) #display Help
    Help
    exit
    ;;
  f) #enter directory
    forward_check=true
    forward_read=${OPTARG}
    ! [ -f ${forward_read} ] && echo "ERROR: Forward read does not exist" && exit 1
    ;;

  r) #enter directory
    reverse_check=true
    reverse_read=${OPTARG}
    ! [ -f ${reverse_read} ] && echo "ERROR: Reverse read does not exist" && exit 1
    ;;
  p) # primer file
    primer_check=true
    primer_file=${OPTARG}
    ! [ -f ${primer_file} ] && echo "ERROR: Primer file does not exist" && exit 1
    ;;
  o) #output directory
    output_check=true
    output=${OPTARG}
    ! [ -d ${output} ] && mkdir -p ${output}
    ;;
  \?) # Invalid Option
    echo "Error: Invalid Option"
    exit
    ;;
  esac
done

check_if_option_exists ${forward_check} '-f'
check_if_option_exists ${reverse_check} '-r'
check_if_option_exists ${primer_check} '-p'
check_if_option_exists ${output_check} '-o'

########## main function #################

mkdir -p ${output}/stats
mkdir -p ${output}/mismatch

input1=${forward_read}
input2=${reverse_read}

input1_base=$(basename ${input1})
input1_headless=${input1_base#*-}
sample_name=${input1_headless%%-*}
sample_name=${sample_name/.R1.fastq/}
output1=${sample_name}_R1.fastq
output2=${sample_name}_R2.fastq
mismatch1=${sample_name}_R1_mismatch.fastq
mismatch2=${sample_name}_R2_mismatch.fastq
stats=${sample_name}_stats.txt
echo
echo "input1: $input1"
echo "input2: $input2"
echo "sample name: ${sample_name}"
echo "output1: $output1"
echo "output2: $output2"
echo "stats: $stats"
echo

/scratch/clr96/packages/src/bbmap/bbduk.sh -Xmx60g -da \
  in=$input1 \
  in2=$input2 \
  out=${output}/${output1} \
  out2=${output}/${output2} \
  outm=${output}/mismatch/${mismatch1} \
  outm2=${output}/mismatch/${mismatch2} \
  ref="${primer_file}" \
  stats=${output}/stats/${stats} \
  statscolumns=5 \
  ottm=t \
  restrictleft=30 \
  ordered=t k=7 \
  minlen=80 \
  ktrim=l \
  edist=3 \
  edist2=1 \
  ftm=5 \
  mink=5 \
  copyundefined \
  fixjunk
