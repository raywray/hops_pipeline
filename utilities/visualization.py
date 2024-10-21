import matplotlib.pyplot as plt
import os
import pandas as pd
import re
import seaborn as sns


def plot_aic_values(aic_file, prefix):
    visualization_dir = os.path.join(
        "/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output",
        "bootstrap",
    )
    # step 1: read data from file
    with open(aic_file, "r") as aic_f:
        data = [line.strip().split() for line in aic_f]

    # step 2: convert string to integers and floats
    data = [(str(pair[0]), float(pair[1])) for pair in data]

    # step 3: sort data based on x-values
    data.sort(key=lambda pair: pair[0])

    # step 4: separate sorted data into x and y values
    x = [re.search(r'\d+', pair[0]).group() for pair in data]
    y = [pair[1] for pair in data]

    # step 5: Create a line plot
    plt.plot(x, y, marker="o", linestyle="-")

    # step 6: Add labels and title
    plt.xlabel("Top Models")
    plt.ylabel("AIC Value")
    plt.title("Best Run AIC Values Comparison")

    # Set ticks on the x-axis to show each x-value
    plt.xticks(x)

    # Display the plot
    plt.savefig(os.path.join(visualization_dir, "best_run_AIC_values_comparison.pdf"))

def plot_bootstrapped_aic_boxplot(aic_file):
    print("hey")

def plot_bootstrapped_lhoods_boxplot(lhoods_filepath, prefix):
    visualization_dir = os.path.join(
        "/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output",
        "bootstrap",
    )
    
    # Function to read the data and group by the first digit
    def read_data_and_group(filename):
        groups = {}
        
        # Read the file line by line
        with open(filename, 'r') as file:
            for line in file:
                # Split the line by space
                first_part, value = line.split()
                
                # Extract the first digit (before the colon)
                group = int(first_part.split(':')[0])  # Convert to integer
                
                # Convert the value to a float
                value = float(value)
                
                # Add the value to the appropriate group
                if group not in groups:
                    groups[group] = []
                groups[group].append(value)
        
        return groups

    # Read in the data and group by the first digit
    data_groups = read_data_and_group(lhoods_filepath)

    # Prepare the data for boxplot, sorted numerically by group
    sorted_keys = sorted(data_groups.keys())  # Sort keys as integers
    data = [data_groups[key] for key in sorted_keys]
    labels = [str(key) for key in sorted_keys]  # Convert labels back to strings for plotting

    # Plot the boxplot
    plt.figure(figsize=(8, 6))
    plt.boxplot(data, showfliers=False)
    plt.ylabel("Lhoods")
    plt.xlabel("Model Number")
    plt.title(f"Bootstrapped Likelihoods for {prefix}")
    plt.xticks(range(1, len(labels) + 1), labels)
    plt.savefig(os.path.join(visualization_dir, f"bootstrapped_likelihoods_{prefix}.pdf"))

def plot_aic_box_and_whisker(aic_filepath, prefix):
    visualization_dir = os.path.join(
        "/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output",
        "bootstrap",
    )
    # Step 1: Load the data
    data = pd.read_csv(aic_filepath, sep=' ', header=None, names=['Model', 'AIC'])

    # Step 2: Extract the model number
    data['Model'] = data['Model'].apply(lambda x: x.split(':')[0])

    # Step 3: Create the boxplot
    plt.figure(figsize=(12, 8))
    data.boxplot(column='AIC', by='Model', grid=False, rot=90)
    plt.title('Box and Whisker Plot of AIC Values by Best Models')
    plt.suptitle('')  # Remove automatic title to make it cleaner
    plt.xlabel('Best Model')
    plt.ylabel('AIC Value')
    plt.savefig(os.path.join(visualization_dir, f"bootstrapped_aic_{prefix}_bw.pdf"))

def aic_violin(aic_filepath, prefix):
    visualization_dir = os.path.join(
        "/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output",
        "bootstrap",
    )
    # Step 1: Load the data
    data = pd.read_csv(aic_filepath, sep=' ', header=None, names=['Model', 'AIC'])

    # Step 2: Extract the model number
    data['Model'] = data['Model'].apply(lambda x: x.split(':')[0])

    # Step 3: Create the violin plot
    plt.figure(figsize=(12, 8))
    sns.violinplot(x='Model', y='AIC', data=data)
    plt.title('Violin Plot of AIC Values by Best Models')
    plt.xlabel('Best Model')
    plt.ylabel('AIC Value')
    plt.xticks(rotation=90)  # Rotate x labels for better readability
    plt.savefig(os.path.join(visualization_dir, f"bootstrapped_aic_{prefix}_violin.pdf"))

def aic_barplot(aic_filepath, prefix):
    visualization_dir = os.path.join(
        "/home/raya/Documents/Projects/hops_pipeline/data_output/fsc_output",
        "bootstrap",
    )
    # Step 1: Load the data
    data = pd.read_csv(aic_filepath, sep=' ', header=None, names=['Model', 'AIC'])

    # Step 2: Extract the model number
    data['Model'] = data['Model'].apply(lambda x: x.split(':')[0])

    # Step 3: Calculate the mean AIC values for each model
    mean_aic = data.groupby('Model')['AIC'].mean().reset_index()

    # Step 4: Create the bar plot
    plt.figure(figsize=(12, 8))
    plt.bar(mean_aic['Model'], mean_aic['AIC'], color='skyblue')
    plt.title('Bar Plot of Mean AIC Values by Best Models')
    plt.xlabel('Best Model')
    plt.ylabel('Mean AIC Value')
    plt.xticks(rotation=90)  # Rotate x labels for better readability
    plt.savefig(os.path.join(visualization_dir, f"bootstrapped_aic_{prefix}_bar.pdf"))


