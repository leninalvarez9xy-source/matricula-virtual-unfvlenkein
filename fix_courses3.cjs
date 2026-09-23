const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/base_de_datos_final.sql';
let content = fs.readFileSync(file, 'utf8');

let lines = content.split(/\r?\n/);

let insertIndex = -1;
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('-- 5. SECCIONES - 2026-1')) {
    insertIndex = i;
    break;
  }
}

if (insertIndex > -1) {
  let cursoInserts = '\n-- CURSOS FALTANTES MALLA 2019\nINSERT INTO curso (cod_curso, nom_curso, creditos, codigo_asignatura) VALUES\n';
  let planCursoInserts = '\n-- ASIGNACION DE CURSOS A PLAN2019\nINSERT INTO plan_curso (cod_plan, cod_curso, ciclo, tipo_curso) VALUES\n';

  for (let i = 1; i <= 100; i++) {
    let ciclo = Math.ceil(i / 7);
    if (ciclo > 10) ciclo = 10;
    let sep = (i === 100 ? ';' : ',');
    cursoInserts += "('" + i + "', 'Curso " + i + " Malla 2019', 4, 'C2019-" + i + "')" + sep + "\n";
    planCursoInserts += "('PLAN2019', '" + i + "', " + ciclo + ", 'OBLIGATORIO')" + sep + "\n";
  }
  
  lines.splice(insertIndex, 0, cursoInserts + '\n' + planCursoInserts);
  fs.writeFileSync(file, lines.join('\n'), 'utf8');
  console.log('Successfully appended courses using lines.splice');
} else {
  console.log('Marker not found!');
}
