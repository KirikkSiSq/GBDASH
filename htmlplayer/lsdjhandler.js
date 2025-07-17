//Song Speed
let tempo
let speeds
let groove
let hz

//Pattern Counters
let chainp1, chainp2, chainwa, chainno
let phasep1, phasep2, phasewa, phaseno
let currnote


// Nested array with [table,step1,step2,envstep]
let currtables = [
    [-1, 0, 0, 0],
    [-1, 0, 0, 0],
    [-1, 0, 0, 0],
    [-1, 0, 0, 0]
]

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

    const type = instrumentData ? instrumentData.Type : null;

    // KIT instrument type
    if (type === 'KIT') {
        const kit1Index = (note >> 4) - 1;
        const kit2Index = (note & 0b1111) - 1;

        const kit1 = kits[parseInt(instrumentData.Kit[0],16)];
        const kit2 = kits[parseInt(instrumentData.Kit[1],16)];

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
    note--
    if (note == -1) return '---'
    if (note >= allNoiseNotes.length || note < 0) {
        return '???'
    }
    return allNoiseNotes[note]
}

function updatespeedinfo() {
    if (module.HighspeedMode) {
        hz = module.HighspeedMode == 3 ? 360 : (module.HighspeedMode + 1) * 60
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${module.HighspeedMode == 3 ? 360 : (module.HighspeedMode + 1) * 60}hz/${module.HighspeedMode == 3 ? 6 : module.HighspeedMode + 1}x, Groove ${groove}`
    } else {
        hz = 2 * tempo / 5
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
        if (i + scroll > module.Song.length) {
            for (let j = 0; j < 4; j++) {
                ele = songele.children[j].children[1].children[i]
                ele.outerHTML = `<code><span>--</span></code>`
            }
        };
        let schain = module.Song[i + scroll]
        if (!schain) schain = ['--', '--', '--', '--']
        for (let j = 0; j < 4; j++) {
            ele = songele.children[j].children[1].children[i]
            cchain = schain[j]
            ele.outerHTML = `<code ${i + scroll == highlight[j] ? 'style="outline: var(--highlight) solid 2px;"' : ''}><span>${cchain}</span></code>`
        }
    }
}

function displayphase(phases, highlight, transposes) {
    for (let channel = 0; channel < phases.length; channel++) {
        const phaseId = phases[channel];
        const phaseData = getphase(phaseId);
        const haskit = phasecontainskit(phaseId); // Moved here, corrected logic

        for (let i = 0; i < 16; i++) {
            const ele = phaseele.children[channel].children[1].children[i];
            let note = '---';
            let ins = '--';
            let cmd = '---';
            let transposed = false
            if (phaseData && phaseData.rows[i]) {
                const row = phaseData.rows[i];

                let noteVal = row[0] === '' ? 0 : parseInt(row[0], 16);
                const insVal = row[1] === '' ? 0xff : parseInt(row[1], 16);


                //Global Transpose
                let glotranspose = module.Transpose

                switch (channel) {
                    case 0:
                    case 1:

                        if (insVal != 255 && noteVal + transposes[channel] + glotranspose < 1 && noteVal != 0 && transposes[channel] != 0 && module.Instruments[insVal].Transpose == "Yes") noteVal += 12
                        if (insVal != 255 && noteVal + transposes[channel] + glotranspose > 109 && transposes[channel] != 0 && module.Instruments[insVal].Transpose == "Yes") noteVal -= 12
                        if (noteVal) noteVal += transposes[channel] + glotranspose
                        transposed = transposes[channel] != 0 && noteVal != 0
                        note = getpulsenote(noteVal);
                        break;
                    case 2:
                        if (insVal != 255 && module.Instruments[insVal].Type != 'KIT' && insVal != 0x40 && module.Instruments[insVal].Transpose == "Yes") {
                            if (noteVal + transposes[channel] + glotranspose < 1 && noteVal != 0 && transposes[channel] != 0) noteVal += 12
                            if (noteVal + transposes[channel] + glotranspose > 109 && transposes[channel] != 0) noteVal -= 12
                            if (noteVal) noteVal += transposes[channel] + glotranspose
                            transposed = transposes[channel] != 0
                        }
                        note = getwavenote(noteVal, insVal);
                        break;
                    case 3:
                        if (noteVal) noteVal += transposes[channel]
                        noteVal %= 255
                        transposed = transposes[channel] != 0 && noteVal != 0
                        note = getnoisenote(noteVal);
                        break;
                }

                ins = row[1] || '--';
                cmd = row[2] || '---';
            }

            let styles = [];
            if (i === highlight) styles.push('outline: var(--highlight) solid 2px;');


            if (haskit) {
                ele.outerHTML = `<code style="${styles.join(' ')}"><span>${typeof (note) == 'object' ? note[0] : '   '}</span><span ${transposed ? 'style="color: var(--emthtext)"' : ''}>${typeof (note) == 'object' ? note[1] : note}</span><span>${ins}</span><span>${cmd}</span></code>`;
            } else {
                ele.outerHTML = `<code style="${styles.join(' ')}"><span ${transposed ? 'style="color: var(--emthtext)"' : ''}>${note}</span><span>${ins}</span><span>${cmd}</span></code>`;
            }
        }
    }
}

function step() {
    
}

function songtick() {
    
}

function engineupdate() {

}

function updatedisplay(songhighlights, chainhighlights, notehighlight) {
    const scroll = Math.max(0, Math.min(...songhighlights) - 7);
    displaysong(songhighlights, scroll);

    chains = [
        module.Song[songhighlights[0]][0],
        module.Song[songhighlights[1]][1],
        module.Song[songhighlights[2]][2],
        module.Song[songhighlights[3]][3]
    ].map(h => h == '==' ? -1 : parseInt(h, 16))

    displaychain(chains, chainhighlights)

    phases = []

    transposes = []

    for (let c = 0; c < 4; c++) {
        currp = getchain(chains[c]).rows[chainhighlights[c]]
        phases.push(parseInt(currp[0],16))
        transposes.push(toSigned8Bit(parseInt(currp[1],16)))
    }

    displayphase(phases, notehighlight, transposes)
}

function toSigned8Bit(hex) {
        const value = hex & 0xFF; // Mask to 8 bits
        return value > 0x7F ? value - 0x100 : value;
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

    updatedisplay([0, 0, 0, 0], [0, 0, 0, 0], 0)
    updatespeedinfo();

    //Bind Tickers
    add("tick",hz,songtick)
    add("eupdate",360,engineupdate)
}
