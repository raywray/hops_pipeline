#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=300M
#SBATCH --time=0-48:00:00
#SBATCH --array=1-ARRAY_MAX
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

# Activate the Conda environment
conda init bash
source /opt/linux/rocky/8.x/x86_64/pkgs/miniconda3/py39_4.12.0/etc/profile.d/conda.sh
conda activate fsc_wrapper_env # TODO: change env

# List the Conda environments for debugging
conda info --envs

echo "activating my env"
conda info --envs | grep '^*'

# Calculate the parameters based on the array index
INDEX=$SLURM_ARRAY_TASK_ID
PARAMS=$(sed -n "${INDEX}p" PARAM_FILE)

# Extract individual parameters
output_dir=$(echo $PARAMS | cut -d ' ' -f 1)
project_path=$(echo $PARAMS | cut -d ' ' -f 2)
prefix=$(echo $PARAMS | cut -d ' ' -f 3)
i=$(echo $PARAMS | cut -d ' ' -f 4)
np=$(echo $PARAMS | cut -d ' ' -f 5)

run_fsc_py="${project_path}/evolutionary_history/cluster_scripts/FSC_SCRIPT"

# Run your Python script with the parameters
echo python3 $run_fsc_py $output_dir $project_path $prefix $i $np
python3 $run_fsc_py $output_dir $project_path $prefix $i $np
