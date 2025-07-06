import json

def parsefurtext(txt_file, json_file):
    with open(txt_file, 'r') as input, open(json_file, 'w') as output:
        e = ""

        print("Opening file... let's see what you've brought me.")
        if not input.readline().startswith("# Furnace Text Export"):
            raise ValueError("Hmm... This doesn’t look like a Furnace text export. Sure it’s the right file?")

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
                v = p[1].replace(" ","")

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

# Run the function
parsefurtext("music/txt/fur_freedom.txt", "fur.json")
