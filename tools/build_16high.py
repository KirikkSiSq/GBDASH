# build_16high.py

import subprocess

INPUT_FILE = 'levels/level_data/stereomadness_bg.bin'
OUTPUT_BIN = 'levels/level_data/stereomadness_16high.bin'
OUTPUT_ZX0 = 'levels/level_data/stereomadness_16high.zx0'

ROW_WIDTH = 894

# Load full map
with open(INPUT_FILE, 'rb') as f:
    data = f.read()

# Crop rows 11–26 (16 rows total)
out = b''.join(
    data[y * ROW_WIDTH:(y + 1) * ROW_WIDTH]
    for y in range(12, 28)
)

# Save cropped binary
with open(OUTPUT_BIN, 'wb') as f:
    f.write(out)

print('Cropped size:', len(out), 'bytes')

# Compress using zx0
subprocess.run([
    'gbdk/lib/win/zx0.exe',
    OUTPUT_BIN,
    OUTPUT_ZX0
], check=True)

print('Compression complete!')