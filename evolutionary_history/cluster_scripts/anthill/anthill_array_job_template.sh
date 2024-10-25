#!/bin/bash

#PBS -V
#PBS -l nodes=1:ppn=10
#PBS -l mem=300M
#PBS -l walltime=48:00:00
#PBS -N JOB_NAME
#PBS -j oe
#PBS -t 1-ARRAY_MAX
#PBS -q batch
#PBS -o JOB_NAME.$PBS_JOBID.$PBS_ARRAYID

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
cd $PBS_O_WORKDIR

# Activate the Conda environment
# Initialize conda for bash
source /home3/resplin5072/miniconda3/bin/conda init bash

# Activate the conda environment TODO: change conda env
source /home3/resplin5072/miniconda3/bin/activate coalminer_sims_env

# List the Conda environments for debugging
conda info --envs

echo "activating my env"
conda info --envs | grep '^*'

# Calculate the parameters based on the array index
INDEX=$PBS_ARRAYID
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
