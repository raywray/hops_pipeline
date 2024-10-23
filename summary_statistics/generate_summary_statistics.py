import os

def execute_command(command_list):
    command = " ".join(command_list)
    
    print(command)
    os.system(command)

def get_statmix_stats():
    stats = ["hwe", "pop_structure", "sfs", "generic_stats", "fsc"]
    statmix_path = os.path.join("/home/raya/Documents/Projects/hops_pipeline/statMix", "statmix.py")
    vcf_path = "/home/raya/Documents/Projects/hops_pipeline/data/input/summary_statistics/hops.vcf"
    output_prefix = "hops"

    command = [
        "python3",  # python executable
        statmix_path,
        "--vcf",
        vcf_path,
        "--out-prefix",
        output_prefix,
        "--analyses"
    ] + [f"{stat}" for stat in stats]

    execute_command(command)


if __name__ == "__main__":
    get_statmix_stats()
