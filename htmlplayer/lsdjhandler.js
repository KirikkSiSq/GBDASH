let tempo
let speeds
let groove

function updatespeedinfo() {
    document.getElementById("LSDSpeed").innerText = `Speed ${speeds.join(':')} @ ${2 * tempo / 5}hz/${tempo}bpm, Groove ${groove}`
}

function setupLSDJ() {
    if (module.Grooves[0]) {
        speeds = module.Grooves[0].map(num => parseInt(num, 16));
    }
    if (!speeds) {
        speeds = [6]
    }
    tempo = module.Tempo
    groove = 0

    updatespeedinfo()
}