#!/usr/bin/env bash

snakemake -R \
  -j 50 \
  --use-conda \
  --conda-frontend conda \
  --conda-prefix /scratch/cridenour/Projects/VECTR/WNVHeppNextstrain/wnv_nextstrain/sample_processing/conda_envs \
  --configfile config/sample_config.yml \
  --latency-wait 120 \
  --cluster 'sbatch -J VECTR --mem={resources.memory} --time={resources.cpus} --output=/scratch/cridenour/Projects/VECTR/WNVHeppNextstrain/wnv_nextstrain/sample_processing/slurm_output/%x_slurm_%j.log'
