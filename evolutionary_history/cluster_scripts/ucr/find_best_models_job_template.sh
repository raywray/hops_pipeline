#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=300M
#SBATCH --time=0-48:00:00
#SBATCH --job-name=JOB_NAME
#SBATCH --partition=PARTITION 

DATE=$(date)
HOST=$(hostname)
NCORES=$(nproc)

echo " "
echo "running on host: $HOST"
echo "$NCORES cores requested"
echo "job submitted: $DATE"
echo "job STDOUT follows:"
echo " "

# Change to the directory where the job was submitted from
cd $SLURM_SUBMIT_DIR

script_path=SCRIPT_PATH
prefix=PREFIX
output_dir=REMOTE_OUTPUT_DIR
local_output_dir=LOCAL_OUTPUT_DIR
num_models=NUM_MODELS
num_sims_per_model=NUM_SIMS_PER_MODEL

echo "python3 $script_path $prefix $output_dir $num_models $num_sims_per_model" 
python3 "$script_path" "$prefix" "$output_dir" "$local_output_dir" "$num_models" "$num_sims_per_model"
