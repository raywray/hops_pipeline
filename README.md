# hops_pipeline

This is the pipeline used in the hops paper (citation). 

First, we created a reusable pipeline that generates several summary statistics (statMix) and fed our *hops* `vcf` data through the pipeline. The summary statistics and analysis results we generated for *hops* are as follows: 
- Hardy Weinberg Equilibrium
- Full population structure analysis using admixture 
- SFS based on the population structure results
- tajima's D
- windowed weir Fst
- weir Fst
- site pi
- site pi per population (from population structure analysis)
- windowed pi
- windowed pi per population (from population structure analysis)
- Fit
- Fis
- allele frequency
- SFS(s) compatible for fastsimcoal analyses

Next, the pipeline uses the SFS(s) created for fastsimcoal analyses, as well as a user-generated parameter `yaml` file, to feed into a fastsimcoal wrapper (citation here) that generates thousands of random coalescent models. This was run on a cluster. The wrapper identified the best model and parameters, ran a bootstrap analysis, and generated images. The results of the best model are included here in the `results/fastsimcoal` folder. 