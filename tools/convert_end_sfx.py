import os
import sys
import subprocess
from pathlib import Path
import numpy as np

REPO_ROOT = Path(__file__).resolve().parent.parent
INPUT_OGG = REPO_ROOT / "archive" / "raw_assets" / "endStart_02.ogg"
OUT_C = REPO_ROOT / "src" / "sfx" / "level_complete_sfx.c"
OUT_H = REPO_ROOT / "include" / "level_complete_sfx.h"

def convert_sfx(ogg_path=INPUT_OGG, target_blocks=820):
    if not os.path.exists(ogg_path):
        print(f"Error: {ogg_path} not found.")
        sys.exit(1)

    cmd = [
        'ffmpeg', '-y', '-i', str(ogg_path),
        '-ar', '8192', '-ac', '1',
        '-af', 'compand=attacks=0.01:decays=0.1:points=-80/-80|-20/-6|0/0,volume=3dB',
        '-f', 'f32le', 'pipe:1'
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    raw, err = proc.communicate()
    if proc.returncode != 0:
        print(f"FFmpeg error: {err.decode('utf-8', errors='ignore')}")
        sys.exit(1)

    target_samples = target_blocks * 32
    samples = np.frombuffer(raw, dtype=np.float32)
    if len(samples) < target_samples:
        padded = np.zeros(target_samples, dtype=np.float32)
        padded[:len(samples)] = samples
        samples = padded
    else:
        samples = np.copy(samples[:target_samples])

    # Smooth the last 64 samples towards 0.0 to prevent a pop/click
    for i in range(64):
        samples[target_samples - 64 + i] *= (63 - i) / 64.0

    clipped = np.clip(samples, -1.0, 1.0)
    nibbles = np.clip(np.round((clipped + 1.0) * 7.5).astype(int), 0, 15)
    bytes_out = ((nibbles[0::2] << 4) | (nibbles[1::2] & 0x0F)).astype(np.uint8)

    os.makedirs(OUT_C.parent, exist_ok=True)
    os.makedirs(OUT_H.parent, exist_ok=True)

    with open(OUT_C, 'w') as f:
        f.write('#pragma bank 222\n')
        f.write('#include <gb/gb.h>\n')
        f.write('#include "level_complete_sfx.h"\n\n')
        f.write(f'const uint8_t level_complete_sfx_data[{len(bytes_out)}] = {{\n')
        for i in range(0, len(bytes_out), 16):
            chunk = bytes_out[i:i+16]
            f.write('    ' + ', '.join(f'0x{b:02X}' for b in chunk) + ',\n')
        f.write('};\n')

    with open(OUT_H, 'w') as f:
        f.write('#ifndef LEVEL_COMPLETE_SFX_H\n')
        f.write('#define LEVEL_COMPLETE_SFX_H\n\n')
        f.write('#include <gb/gb.h>\n\n')
        f.write('#define BANK_LEVEL_COMPLETE_SFX 222\n')
        f.write(f'#define LEVEL_COMPLETE_SFX_LEN {len(bytes_out)}\n')
        f.write(f'extern const uint8_t level_complete_sfx_data[{len(bytes_out)}];\n\n')
        f.write('#endif\n')

    print(f"Generated {OUT_C} and {OUT_H} successfully ({len(bytes_out)} bytes, {len(bytes_out)/4096:.2f}s audio).")

if __name__ == "__main__":
    convert_sfx()
