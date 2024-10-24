We created a reusable pipeline (statMix) that generates several summary statistics and fed our *hops* `vcf` data through the pipeline. The summary statistics and analysis results we generated for *hops* are as follows: 
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

The commands we used to generate the summary statistics are found in `/summary_statistics/generate_summary_statistics.py`

The results of these analyses are found in `/data/output/summary_statistics/statmix_output`

The vcf used for the analysis is available upon request from the USDA