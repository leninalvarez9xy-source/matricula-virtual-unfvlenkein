const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/instalacion_completa.sql';
const content = fs.readFileSync(file, 'utf8');

// seccion id
let maxSeccion = 0;
let reSec = /INSERT INTO seccion.*?\n([\s\S]*?)(?=INSERT|-- ====)/g;
let match;
while ((match = reSec.exec(content)) !== null) {
  let block = match[1];
  let re = /\((\d+),/g;
  let m;
  while ((m = re.exec(block)) !== null) {
    let v = parseInt(m[1], 10);
    if (v > maxSeccion) maxSeccion = v;
  }
}
console.log('Max id_seccion in seccion:', maxSeccion);

// horario_cabecera id_seccion
let maxHc = 0;
let reHc = /INSERT INTO horario_cabecera.*?\n([\s\S]*?)(?=INSERT|-- ====)/g;
while ((match = reHc.exec(content)) !== null) {
  let block = match[1];
  let re = /\((\d+),/g;
  let m;
  while ((m = re.exec(block)) !== null) {
    let v = parseInt(m[1], 10);
    if (v > maxHc) maxHc = v;
  }
}
console.log('Max id_seccion in horario_cabecera:', maxHc);

