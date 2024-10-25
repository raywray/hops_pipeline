import os
import random

# THIS SCRIPT RUN ON CLUSTER

def delete_empty_subdirs(parent_dir):
    # Iterate through all subdirectories in the parent directory
    for subdir in os.listdir(parent_dir):
        subdir_path = os.path.join(parent_dir, subdir)

        # Ensure the path is a directory
        if os.path.isdir(subdir_path):
            # List all visible (non-hidden) files in the current subdirectory
            files_in_subdir = [f for f in os.listdir(subdir_path) if not f.startswith('.')]
            
            # Check if the subdir only contains a .est and .tpl file
            if set(files_in_subdir) <= {"hops.est", "hops.tpl"} and len(files_in_subdir) == 2:
                # If true, remove the .est and .tpl files
                est_file = os.path.join(subdir_path, "hops.est")
                tpl_file = os.path.join(subdir_path, "hops.tpl")
                
                print(f"Deleting files and directory: {subdir_path}")
                os.remove(est_file)
                os.remove(tpl_file)
                
                # Remove the now empty subdirectory
                os.rmdir(subdir_path)

# Example usage:
# parent_dir = "/rhome/respl001/bigdata/output/fsc_output" # Replace with the actual path to your parent directory
# delete_empty_subdirs(parent_dir)

def add_model_to_final_results(dir_1, dir_2, prefix, combined_runs_path):
    counter = 0
    # step 1: start in one dir, check to see if same dir exists in other folder, then decide. 
    for model_dir in os.listdir(dir_1):
        # first, check to see if the random model is already in the combined results
        if os.path.isdir(os.path.join(combined_runs_path, model_dir)):
            print("already combined")
            continue

        # Now, check to see if it exists in the other folder
        if os.path.isdir(os.path.join(dir_2, model_dir)):
            counter += 1
            
            # need to figure out if dir_1 or dir_2 had more completed runs
            dir_1_completed_counter = 0
            dir_2_completed_counter = 0
            for run_dir in os.listdir(os.path.join(dir_1, model_dir)):
                if os.path.exists(os.path.join(dir_1, model_dir, run_dir, prefix, f"{prefix}.bestlhoods")):
                    dir_1_completed_counter += 1
            for run_dir in os.listdir(os.path.join(dir_2, model_dir)):
                if os.path.exists(os.path.join(dir_2, model_dir, run_dir, prefix, f"{prefix}.bestlhoods")):
                    dir_2_completed_counter += 1
            
            # determine winners
            if dir_1_completed_counter > dir_2_completed_counter:
                print("Model: ", model_dir, "Dir 1: ", str(dir_1_completed_counter) + "vs" + str(dir_2_completed_counter))
                # move dir_1 to final results
                os.system(f"cp -r {os.path.join(dir_1, model_dir)} {combined_runs_path}")
            elif dir_2_completed_counter > dir_1_completed_counter:
                print("Model: ", model_dir, "Dir 2: ", str(dir_2_completed_counter) + "vs" + str(dir_1_completed_counter))
                # move dir_2 to final results
                os.system(f"cp -r {os.path.join(dir_2, model_dir)} {combined_runs_path}")
            else:
                print("Model: ", model_dir, "BOTH: ", "dir_1: ", str(dir_1_completed_counter), "dir_2: ", str(dir_2_completed_counter))
                if dir_1_completed_counter > 0 and dir_2_completed_counter > 0:
                    # not 0, same number of success, randomly add one
                    if random.choice([True, False]):
                        # dir_1
                        os.system(f"cp -r {os.path.join(dir_1, model_dir)} {combined_runs_path}")
                    else:
                        # dir_2
                        os.system(f"cp -r {os.path.join(dir_2, model_dir)} {combined_runs_path}")
        else:
            # add dir to combined results we need to do this again for dir_2 dirs
            print("adding directory to results")
            os.system(f"cp -r {os.path.join(dir_1, model_dir)} {combined_runs_path}")
    print("counter: ", counter)

ucr_dir = "/rhome/respl001/bigdata/output/fsc_output"
anthill_dir = "/rhome/respl001/bigdata/output/hops_anthill_output"
prefix = "hops"
combined_runs_path = "/rhome/respl001/bigdata/output/combined_results"
add_model_to_final_results(ucr_dir, anthill_dir, prefix, combined_runs_path)
add_model_to_final_results(anthill_dir, ucr_dir, prefix, combined_runs_path)