import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from utilities import bootstrap_utils


def find_best_models(prefix, base_output_dir):
    num_random_models = 100
    num_sims_per_model = 100

    lhoods_results = bootstrap_utils.extract_all_lhoods(
        num_random_models, num_sims_per_model, prefix, base_output_dir
    )

    top_ten_models = bootstrap_utils.get_top_ten_unique_models(
        lhoods_results, base_output_dir
    )
    bootstrap_utils.make_best_run_dirs(top_ten_models, base_output_dir)

# you have to copy them yourself
# def copy_models_to_local(remote_out_dir, local_output_dir):
#     print("copying models to local dir...")
#     copy_cmd = ["scp", "-r", f"{remote_out_dir}/best_run*", local_output_dir]
#     utilities.execute_command(copy_cmd)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <parameter>")
        sys.exit(1)
    prefix = sys.argv[1]
    remote_output_dir = sys.argv[2]
    local_output_dir = sys.argv[3]

    # run program
    find_best_models(prefix, remote_output_dir)
    # have to copy them yourself
    # copy_models_to_local(remote_output_dir, local_output_dir)
