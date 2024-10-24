#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1M
#SBATCH --time=0-48:00:00
#SBATCH --job-name=submit_jobs
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

# Script setup
output_file="a_submit_jobs_output.txt"
> "$output_file" # clear if it already exists

# Files to track submitted and failed jobs
submitted_jobs_file="a_submitted_jobs.txt"
failed_jobs_file="a_failed_jobs.txt"
> "$submitted_jobs_file" # clear if it already exists
> "$failed_jobs_file" # clear if it already exists

# Hardcode the path to the list of SLURM script names
SLURM_SCRIPT_LIST_PATH=$1

if [ ! -f "$SLURM_SCRIPT_LIST_PATH" ]; then
    echo "File not found: $SLURM_SCRIPT_LIST_PATH"
    exit 1
fi

# Function to handle cleanup and save state on exit
cleanup() {
    echo "Saving submitted and failed jobs to files..."
    printf "%s\n" "${submitted_jobs[@]}" > "$submitted_jobs_file"
    printf "%s\n" "${failed_jobs[@]}" > "$failed_jobs_file"
    echo "Cleanup complete. Exiting..."
    exit 0
}

# Trap termination signals to run cleanup
trap cleanup SIGTERM

# Initialize arrays for submitted and failed jobs
submitted_jobs=()
failed_jobs=()

# Function to submit jobs and track which ones fail
submit_jobs() {
    local script_list=("$@")
    local new_failed_jobs=()
    local COUNTER=0

    for SLURM_SCRIPT in "${script_list[@]}"; do
        if [ -f "$SLURM_SCRIPT" ]; then
            sbatch_output=$(sbatch "$SLURM_SCRIPT" 2>&1)
            if [[ $? -eq 0 ]]; then
                echo "Submitted: $SLURM_SCRIPT"
                echo "Submitted: $SLURM_SCRIPT" >> "$output_file"
                submitted_jobs+=("$SLURM_SCRIPT")
                COUNTER=$((COUNTER + 1))
            else
                echo "Failed to submit: $SLURM_SCRIPT"
                echo "Failed to submit: $SLURM_SCRIPT" >> "$output_file"
                echo "Error: $sbatch_output" >> "$output_file"
                new_failed_jobs+=("$SLURM_SCRIPT")
            fi
        else
            echo "Script not found: $SLURM_SCRIPT"
            echo "Script not found: $SLURM_SCRIPT" >> "$output_file"
        fi
    done

    echo "Total scripts submitted in this round: $COUNTER"
    echo "Total scripts submitted in this round: $COUNTER" >> "$output_file"
    
    # Print the list of failed jobs and update the failed_jobs array
    if [ "${#new_failed_jobs[@]}" -gt 0 ]; then
        echo "Failed jobs in this round:"
        printf "%s\n" "${new_failed_jobs[@]}"
        printf "%s\n" "${new_failed_jobs[@]}" >> "$output_file"
        failed_jobs=("${new_failed_jobs[@]}")
    else
        failed_jobs=()
    fi
}

# Read all script names into an array
mapfile -t slurm_scripts < "$SLURM_SCRIPT_LIST_PATH"

# Loop until all jobs are successfully submitted
while [ "${#slurm_scripts[@]}" -gt 0 ]; do
    echo "Attempting to submit jobs..."
    
    # Submit jobs and track failed jobs
    submit_jobs "${slurm_scripts[@]}"
    
    if [ "${#failed_jobs[@]}" -eq 0 ]; then
        echo "All jobs submitted successfully."
        break
    else
        echo "Waiting for 1 minute before retrying failed jobs..."
        sleep 60  # Wait for 1 minute (60 seconds)
        
        # Prepare for next round by resetting the script list to failed jobs
        slurm_scripts=("${failed_jobs[@]}")
        echo "Retrying ${#slurm_scripts[@]} failed jobs..."

        # Save the state of submitted and failed jobs after each iteration
        printf "%s\n" "${submitted_jobs[@]}" > "$submitted_jobs_file"
        printf "%s\n" "${failed_jobs[@]}" > "$failed_jobs_file"
    fi
done

# Final cleanup
cleanup

echo "Total scripts finally submitted successfully: $(grep -c "Submitted" "$output_file")"
echo "Total scripts that failed after all attempts: $(grep -c "Failed to submit" "$output_file")"
