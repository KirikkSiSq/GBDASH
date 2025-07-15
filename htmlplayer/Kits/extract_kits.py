import os
import sys

def extract_kit_banks(filename):
    BANK_SIZE = 0x4000
    START_OFFSET = 0x20000
    HEADER_BYTES = bytes([0x60, 0x40])
    MAX_VALID_BANKS = 51
    SKIP_BANKS = set(range(19, 24))  # Banks to skip entirely

    try:
        with open(filename, "rb") as f:
            f.seek(0, os.SEEK_END)
            filesize = f.tell()

            processed_count = 0  # Non-skipped banks processed
            bank_index = 0       # Current overall bank index

            while processed_count < MAX_VALID_BANKS:
                if bank_index in SKIP_BANKS:
                    print(f"Bank {bank_index}: skipped (manually excluded).")
                    bank_index += 1
                    continue

                offset = START_OFFSET + bank_index * BANK_SIZE
                if offset + 2 > filesize:
                    print(f"Bank {bank_index}: file too short to read header, skipping.")
                    bank_index += 1
                    processed_count += 1
                    continue

                f.seek(offset)
                header = f.read(2)

                if header == HEADER_BYTES:
                    f.seek(offset)
                    data = f.read(BANK_SIZE)
                    filename_out = f"{processed_count:02X}.kit"
                    with open(filename_out, "wb") as out_file:
                        out_file.write(data)
                    print(f"Wrote {filename_out} from bank {bank_index}")
                else:
                    print(f"Bank {bank_index}: header != 0x6040, no file written.")

                bank_index += 1
                processed_count += 1

    except FileNotFoundError:
        print(f"File '{filename}' not found.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_kits.py input_file.gb")
    else:
        extract_kit_banks(sys.argv[1])
