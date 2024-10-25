After the summary statistics were generated, we used the SFS(s) created for fastsimcoal analyses from statMix, as well as a user-generated parameter `yaml` file, to feed into CoalMiner (citation here), a random coalescent topology generate to create 1000 coalescent models. This was run on 2 clusters, *anthill* from SDSU and the *hpcc* cluster at UC Riverside. We then identified the best model and parameters, ran a bootstrap analysis, and generated images. The results of the best model are included here in the `results/fastsimcoal` folder. 

First, we ran CoalMiner to generate 1000 random topologies. The output can be found at `/data/output/evolutionary_history/coalminer_output` and the commands we used to do that can be found in `generate_evolutionary_history.py` in the `generate_models_with_coalminer` function. The generated CoalMiner models can be found in `/data/output/evolutionary_history/coalminer_output`

Next, we ran each random model 10,000 times with `fastsimcoal28`, using the following parameters 1000 times: `-d` for a DSFS type, `-0` to remove zero SFS, `-C 10` to specific the minimum SFS count, `-n 1000` to specify the number of simulations of fastsimcoal, `-L 40` to set the number of loops to 40, `-s 0` to output all SNPs in the DNA sequence(s), `-M` to output the maximum likelihood, and `-c 10` to specify the number of processors. The commands used to accomplish this are found in `generate_evolutionary_history.py` in the `run_models_on_cluster` function. The results of these runs can be found [here.](https://drive.google.com/drive/folders/1MRSp3PDxnQSaDUD5yfDzmR6Q5cH4zGHN?usp=sharing)

Following, we first combined the runs from *anthill* with *hpcc* by running the `combine_results_anthill_ucr.py` on the UCR cluster. We then identified the top 10 "best-fitting" models, or the models with the smallest differences in their maximum estimated likelihood and the maximum observed likelihood (the commands for this are found in `generate_evolutionary_history.py` in the `find_best_model` function). We calculated and graphed the AIC values per model, as well as generated figures of what each topologies looks like given the maximum likelihood parameters (commands found in the `run_bootstrap` function of `generate_evolutionary_history.py`). 

TODO: @Arun add finishing bootstrap analysis here.



