//Song Speed
let tempo
let speeds
let groove

//Pattern Counters
let chainp1, chainp2, chainwa, chainno
let phasep1, phasep2, phasewa, phaseno
let currnote

//elements
const container = document.getElementById("LSDPlayer")
const chainele = container.children[0]
const phaseele = container.children[1]
const songele = container.children[2]

//Notes
const notes = [
    'C ', 'C#', 'D ', 'D#', 'E ', 'F ', 'F#', 'G ', 'G#', 'A ', 'A#', 'B '
]

const noisenotes = []

for (let i = 0x00; i <= 0x3B; i++) {
    noisenotes.push(i.toString(16).toUpperCase().padStart(2, '0') + ' ');
}

const noiseShortModeNotes = [
    // -9
    'D-9', 'F-9', 'G-9',
    // -8 to -1
    'C-8', 'D-8', 'F-8', 'G-8',
    'C-7', 'D-7', 'F-7', 'G-7',
    'C-6', 'D-6', 'F-6', 'G-6',
    'C-5', 'D-5', 'F-5', 'G-5',
    'C-4', 'D-4', 'F-4', 'G-4',
    'C-3', 'D-3', 'F-3', 'G-3',
    'C-2', 'D-2', 'F-2', 'G-2',
    'C-1', 'D-1', 'F-1', 'G-1',
    // 0 to 4
    'C 0', 'D 0', 'F 0', 'G#0',
    'C 1', 'D 1', 'F 1', 'G#1',
    'C 2', 'D 2', 'F 2', 'G#2',
    'C 3', 'D 3', 'F 3', 'G#3',
    'C 4', 'D 4', 'F 4', 'G#4',
    // 5
    'C 5', 'F 5',
    // 6 to 8
    'C 6', 'C 7', 'C 8'
];

let words = [
    'W-0',
    'W-1',
    'W-3',
    'W-4',
    'W-5',
    'W-6',
    'W-7',
    'W-8',
    'W-9',
    'W-A',
    'W-B',
    'W-C',
    'W-D',
]

const allNoiseNotes = noisenotes.concat(noiseShortModeNotes);

function getpulsenote(note) {
    note--
    if (note == -1 || typeof (note) == 'undefined') { return '---' }
    return `${notes[note % 12]}${(Math.floor(note / 12) + 2).toString(16).toUpperCase()}`
}

function resetWordTable() {
    words = [
        'W-0',
        'W-1',
        'W-3',
        'W-4',
        'W-5',
        'W-6',
        'W-7',
        'W-8',
        'W-9',
        'W-A',
        'W-B',
        'W-C',
        'W-D',
    ];
}

function getwavenote(note, instrument) {
    const instrumentData = module.Instruments[instrument];


    // Wave channel using word table
    if (instrument == 0x40) {
        note--;
        if (note < 0) return '---';
        if (note >= words.length) return '---';
        return words[note];
    }

    const type = instrumentData.Type;

    // KIT instrument type
    if (type === 'KIT') {
        const kit1Index = (note >> 4) - 1;
        const kit2Index = (note & 0b1111) - 1;

        const kit1 = kits[instrumentData.Kit[0]];
        const kit2 = kits[instrumentData.Kit[1]];

        const sample1 = (kit1Index < 0) ? '---' : (kit1Index >= kit1.sample_names.length ? 'OFF' : kit1.sample_names[kit1Index]);
        const sample2 = (kit2Index < 0) ? '---' : (kit2Index >= kit2.sample_names.length ? 'OFF' : kit2.sample_names[kit2Index]);

        return [sample1, sample2];
    }

    // Default wave note
    note--;
    if (note < 0) return '---';
    return `${notes[note % 12]}${(Math.floor(note / 12) + 1).toString(16).toUpperCase()}`;
}


function getnoisenote(note) {
    if (note >= allNoiseNotes.length || note < 0) {
        return '???'
    }
    return allNoiseNotes[note]
}

function updatespeedinfo() {
    if (module.HighspeedMode) {
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${module.HighspeedMode == 3 ? 360 : (module.HighspeedMode + 1) * 60}hz/${module.HighspeedMode == 3 ? 6 : module.HighspeedMode + 1}x, Groove ${groove}`
    } else {
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${2 * tempo / 5}hz/${tempo}bpm, Groove ${groove}`
    }
}

function getchain(chainId) {
    return module.Chains.find(c => c.chain === chainId) || null;
}

function getphase(phaseId) {
    return module.Phrases.find(p => p.phrase === phaseId) || null;
}

function phasecontainskit(phase) {
    const phraseData = getphase(phase);
    if (!phraseData) return false;

    for (const row of phraseData.rows) {
        const instrumentHex = row[1];
        if (!instrumentHex) continue;

        const instrument = parseInt(instrumentHex, 16);
        const instrumentData = module.Instruments[instrument];
        if (!instrumentData) continue;

        if (instrumentData.Type && instrumentData.Type.includes('KIT')) {
            return true;
        }
    }

    return false;
}

function displaychain(chains, highlights) {
    for (let channel = 0; channel < chains.length; channel++) {
        const chainId = chains[channel];
        const highlight = highlights[channel];
        const chainData = getchain(chainId);

        for (let i = 0; i < 16; i++) {
            const ele = chainele.children[channel].children[1].children[i];
            let ph = '--';
            let tsp = '00';

            if (chainData && chainData.rows[i]) {
                const row = chainData.rows[i];
                ph = row[0] || '--';
                tsp = row[1] || '00';
            }

            ele.outerHTML = `<code ${i === highlight ? 'style="outline: var(--highlight) solid 2px;"' : ''}><span>${ph}</span><span>${tsp}</span></code>`;
        }
    }
}


function displaysong(highlight, scroll) {
    for (let i = 0; i < 16; i++) {
        if (i+scroll > module.Song.length) {
            for (let j = 0; j < 4; j++) {
                ele = songele.children[j].children[1].children[i]
                ele.outerHTML = `<code><span>--</span></code>`
            }
        };
        let schain = module.Song[i+scroll]
        if (!schain) schain = ['--','--','--','--']
        for (let j = 0; j < 4; j++) {
            ele = songele.children[j].children[1].children[i]
            cchain = schain[j]
            ele.outerHTML = `<code ${i+scroll == highlight[j] ? 'style="outline: var(--highlight) solid 2px;"' : ''}><span>${cchain}</span></code>`
        }
    }
}

function displayphase(phases, highlight) {
    for (let channel = 0; channel < phases.length; channel++) {
        const phaseId = phases[channel];
        const phaseData = getphase(phaseId);
        const haskit = phasecontainskit(phaseId); // Moved here, corrected logic

        for (let i = 0; i < 16; i++) {
            const ele = phaseele.children[channel].children[1].children[i];
            let note = '---';
            let ins = '--';
            let cmd = '---';

            if (phaseData && phaseData.rows[i]) {
                const row = phaseData.rows[i];

                const noteVal = row[0] === '' ? 0 : parseInt(row[0], 16);
                const insVal = row[1] === '' ? 0 : parseInt(row[1], 16);

                switch (channel) {
                    case 0:
                    case 1:
                        note = getpulsenote(noteVal);
                        break;
                    case 2:
                        note = getwavenote(noteVal, insVal);
                        break;
                    case 3:
                        note = getnoisenote(noteVal);
                        break;
                }

                ins = row[1] || '--';
                cmd = row[2] || '---';
            }

            const highlightStyle = i === highlight ? 'style="outline: var(--highlight) solid 2px;"' : '';

            if (haskit) {
                ele.outerHTML = `<code ${i === highlight ? 'style="outline: var(--highlight) solid 2px;"' : ''}><span>${typeof(note) == 'object' ? note[0] : '   '}</span><span>${typeof(note) == 'object' ? note[1] : note}</span><span>${ins}</span><span>${cmd}</span></code>`;
            } else {
                ele.outerHTML = `<code ${i === highlight ? 'style="outline: var(--highlight) solid 2px;"' : ''}><span>${note}</span><span>${ins}</span><span>${cmd}</span></code>`;
            }
        }
    }
}

function setupLSDJ() {
    if (module.Grooves[0]) {
        speeds = module.Grooves[0].map(num => parseInt(num, 16));
    } else {
        speeds = [6];
    }

    tempo = module.Tempo;
    groove = 0;

    // Reset words to defaults
    resetWordTable();

    // Overwrite part of words with entries from module.Speech
    if (Array.isArray(module.Speech)) {
        for (let i = 0; i < module.Speech.length && i < words.length; i++) {
            words[i] = module.Speech[i].word;
        }
    }

    // Parse chains from first song row
    const songRow = module.Song[0] || ['--', '--', '--', '--'];
    const chains = songRow.map(c => (c === '--' ? null : parseInt(c, 16)));

    // Default highlights to 0 or null
    const highlights = chains.map(c => c !== null ? 0 : null);

    displaysong([0, 0, 0, 0], 0);
    displaychain(chains, highlights);

    updatespeedinfo();
}
