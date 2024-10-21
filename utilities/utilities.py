import os

def execute_command(command_list):
    command = " ".join(command_list)
    print(command)
    result = os.system(command)
    if result != 0:
        print("Command Failed to Execute")
    else:
        print("Command Successfully Executed")

def create_directory(dir_path):
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)