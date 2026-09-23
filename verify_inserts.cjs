const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/base_de_datos_final.sql';
let content = fs.readFileSync(file, 'utf8');

// We will check column counts for all INSERTs
const inserts = content.match(/INSERT INTO \w+\s*\([^)]+\)\s*VALUES/gi);
if (inserts) {
  for (let insert of inserts) {
    console.log(insert.replace(/\n/g, ' '));
  }
}
