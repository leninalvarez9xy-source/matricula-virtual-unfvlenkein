const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/instalacion_completa.sql';
const content = fs.readFileSync(file, 'utf8');
const lines = content.split('\n');

let errors = [];

// check for weird characters
lines.forEach((line, i) => {
    if (line.includes('')) {
        errors.push(Line : Encoding issue () -> );
    }
});

// Check for missing semicolons before specific keywords
// like INSERT INTO, COMMIT
let isInsideInsert = false;
let insertBuffer = '';
let insertStartLine = 0;

for (let i=0; i < lines.length; i++) {
    let l = lines[i].trim();
    if (l.startsWith('--') || l === '') continue;
    
    if (l.startsWith('INSERT INTO')) {
        if (isInsideInsert && !insertBuffer.trim().endsWith(';')) {
           // Maybe the previous statement didn't end with ;
           // Check if it's not a CONFLICT block
        }
        isInsideInsert = true;
        insertStartLine = i+1;
    }
    
    if (isInsideInsert) {
        insertBuffer += l + '\n';
        if (l.endsWith(';')) {
            isInsideInsert = false;
            insertBuffer = '';
        }
    }
}

if (isInsideInsert) {
    errors.push(Unfinished INSERT at EOF started at line );
}

console.log(errors.join('\n'));
