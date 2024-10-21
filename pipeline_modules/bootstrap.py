import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from automated_cluster_commands.ucr import find_best_models
from utilities import utilities, visualization

def extract_number_of_samples(filename):
    with open(filename, "r") as file:
        for line in file:
            # Remove leading and trailing whitespace from each line
            line = line.strip()
            # Check if the line starts with "//Number of population samples"
            if line.startswith("//Number of population samples (demes)"):
                number_of_samples = next(file).strip()
                return int(number_of_samples)

    # Return None if the line is not found
    return None


def visualize_model_fit(prefix, best_runs_base_dir):
    best_models = os.listdir(best_runs_base_dir)

    for model in best_models:
        # NOTE: the .tpl file has to be in the working dir, as well as the .obs files
        cur_best_run_dir = os.path.join(best_runs_base_dir, model)
        cur_tpl_file_path = os.path.join(cur_best_run_dir, f"{prefix}.tpl")
        cur_fsc_output_dir = os.path.join(cur_best_run_dir, prefix)
        copy_tpl_command = ["cp", cur_tpl_file_path, cur_fsc_output_dir]
        utilities.execute_command(copy_tpl_command)

        # move all .obs files into the fsc output dir
        obs_file_path = os.path.join(cur_best_run_dir, f"{prefix}*.obs")
        copy_obs_command = ["cp", obs_file_path, cur_fsc_output_dir]
        utilities.execute_command(copy_obs_command)

        # defin executable paths
        sfstools_ex = (
            "/home/raya/Documents/Projects/hops_pipeline/utilities/SFStools.r"
        )
        plotmodel_ex = (
            "/home/raya/Documents/Projects/hops_pipeline/utilities/ParFileViewer.r"
        )
        # plotmodel_ex = (
        #     "/home/raya/Documents/Projects/hops_pipeline/utilities/plotModel.r"
        # )

        os.chdir(cur_fsc_output_dir)
        # run sfs tools: NOTE: this does not work, but idk how to fix it
        print("TRYING SFS TOOLS****************************")
        run_sfstools = [sfstools_ex, "-t", "print2D", "-i", prefix]
        utilities.execute_command(run_sfstools)

        # run plot model
        # need number of pops to plot
        num_pops = extract_number_of_samples(cur_tpl_file_path)
        populations_list = []
        for i in range(num_pops):
            populations_list.append(f"pop{i}")
        populations = ",".join(populations_list)

        print("TRYING PLOT MODEL***************************")
        # run_plotmodel = [plotmodel_ex, "-p", prefix, "-l", populations]
        run_plotmodel = ["Rscript", plotmodel_ex, f"{prefix}_maxL.par"]
        utilities.execute_command(run_plotmodel)

def calculate_aic_per_sim(base_output_dir, prefix):
    best_sims = os.listdir(base_output_dir)
    for sim in best_sims:
        # first, need to move .est file into the fsc output dir
        cur_best_sim_dir = os.path.join(base_output_dir, sim)
        cur_best_est_path = os.path.join(cur_best_sim_dir, f"{prefix}.est")
        cur_fsc_output_dir = os.path.join(cur_best_sim_dir, prefix)
        # move est into prefix dir
        copy_est = ["cp", cur_best_est_path, cur_fsc_output_dir]
        utilities.execute_command(copy_est)

        # run aic
        utilities_dir = "/home/raya/Documents/Projects/hops_pipeline/utilities"
        aic_executable_path = os.path.join(utilities_dir, "calculate_AIC.sh")
        os.chdir(cur_fsc_output_dir)

        print("****************CALCULATING AIC****************")
        aic_execute_command = [aic_executable_path, prefix]
        utilities.execute_command(aic_execute_command)
        # the output will the in the working directory under {prefix}.AIC

def compare_aic(prefix, base_output_dir, local_aic_filepath):
    # iterate through each best run, save best run value and AIC to a txt file
    runs_and_aic_values = []
    all_sims = os.listdir(base_output_dir)
    for sim in all_sims:
        cur_aic_filepath = os.path.join(base_output_dir, sim, prefix, f"{prefix}.AIC")

        with open(cur_aic_filepath, "r") as aic_f:
            header = next(aic_f).split()
            aic_index = header.index("AIC")
            values = next(aic_f).split()
            aic_value = values[aic_index]
            runs_and_aic_values.append((sim, aic_value))
    sorted_values = sorted(runs_and_aic_values, key=lambda x: float(x[1]))
    with open(local_aic_filepath, "w") as out_f:
        for run_num, aic_value in sorted_values:
            out_f.write(f"{run_num} {aic_value}\n")

def aic_calculation_comparisons_and_plots(best_runs_out_dir, prefix, local_aic_filepath):
    # calculate aic
    calculate_aic_per_sim(best_runs_out_dir, prefix)
    # compare aic
    compare_aic(prefix, best_runs_out_dir, local_aic_filepath)
    # visualize aic
    visualization.plot_aic_values(local_aic_filepath, prefix)

def run():
    prefix = "hops"
    local_best_runs_dir = "/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output"
    best_runs_out_dir = os.path.join(local_best_runs_dir, "best_models")
    bootstrap_results_directory = os.path.join(local_best_runs_dir, "bootstrap")

    local_aic_filepath = os.path.join(bootstrap_results_directory, "aic_values_without_parametric_bootstrap.txt")
    # step 1: find best 10 models (on cluster)
    # find_best_models.run(prefix, local_best_runs_dir)

    # step 3: calculate AIC and plot
    # aic_calculation_comparisons_and_plots(best_runs_out_dir, prefix, local_aic_filepath)

    # step 4: visualize model fit
    visualize_model_fit(prefix, best_runs_out_dir)
run()