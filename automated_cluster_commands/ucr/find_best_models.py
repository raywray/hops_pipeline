import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from utilities import utilities, cluster_commands

"""DEFINE CONSTANTS"""

# local
isMacbook = False
if isMacbook:
    LOCAL_BASE_PATH = "/Users/raya/Documents/School/hops_pipeline/"
else:
    LOCAL_BASE_PATH = "/home/raya/Documents/Projects/hops_pipeline/"
LOCAL_TEMPLATE_SLURM_FILE = os.path.join(
    LOCAL_BASE_PATH, "automated_cluster_commands", "ucr", "best_models_job_template.sh"
)
LOCAL_OUT_DIR = os.path.join(LOCAL_BASE_PATH, "sim_output")
LOCAL_OUTPUT_COMMANDS_DIR = os.path.join(LOCAL_OUT_DIR, "slurm_commands")
LOCAL_CLUSTER_CMDS_FILE = os.path.join(LOCAL_OUTPUT_COMMANDS_DIR, "cluster_cmds.txt")

# remote
REMOTE_BASE_PATH = "/rhome/respl001"
REMTOE_BASH_PROFILE_PATH = os.path.join(REMOTE_BASE_PATH, ".bash_profile")
REMOTE_OUTPUT_BASE_PATH = "/bigdata/armstronglab/respl001"
REMOTE_PROJECT_PATH = os.path.join(REMOTE_BASE_PATH, "Projects", "CoalMinerExamples")
ME_AT_REMOTE_URL = "respl001@cluster.hpcc.ucr.edu"
REMOTE_CLUSTER_CMDS_DIR = os.path.join(REMOTE_OUTPUT_BASE_PATH, "cluster_commands")
REMOTE_RESULTS_OUTPUT_DIR = os.path.join(REMOTE_OUTPUT_BASE_PATH, "output")

def create_job_script(prefix, local_output_dir):
    job_name = "find_best_models"
    partition = "batch"
    script_path = os.path.join(REMOTE_PROJECT_PATH, "automated_cluster_commands", "find_best_models.py")
    remote_output_dir = os.path.join(REMOTE_RESULTS_OUTPUT_DIR, "combined_results")
    
    replacements = [
        ("JOB_NAME", job_name),
        ("PARTITION", partition),
        ("SCRIPT_PATH", script_path),
        ("PREFIX", prefix),
        ("REMOTE_OUTPUT_DIR", remote_output_dir),
        ("LOCAL_OUTPUT_DIR", local_output_dir)
    ]
    job_script_name = job_name + ".sh"
    jobs = cluster_commands.write_sh_file(
        LOCAL_TEMPLATE_SLURM_FILE,
        LOCAL_OUTPUT_COMMANDS_DIR,
        job_script_name,
        replacements
    )
    cluster_cmd = job_script_name

    return cluster_cmd

def make_remote_dir(remote_dir_path):
    make_dir_cmd = [
        "mkdir", remote_dir_path
    ]
    out, er = cluster_commands.send_cmd_to_cluster(
        ME_AT_REMOTE_URL, REMTOE_BASH_PROFILE_PATH, make_dir_cmd, LOCAL_OUT_DIR
    )

def run(prefix, local_path_to_put_best_runs):
    remote_cluster_cmds_dir = os.path.join(REMOTE_CLUSTER_CMDS_DIR, f"{prefix}_output", "find_best_runs")

    # step 1: make out dirs
    # local
    utilities.create_directory(LOCAL_OUT_DIR)
    utilities.create_directory(LOCAL_OUTPUT_COMMANDS_DIR)

    # remote
    make_remote_dir(remote_cluster_cmds_dir)
    
    # step 2: create template job file
    cluster_cmd = create_job_script(prefix, local_path_to_put_best_runs)
    
    # step 3: send command to cluster
    copy_to_cluster_cmd = [
        "scp",
        "-r", 
        os.path.join(LOCAL_OUTPUT_COMMANDS_DIR),
        ME_AT_REMOTE_URL + ":" + os.path.join(remote_cluster_cmds_dir)
    ]
    o, e = cluster_commands.run_and_wait_on_process(copy_to_cluster_cmd, LOCAL_OUT_DIR)

    # step 4: submit job
    submit_job_cmd = [
        "cd", os.path.join(remote_cluster_cmds_dir, "slurm_commands") + ";",
        "sbatch", cluster_cmd + ";"
    ]
    out, er = cluster_commands.send_cmd_to_cluster(
        ME_AT_REMOTE_URL, REMTOE_BASH_PROFILE_PATH, submit_job_cmd, LOCAL_OUT_DIR, retry=True
    )