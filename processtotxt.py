import os
import sys
import subprocess
import platform

def clear_terminal():
    if platform.system() == "Windows":
        os.system("cls")
    else:
        os.system("clear")

input_dir = "music/modules"
output_dir = "music/txt"
burner = subprocess.DEVNULL

# Wipe output_dir before beginning
if os.path.isdir(output_dir):
    for f in os.listdir(output_dir):
        file_path = os.path.join(output_dir, f)
        if os.path.isfile(file_path):
            os.remove(file_path)
else:
    os.makedirs(output_dir)

script_dir = os.path.dirname(os.path.abspath(__file__))

# Detect the host operating system
is_windows = platform.system() == "Windows"

# Define paths to tools based on platform
if is_windows:
    furnace_path = os.path.join("processers", "FUR", "furnace.exe")
    lsdj2txt_path = os.path.join("processers", "LSDJ", "lsdj2txt.exe")
else:
    furnace_path = os.path.join(script_dir, "processers", "FUR", "furnace")
    lsdj2txt_path = os.path.join(script_dir, "processers", "LSDJ", "lsdj2txt")

# Sanity check: are the tools where they’re supposed to be?
for exe_path in [furnace_path, lsdj2txt_path]:
    if not os.path.isfile(exe_path) or not os.access(exe_path, os.X_OK):
        print(f"Where did '{exe_path}' go? It was *right here* a minute ago.")
        sys.exit(1)

def furnace(input_file, output_file):
    subprocess.run(
        [furnace_path, "-txtout", output_file, "-noreport", input_file, "-loglevel", "error"],
        check=True,
        stdout=burner,
        stderr=burner
    )

def lsdj(input_file, output_file):
    with open(output_file, "w", encoding="utf-8") as out_file:
        subprocess.run(
            [lsdj2txt_path, input_file],
            check=True,
            stdout=out_file,
            stderr=burner
        )

if not os.path.isdir(input_dir):
    print(f"Where's '{input_dir}'? That's where we keep the music.")
    sys.exit(1)

# Begin conversion loop
for filename in os.listdir(input_dir):
    filepath = os.path.join(input_dir, filename)
    if not os.path.isfile(filepath):
        continue

    base, ext = os.path.splitext(filename)
    ext = ext.lower().lstrip('.')

    if ext == "fur":
        prefix = "fur"
    elif ext in ["srm", "sav"]:
        prefix = "lsdj"
    else:
        print(f"Not sure what to do with '{filename}'. It's not a Furnace or LSDJ file — just vibes.")
        continue

    output_filename = f"{prefix}_{base}.txt"
    output_path = os.path.join(output_dir, output_filename)

    try:
        clear_terminal()
        if prefix == "fur":
            print(f"🔧 Converting Furnace module: {base}")
            furnace(filepath, output_path)
        else:
            print(f"🔄 Converting LSDj save: {base}")
            lsdj(filepath, output_path)
    except subprocess.CalledProcessError as e:
        print(f"🚨 Something went sideways while handling '{filename}': {e}")

clear_terminal()
print("🎉 All done! The converters have left the building.")
