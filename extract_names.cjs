const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/base_de_datos_final.sql';
let content = fs.readFileSync(file, 'utf8');

// 1. Map id_seccion -> cod_curso from SECCION inserts
const seccionMap = {};
// Example: (1, 'A', 35, 35, '1', '2026-1', 'PROF001')
const seccionRegex = /\((\d+),\s*'[^']+',\s*\d+,\s*\d+,\s*'(\d+)',\s*'[^']+',\s*'[^']+'\)/g;
let match;
while ((match = seccionRegex.exec(content)) !== null) {
  let idSeccion = parseInt(match[1], 10);
  let codCurso = parseInt(match[2], 10);
  seccionMap[idSeccion] = codCurso;
}
console.log('Mapped sections:', Object.keys(seccionMap).length);

// 2. Map id_seccion -> course_name by looking at comments
// We will go line by line
const lines = content.split('\n');
let currentComment = null;
const cursoMap = {}; // cod_curso -> nombre

for (let line of lines) {
  line = line.trim();
  // Look for comments that are not SQL headers (like -- ==== or -- 5. SECCIONES or -- I CICLO)
  if (line.startsWith('--') && !line.startsWith('-- =') && !line.match(/-- \d+\./) && !line.match(/-- [IVX]+ CICLO/) && !line.match(/-- 2026-/) && !line.match(/-- HISTORIAL/) && !line.match(/-- LENIN/) && !line.match(/-- .*AUTOCOMPLETADO.*/)) {
    // This is likely a course name comment
    currentComment = line.substring(2).trim();
    // uppercase it to normalize
    currentComment = currentComment.toUpperCase();
  } else if (line.startsWith('(') && currentComment) {
    // Likely a tuple: (109,'A',...) or (133,'LUNES',...) or (109,109,'2026-2')
    // Extract the first number
    let tupleMatch = line.match(/^\((\d+),/);
    if (tupleMatch) {
      let idSec = parseInt(tupleMatch[1], 10);
      let codCurso = seccionMap[idSec];
      if (codCurso && !cursoMap[codCurso]) {
        cursoMap[codCurso] = currentComment;
      }
    }
  } else if (line === '') {
    // Keep current comment if it's just a blank line, maybe not?
    // Let's reset on blank line? No, sometimes there is no blank line.
    // Actually, just let it carry over until a new comment or a non-tuple line
  } else if (!line.startsWith('(') && !line.startsWith('INSERT') && !line.startsWith('ON CONFLICT') && !line.startsWith('VALUES')) {
    currentComment = null;
  }
}

console.log('Mapped courses:', Object.keys(cursoMap).length);
console.log(cursoMap);

// Now update the CURSO inserts
// We look for: ('1', 'Curso 1 Malla 2019', 4, 'C2019-1')
let newContent = content;
for (let cod in cursoMap) {
  let name = cursoMap[cod];
  let searchStr = 'Curso  Malla 2019';
  let replaceStr = '';
  newContent = newContent.replace(searchStr, replaceStr);
}

fs.writeFileSync(file, newContent, 'utf8');
console.log('Replaced names!');


