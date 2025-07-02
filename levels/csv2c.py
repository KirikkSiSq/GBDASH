import csv
import os
import sys

def sanitize_identifier(name):
    # Reemplaza caracteres no válidos para C y evita empezar con número
    name = name.replace("-", "_").replace(" ", "_")
    if name and name[0].isdigit():
        name = "_" + name
    return name

def convert_csv_to_gbdk_c_and_h(input_csv_path):
    base_name = os.path.splitext(os.path.basename(input_csv_path))[0]
    # Cambiar el nombre del array a level_map fijo
    array_name = "level_map"
    macro_prefix = "LEVEL_MAP"

    # Leer CSV
    with open(input_csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        tile_rows = [list(map(int, row)) for row in reader]

    if not tile_rows:
        raise ValueError("El archivo CSV está vacío o es incorrecto.")

    height = len(tile_rows)
    width = len(tile_rows[0])

    # Aplanar datos
    flat_tile_data = [tile for row in tile_rows for tile in row]

    # Salidas
    c_filename = base_name + ".c"
    h_filename = base_name + ".h"

    # Archivo .c
    with open(c_filename, 'w') as cfile:
        cfile.write(f"// {c_filename}\n")
        cfile.write(f"#include \"{h_filename}\"\n\n")
        cfile.write(f"const unsigned char {array_name}[] = {{\n")
        for i in range(0, len(flat_tile_data), 16):
            line = flat_tile_data[i:i+16]
            cfile.write("    " + ", ".join(str(num) for num in line))
            cfile.write(",\n" if i + 16 < len(flat_tile_data) else "\n")
        cfile.write("};\n")

    # Archivo .h
    include_guard = f"_{macro_prefix}_H_"
    with open(h_filename, 'w') as hfile:
        hfile.write(f"// {h_filename}\n")
        hfile.write(f"#ifndef {include_guard}\n")
        hfile.write(f"#define {include_guard}\n\n")
        hfile.write(f"#define {macro_prefix}_WIDTH {width}\n")
        hfile.write(f"#define {macro_prefix}_HEIGHT {height}\n")
        hfile.write(f"extern const unsigned char {array_name}[];\n\n")
        hfile.write(f"#endif // {include_guard}\n")

    print(f"Archivos generados:\n- {c_filename}\n- {h_filename}")
    print(f"Nombre del array: {array_name}")
    print(f"Tamaño del nivel: {width} x {height}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python csv_to_gbdk_c.py <archivo.csv>")
        sys.exit(1)

    input_csv = sys.argv[1]
    if not os.path.exists(input_csv):
        print(f"Error: No se encontró '{input_csv}'.")
        sys.exit(1)

    convert_csv_to_gbdk_c_and_h(input_csv)
