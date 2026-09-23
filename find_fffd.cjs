const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/instalacion_completa.sql';
const lines = fs.readFileSync(file, 'utf8').split('\n');
lines.forEach((line, idx) => {
    if (line.includes('\uFFFD')) {
        console.log(Line : );
    }
});
