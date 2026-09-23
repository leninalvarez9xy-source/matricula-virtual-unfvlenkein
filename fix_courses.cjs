const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/instalacion_completa.sql';
let content = fs.readFileSync(file, 'utf8');

let maxCurso = 0;
const regex = /,\s*'(\d+)'\s*,\s*'2026-[12]'/g;
let match;
while ((match = regex.exec(content)) !== null) {
  let val = parseInt(match[1], 10);
  if (val > maxCurso) maxCurso = val;
}
console.log('Max curso in SECCION:', maxCurso);

const histRegex = /'2024\d+',\s*'(\d+)'/g;
while ((match = histRegex.exec(content)) !== null) {
  let val = parseInt(match[1], 10);
  if (val > maxCurso) maxCurso = val;
}
console.log('Max curso in HISTORIAL:', maxCurso);

let cursoInserts = '\n-- CURSOS FALTANTES MALLA 2019\nINSERT INTO curso (cod_curso, nom_curso, creditos, codigo_asignatura) VALUES\n';
let planCursoInserts = '\n-- ASIGNACION DE CURSOS A PLAN2019\nINSERT INTO plan_curso (cod_plan, cod_curso, ciclo, tipo_curso) VALUES\n';

for (let i = 1; i <= maxCurso; i++) {
  let ciclo = Math.ceil(i / 7);
  let sep = (i === maxCurso ? ';' : ',');
  cursoInserts += "('" + i + "', 'Curso " + i + " Malla 2019', 4, 'C2019-" + i + "')" + sep + "\n";
  planCursoInserts += "('PLAN2019', '" + i + "', " + ciclo + ", 'OBLIGATORIO')" + sep + "\n";
}

const marker = '-- =========================================================\n-- 5. SECCIONES';
content = content.replace(marker, cursoInserts + '\n' + planCursoInserts + '\n' + marker);
fs.writeFileSync(file, content, 'utf8');
console.log('Appended courses missing to the SQL file.');
