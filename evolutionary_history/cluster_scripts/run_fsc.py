import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from utilities import basic_utilities, fsc_utilities


def run_setup(cur_run, output_dir, prefix):
    # make directory
    run_output_folder = os.path.join(output_dir, f"run_{cur_run}")
    basic_utilities.create_directory(run_output_folder)

    # copy .tpl and .est into new dir
    print(f"cp {output_dir}/{prefix}* {run_output_folder}")
    os.system(f"cp {output_dir}/{prefix}* {run_output_folder}")

    # move into new dir
    os.chdir(run_output_folder)

def run(output_dir, project_path, prefix, cur_run, np):
    # first, add fsc to project path
    fsc_utilities.add_fsc_to_path(project_path)
    print("fsc added")

    # setup the run
    run_setup(
        cur_run=cur_run, output_dir=output_dir, project_path=project_path, prefix=prefix
    )
    print("set up complete")

    tpl_filename = f"{prefix}.tpl"
    est_filename = f"{prefix}.est"
    
    # run in fsc
    fsc_utilities.send_model_to_fsc(tpl_filename=tpl_filename, est_filename=est_filename, sfs_type="d", np=np) # the d is hardcoded here


if __name__ == "__main__":
    # get user params
    # example call: python3 cluster_main.py output_directory/ fscWrapper_project_path/ hom_sap 3
    if len(sys.argv) < 2:
        print("Usage: python script.py <parameter>")
        sys.exit(1)
    output_dir = sys.argv[1]
    project_path = sys.argv[2]
    prefix = sys.argv[3]
    cur_run = sys.argv[4]
    np = sys.argv[5]

    # run program
    run(
        output_dir=output_dir,
        project_path=project_path,
        prefix=prefix,
        cur_run=cur_run,
        np=np
    )
