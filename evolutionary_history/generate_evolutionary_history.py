import os

from utilities import basic_utilities
from cluster_scripts.anthill import send_jobs_to_anthill
from cluster_scripts.ucr import send_jobs_to_ucr

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
    os.chdir(coalminer_path)
    run_coalminer_cmd = [
        "python3",
        "coalminer.py",
        coalminer_input_yml
    ]
    basic_utilities.execute_command(run_coalminer_cmd)
    

def run_models_on_cluster():
    send_jobs_to_anthill.send()
    send_jobs_to_ucr.send()

def find_best_model():
    print("best")

def run_bootstrap():
    print("boot")
    # @ARUN