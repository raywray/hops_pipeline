import os

from utilities import basic_utilities

def generate_models_with_coalminer():
    # define paths
    project_path = "/home/raya/Documents/Projects/hops_pipeline"
    coalminer_path = os.path.join(project_path, "evolutionary_history/CoalMiner")
    coalminer_input_folder_path = os.path.join(project_path, "data/input/evolutionary_history/coal_miner_input_files")
    coalminer_input_yml = "user_input_hops_k4.yml"

    # copy observed SFS and .yml into the CoalMiner project
    copy_sfs_cmd = [
        "cp",
        "-r",
        coalminer_input_folder_path,
        coalminer_path
    ]
    basic_utilities.execute_command(copy_sfs_cmd)

    # run coalminer
    # change into the coalminer dir
    os.chdir(coalminer_path)
    run_coalminer_cmd = [
        "python3",
        "coalminer.py",
        coalminer_input_yml
    ]
    basic_utilities.execute_command(run_coalminer_cmd)
    

def run_models_on_cluster():
    print("cluster")

def find_best_model():
    print("best")

def run_bootstrap():
    print("boot")
    # @ARUN