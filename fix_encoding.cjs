const fs = require('fs');
const file = 'c:/Users/luisa/OneDrive/Desktop/wbd de lenin/matricula-virtual-unfvlenkein/instalacion_completa.sql';
let content = fs.readFileSync(file, 'utf8');

// The user is seeing weird characters from utf8 conversion.
content = content.replace(/L"GICA/g, 'LOGICA');
content = content.replace(/L"GICA/g, 'LOGICA');
content = content.replace(/LoGICA/g, 'LOGICA');

content = content.replace(/COMPUTACI"N/g, 'COMPUTACION');
content = content.replace(/COMPUTACI"N/g, 'COMPUTACION');
content = content.replace(/COMPUTACIoN/g, 'COMPUTACION');

content = content.replace(/INFORM\?TICA/g, 'INFORMATICA');

content = content.replace(/REDACCI"N/g, 'REDACCION');
content = content.replace(/REDACCI"N/g, 'REDACCION');

content = content.replace(/METODOLOG\?A/g, 'METODOLOGIA');

content = content.replace(/INVESTIGACI"N/g, 'INVESTIGACION');
content = content.replace(/INVESTIGACI"N/g, 'INVESTIGACION');

content = content.replace(/DISE'O/g, 'DISENO');
content = content.replace(/DISEmO/g, 'DISENO');
content = content.replace(/DISEO/g, 'DISENO');

content = content.replace(/InglǸs/g, 'Ingles');
content = content.replace(/Comunicacin/g, 'Comunicacion');
content = content.replace(/Metodologa/g, 'Metodologia');
content = content.replace(/Matemǭtica/g, 'Matematica');
content = content.replace(/Ingeniera/g, 'Ingenieria');
content = content.replace(/Estadstica/g, 'Estadistica');
content = content.replace(/Programacin/g, 'Programacion');
content = content.replace(/Muoz/g, 'Munoz');
content = content.replace(/Investigacin/g, 'Investigacion');
content = content.replace(/Fsica/g, 'Fisica');
content = content.replace(/Hernǭndez/g, 'Hernandez');

fs.writeFileSync(file, content, 'utf8');
