//Song Speed
let tempo
let speeds
let groove

//Pattern Counters
let chainp1, chainp2, chainwa, chainno
let phasep1, phasep2, phasewa, phaseno

//elements
const container = document.getElementById("LSDPlayer")
const chain = container.children[0]
const phase = container.children[1]
const song = container.children[2]

//Notes
const notes = [
    'C ', 'C#', 'D ', 'D#', 'E ', 'F ', 'F#', 'G ', 'G#', 'A ', 'A#', 'B '
]

function getpulsenote(note) {
    note = note - 1
    if (note == -1 || typeof (note) == 'undefined') { return '---' }

    if (note > 107)

        return `${notes[note % 12]}${Math.floor(note / 12) + 2}`
}

function getwavenote(note, instrument) {
    type = module.Instruments[instrument].Type
    if (instrument == 0x40) {
        return;
    }
    if (type == 'KIT') {
        return;
    }
}

function updatespeedinfo() {
    if (module.HighspeedMode) {
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${module.HighspeedMode == 3 ? 360 : (module.HighspeedMode + 1)*60}hz/${module.HighspeedMode == 3 ? 6 : module.HighspeedMode + 1}x, Groove ${groove}`
    } else {
        document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${2 * tempo / 5}hz/${tempo}bpm, Groove ${groove}`
    }
}

function displaychains(p1s, p2s, was, nos, scroll) {

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