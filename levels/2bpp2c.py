import os
import sys

def convert_2bpp_to_c_header(input_file, var_name):
    with open(input_file, 'rb') as f:
        data = f.read()

    num_tiles = len(data) // 16
    if len(data) % 16 != 0:
        print("Warning: The file is not an exact multiple of 16 bytes. It may be corrupted.")

    base_name = os.path.splitext(os.path.basename(input_file))[0]
    c_file = base_name + ".c"
    h_file = base_name + ".h"

    # Generar archivo .h
    with open(h_file, 'w') as h:
        h.write(f"#ifndef __{var_name.upper()}_H__\n")
        h.write(f"#define __{var_name.upper()}_H__\n\n")
        h.write(f"#include <gb/gb.h>\n\n")
        h.write(f"#define {var_name.upper()}_TILE_COUNT {num_tiles}\n\n")
        h.write(f"extern const unsigned char {var_name}[];\n\n")
        h.write(f"#endif // __{var_name.upper()}_H__\n")

    # Generar archivo .c
    with open(c_file, 'w') as c:
        c.write(f"#include \"{base_name}.h\"\n\n")
        c.write(f"const unsigned char {var_name}[] = {{\n")

        for i in range(0, len(data), 16):
            tile = data[i:i+16]
            line = ", ".join(f"0x{b:02x}" for b in tile)
            c.write(f"    {line},\n")

        c.write("};\n")

    print(f"Generated files: {c_file}, {h_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python convert_2bpp_to_gbdk.py filename.2bpp filename")
        sys.exit(1)

    convert_2bpp_to_c_header(sys.argv[1], sys.argv[2])
