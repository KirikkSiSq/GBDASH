import struct
import json
import os

KIT_HEADER_SIZE = 0x60
KIT_SIZE = 0x4000
SAMPLE_COUNT = 15
SAMPLE_DATA_OFFSET = 0x60


def parse_kit_file(file_path):
    with open(file_path, 'rb') as f:
        data = f.read()

    if len(data) != KIT_SIZE:
        raise ValueError(f"Invalid kit file size for {file_path}. Expected 0x4000 bytes.")

    kit = {}

    # End addresses
    end_addresses = [struct.unpack_from('<H', data, 0x0002 + i * 2)[0] for i in range(SAMPLE_COUNT)]
    kit['end_points'] = [addr - 0x4060 for addr in end_addresses]

    # Sample names (3 chars each)
    names = []
    for i in range(SAMPLE_COUNT):
        name_bytes = data[0x0022 + i * 3 : 0x0022 + (i + 1) * 3]
        name = name_bytes.decode('ascii', errors='ignore').rstrip('\x00')
        names.append(name)
    kit['sample_names'] = names

    # Kit name (6 chars)
    kit_name = data[0x0052:0x0058].decode('ascii', errors='ignore').rstrip('\x00')
    kit['kit_name'] = kit_name

    # Loop flags (bits in two bytes)
    loop_flags = []
    loop_byte1 = data[0x005C]
    loop_byte2 = data[0x005D]

    for i in range(SAMPLE_COUNT):
        if i < 8:
            looped = bool(loop_byte1 & (1 << i))
        else:
            looped = bool(loop_byte2 & (1 << (i - 8)))
        loop_flags.append(looped)
    kit['loop_flags'] = loop_flags

    # Sample data
    samples = []
    for i in data[SAMPLE_DATA_OFFSET:]:
        samples.append(i >> 4 & 0b1111)
        samples.append(i & 0b1111)

    kit['samples'] = samples

    # Postprocess kit data
    postprocess_kit_data(kit)

    return kit


def postprocess_kit_data(kit):
    # Strip trailing 15's from samples
    samples = kit['samples']
    while samples and samples[-1] == 15:
        samples.pop()
    kit['samples'] = samples

    sample_names = kit['sample_names']
    while sample_names and sample_names[-1] == '\u0000--':
        sample_names.pop()
    kit['sample_names'] = sample_names

    end_points = kit['end_points']
    while end_points and end_points[-1] == -16480:
        end_points.pop()
    kit['end_points'] = end_points


def parse_all_kits_in_folder(folder_path):
    kits = []
    for filename in sorted(os.listdir(folder_path)):
        if filename.lower().endswith('.kit'):
            path = os.path.join(folder_path, filename)
            try:
                kit_data = parse_kit_file(path)
                kit_data['filename'] = filename  # optional: store filename for reference
                kits.append(kit_data)
            except Exception as e:
                print(f"Error parsing {filename}: {e}")
    return kits


def save_as_js(data, output_path, variable_name='kits'):
    with open(output_path, 'w') as f:
        f.write(f"const {variable_name} = ")
        json.dump(data, f)
        f.write(";\n")


if __name__ == '__main__':
    kits_folder = 'htmlplayer/Kits'  # Folder containing .kit files
    output_file = 'htmlplayer/kits.js'  # Output JS file

    all_kits = parse_all_kits_in_folder(kits_folder)
    save_as_js(all_kits, output_file)
    print(f"Parsed {len(all_kits)} kits saved to {output_file}")
