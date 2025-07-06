import csv
import os
import sys

def sanitize_identifier(name):
    # Replace invalid characters for C and prevent starting with a number
    name = name.replace("-", "_").replace(" ", "_")
    if name and name[0].isdigit():
        name = "_" + name
    return name

def convert_csv_to_gbdk_c_and_h(input_csv_path):
    base_name = os.path.splitext(os.path.basename(input_csv_path))[0]
    # Fixed array name for the level map
    array_name = "level_map"
    # Macro prefix for width/height definitions in the header, reverted to LEVEL_MAP
    macro_prefix = "LEVEL_MAP" 

    # Read CSV data
    with open(input_csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        tile_rows = [list(map(int, row)) for row in reader]

    if not tile_rows:
        raise ValueError("CSV file is empty or incorrect.")

    height = len(tile_rows)
    width = len(tile_rows[0])

    # Flatten data
    flat_tile_data = [tile for row in tile_rows for tile in row]

    # Output filenames
    c_filename = base_name + ".c"
    h_filename = base_name + ".h"

    # Generate .c file
    with open(c_filename, 'w') as cfile:
        cfile.write(f"// {c_filename}\n")
        cfile.write(f"#include \"{h_filename}\"\n\n")
        cfile.write(f"const unsigned char {array_name}[] = {{\n")
        for i in range(0, len(flat_tile_data), 16): # Output 16 values per line for readability
            line = flat_tile_data[i:i+16]
            cfile.write("    " + ", ".join(str(num) for num in line))
            cfile.write(",\n" if i + 16 < len(flat_tile_data) else "\n")
        cfile.write("};\n")

    # Generate .h file
    include_guard = f"_{array_name.upper()}_H_" # Use level_map for include guard
    with open(h_filename, 'w') as hfile:
        hfile.write(f"// {h_filename}\n")
        hfile.write(f"#ifndef {include_guard}\n")
        hfile.write(f"#define {include_guard}\n\n")

        # Level dimensions from CSV, using LEVEL_MAP prefix as requested
        hfile.write(f"#define {macro_prefix}_WIDTH {width}\n")
        hfile.write(f"#define {macro_prefix}_HEIGHT {height}\n\n")

        # Derived tile dimensions (fixed calculations)
        hfile.write(f"#define MAP_TILE_WIDTH ({macro_prefix}_WIDTH * 2)\n")
        hfile.write(f"#define MAP_TILE_HEIGHT ({macro_prefix}_HEIGHT * 2)\n\n")

        # Game Boy screen dimensions in 8x8 pixel tiles (160x144 pixels)
        hfile.write(f"#define SCREEN_TILE_WIDTH 20 // 160 / 8\n")
        hfile.write(f"#define SCREEN_TILE_HEIGHT 18 // 144 / 8\n\n")

        # Physical VRAM background map size in 8x8 pixel tiles (fixed at 32x32)
        hfile.write(f"#define BKG_MAP_WIDTH_TILES 32\n")
        hfile.write(f"#define BKG_MAP_HEIGHT_TILES 32\n\n")

        hfile.write(f"extern const unsigned char {array_name}[];\n\n")
        hfile.write(f"#endif // {include_guard}\n")

    print(f"Generated files:\n- {c_filename}\n- {h_filename}")
    print(f"Array name: {array_name}")
    print(f"Level dimensions (metatiles): {width} x {height}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python csv2c.py <input.csv>")
        sys.exit(1)

    input_csv = sys.argv[1]
    if not os.path.exists(input_csv):
        print(f"Error: '{input_csv}' not found.")
        sys.exit(1)

    convert_csv_to_gbdk_c_and_h(input_csv)