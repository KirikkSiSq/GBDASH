let speedsfur
let vtempo
let tickr

function updatespeedinfoFUR() {
    document.getElementById("FURSpeed").innerText = `Speed ${speedsfur.join(':')} @ ${tickr}hz, ${vtempo[0]}/${vtempo[1]}bpm`
}

function setupFUR() {
    tickr = module.Properties.tickrate
    vtempo = module.Properties.virtualtempo
    speedsfur = module.Properties.speeds

    updatespeedinfoFUR()
}

