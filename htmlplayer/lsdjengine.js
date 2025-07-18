function runphasecommand(phasecommands = ['', '', '', '']) {
    phasecommands.forEach((command, index) => {
        switch (command[0]) {

            case 'H':
                if (command[1] == '0') {
                    stepchain(index)
                    currnote[index] = parseInt(command[2],16)
                }
                if (command == 'HFF') {
                    removeAll()
                    updatedisplay([-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1])
                }
                break
            default:
                break

            case 'T':
                highspeed = 0;
                tempoV = parseInt(command.substring(1,3),16)
                if (tempoV <= 0x27) {
                    tempo = tempoV + 256
                } else {
                    tempo = tempoV
                }

                updatespeedinfo()

                update('tick',hz)
        }
    });
}

// Format [[],[],[],[]]
function runrow(rows = [[], [], [], []], transposes = [[], [], [], []]) {
    const phasecommands = rows.map(row => row[2] || ''); // get cmd from each row
    runphasecommand(phasecommands);
}

function songtick() {
    if (stepdiv >= speeds[grstep]) {
        stepdiv = 0
        step()
    }
    stepdiv++
}


function engineupdate() {

}