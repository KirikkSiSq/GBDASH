

function displaytype(type) {
    const lsdjLogo = document.getElementById("LSDJ");
    const furnaceLogo = document.getElementById("Furnace");

    // Hide both first
    lsdjLogo.style.display = "none";
    furnaceLogo.style.display = "none";

    switch (type) {
        case 0: // Furnace
            furnaceLogo.style.display = "block";
            break;
        case 1: // LSDJ
            lsdjLogo.style.display = "block";
            break;
        default: // Unknown or unsupported
            // No display
            break;
    }
}

let module;

document.getElementById('fileInput').addEventListener('change', function (event) {
    const file = event.target.files[0];
    if (!file) return;
    removeAll();

    document.getElementById('fileNameDisplay').textContent = file.name;

    const reader = new FileReader();
    reader.onload = function (e) {
        try {
            module = JSON.parse(e.target.result);
            // module is now loaded and ready to use
            handleload()
        } catch (err) {
            alert("Invalid JSON")
            console.error('Invalid JSON:', err);
            displaytype(-1)
        }
    };
    reader.readAsText(file);
});

function handleload() {
    const lsdjDisplay = document.getElementById("FmtLSDJ");
    const furnaceDisplay = document.getElementById("FmtFUR");
    displaytype(module["PlayerType"])
    if (!("PlayerType" in module)) {
        alert("Not a valid JSON Module");
    } else {
        try {
            lsdjDisplay.style.display = "none";
            furnaceDisplay.style.display = "none";
            switch (module["PlayerType"]) {
                case 0: // Furnace
                    setupFUR()
                    furnaceDisplay.style.display = "flex";
                    break;
                case 1: // LSDJ
                    setupLSDJ()
                    lsdjDisplay.style.display = "flex";
                    break;
                default: // Unknown or unsupported
                    // No display
                    break;
            }
        } catch (err) {
            alert("Load Failed")
            console.error(err)
        }
    }
}
