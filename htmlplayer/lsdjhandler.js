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
const chain = container.children[0]
const phase = container.children[1]
const song = container.children[2]

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
    if (note == -1 || typeof(note) == 'undefined') { return '---' }
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
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${module.HighspeedMode == 3 ? 360 : (module.HighspeedMode + 1)*60}hz/${module.HighspeedMode == 3 ? 6 : module.HighspeedMode + 1}x, Groove ${groove}`
    } else {
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${2 * tempo / 5}hz/${tempo}bpm, Groove ${groove}`
    }
}

function setupLSDJ() {
    if (module.Grooves[0]) {
        speeds = module.Grooves[0].map(num => parseInt(num, 16));
    } else {
        speeds = [6]
    }
    tempo = module.Tempo
    groove = 0

    updatespeedinfo()
}