import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import utilities

def extract_all_lhoods(
    num_random_models,
    num_sims,
    prefix,
    base_output_path,
    model_path_prefix="random_model_",
    best_lhoods_extension="bestlhoods",
    sort_ascending=False,
):
    results = []

    # iterate through each model
    for model_num in range(1, num_random_models + 1):
        # find current model path
        model_dir_path = os.path.join(
            base_output_path, f"{model_path_prefix}{model_num}"
        )
        print(model_dir_path)

        # iterate through each sim
        for sim_num in range(1, num_sims + 1):
            # find current simulation path
            sim_dir_path = os.path.join(model_dir_path, f"run_{sim_num}")
            print(sim_dir_path)
            best_lhoods_filepath = os.path.join(
                sim_dir_path, prefix, f"{prefix}.{best_lhoods_extension}"
            )
            print(best_lhoods_filepath)

            # check to if file exists (it won't if the params are "bad")
            if os.path.exists(best_lhoods_filepath):
                # calculate difference between the maximum possible likelihood (MaxObsLhood) and the obtained likelihood (MaxEstLhood)
                with open(best_lhoods_filepath, "r") as lhoods_file:
                    header = next(lhoods_file).split()
                    # if this is the SECOND round using maxL...
                    if best_lhoods_extension == "lhoods":
                        lhood_index = 0  # there's only one option here
                        values = next(lhoods_file).split()
                        lhood_value = float(values[lhood_index])
                        if lhood_value != 0.0:
                            results.append((f"{model_num}:{sim_num}", str(lhood_value)))

                    else:
                        max_obs_index = header.index("MaxObsLhood")
                        max_est_index = header.index("MaxEstLhood")
                        values = next(lhoods_file).split()
                        max_est_lhood = float(values[max_est_index])
                        max_obs_lhood = float(values[max_obs_index])
                        difference = max_obs_lhood - max_est_lhood
                        if max_est_lhood != 0.0:
                            results.append((f"{model_num}:{sim_num}", str(difference)))
    sorted_results = sorted(results, key=lambda x: float(x[1]), reverse=sort_ascending)
    print("sorted results sneak peak: ")
    for result in sorted_results[:5]:
        print(result)
    return sorted_results

def make_best_run_dirs(top_ten, base_output_dir):
    for i in range(len(top_ten)):
        best_model_num, best_run_num = top_ten[i][0].split(":")
        best_run_dir = os.path.join(base_output_dir, f"best_model_{best_model_num}")
        dir_to_copy = os.path.join(
            base_output_dir, f"random_model_{best_model_num}", f"run_{best_run_num}"
        )
        populate_best_dir = ["cp", "-r", dir_to_copy, best_run_dir]
        utilities.execute_command(populate_best_dir)

def get_top_ten_unique_models(
    results, base_output_path, best_lhoods_file_path="best_lhoods_results.txt"
):
    best_lhood_results_path = os.path.join(base_output_path, best_lhoods_file_path)
    # initialize lists
    unique_models_and_runs = []
    unique_models = []

    # write all results to a file
    with open(best_lhood_results_path, "w") as f:
        print("writing to file...")
        for result in results:
            f.write(f"{result[0]} {result[1]}\n")
    if not results:
        print("no results")
        unique_models_and_runs.append("NA")
    # get the top 10 models here
    else:
        print("getting top 10...")
        i = 0
        while len(unique_models) < 10 and i < len(results):
            model, run = results[i][0].split(":")
            if model not in unique_models:
                unique_models.append(model)
                unique_models_and_runs.append(results[i])
            i += 1  # Increment the counter
    return unique_models_and_runs