import sys
from general_utilities import bootstrap_utils


def find_best_models(prefix, base_output_dir, num_random_models, num_sims_per_model):

    lhoods_results = bootstrap_utils.extract_all_lhoods(
        num_random_models, num_sims_per_model, prefix, base_output_dir
    )

    top_ten_models = bootstrap_utils.get_top_ten_unique_models(
        lhoods_results, base_output_dir
    )
    bootstrap_utils.make_best_run_dirs(top_ten_models, base_output_dir)

# run this command on cluster
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
    num_models = sys.argv[4]
    num_sims_per_model = sys.argv[5]

    # run program
    find_best_models(prefix, remote_output_dir)
    # have to manually copy them from cluster to local machine
    # copy_models_to_local(remote_output_dir, local_output_dir)
