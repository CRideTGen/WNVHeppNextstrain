#!/usr/bin/env bash

snakemake  -j 20 \
  --rerun-incomplete \
  --use-conda \
  --conda-frontend mamba \
  --conda-prefix /scratch/cridenour/Projects/VECTR/WNVHeppNextstrain/wnv_nextstrain/sample_processing/conda_envs \
  --configfile config/sample_config.yml \
  --latency-wait 120 \
  --slurm \
  --default-resources  slurm_account=tgen-north slurm_partition=defq
#  --cluster 'sbatch -J VECTR --mem={resources.memory} --time={resources.cpus} --output=/scratch/cridenour/Projects/VECTR/WNVHeppNextstrain/wnv_nextstrain/sample_processing/slurm_output/%x_slurm_%j.log'
