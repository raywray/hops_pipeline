#!/bin/bash

#PBS -V
#PBS -l nodes=1:ppn=1
#PBS -l mem=1mb
#PBS -l walltime=48:00:00
#PBS -N submit_jobs
#PBS -j oe
#PBS -q batch

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

# Script setup
output_file="a_submit_jobs_output.txt"
> "$output_file" # clear if it already exists

# Files to track submitted and failed jobs
submitted_jobs_file="a_submitted_jobs.txt"
failed_jobs_file="a_failed_jobs.txt"
> "$submitted_jobs_file" # clear if it already exists
> "$failed_jobs_file" # clear if it already exists

# Hardcode the path to the list of PBS script names
PBS_SCRIPT_LIST_PATH="cluster_cmds.txt"
echo "PBS script name list path: $PBS_SCRIPT_LIST_PATH"

if [ ! -f "$PBS_SCRIPT_LIST_PATH" ]; then
    echo "File not found: $PBS_SCRIPT_LIST_PATH"
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

# Function to check the number of running or queued jobs
check_job_count() {
    local job_count=$(qstat -u $USER | grep -c '^[0-9]')
    echo "Current job count: $job_count"
    if [ "$job_count" -ge 50 ]; then
        return 1
    else
        return 0
    fi
}

# Function to submit jobs and track which ones fail
submit_jobs() {
    local script_list=("$@")
    local new_failed_jobs=()
    local COUNTER=0

    for PBS_SCRIPT in "${script_list[@]}"; do
        if [ -f "$PBS_SCRIPT" ]; then
            if check_job_count; then
                qsub_output=$(qsub "$PBS_SCRIPT" 2>&1)
                if [[ $? -eq 0 ]]; then
                    echo "Submitted: $PBS_SCRIPT"
                    echo "Submitted: $PBS_SCRIPT" >> "$output_file"
                    submitted_jobs+=("$PBS_SCRIPT")
                    COUNTER=$((COUNTER + 1))
                else
                    echo "Failed to submit: $PBS_SCRIPT"
                    echo "Failed to submit: $PBS_SCRIPT" >> "$output_file"
                    echo "Error: $qsub_output" >> "$output_file"
                    new_failed_jobs+=("$PBS_SCRIPT")
                fi
            else
                echo "Too many jobs running or queued: $PBS_SCRIPT"
                echo "Too many jobs running or queued: $PBS_SCRIPT" >> "$output_file"
                new_failed_jobs+=("$PBS_SCRIPT")
            fi
        else
            echo "Script not found: $PBS_SCRIPT"
            echo "Script not found: $PBS_SCRIPT" >> "$output_file"
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
mapfile -t pbs_scripts < "$PBS_SCRIPT_LIST_PATH"

# Loop until all jobs are successfully submitted
while [ "${#pbs_scripts[@]}" -gt 0 ]; do
    echo "Attempting to submit jobs..."
    
    # Submit jobs and track failed jobs
    submit_jobs "${pbs_scripts[@]}"
    
    if [ "${#failed_jobs[@]}" -eq 0 ]; then
        echo "All jobs submitted successfully."
        break
    else
        echo "Waiting for 1 minute before retrying failed jobs..."
        sleep 60  # Wait for 1 minute (60 seconds)
        
        # Prepare for next round by resetting the script list to failed jobs
        pbs_scripts=("${failed_jobs[@]}")
        echo "Retrying ${#pbs_scripts[@]} failed jobs..."

        # Save the state of submitted and failed jobs after each iteration
        printf "%s\n" "${submitted_jobs[@]}" > "$submitted_jobs_file"
        printf "%s\n" "${failed_jobs[@]}" > "$failed_jobs_file"
    fi
done

# Final cleanup
cleanup

echo "Total scripts finally submitted successfully: $(grep -c "Submitted" "$output_file")"
echo "Total scripts that failed after all attempts: $(grep -c "Failed to submit" "$output_file")"
