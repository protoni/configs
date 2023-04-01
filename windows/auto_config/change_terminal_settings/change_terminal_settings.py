import json
import os
import shutil

def get_settings_file_path():
    app_data_root = os.getenv('APPDATA')
    settings_path_root = app_data_root + "\..\Local\Packages\\"
    
    terminal_folder = ""
    for name in os.listdir(settings_path_root):
        if 'Microsoft.WindowsTerminal' in name:
            terminal_folder = settings_path_root + name + "\\LocalState\\"
            
    if terminal_folder == "":
        print("Failed to get Terminal settings path!")


    return terminal_folder


# Terminal settings file name
file_name = 'settings.json'

# Backup settings file name
backup_name = 'settings_backup.json'

# Get Terminal settings root path
settings_file=get_settings_file_path()

# Load settings file data
# print("Loading Windows Terminal settings file: " + settings_file + file_name + "..")
f = open(settings_file + file_name, "r")
data = json.load(f)

# Create backup
backup_file = open(settings_file + backup_name, "w")
backup_file.write(json.dumps(data, sort_keys=True, indent=4))
backup_file.close()

# Close settings file
f.close()

# Delete old settings file
os.remove(settings_file + file_name) 

# Get current path
current_path = os.path.dirname(os.path.realpath(__file__))

# Replace old settings file with new one
shutil.copyfile(current_path + "\\" + file_name, settings_file + file_name)









