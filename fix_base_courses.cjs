const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/base_de_datos_final.sql';
let content = fs.readFileSync(file, 'utf8');

const base = {
  '1': 'MATEMATICA BASICA',
  '2': 'PROGRAMACION I',
  '3': 'COMUNICACION',
  '4': 'PROGRAMACION II',
  '5': 'METODOLOGIA',
  '6': 'INTRODUCCION A SISTEMAS',
  '7': 'FISICA',
  '8': 'ECONOMIA'
};

for (let cod in base) {
  let name = base[cod];
  let searchStr = 'Curso  Malla 2019';
  let replaceStr = '';
  content = content.replace(searchStr, replaceStr);
}

fs.writeFileSync(file, content, 'utf8');
console.log('Replaced base courses 1-8!');


