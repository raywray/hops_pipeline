import os
from supercomputer_scripts.managers.supercomputer_job_manager import (
    SupercomputerJobManager,
)
from evolutionary_history.cluster_scripts.supercomputer_scripts.utilities import cluster_commands

OUTPUT_PREFIX = "hops_find_best"
CLUSTER_PROJECT_NAME = "hops_fsc"


def create_job_script(job_manager):
    job_name = OUTPUT_PREFIX
    num_models = 1000
    num_sims_per_model = 1000
    template_sh_file = "/home/raya/Documents/Projects/hops_pipeline/evolutionary_history/cluster_scripts/ucr/find_best_models_job_template.sh"
    local_dir_to_save_results = os.path.join(
        job_manager.local_config.base_path,
        "hops_pipeline",
        "data",
        "output",
        "evolutionary_history",
        "fsc_output",
        "best_models",
    )

    partition = "batch"

    # this should just make a job script that calls the find best models py script
    # and return that as the single command
    cluster_cmds = []
    path_to_find_best_script = os.path.join(
        job_manager.cluster_config.base_project_path,
        CLUSTER_PROJECT_NAME,
        "cluster_scripts",
        "find_best_models.py",
    )
    fsc_prefix = "hops"
    cluster_results_dir = os.path.join(
        job_manager.cluster_config.results_base_output_dir,
        "combined_anthill_ucr_results",
    )

    replacements = [
        ("JOB_NAME", job_name),
        ("PARTITION", partition),
        ("SCRIPT_PATH", path_to_find_best_script),
        ("PREFIX", fsc_prefix),
        ("REMOTE_OUTPUT_DIR", cluster_results_dir),
        ("LOCAL_OUTPUT_DIR", local_dir_to_save_results),
        ("NUM_MODELS", num_models),
        ("NUM_SIMS_PER_MODEL", num_sims_per_model)
    ]
    job_script_name = job_name + ".sh"

    jobs = cluster_commands.write_sh_file(
        template_sh_file,
        job_manager.local_config.local_output_scripts_dir,
        job_script_name,
        replacements
    )
    cluster_cmds.append(job_script_name)
    return cluster_cmds


def find():
    cluster = "ucr"
    submit_jobs_script = "/home/raya/Documents/Projects/hops_pipeline/evolutionary_history/cluster_scripts/ucr/recursive_submit_jobs.sh"

    # initialize job manager
    supercomputer_manager = SupercomputerJobManager(
        cluster_name=cluster, output_prefix=OUTPUT_PREFIX
    )

    # setup dirs
    supercomputer_manager.setup_directories()

    # generate and copy scripts
    supercomputer_manager.generate_and_copy_scripts(create_job_script, submit_jobs_script)

    # transfer scripts to cluster
    supercomputer_manager.transfer_scripts_to_cluster()