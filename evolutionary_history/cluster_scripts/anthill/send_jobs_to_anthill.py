import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from supercomputer_scripts.managers.supercomputer_job_manager import SupercomputerJobManager
from supercomputer_scripts.utilities import cluster_commands
from utilities import basic_utilities

OUTPUT_PREFIX = "hops"
CLUSTER_PROJECT_NAME = f"{OUTPUT_PREFIX}_fsc"
TEMPLATE_SH_FILE_PATH = "/home/raya/Documents/Projects/hops_pipeline/evolutionary_history/cluster_scripts/anthill/anthill_array_job_template.sh"

def generate_job_scripts(job_manager):
    # define reused elements
    local_output_dir = job_manager.local_config.local_output_scripts_dir
    cluster_output_dir = job_manager.cluster_config.results_output_dir
    
    # copy models to cluster
    copy_models_to_cluster = [
        "scp",
        "-r",
        local_output_dir,
        f"{job_manager.get_cluster_username()}:{cluster_output_dir}"
    ]
    basic_utilities.execute_command(copy_models_to_cluster)

    # generate scripts
    num_models = 1000
    num_sims_per_model = 1000
    np = 10
    total_jobs_to_run = num_models * num_sims_per_model
    index = 0
    cluster_cmds = []
    project_path = os.path.join(job_manager.cluster_config.base_project_path, CLUSTER_PROJECT_NAME)

    # loop until all jobs are assigned
    while index < total_jobs_to_run:
        max_jobs_per_array = 16 if total_jobs_to_run > 16 else total_jobs_to_run
        job_name = f"{OUTPUT_PREFIX}_run_{len(cluster_cmds) + 1}"

        param_txt_file_base_name = f"params_{len(cluster_cmds) + 1}.txt"
        param_txt_file_path = os.path.join(
            local_output_dir, param_txt_file_base_name
        )
        params = []

        while len(params) < max_jobs_per_array and index < total_jobs_to_run:
            cur_model = index // num_sims_per_model
            cur_run = index % num_sims_per_model
            cur_model_out_dir_name = os.path.join(
                cluster_output_dir, f"random_model_{cur_model + 1}"
            )

            params.append(
                [
                    cur_model_out_dir_name, # outputdir
                    project_path, # projectpath
                    OUTPUT_PREFIX, # prefix
                    str(cur_run + 1), # cur_run
                    str(np) # np
                ]
            )
            index += 1
        # write params file
        with open(param_txt_file_path, "w") as f:
            for param_line in params:
                line = " ".join(param_line)
                f.write(line + "\n")

        # make individual job script
        replacements = [
            ("JOB_NAME", job_name),
            ("PARAM_FILE", param_txt_file_base_name),
            ("ARRAY_MAX", str(max_jobs_per_array)),
            ("FSC_SCRIPT", "run_fsc.py")
        ]
        job_script_name = job_name + ".sh"
        job = cluster_commands.write_sh_file(
            TEMPLATE_SH_FILE_PATH,
            local_output_dir,
            job_script_name,
            replacements
        )
        cluster_cmds.append(job_script_name)
    return cluster_cmds

def send():
    cluster = "anthill"
    submit_jobs_script = "/home/raya/Documents/Projects/hops_pipeline/evolutionary_history/cluster_scripts/anthill/recursive_submit_jobs.sh"

    # initialize job manager
    supercomputer_manager = SupercomputerJobManager(
        cluster_name=cluster,
        output_prefix=OUTPUT_PREFIX,
    )

    # setup dirs
    supercomputer_manager.setup_directories()

    # generate and copy scripts
    supercomputer_manager.generate_and_copy_scripts(generate_job_scripts, submit_jobs_script)

    # transfer scripts to cluter
    supercomputer_manager.transfer_scripts_to_cluster()


