const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/base_de_datos_final.sql';
let content = fs.readFileSync(file, 'utf8');

let cursoInserts = '\n-- CURSOS FALTANTES MALLA 2019\nINSERT INTO curso (cod_curso, nom_curso, creditos, codigo_asignatura) VALUES\n';
let planCursoInserts = '\n-- ASIGNACION DE CURSOS A PLAN2019\nINSERT INTO plan_curso (cod_plan, cod_curso, ciclo, tipo_curso) VALUES\n';

for (let i = 1; i <= 100; i++) {
  let ciclo = Math.ceil(i / 7);
  if (ciclo > 10) ciclo = 10;
  let sep = (i === 100 ? ';' : ',');
  cursoInserts += "('" + i + "', 'Curso " + i + " Malla 2019', 4, 'C2019-" + i + "')" + sep + "\n";
  planCursoInserts += "('PLAN2019', '" + i + "', " + ciclo + ", 'OBLIGATORIO')" + sep + "\n";
}

const marker = '-- =========================================================\n-- 5. SECCIONES';
content = content.replace(marker, cursoInserts + '\n' + planCursoInserts + '\n' + marker);
fs.writeFileSync(file, content, 'utf8');
console.log('Appended courses missing to the SQL file.');


