import json

def parsefurtext(txt_file, json_file):
    with open(txt_file, 'r') as input, open(json_file, 'w') as output:
        e = ""

        print("Opening file... let's see what you've brought me.")
        if not input.readline().startswith("# Furnace Text Export"):
            raise ValueError("Hmm... This doesn't look like a Furnace text export. Sure it's the right file?")

        # Extract Name
        while not e.startswith("- name: "):
            e = input.readline()
        name = e[len("- name: "):].strip()

        print(f"🎵 Found song name: '{name}'")

        # Validate The File: Look for Sound Chips section
        print("Scanning for sound chips. Please stand by...")
        while not e.startswith("# Sound Chips"):
            e = input.readline()

        seengb = False
        others = False
        while True:
            e = input.readline()

            if e.startswith("# Instruments"):
                break

            if e.startswith("- "):
                chip_name = e[2:].strip()
                if chip_name.startswith("Game Boy"):
                    if not seengb:
                        seengb = True
                    else:
                        others = True  # Multiple Game Boy chips?
                else:
                    others = True

        if not seengb:
            raise ValueError("No Game Boy chip found — and this whole parser kind of depends on that.")
        if others:
            raise ValueError("Only one Game Boy chip allowed. This isn't a chip buffet.")

        print("✅ Sound chip check passed. One Game Boy, no surprises.")

        instruments = []

        print("📦 Starting instrument extraction... fingers crossed.")
        currentintr = 0
        key = ""
        hws = []
        while True:
            e = input.readline()
            if e.startswith("## "):
                print(f"🎛️  Instrument {e[3:].strip()} detected")

                currentintr = int(e[3:].split()[0].rstrip(":"), 16)
                instruments.append({})
                hws = []

            if e.startswith("- type: "):
                if not e[len("- type: "):].startswith("2"):
                    raise ValueError(f"Instrument {currentintr} isn't a Game Boy one. What's it doing here?")

            if e.startswith("- Game Boy parameters:"):
                key = "gb"
                instruments[currentintr][key] = {}

            if e.startswith("- Wavetable Synth parameters"):
                key = "wavesynth"
                instruments[currentintr][key] = {}

            if e.startswith("- macros:"):
                if hws:
                    instruments[currentintr][key]["hardware sequence"] = hws
                key = "macros"
                instruments[currentintr][key] = {}

            if e.startswith("  - ") and not e.startswith("  - hardware sequence:"):
                temp1 = e[4:]
                k = temp1[0:temp1.find(": ")].strip()
                v = temp1[temp1.find(": ")+2:].strip()
                if (v == "yes"):
                    v = True
                elif (v == "no"):
                    v = False
                elif (v.isnumeric()):
                    v = int(v)
                instruments[currentintr][key][k] = v

            if e.startswith("    - "):
                temp1 = e[len("    - "):].strip()
                hws.append(temp1.split(" "))

            if e.startswith("# Wavetables"):
                break

        print("🧪 Wavetables incoming...")
        wavetables = []
        while True:
            e = input.readline()

            if e.startswith("- "):
                w = e[len("- 0 (32x16): "):].strip()
                wavetables.append(w.split(" "))

            if e.startswith("# Samples"):
                break

        print("🔇 Skipping samples. As usual.")
        while True:
            e = input.readline()
            if e.startswith("## 0: "):
                break

        print("🛠️  Gathering song properties...")
        songproperties = {}
        orders = []
        while True:
            e = input.readline()

            if e.startswith("- "):
                t = e[2:].strip()
                p = t.split(":")
                k = p[0].replace(" ","")
                v = p[1].strip()

                if k == "speeds":
                    songproperties[k] = v.split(" ")
                elif k == "virtualtempo":
                    songproperties[k] = v.split("/")
                else:
                    songproperties[k] = v

            if e.startswith("orders:"):
                break

        print("🧾 Reading order list...")
        input.readline()
        while True:
            e = input.readline()
            if e.startswith("```") or e == "":
                break

            if "|" not in e:
                continue

            try:
                line = e.strip()
                _, data = line.split("|", 1)
                hex_values = data.strip().split()
                int_values = [int(x, 16) for x in hex_values]
                orders.append(int_values)
            except Exception as err:
                print(f"⚠️  Couldn't make sense of this order line: {e.strip()} — {err}")

        while True:
            e = input.readline()
            if e == "":
                raise ValueError("Missing the '## Patterns' section. This is where things usually get interesting.")
            if e.strip() == "## Patterns":
                break

        print("🎼 Reading pattern data...")
        currentorder = -1
        patterns = {1: [], 2: [], 3: [], 4: []}
        seen_patterns = {1: {}, 2: {}, 3: {}, 4: {}}

        while True:
            e = input.readline()

            if e.startswith("----- ORDER "):
                if currentorder != -1:
                    for ch in range(1, 5):
                        pat_num = orders[currentorder][ch - 1]
                        pattern_data = rows[ch]
                        hash_key = json.dumps(pattern_data, sort_keys=True)

                        if pat_num not in seen_patterns[ch]:
                            seen_patterns[ch][pat_num] = hash_key
                            patterns[ch].append({"Pattern": pat_num, "Rows": pattern_data})
                        elif seen_patterns[ch][pat_num] != hash_key:
                            patterns[ch].append({"Pattern": pat_num, "Rows": pattern_data})

                rows = {1: [], 2: [], 3: [], 4: []}
                currentorder = int(e[len("----- ORDER "):], 16)
                print(f"🔢 Parsing ORDER {hex(currentorder)}")

            elif "|" in e and currentorder != -1:
                p = e.split("|")
                for i in range(4):
                    r = p[i + 1].strip().split(" ")
                    d = {}
                    if r[0] != "...":
                        d["Note"] = r[0]
                    if r[1] != "..":
                        d["Intrument"] = r[1]
                    if r[2] != "..":
                        d["Volume"] = r[2]
                    if not all(x == "...." for x in r[3:]):
                        d["Effects"] = [x for x in r[3:] if x != "...."]
                    rows[i + 1].append(d)

            elif e == "":
                if currentorder != -1:
                    for ch in range(1, 5):
                        pat_num = orders[currentorder][ch - 1]
                        pattern_data = rows[ch]
                        hash_key = json.dumps(pattern_data, sort_keys=True)

                        if pat_num not in seen_patterns[ch]:
                            seen_patterns[ch][pat_num] = hash_key
                            patterns[ch].append({"Pattern": pat_num, "Rows": pattern_data})
                        elif seen_patterns[ch][pat_num] != hash_key:
                            patterns[ch].append({"Pattern": pat_num, "Rows": pattern_data})
                break

        dd = {
            "PlayerType": 0,
            "Name": name,
            "Properties": songproperties,
            "Instruments": instruments,
            "Wavetables": wavetables,
            "Orders": orders,
            "Patterns": patterns
        }

        print("🧾 Writing everything to JSON...")
        output.write(json.dumps(dd))
        output.close()
        print("✅ Done! JSON file created successfully.")



import json

def parselsdjtext(txt_file, json_file):
    import json

    with open(txt_file, 'r', encoding='cp1252') as input, open(json_file, 'w') as output:
        if not input.readline().startswith("Active project index:"):
            raise ValueError("This ain't an LSDJ file — nice try though.")

        # Read metadata
        name = input.readline()[len("Project name: "):].strip()
        version = int(input.readline()[len("Version: "):].strip())
        tempo = int(input.readline()[len("Tempo: "):].strip())
        fasttempo = int(input.readline()[len("Highspeed Mode: "):].strip())
        input.readline()  # skip empty or unused
        transpose = int(input.readline()[len("Transpose: "):].strip())

        print(f"📁 Project: {name}, v{version}, Tempo: {tempo}, Transpose: {transpose}")

        # Scan until Instruments section
        while True:
            e = input.readline()
            if not e:
                break
            if e.startswith("Instruments:"):
                print("🎛 Parsing Instruments...")
                break

        # 🎛 Instruments
        instruments = []
        currentintr = None
        while True:
            e = input.readline()
            if not e:
                break

            if e.startswith("  Instrument"):
                num = int(e.split("#")[1].split()[0], 16)
                currentintr = num
                while len(instruments) <= num:
                    instruments.append({})
                print(f"  └─ Found Instrument #{num:02X}")
                continue

            if currentintr is not None and e.startswith("    "):
                s = e.split(": ", 1)
                if len(s) < 2:
                    continue
                key = s[0].strip()
                value = s[1].strip().replace(",", " ").replace("/", " ").split()
                value = value[0] if len(value) == 1 else value
                instruments[currentintr][key] = value
                continue

            if e.startswith("Synths:") or e.startswith("Waves:") or e.startswith("Phrases:"):
                break

        # Skip Synths section if present
        if e.startswith("Synths:"):
            print("🧪 Skipping Synths...")
            while True:
                e = input.readline()
                if not e:
                    break
                if e.startswith("Waves:") or e.startswith("Phrases:"):
                    break

        # 📈 Wave section
        wave = []
        expected_index = 0
        if e.startswith("Waves:"):
            print("🌊 Parsing Waves...")
            while True:
                e = input.readline()
                if not e:
                    break

                e = e.strip()
                if e.startswith("Phrases:"):
                    break

                if e.startswith("Wave "):
                    index = int(e.split()[1].rstrip(":"), 16)
                    while expected_index < index:
                        wave.append([])
                        expected_index += 1
                    data_line = input.readline()
                    if not data_line:
                        continue
                    hex_values = [int(c, 16) for c in data_line.strip()]
                    wave.append(hex_values)
                    expected_index += 1
            print(f"  └─ {len(wave)} waves parsed.")

        # 🎵 Phrases
        print("🎵 Parsing Phrases...")
        phrases = []
        while True:
            e = input.readline()
            if not e:
                break

            if e.startswith("  Phrase "):
                curr = int(e[len("  Phrase "):].strip(":\n"), 16)
                phrases.append({"phrase": curr, "rows": []})
                continue

            if e.startswith("    ") and phrases:
                phrases[-1]["rows"].append(e.strip().replace("-", "").split("|"))
                continue

            if e.startswith("Chains:"):
                break
        print(f"  └─ {len(phrases)} phrases loaded.")

        # 🔗 Chains
        print("🔗 Parsing Chains...")
        chains = []
        while True:
            e = input.readline()
            if not e:
                break

            if e.startswith("  Chain "):
                curr = int(e[len("  Chain "):].strip(":\n"), 16)
                chains.append({"chain": curr, "rows": []})
                continue

            if e.startswith("    ") and chains and e[4:].strip():
                chains[-1]["rows"].append(e.strip().split("|"))
                continue

            if e.startswith("Song:"):
                break
        print(f"  └─ {len(chains)} chains captured.")

        # 🎼 Song
        print("🎼 Parsing Song structure...")
        song = []
        while True:
            e = input.readline()
            if not e:
                break
            if e.startswith("  "):
                song.append(e.strip().split("|"))
                continue
            if e.startswith("Grooves:") or e.startswith("Tables:") or e.startswith("Speech:"):
                break
        print(f"  └─ {len(song)} song rows assembled.")

        # 🦶 Grooves
        grooves = []
        if e.startswith("Grooves:"):
            print("🦶 Parsing Grooves...")
            while True:
                e = input.readline()
                if not e:
                    break
                if e.startswith("  Groove "):
                    index = int(e.strip().split()[1].rstrip(":"), 16)
                    while len(grooves) <= index:
                        grooves.append([])
                    grooves[index] = []
                    continue
                if e.startswith("    ") and grooves:
                    if e.strip():
                        grooves[index].append(e.strip())
                        continue
                if e.startswith("Tables:") or e.startswith("Speech:"):
                    break
            print(f"  └─ {len(grooves)} groove patterns saved.")

        # 📊 Tables
        tables = []
        if e.startswith("Tables:"):
            print("📊 Parsing Tables...")
            while True:
                e = input.readline()
                if not e:
                    break
                if e.startswith("  Table "):
                    index = int(e.strip().split()[1].rstrip(":"), 16)
                    while len(tables) <= index:
                        tables.append([])
                    tables[index] = []
                    continue
                if e.startswith("    ") and tables:
                    tables[index].append(e.strip().split("|"))
                    continue
                if e.startswith("Speech:"):
                    break
            print(f"  └─ {len(tables)} tables captured.")

        # 🗣 Speech
        speech = []
        if e.startswith("Speech:"):
            print("🗣 Capturing Speech data...")
            while True:
                e = input.readline()
                if not e:
                    break
                if e.startswith("  Word "):
                    speech.append({"word": e[7:10], "phonemes": []})
                    continue
                if e.startswith("    ") and speech:
                    speech[-1]["phonemes"].append(e[4:].strip().split("|"))
            print(f"  └─ {len(speech)} words recorded.")

        # Output
        result = {
            "PlayerType": 1,
            "HighspeedMode": fasttempo,
            "Name": name,
            "Version": version,
            "Tempo": tempo,
            "Transpose": transpose,
            "Instruments": instruments,
            "Waves": wave,
            "Phrases": phrases,
            "Chains": chains,
            "Song": song,
            "Grooves": grooves,
            "Tables": tables,
            "Speech": speech
        }

        print("💾 Exporting JSON...")
        json.dump(result, output)
        print("✅ LSDJ parse complete.")


import os
import platform
import sys

def clear_terminal():
    if platform.system() == "Windows":
        os.system("cls")
    else:
        os.system("clear")

input_dir = "music/txt"
output_dir = "music/json"
import traceback  # Add this at the top of your script

# Wipe output_dir before beginning
if os.path.isdir(output_dir):
    for f in os.listdir(output_dir):
        file_path = os.path.join(output_dir, f)
        if os.path.isfile(file_path):
            os.remove(file_path)
else:
    os.makedirs(output_dir)


if not os.path.isdir(input_dir):
    print(f"Where's '{input_dir}'? That's where we keep the text.")
    sys.exit(1)

# Begin conversion loop
for filename in os.listdir(input_dir):
    filepath = os.path.join(input_dir, filename)
    if not os.path.isfile(filepath):
        continue

    base, ext = os.path.splitext(filename)
    ext = ext.lower().lstrip('.')

    if base.startswith("fur_"):
        prefix = "fur"
    elif base.startswith("lsdj_"):
        prefix = "lsdj"
    else:
        print(f"Not sure what to do with '{filename}'. It's not a Furnace or LSDJ text file — just vibes.")
        continue

    output_filename = f"{base}.json"
    output_path = os.path.join(output_dir, output_filename)

    # Inside the try-except block:
    try:
        clear_terminal()
        if prefix == "fur":
            print(f"🔧 Converting Furnace module: {base}")
            parsefurtext(filepath, output_path)
        else:
            print(f"🔄 Converting LSDj save: {base}")
            parselsdjtext(filepath, output_path)
    except Exception as e:
        print(f"🚨 Something went sideways while handling '{filename}'")
        traceback.print_exc()  # <-- This prints the full stack trace
        sys.exit(1)

clear_terminal()
print("🎉 All done! The converters have left the building.")
