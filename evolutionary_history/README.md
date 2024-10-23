After the summary statistics were generated, we used the SFS(s) created for fastsimcoal analyses from statMix, as well as a user-generated parameter `yaml` file, to feed into CoalMiner (citation here), a random coalescent topology generate to create 1000 coalescent models. This was run on a cluster. The wrapper identified the best model and parameters, ran a bootstrap analysis, and generated images. The results of the best model are included here in the `results/fastsimcoal` folder. 

First, we ran CoalMiner. The output can be found at `/data/output/evolutionary_history/coalminer_output`

