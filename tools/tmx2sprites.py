import argparse
import csv
import struct
import xml.etree.ElementTree as ET
from pathlib import Path


def c_identifier(name):
    cleaned = []
    for char in name:
        if char.isalnum() or char == "_":
            cleaned.append(char)
        else:
            cleaned.append("_")
    result = "".join(cleaned).strip("_")
    if not result:
        result = "level"
    if result[0].isdigit():
        result = "_" + result
    return result


def parse_tmx_sprite_layer(path, layer_name="SP", tileset_name="sprites"):
    tree = ET.parse(path)
    root = tree.getroot()

    sprite_tileset = None
    for tileset in root.findall("tileset"):
        if tileset.attrib.get("name") == tileset_name:
            sprite_tileset = tileset
            break

    if sprite_tileset is None:
        raise ValueError(f"{path}: could not find tileset {tileset_name!r}")

    sprite_firstgid = int(sprite_tileset.attrib["firstgid"])
    tilewidth = int(sprite_tileset.attrib.get("tilewidth", root.attrib.get("tilewidth", 16)))
    tileheight = int(sprite_tileset.attrib.get("tileheight", root.attrib.get("tileheight", 16)))

    selected_layer = None
    for layer in root.findall("layer"):
        if layer.attrib.get("name", "") == layer_name:
            selected_layer = layer
            break

    if selected_layer is None:
        label = "(blank unnamed layer)" if layer_name == "" else layer_name
        raise ValueError(f"{path}: could not find layer {label}")

    data = selected_layer.find("data")
    if data is None or data.attrib.get("encoding") != "csv":
        raise ValueError(f"{path}: selected layer must use CSV-encoded data")

    lines = data.text.strip().splitlines()
    rows = []
    for row in csv.reader(lines):
        values = [cell.strip() for cell in row if cell.strip() != ""]
        rows.append([int(value, 0) for value in values])

    width = int(selected_layer.attrib["width"])
    height = int(selected_layer.attrib["height"])
    if len(rows) != height:
        raise ValueError(f"{path}: layer has {len(rows)} CSV rows, expected {height}")

    for row_number, row in enumerate(rows, start=1):
        if len(row) != width:
            raise ValueError(
                f"{path}:{row_number}: row has {len(row)} values, expected {width}"
            )

    placements = []
    for y, row in enumerate(rows):
        for x, gid in enumerate(row):
            if gid == 0:
                continue
            if gid < sprite_firstgid:
                raise ValueError(
                    f"{path}: layer {layer_name!r} contains non-sprite tile gid {gid}"
                )

            placements.append(
                {
                    "x": x * tilewidth,
                    "y": y * tileheight,
                    "tile": gid - sprite_firstgid,
                    "gid": gid,
                }
            )

    return placements, width, height, tilewidth, tileheight


def write_outputs(placements, name, out_dir):
    stem = c_identifier(name)
    file_stem = f"{stem}_sprites"
    guard = f"{file_stem.upper()}_H"
    array_name = f"{file_stem}_placements"
    macro = f"{file_stem.upper()}_COUNT"

    out_dir.mkdir(parents=True, exist_ok=True)
    header_path = out_dir / f"{file_stem}.h"
    source_path = out_dir / f"{file_stem}.c"
    binary_path = out_dir / f"{file_stem}.bin"
    array_decl = "[]" if placements else "[1]"
    array_init = "[]" if placements else "[1]"

    with header_path.open("w", newline="\n") as header:
        header.write(f"#ifndef {guard}\n")
        header.write(f"#define {guard}\n\n")
        header.write("#include <stdint.h>\n\n")
        header.write("typedef struct {\n")
        header.write("    uint16_t x;\n")
        header.write("    uint16_t y;\n")
        header.write("    uint8_t tile;\n")
        header.write(f"}} {file_stem}_placement_t;\n\n")
        header.write(f"#define {macro} {len(placements)}\n")
        header.write(f"extern const {file_stem}_placement_t {array_name}{array_decl};\n\n")
        header.write(f"#endif /* {guard} */\n")

    with source_path.open("w", newline="\n") as source:
        source.write(f'#include "{file_stem}.h"\n\n')
        source.write(f"const {file_stem}_placement_t {array_name}{array_init} = {{\n")
        if placements:
            for placement in placements:
                source.write(
                    f"    {{ {placement['x']}, {placement['y']}, {placement['tile']} }},"
                    f" /* gid {placement['gid']} */\n"
                )
        else:
            source.write("    { 0, 0, 0 },\n")
        source.write("};\n")

    binary = bytearray()
    binary.extend(struct.pack("<H", len(placements)))
    for placement in placements:
        binary.extend(struct.pack("<HHB", placement["x"], placement["y"], placement["tile"]))
    binary_path.write_bytes(binary)

    return header_path, source_path, binary_path


def main():
    parser = argparse.ArgumentParser(
        description="Convert the Tiled SP layer into sparse sprite placement data."
    )
    parser.add_argument("input", type=Path, help="Input TMX map")
    parser.add_argument(
        "-o",
        "--out-dir",
        type=Path,
        default=Path("include"),
        help="Output directory for .c/.h/.bin files",
    )
    parser.add_argument(
        "-n",
        "--name",
        help="Output file stem and macro prefix; defaults to the TMX filename",
    )
    parser.add_argument(
        "--layer",
        default="SP",
        help="TMX layer name to extract; defaults to SP",
    )
    parser.add_argument(
        "--tileset",
        default="sprites",
        help="Tileset name used by the sprite layer",
    )

    args = parser.parse_args()

    placements, width, height, tilewidth, tileheight = parse_tmx_sprite_layer(
        args.input, args.layer, args.tileset
    )
    name = args.name if args.name else args.input.stem
    header_path, source_path, binary_path = write_outputs(placements, name, args.out_dir)

    print(f"Generated {len(placements)} sprite placements from {width}x{height} cells:")
    print(f"- {header_path}")
    print(f"- {source_path}")
    print(f"- {binary_path}")
    print(f"- tile size {tilewidth}x{tileheight}")


if __name__ == "__main__":
    main()
