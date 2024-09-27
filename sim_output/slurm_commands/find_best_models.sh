#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=300M
#SBATCH --time=0-48:00:00
#SBATCH --job-name=find_best_models
#SBATCH --partition=batch 

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

script_path=/rhome/respl001/Projects/CoalMinerExamples/automated_cluster_commands/find_best_models.py
prefix=hops
output_dir=/bigdata/armstronglab/respl001/output/combined_results
local_output_dir=/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output

echo "python3 $script_path $prefix $output_dir" 
python3 "$script_path" "$prefix" "$output_dir" "$local_output_dir"
