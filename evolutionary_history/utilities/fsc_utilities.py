import os

from utilities import utilities

def add_fsc_to_path(project_path):
    print("adding fsc to path...")
    fsc_path = os.path.join(project_path, "fsc28_linux64")
    
    # Get the current PATH
    path = os.getenv("PATH")
    
    # Add the fsc_path to PATH if it's not already there
    if fsc_path not in path:
        os.environ["PATH"] = f"{path}:{fsc_path}"
        print("Added fsc28 to PATH")
    else:
        print("fsc28 is already in PATH")

    # Check if fsc28 is now in PATH
    path = os.getenv("PATH")
    if fsc_path in path:
        print("IN PATH")
    else:
        print("NOT IN PATH")

import os

def add_permissions(tpl, est):
    print("adding permissions...")
    add_permissions_tpl = [
        "chmod a+rwx", tpl
    ]
    add_permissions_est = [
        "chmod a+rwx", est
    ]
    utilities.execute_command(add_permissions_tpl)
    utilities.execute_command(add_permissions_est)


def send_model_to_fsc(tpl_filename, est_filename, sfs_type, np):
    print("sending model to fsc...")
    add_permissions(tpl_filename, est_filename)

    fsc_executable = "fsc28"    
    fsc_command = [
        fsc_executable,
        "-t", # add tpl file 
        tpl_filename,
        "-e", # add est file 
        est_filename,
        f"-{sfs_type}",
        "-0", # removeZeroSFS
        "-C", # minSFSCount
        "10",
        "-n", # numsims
        "1000",
        "-L", # numloops
        "40",
        "-s", # dnaToSnp 
        "0", # this outputs all SNP's in DNA sequence(s)
        "-M", # maxlhood
        "-c", # num processors
        np,
    ]
    utilities.execute_command(fsc_command)
    print("Finished running fsc28")

def send_model_to_fsc_maxL(sfs_type, par_filename, np):
    print("sending model to fsc for maxL...")
    fsc_executable = "fsc28"    
    fsc_command = [
        fsc_executable,
        "-i",
        par_filename,
        f"-{sfs_type}",
        "-j", # output one simulated or bootstrapped SFS per file
        "-n100", # numsims
        "-s0", # Output DNA as SNP data
        "-x", # Does not generate Arlequin output files 
        "-I", # Generates DNA mutations according to an infinite site (IS) mutation model
        "-q", # quiet mode
        "-c", # num processors
        np,
    ]
    utilities.execute_command(fsc_command)
    print("Finished running fsc28")