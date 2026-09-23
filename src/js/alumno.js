import { checkAuth, logout } from './auth.js';
import { supabase } from './supabase.js';

let currentUserData = null;
let alumnoInfo = null;
let periodoActivo = null;
let planCursos = [];
let requisitosCursos = [];
let matriculaActual = null;
let historialCursos = [];
let cursosSeleccionados = [];
let seccionesSeleccionadas = {};
let stepActual = 1;

document.addEventListener('DOMContentLoaded', async () => {
    currentUserData = await checkAuth('alumno');
    if (!currentUserData) return;

    alumnoInfo = currentUserData.alumnoInfo;

    // Header
    if (alumnoInfo) {
        document.getElementById('header-user-name').textContent = alumnoInfo.nombres + ' ' + alumnoInfo.apellidos;
        document.getElementById('avatar-img').src = `https://ui-avatars.com/api/?name=${encodeURIComponent(alumnoInfo.nombres)}&background=F28C28&color=fff`;
    } else {
        document.getElementById('header-user-name').textContent = currentUserData.codigo;
    }

    // Logout
    document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
        e.preventDefault();
        await logout();
    });

    // Cargar datos en paralelo para mejorar el rendimiento
    try {
        const promises = [
            supabase
                .from('periodo_academico')
                .select('*')
                .eq('estado', 'ACTIVO')
                .order('fecha_inicio', { ascending: false })
                .limit(1)
                .then(res => res, err => ({ data: [], error: err })),
            
            alumnoInfo && alumnoInfo.cod_plan
                ? supabase
                    .from('plan_curso')
                    .select('*, curso(*)')
                    .eq('cod_plan', alumnoInfo.cod_plan)
                    .then(res => res, err => ({ data: [], error: err }))
                : Promise.resolve({ data: [] }),
                
            alumnoInfo
                ? supabase
                    .from('historial_notas')
                    .select('*')
                    .eq('cod_alumno', alumnoInfo.cod_alumno)
                    .then(res => res, err => ({ data: [], error: err }))
                : Promise.resolve({ data: [] }),
                
            supabase
                .from('prerequisito')
                .select('*')
                .then(res => res, err => ({ data: [], error: err }))
        ];

        const results = await Promise.all(promises);
        
        const periodos = results[0]?.data;
        const planData = results[1]?.data;
        const historialData = results[2]?.data;
        const reqData = results[3]?.data;

        if (periodos && periodos.length > 0) periodoActivo = periodos[0];
        planCursos = planData || [];
        historialCursos = historialData || [];
        requisitosCursos = reqData || [];
    } catch (error) {
        console.error("Error cargando datos paralelos:", error);
    }

    // Cargar matrícula actual del alumno (depende del periodo activo)
    if (alumnoInfo && periodoActivo) {
        const { data } = await supabase
            .from('matricula')
            .select('*')
            .eq('cod_alumno', alumnoInfo.cod_alumno)
            .eq('cod_periodo', periodoActivo.cod_periodo)
            .maybeSingle();
        matriculaActual = data;
    }

    // Navigation
    const menuLinks = document.querySelectorAll('#alumno-menu a[data-target]');
    const sections = document.querySelectorAll('.view-section');

    menuLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            menuLinks.forEach(l => l.classList.remove('active'));
            sections.forEach(s => s.classList.remove('active'));
            link.classList.add('active');
            const targetId = link.getAttribute('data-target');
            document.getElementById(targetId).classList.add('active');
            loadSectionData(targetId);
        });
    });

    loadSectionData('inicio');
});

async function loadSectionData(section) {
    try {
        switch (section) {
            case 'inicio': renderInicio(); break;
            case 'perfil': renderPerfil(); break;
            case 'plan': await loadPlanEstudios(); break;
            case 'cursos': await loadCursos(); break;
            case 'horarios': await loadHorarios(); break;
            case 'matricula': await loadMatricula(); break;
            case 'mi-horario': await loadMiHorario(); break;
        }
    } catch (err) {
        console.error('Error en sección', section, err);
    }
}

// ─────────────────────────────────────────────
// INICIO
// ─────────────────────────────────────────────
function renderInicio() {
    const container = document.getElementById('inicio-content');
    if (!container) return;
    const nombre = alumnoInfo ? alumnoInfo.nombres.split(' ')[0] : currentUserData.codigo;
    const periodo = periodoActivo ? periodoActivo.nombre_periodo : 'No disponible';
    const totalCursos = planCursos.length;
    const estadoMatricula = matriculaActual
        ? `<span style="color:#10B981;font-weight:600;">Matriculado</span>`
        : `<span style="color:#F59E0B;font-weight:600;">Pendiente</span>`;
    const escuelaNombre = alumnoInfo?.escuela?.nom_escuela || alumnoInfo?.cod_escuela || '—';

    container.innerHTML = `
        <div style="margin-bottom:2rem; background: linear-gradient(135deg, #101A24 0%, #1e293b 100%); border-radius:16px; padding:2.5rem; color:#fff; position:relative; overflow:hidden;">
            <div style="position:relative; z-index:1;">
                <h1 style="font-size:2rem; font-weight:700; margin-bottom:0.5rem;">¡Bienvenido, ${nombre}!</h1>
                <p style="color:#94a3b8; margin-bottom:1.5rem;">Aquí podrás gestionar tu información académica y realizar tus trámites de matrícula.</p>
                <button class="btn-primary" onclick="document.querySelector('[data-target=plan]').click()">Mi plan de estudios →</button>
            </div>
            <div style="position:absolute; right:2rem; bottom:-1rem; font-size:8rem; opacity:0.05;">🎓</div>
        </div>
        <div class="cards-grid" style="margin-bottom:2rem;">
            <div class="card" style="cursor:pointer;" onclick="document.querySelector('[data-target=plan]').click()">
                <div class="stat-card-icon"><i data-lucide="book-open"></i></div>
                <h4 style="color:var(--text-secondary);font-weight:500;font-size:0.9rem;margin-bottom:0.5rem;">Mi plan de estudios</h4>
                <div style="font-size:1rem;font-weight:600;">${escuelaNombre}</div>
                <a style="color:var(--primary-orange);font-size:0.85rem;text-decoration:none;margin-top:1rem;display:inline-block;font-weight:500;">Ver detalle →</a>
            </div>
            <div class="card">
                <div class="stat-card-icon"><i data-lucide="calendar"></i></div>
                <h4 style="color:var(--text-secondary);font-weight:500;font-size:0.9rem;margin-bottom:0.5rem;">Periodo académico</h4>
                <div style="font-size:1rem;font-weight:600;">${periodo}</div>
                <a style="color:var(--primary-orange);font-size:0.85rem;text-decoration:none;margin-top:1rem;display:inline-block;font-weight:500;">Ver detalle →</a>
            </div>
            <div class="card" style="cursor:pointer;" onclick="document.querySelector('[data-target=cursos]').click()">
                <div class="stat-card-icon"><i data-lucide="library"></i></div>
                <h4 style="color:var(--text-secondary);font-weight:500;font-size:0.9rem;margin-bottom:0.5rem;">Cursos disponibles</h4>
                <div style="font-size:1rem;font-weight:600;">${totalCursos > 0 ? totalCursos + ' cursos' : 'No disponible'}</div>
                <a style="color:var(--primary-orange);font-size:0.85rem;text-decoration:none;margin-top:1rem;display:inline-block;font-weight:500;">Ver cursos →</a>
            </div>
            <div class="card" style="cursor:pointer;" onclick="document.querySelector('[data-target=matricula]').click()">
                <div class="stat-card-icon"><i data-lucide="check-circle"></i></div>
                <h4 style="color:var(--text-secondary);font-weight:500;font-size:0.9rem;margin-bottom:0.5rem;">Estado de matrícula</h4>
                <div style="font-size:1rem;font-weight:600;">${estadoMatricula}</div>
                <a style="color:var(--primary-orange);font-size:0.85rem;text-decoration:none;margin-top:1rem;display:inline-block;font-weight:500;">Ver detalle →</a>
            </div>
        </div>
        <div class="card" style="background:linear-gradient(135deg,#FFF7ED,#FEF3C7); border:1px solid #FDE68A;">
            <div style="display:flex;align-items:center;gap:2rem;flex-wrap:wrap;">
                <div style="font-size:4rem;">📚</div>
                <div>
                    <h3 style="font-weight:700;margin-bottom:0.5rem;">Sistema de Matrícula Virtual</h3>
                    <p style="color:var(--text-secondary);margin-bottom:1rem;">Consulta tu plan de estudios, revisa horarios disponibles y realiza tu matrícula en línea.</p>
                    <button class="btn-primary" onclick="document.querySelector('[data-target=matricula]').click()">Realizar matrícula →</button>
                </div>
            </div>
        </div>
    `;
    lucide.createIcons();
}

// ─────────────────────────────────────────────
// PERFIL
// ─────────────────────────────────────────────
function renderPerfil() {
    const container = document.getElementById('perfil-content');
    if (!container) return;
    if (!alumnoInfo) {
        container.innerHTML = `<p style="color:var(--text-secondary);">No se encontraron datos de perfil para el código <strong>${currentUserData.codigo}</strong>.</p>`;
        return;
    }
    const a = alumnoInfo;
    container.innerHTML = `
        <div style="display:flex;gap:2rem;align-items:flex-start;flex-wrap:wrap;">
            <div style="text-align:center;">
                <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(a.nombres+' '+a.apellidos)}&background=F28C28&color=fff&size=100" style="width:100px;height:100px;border-radius:50%;margin-bottom:1rem;">
                <h3 style="font-weight:700;">${a.nombres} ${a.apellidos}</h3>
                <p style="color:var(--text-secondary);font-size:0.85rem;">Código: ${a.cod_alumno}</p>
                <span class="badge" style="background:#D1FAE5;color:#065F46;margin-top:0.5rem;">Activo</span>
            </div>
            <div style="flex:1;min-width:250px;">
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                    <div>
                        <label style="font-size:0.8rem;color:var(--text-secondary);font-weight:600;">DNI</label>
                        <p style="font-weight:500;margin-top:0.25rem;">${a.dni || '—'}</p>
                    </div>
                    <div>
                        <label style="font-size:0.8rem;color:var(--text-secondary);font-weight:600;">Código de alumno</label>
                        <p style="font-weight:500;margin-top:0.25rem;">${a.cod_alumno}</p>
                    </div>
                    <div>
                        <label style="font-size:0.8rem;color:var(--text-secondary);font-weight:600;">Escuela</label>
                        <p style="font-weight:500;margin-top:0.25rem;">${a.escuela?.nom_escuela || a.cod_escuela || '—'}</p>
                    </div>
                    <div>
                        <label style="font-size:0.8rem;color:var(--text-secondary);font-weight:600;">Plan de estudios</label>
                        <p style="font-weight:500;margin-top:0.25rem;">${a.plan_estudio?.nombre_plan || a.cod_plan || '—'}</p>
                    </div>
                    <div>
                        <label style="font-size:0.8rem;color:var(--text-secondary);font-weight:600;">Estado</label>
                        <p style="font-weight:500;margin-top:0.25rem;color:#10B981;">Activo</p>
                    </div>
                    <div>
                        <label style="font-size:0.8rem;color:var(--text-secondary);font-weight:600;">Periodo actual</label>
                        <p style="font-weight:500;margin-top:0.25rem;">${periodoActivo?.nombre_periodo || '—'}</p>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// ─────────────────────────────────────────────
// PLAN DE ESTUDIOS
// ─────────────────────────────────────────────
async function loadPlanEstudios() {
    const semContainer = document.getElementById('plan-semesters');
    const planContainer = document.getElementById('plan-content');
    if (!semContainer || !planContainer) return;

    if (planCursos.length === 0) {
        semContainer.innerHTML = '';
        planContainer.innerHTML = `<div class="card"><p style="color:var(--text-secondary);">No se encontraron cursos en el plan de estudios.</p></div>`;
        return;
    }

    const semestres = [...new Set(planCursos.map(pc => pc.semestre))].sort((a, b) => a - b);

    semContainer.innerHTML = semestres.map(sem => `
        <button class="semester-btn" data-sem="${sem}" onclick="mostrarSemestre(${sem})" style="background:var(--white);border:1.5px solid var(--border-color);border-radius:12px;padding:1rem;cursor:pointer;text-align:center;transition:all 0.2s;min-width:80px;">
            <div style="font-size:1.5rem;font-weight:700;color:var(--navy-dark);">${sem}</div>
            <div style="font-size:0.75rem;color:var(--text-secondary);margin-top:0.25rem;">Semestre</div>
        </button>
    `).join('');

    mostrarSemestre(semestres[0]);
}

window.mostrarSemestre = function(sem) {
    document.querySelectorAll('.semester-btn').forEach(btn => {
        const isActive = parseInt(btn.getAttribute('data-sem')) === sem;
        btn.style.background = isActive ? 'var(--primary-orange)' : 'var(--white)';
        btn.style.borderColor = isActive ? 'var(--primary-orange)' : 'var(--border-color)';
        const divs = btn.querySelectorAll('div');
        if (divs[0]) divs[0].style.color = isActive ? '#fff' : 'var(--navy-dark)';
        if (divs[1]) divs[1].style.color = isActive ? 'rgba(255,255,255,0.8)' : 'var(--text-secondary)';
    });

    const cursosSemestre = planCursos.filter(pc => pc.semestre === sem);
    const planContainer = document.getElementById('plan-content');

    if (cursosSemestre.length === 0) {
        planContainer.innerHTML = `<div class="card"><p style="color:var(--text-secondary);">No hay cursos en este semestre.</p></div>`;
        return;
    }

    planContainer.innerHTML = `
        <h3 style="margin:1.5rem 0 1rem;">Semestre ${sem}</h3>
        <div class="cards-grid">
            ${cursosSemestre.map(pc => {
                const c = pc.curso;
                const esOblig = pc.tipo_curso === 'OBLIGATORIO';
                return `
                    <div class="card" style="border-left:4px solid var(--primary-orange);">
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:0.75rem;">
                            <span style="font-weight:700;font-size:0.85rem;color:var(--text-secondary);">${c?.cod_curso || pc.cod_curso}</span>
                            <span style="background:${esOblig ? '#FEE2E2' : '#E0E7FF'};color:${esOblig ? '#991B1B' : '#3730A3'};font-size:0.7rem;font-weight:600;padding:0.2rem 0.5rem;border-radius:4px;">${pc.tipo_curso}</span>
                        </div>
                        <h4 style="font-size:0.95rem;font-weight:600;margin-bottom:0.75rem;line-height:1.4;">${c?.nom_curso || '—'}</h4>
                        <div style="display:flex;gap:1rem;font-size:0.8rem;color:var(--text-secondary);">
                            <span>⭐ ${c?.creditos || 0} créditos</span>
                            ${c?.codigo_asignatura ? `<span>📋 ${c.codigo_asignatura}</span>` : ''}
                        </div>
                        <button class="btn-outline" style="width:100%;margin-top:1rem;font-size:0.85rem;" onclick="document.querySelector('[data-target=horarios]').click()">Ver horarios →</button>
                    </div>
                `;
            }).join('')}
        </div>
    `;
    lucide.createIcons();
}

// ─────────────────────────────────────────────
// CURSOS
// ─────────────────────────────────────────────
async function loadCursos() {
    const container = document.getElementById('cursos-content');
    if (!container) return;
    container.innerHTML = '<div class="loader-container"><div class="spinner"></div></div>';

    const { data: cursos, error } = await supabase
        .from('plan_curso')
        .select('*, curso(*)')
        .eq('cod_plan', alumnoInfo?.cod_plan || '');

    if (error || !cursos || cursos.length === 0) {
        container.innerHTML = `<div class="card"><p style="color:var(--text-secondary);">No se encontraron cursos.</p></div>`;
        return;
    }

    const semestres = [...new Set(cursos.map(pc => pc.semestre))].sort((a, b) => a - b);

    container.innerHTML = `
        <div style="display:flex;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;align-items:center;">
            <div style="flex:1;min-width:200px;display:flex;align-items:center;gap:0.5rem;border:1.5px solid var(--border-color);border-radius:8px;padding:0.5rem 1rem;background:#fff;">
                <i data-lucide="search" style="color:#9CA3AF;width:18px;flex-shrink:0;"></i>
                <input type="text" id="buscar-curso" placeholder="Buscar cursos..." style="border:none;outline:none;width:100%;font-size:0.9rem;" oninput="filtrarCursos()">
            </div>
            <select id="filtro-semestre" onchange="filtrarCursos()" style="border:1.5px solid var(--border-color);border-radius:8px;padding:0.5rem 1rem;background:#fff;font-size:0.9rem;cursor:pointer;">
                <option value="">Todos los semestres</option>
                ${semestres.map(s => `<option value="${s}">Semestre ${s}</option>`).join('')}
            </select>
            <select id="filtro-tipo" onchange="filtrarCursos()" style="border:1.5px solid var(--border-color);border-radius:8px;padding:0.5rem 1rem;background:#fff;font-size:0.9rem;cursor:pointer;">
                <option value="">Todos</option>
                <option value="OBLIGATORIO">Obligatorio</option>
                <option value="ELECTIVO">Electivo</option>
            </select>
        </div>
        <div id="cursos-grid" class="cards-grid">
            ${renderCursoCards(cursos)}
        </div>
    `;
    window._cursosData = cursos;
    lucide.createIcons();
}

function renderCursoCards(cursos) {
    if (!cursos || cursos.length === 0) return `<p style="color:var(--text-secondary);">No se encontraron cursos.</p>`;
    return cursos.map(pc => {
        const c = pc.curso;
        const esOblig = pc.tipo_curso === 'OBLIGATORIO';
        return `
            <div class="card" style="border-left:4px solid var(--primary-orange);">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:0.75rem;">
                    <span style="font-weight:700;font-size:0.85rem;color:var(--text-secondary);">${c?.cod_curso || pc.cod_curso}</span>
                    <span style="background:${esOblig ? '#FEE2E2' : '#E0E7FF'};color:${esOblig ? '#991B1B' : '#3730A3'};font-size:0.7rem;font-weight:600;padding:0.2rem 0.5rem;border-radius:4px;">${pc.tipo_curso}</span>
                </div>
                <h4 style="font-size:0.95rem;font-weight:600;margin-bottom:0.5rem;line-height:1.4;">${c?.nom_curso || '—'}</h4>
                <p style="font-size:0.8rem;color:var(--text-secondary);margin-bottom:0.75rem;">Semestre ${pc.semestre}</p>
                <div style="display:flex;gap:1rem;font-size:0.8rem;color:var(--text-secondary);">
                    <span>⭐ ${c?.creditos || 0} créditos</span>
                    ${c?.codigo_asignatura ? `<span>📋 ${c.codigo_asignatura}</span>` : ''}
                </div>
                <button class="btn-outline" style="width:100%;margin-top:1rem;font-size:0.85rem;" onclick="document.querySelector('[data-target=horarios]').click()">Ver horarios →</button>
            </div>
        `;
    }).join('');
}

window.filtrarCursos = function() {
    const buscar = document.getElementById('buscar-curso')?.value.toLowerCase() || '';
    const semestre = document.getElementById('filtro-semestre')?.value || '';
    const tipo = document.getElementById('filtro-tipo')?.value || '';
    let filtrados = window._cursosData || [];
    if (buscar) filtrados = filtrados.filter(pc =>
        pc.curso?.nom_curso?.toLowerCase().includes(buscar) ||
        pc.cod_curso?.toLowerCase().includes(buscar)
    );
    if (semestre) filtrados = filtrados.filter(pc => pc.semestre === parseInt(semestre));
    if (tipo) filtrados = filtrados.filter(pc => pc.tipo_curso === tipo);
    const grid = document.getElementById('cursos-grid');
    if (grid) grid.innerHTML = renderCursoCards(filtrados);
    lucide.createIcons();
}

// ─────────────────────────────────────────────
// HORARIOS DISPONIBLES
// ─────────────────────────────────────────────
async function loadHorarios() {
    const container = document.getElementById('horarios-content');
    if (!container) return;
    container.innerHTML = '<div class="loader-container"><div class="spinner"></div></div>';

    if (!periodoActivo) {
        container.innerHTML = '<p style="color:var(--text-secondary);">No hay periodo académico activo.</p>';
        return;
    }

    // seccion tiene: id_seccion, grupo, cupos_max, cupos_disp, cod_curso, cod_periodo, cod_profesor
    // horario_cabecera tiene: id_horario, id_seccion, cod_periodo
    // horario_detalle tiene: id_detalle, id_horario, dia_semana, hora_inicio, hora_fin, tipo_clase, ambiente
    const { data: secciones, error } = await supabase
        .from('seccion')
        .select(`
            id_seccion, grupo, cupos_max, cupos_disp, cod_curso, cod_profesor,
            curso(nom_curso, creditos),
            profesor(nombres, apellidos),
            horario_cabecera(id_horario, horario_detalle(dia_semana, hora_inicio, hora_fin, tipo_clase, ambiente))
        `)
        .eq('cod_periodo', periodoActivo.cod_periodo)
        .order('cod_curso');

    if (error || !secciones || secciones.length === 0) {
        container.innerHTML = `<div class="card" style="text-align:center;padding:2rem;">
            <div style="font-size:3rem;margin-bottom:1rem;">📭</div>
            <p style="color:var(--text-secondary);">No hay secciones disponibles para el periodo <strong>${periodoActivo.nombre_periodo}</strong>.</p>
        </div>`;
        return;
    }

    const cursosCodigos = [...new Set(secciones.map(s => s.cod_curso))].sort();

    container.innerHTML = `
        <div style="display:flex;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;">
            <select id="filtro-horario-curso" onchange="filtrarHorarios()" style="border:1.5px solid var(--border-color);border-radius:8px;padding:0.5rem 1rem;background:#fff;font-size:0.9rem;cursor:pointer;">
                <option value="">Todos los cursos</option>
                ${cursosCodigos.map(c => `<option value="${c}">${c}</option>`).join('')}
            </select>
        </div>
        <div id="tabla-horarios">
            ${renderTablaHorarios(secciones)}
        </div>
    `;
    window._seccionesData = secciones;
    lucide.createIcons();
}

function renderTablaHorarios(secciones) {
    // Expandir: una fila por cada detalle de horario
    let filas = '';
    secciones.forEach(sec => {
        const curso = sec.curso;
        const prof = sec.profesor;
        const detalles = [];
        // horario_cabecera puede ser array
        const cabeceras = Array.isArray(sec.horario_cabecera) ? sec.horario_cabecera : (sec.horario_cabecera ? [sec.horario_cabecera] : []);
        cabeceras.forEach(cab => {
            const dets = Array.isArray(cab.horario_detalle) ? cab.horario_detalle : (cab.horario_detalle ? [cab.horario_detalle] : []);
            dets.forEach(d => detalles.push(d));
        });

        if (detalles.length === 0) {
            // Aun mostrar la sección sin horario
            detalles.push({});
        }

        detalles.forEach(det => {
            const tipoClase = det.tipo_clase || '—';
            const tipoBadge = tipoClase.toLowerCase().includes('teor')
                ? '<span class="badge badge-teoria">Teoría</span>'
                : tipoClase.toLowerCase().includes('prac') || tipoClase.toLowerCase().includes('lab')
                    ? '<span class="badge badge-practica">Práctica</span>'
                    : `<span class="badge">${tipoClase}</span>`;
            const cupoColor = sec.cupos_disp > 5 ? '#10B981' : sec.cupos_disp > 0 ? '#F59E0B' : '#EF4444';

            filas += `
                <tr>
                    <td>
                        <div style="font-weight:600;font-size:0.85rem;">${sec.cod_curso}</div>
                        <div style="font-size:0.75rem;color:var(--text-secondary);">${curso?.nom_curso || '—'}</div>
                    </td>
                    <td style="font-weight:600;">${sec.grupo || String(sec.id_seccion).padStart(2,'0')}</td>
                    <td>${prof ? prof.nombres + ' ' + prof.apellidos : '—'}</td>
                    <td>${det.dia_semana || '—'}</td>
                    <td style="white-space:nowrap;">${det.hora_inicio ? det.hora_inicio + ' - ' + det.hora_fin : '—'}</td>
                    <td>${tipoBadge}</td>
                    <td>${det.ambiente || '—'}</td>
                    <td style="font-weight:700;color:${cupoColor};">${sec.cupos_disp ?? '—'}</td>
                </tr>
            `;
        });
    });

    return `
        <div style="overflow-x:auto;">
            <table class="modern-table">
                <thead>
                    <tr>
                        <th>Curso</th>
                        <th>Grupo</th>
                        <th>Profesor</th>
                        <th>Día</th>
                        <th>Hora</th>
                        <th>Tipo</th>
                        <th>Ambiente</th>
                        <th>Cupos</th>
                    </tr>
                </thead>
                <tbody>${filas}</tbody>
            </table>
        </div>
    `;
}

window.filtrarHorarios = function() {
    const curso = document.getElementById('filtro-horario-curso')?.value || '';
    let filtrados = window._seccionesData || [];
    if (curso) filtrados = filtrados.filter(s => s.cod_curso === curso);
    const tabla = document.getElementById('tabla-horarios');
    if (tabla) tabla.innerHTML = renderTablaHorarios(filtrados);
}

// ─────────────────────────────────────────────
// MATRÍCULA (proceso de 4 pasos)
// ─────────────────────────────────────────────
async function loadMatricula() {
    cursosSeleccionados = [];
    seccionesSeleccionadas = {};
    stepActual = 1;
    await renderStep(1);
}

function actualizarStepper(step) {
    document.querySelectorAll('.step').forEach((el, i) => {
        el.classList.toggle('active', i + 1 <= step);
    });
}

async function renderStep(step) {
    stepActual = step;
    actualizarStepper(step);
    const container = document.getElementById('matricula-form-container');
    if (!container) return;

    if (step === 1) {
        // Verificar si ya tiene matrícula
        if (matriculaActual) {
            container.innerHTML = `
                <div style="text-align:center;padding:3rem;">
                    <div style="font-size:4rem;margin-bottom:1rem;">✅</div>
                    <h3 style="color:#10B981;margin-bottom:0.5rem;">Ya estás matriculado</h3>
                    <p style="color:var(--text-secondary);margin-bottom:1.5rem;">Periodo: <strong>${periodoActivo?.nombre_periodo}</strong></p>
                    <button class="btn-primary" style="margin-top:1.5rem;" onclick="document.querySelector('[data-target=mi-horario]').click()">Ver mi horario →</button>
                </div>
            `;
            return;
        }

        if (!periodoActivo) {
            container.innerHTML = '<p style="color:var(--text-secondary);">No hay periodo académico activo.</p>';
            return;
        }

        container.innerHTML = '<div class="loader-container"><div class="spinner"></div></div>';

        // Filtrar cursos permitidos
        const semestreAlumno = alumnoInfo.semestre_actual || 1;
        
        // Mapear historial para búsquedas rápidas
        const historialMap = {};
        historialCursos.forEach(h => {
            historialMap[h.cod_curso] = h.estado; // 'APROBADO', 'REPROBADO'
        });

        const cursosPermitidos = (planCursos || [])
            .filter(pc => {
                // 1. Matrícula anual: puede ver cursos hasta 1 ciclo por encima del actual
                if (pc.semestre > semestreAlumno + 1) return false;
                
                // 2. Si ya está aprobado, no mostrar
                if (historialMap[pc.cod_curso] === 'APROBADO') return false;

                // 3. Si tiene prerrequisitos, verificar que todos estén aprobados
                const requisitosDelCurso = requisitosCursos.filter(r => r.cod_curso === pc.cod_curso);
                for (const req of requisitosDelCurso) {
                    if (historialMap[req.cod_curso_req] !== 'APROBADO') {
                        return false; // Falta aprobar un prerrequisito
                    }
                }
                
                return true;
            })
            .map(pc => pc.cod_curso);

        if (cursosPermitidos.length === 0) {
            container.innerHTML = '<p style="color:var(--text-secondary);">No hay cursos permitidos para tu ciclo actual en tu plan de estudios.</p>';
            return;
        }

        const { data: secciones } = await supabase
            .from('seccion')
            .select(`
                id_seccion, grupo, cupos_max, cupos_disp, cod_curso,
                curso(nom_curso, creditos),
                profesor(nombres, apellidos),
                horario_cabecera(horario_detalle(dia_semana, hora_inicio, hora_fin, tipo_clase))
            `)
            .eq('cod_periodo', periodoActivo.cod_periodo)
            .gt('cupos_disp', 0)
            .in('cod_curso', cursosPermitidos);

        if (!secciones || secciones.length === 0) {
            container.innerHTML = '<p style="color:var(--text-secondary);">No hay cursos disponibles con cupos para este periodo.</p>';
            return;
        }

        // Agrupar por curso
        const porCurso = {};
        secciones.forEach(s => {
            if (!porCurso[s.cod_curso]) porCurso[s.cod_curso] = { curso: s.curso, secciones: [] };
            porCurso[s.cod_curso].secciones.push(s);
        });

        window._seccionesMatricula = porCurso;

        container.innerHTML = `
            <h3 style="margin-bottom:1rem;">Selecciona los cursos que deseas matricular</h3>
            <div style="display:flex;gap:2rem;align-items:flex-start;flex-wrap:wrap;">
                <div style="flex:2;min-width:280px;">
                    <p style="color:var(--text-secondary);margin-bottom:1rem;font-size:0.9rem;">Selecciona los cursos en los que deseas matricularte:</p>
                    ${Object.entries(porCurso).map(([cod, info]) => `
                        <div class="card" style="margin-bottom:0.75rem;padding:1rem;display:flex;align-items:center;gap:1rem;border-left:4px solid var(--primary-orange);">
                            <input type="checkbox" value="${cod}" id="curso-cb-${cod}" onchange="actualizarResumen(this)" style="width:18px;height:18px;accent-color:var(--primary-orange);cursor:pointer;flex-shrink:0;">
                            <label for="curso-cb-${cod}" style="cursor:pointer;flex:1;">
                                <div style="font-weight:600;font-size:0.9rem;">${cod} - ${info.curso?.nom_curso || '—'}</div>
                                <div style="font-size:0.8rem;color:var(--text-secondary);margin-top:0.2rem;">${info.curso?.creditos || 0} créditos • ${info.secciones.length} sección(es)</div>
                            </label>
                        </div>
                    `).join('')}
                </div>
                <div style="flex:1;min-width:220px;">
                    <div class="card" style="background:#FAFAFA;position:sticky;top:1rem;">
                        <h4 style="margin-bottom:1.5rem;font-weight:700;">Resumen de matrícula</h4>
                        <div style="display:flex;justify-content:space-between;margin-bottom:0.75rem;">
                            <span style="color:var(--text-secondary);font-size:0.9rem;">Alumno:</span>
                            <span style="font-weight:600;font-size:0.9rem;">${alumnoInfo ? alumnoInfo.nombres.split(' ')[0] : 'N/A'}</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;margin-bottom:0.75rem;">
                            <span style="color:var(--text-secondary);font-size:0.9rem;">Plan:</span>
                            <span style="font-weight:600;font-size:0.9rem;">${alumnoInfo?.cod_plan || 'N/A'}</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;margin-bottom:0.75rem;">
                            <span style="color:var(--text-secondary);font-size:0.9rem;">Cursos seleccionados:</span>
                            <span style="font-weight:700;font-size:0.9rem;" id="resumen-count">0</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;margin-bottom:1.5rem;">
                            <span style="color:var(--text-secondary);font-size:0.9rem;">Total créditos:</span>
                            <span style="font-weight:700;color:var(--primary-orange);font-size:1rem;" id="resumen-creditos">0</span>
                        </div>
                        <div id="resumen-lista" style="margin-bottom:1.5rem;font-size:0.85rem;color:var(--text-secondary);">Sin cursos seleccionados</div>
                        <hr style="border:0;border-top:1px solid var(--border-color);margin-bottom:1.5rem;">
                        <button id="btn-siguiente" class="btn-primary" style="width:100%;" onclick="irASiguientePaso()" disabled>Siguiente →</button>
                    </div>
                </div>
            </div>
        `;
        lucide.createIcons();
    }
    else if (step === 2) {
        const porCurso = window._seccionesMatricula;
        container.innerHTML = `
            <h3 style="margin-bottom:1rem;">Selecciona una sección por cada curso</h3>
            <div style="display:flex;gap:2rem;align-items:flex-start;flex-wrap:wrap;">
                <div style="flex:2;min-width:280px;">
                    ${cursosSeleccionados.map(cod => {
                        const info = porCurso[cod];
                        return `
                            <div class="card" style="margin-bottom:1.5rem;">
                                <h4 style="margin-bottom:1rem;font-weight:700;border-bottom:1px solid var(--border-color);padding-bottom:0.75rem;">${cod} - ${info?.curso?.nom_curso || '—'}</h4>
                                ${(info?.secciones || []).map(sec => {
                                    const det = sec.horario_cabecera?.[0]?.horario_detalle?.[0] || {};
                                    const prof = sec.profesor;
                                    const tipoClase = det.tipo_clase || '—';
                                    return `
                                        <label style="display:flex;align-items:center;gap:1rem;padding:0.75rem;border:1.5px solid var(--border-color);border-radius:8px;margin-bottom:0.5rem;cursor:pointer;transition:all 0.2s;"
                                            onmouseover="this.style.borderColor='var(--primary-orange)'"
                                            onmouseout="this.style.borderColor='var(--border-color)'">
                                            <input type="radio" name="sec-${cod}" value="${sec.id_seccion}" onchange="seleccionarSeccion('${cod}',${sec.id_seccion})" style="accent-color:var(--primary-orange);">
                                            <div style="flex:1;">
                                                <div style="font-weight:600;font-size:0.9rem;">Grupo ${sec.grupo || sec.id_seccion} • ${prof ? prof.nombres+' '+prof.apellidos : '—'}</div>
                                                <div style="font-size:0.8rem;color:var(--text-secondary);margin-top:0.2rem;">${det.dia_semana || '—'} • ${det.hora_inicio || '—'} - ${det.hora_fin || '—'} • ${tipoClase}</div>
                                            </div>
                                            <span style="font-size:0.8rem;font-weight:600;color:${sec.cupos_disp > 5 ? '#10B981' : '#F59E0B'};">${sec.cupos_disp} cupos</span>
                                        </label>
                                    `;
                                }).join('')}
                            </div>
                        `;
                    }).join('')}
                </div>
                <div style="flex:1;min-width:220px;">
                    <div class="card" style="background:#FAFAFA;position:sticky;top:1rem;">
                        <h4 style="margin-bottom:1rem;font-weight:700;">Secciones seleccionadas</h4>
                        <div id="resumen-secciones" style="font-size:0.85rem;color:var(--text-secondary);margin-bottom:1.5rem;">Ninguna seleccionada</div>
                        <div style="display:flex;gap:0.75rem;">
                            <button class="btn-outline" style="flex:1;" onclick="renderStep(1)">← Atrás</button>
                            <button id="btn-revisar" class="btn-primary" style="flex:1;" onclick="irARevision()" disabled>Revisar →</button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    else if (step === 3) {
        const porCurso = window._seccionesMatricula;
        let totalCreditos = 0;

        const filas = cursosSeleccionados.map(cod => {
            const info = porCurso[cod];
            const secId = seccionesSeleccionadas[cod];
            const sec = info?.secciones?.find(s => s.id_seccion === secId);
            const det = sec?.horario_cabecera?.[0]?.horario_detalle?.[0] || {};
            const prof = sec?.profesor;
            const creditos = info?.curso?.creditos || 0;
            totalCreditos += creditos;
            return `
                <tr>
                    <td><div style="font-weight:600;">${cod}</div><div style="font-size:0.75rem;color:var(--text-secondary);">${info?.curso?.nom_curso || '—'}</div></td>
                    <td>${sec?.grupo || String(secId).padStart(2,'0')}</td>
                    <td>${prof ? prof.nombres+' '+prof.apellidos : '—'}</td>
                    <td>${det.dia_semana || '—'}</td>
                    <td style="white-space:nowrap;">${det.hora_inicio ? det.hora_inicio+' - '+det.hora_fin : '—'}</td>
                    <td>${det.ambiente || '—'}</td>
                    <td style="font-weight:700;color:var(--primary-orange);">${creditos}</td>
                </tr>
            `;
        }).join('');

        container.innerHTML = `
            <div class="card" style="margin-bottom:1.5rem;background:#F0FDF4;border:1px solid #BBF7D0;">
                <div style="display:flex;gap:1rem;align-items:center;">
                    <div style="font-size:2rem;">✅</div>
                    <div>
                        <h4 style="color:#065F46;font-weight:700;">Resumen de matrícula</h4>
                        <p style="color:#047857;font-size:0.9rem;">${cursosSeleccionados.length} curso(s) • Total: ${totalCreditos} créditos</p>
                    </div>
                </div>
            </div>
            <div style="overflow-x:auto;margin-bottom:1.5rem;">
                <table class="modern-table">
                    <thead><tr><th>Curso</th><th>Grupo</th><th>Profesor</th><th>Día</th><th>Horario</th><th>Ambiente</th><th>Créditos</th></tr></thead>
                    <tbody>${filas}</tbody>
                </table>
            </div>
            <div style="display:flex;gap:1rem;justify-content:flex-end;">
                <button class="btn-outline" onclick="renderStep(2)">← Atrás</button>
                <button class="btn-primary" onclick="confirmarMatricula()">Confirmar matrícula ✓</button>
            </div>
            <div id="matricula-msg" style="margin-top:1rem;"></div>
        `;
    }
    else if (step === 4) {
        container.innerHTML = `
            <div style="text-align:center;padding:3rem;">
                <div style="font-size:5rem;margin-bottom:1rem;">🎉</div>
                <h2 style="color:var(--primary-orange);margin-bottom:0.5rem;">¡Matrícula registrada con éxito!</h2>
                <p style="color:var(--text-secondary);margin-bottom:0.5rem;">Se matricularon <strong>${cursosSeleccionados.length}</strong> curso(s).</p>
                <p style="color:var(--text-secondary);margin-bottom:2rem;">Periodo: <strong>${periodoActivo?.nombre_periodo}</strong></p>
                <button class="btn-primary" onclick="document.querySelector('[data-target=mi-horario]').click()">Ver mi horario →</button>
            </div>
        `;
    }
}

window.actualizarResumen = function(checkboxEl) {
    let checks = document.querySelectorAll('input[type=checkbox]:checked');
    let seleccionadosTemp = Array.from(checks).map(c => c.value);
    const porCurso = window._seccionesMatricula || {};
    
    let creditosPorSemestre = {};
    let totalCreditos = 0;
    let semestreExcedido = null;

    seleccionadosTemp.forEach(cod => {
        const cred = porCurso[cod]?.curso?.creditos || 0;
        totalCreditos += cred;
        
        // Buscar el semestre del curso en planCursos
        const pc = planCursos.find(p => p.cod_curso === cod);
        const semestre = pc ? pc.semestre : 1;

        if (!creditosPorSemestre[semestre]) creditosPorSemestre[semestre] = 0;
        creditosPorSemestre[semestre] += cred;

        if (creditosPorSemestre[semestre] > 21) {
            semestreExcedido = semestre;
        }
    });

    // Validar límite de 21 créditos por semestre exacto
    if (semestreExcedido) {
        alert('No puedes matricularte en más de 21 créditos en el ciclo ' + semestreExcedido + '.');
        if (checkboxEl) {
            checkboxEl.checked = false; // Deshacer la selección
            // Recalcular
            checks = document.querySelectorAll('input[type=checkbox]:checked');
            seleccionadosTemp = Array.from(checks).map(c => c.value);
            totalCreditos = 0;
            seleccionadosTemp.forEach(cod => totalCreditos += (porCurso[cod]?.curso?.creditos || 0));
        }
    }

    cursosSeleccionados = seleccionadosTemp;

    document.getElementById('resumen-count').textContent = cursosSeleccionados.length;
    document.getElementById('resumen-creditos').textContent = totalCreditos;

    const lista = document.getElementById('resumen-lista');
    if (cursosSeleccionados.length === 0) {
        lista.textContent = 'Sin cursos seleccionados';
    } else {
        lista.innerHTML = cursosSeleccionados.map(cod =>
            `<div style="padding:0.25rem 0;">• ${cod} - ${porCurso[cod]?.curso?.nom_curso?.substring(0,25) || '—'}</div>`
        ).join('');
    }

    const btn = document.getElementById('btn-siguiente');
    if (btn) btn.disabled = cursosSeleccionados.length === 0;
}

window.irASiguientePaso = function() {
    if (cursosSeleccionados.length > 0) renderStep(2);
}

window.seleccionarSeccion = function(cod, id) {
    seccionesSeleccionadas[cod] = id;
    const resumen = document.getElementById('resumen-secciones');
    const todosSeleccionados = cursosSeleccionados.every(c => seccionesSeleccionadas[c]);

    if (resumen) {
        resumen.innerHTML = Object.entries(seccionesSeleccionadas)
            .map(([c, s]) => `<div style="padding:0.25rem 0;">• ${c} → Sección ${s}</div>`)
            .join('') || 'Ninguna seleccionada';
    }

    const btn = document.getElementById('btn-revisar');
    if (btn) btn.disabled = !todosSeleccionados;
}

window.irARevision = function() {
    if (cursosSeleccionados.every(c => seccionesSeleccionadas[c])) renderStep(3);
    else alert('Selecciona una sección para cada curso.');
}

window.confirmarMatricula = async function() {
    const msg = document.getElementById('matricula-msg');
    if (!alumnoInfo || !periodoActivo) {
        if (msg) msg.innerHTML = '<p style="color:red;">Error: datos incompletos.</p>';
        return;
    }

    if (msg) msg.innerHTML = '<p style="color:var(--primary-orange);">Registrando matrícula...</p>';

    const { data, error } = await supabase
        .from('matricula')
        .insert({
            cod_alumno: alumnoInfo.cod_alumno,
            cod_periodo: periodoActivo.cod_periodo,
            fecha_matricula: new Date().toISOString()
        })
        .select()
        .single();

    if (error) {
        if (msg) msg.innerHTML = `<p style="color:red;">Error: ${error.message}</p>`;
        return;
    }

    // Insertar detalles de matrícula
    const detalles = cursosSeleccionados.map(cod => ({
        num_matricula: data.num_matricula,
        id_seccion: seccionesSeleccionadas[cod]
    }));

    if (detalles.length > 0) {
        await supabase.from('detalle_matricula').insert(detalles);
    }

    matriculaActual = data;
    renderStep(4);
}

// Hacer renderStep global para los botones
window.renderStep = renderStep;

// ─────────────────────────────────────────────
// MI HORARIO
// ─────────────────────────────────────────────
async function loadMiHorario() {
    const container = document.getElementById('mi-horario-content');
    if (!container) return;
    container.innerHTML = '<div class="loader-container"><div class="spinner"></div></div>';

    if (!matriculaActual) {
        container.innerHTML = `
            <div class="card" style="text-align:center;padding:3rem;">
                <div style="font-size:4rem;margin-bottom:1rem;">📅</div>
                <h3 style="margin-bottom:0.5rem;">No tienes matrícula registrada</h3>
                <p style="color:var(--text-secondary);margin-bottom:1.5rem;">Realiza tu matrícula para ver tu horario semanal.</p>
                <button class="btn-primary" onclick="document.querySelector('[data-target=matricula]').click()">Ir a Matrícula →</button>
            </div>
        `;
        return;
    }

    // Obtener secciones matriculadas
    const { data: detalles } = await supabase
        .from('detalle_matricula')
        .select(`
            id_seccion,
            seccion(
                id_seccion, grupo, cod_curso,
                curso(nom_curso, creditos),
                profesor(nombres, apellidos),
                horario_cabecera(horario_detalle(dia_semana, hora_inicio, hora_fin, tipo_clase, ambiente))
            )
        `)
        .eq('num_matricula', matriculaActual.num_matricula);

    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    const colores = ['#DBEAFE', '#D1FAE5', '#FEF3C7', '#FCE7F3', '#E0E7FF', '#FEE2E2'];
    const bordes = ['#1E40AF', '#065F46', '#92400E', '#9D174D', '#3730A3', '#991B1B'];

    container.innerHTML = `
        <div style="margin-bottom:1rem;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem;">
            <p style="color:var(--text-secondary);">Periodo: <strong>${periodoActivo?.nombre_periodo || '—'}</strong></p>
            <span class="badge" style="background:#D1FAE5;color:#065F46;">Matrícula activa</span>
        </div>
        ${detalles && detalles.length > 0 ? `
            <div style="overflow-x:auto;">
                <table class="modern-table">
                    <thead><tr><th>Curso</th><th>Grupo</th><th>Profesor</th><th>Día</th><th>Hora</th><th>Tipo</th><th>Ambiente</th></tr></thead>
                    <tbody>
                        ${detalles.map((dm, i) => {
                            const sec = dm.seccion;
                            if (!sec) return '';
                            const det = sec.horario_cabecera?.[0]?.horario_detalle?.[0] || {};
                            const prof = sec.profesor;
                            return `<tr>
                                <td><div style="font-weight:600;">${sec.cod_curso}</div><div style="font-size:0.75rem;color:var(--text-secondary);">${sec.curso?.nom_curso || '—'}</div></td>
                                <td>${sec.grupo || sec.id_seccion}</td>
                                <td>${prof ? prof.nombres+' '+prof.apellidos : '—'}</td>
                                <td>${det.dia_semana || '—'}</td>
                                <td>${det.hora_inicio ? det.hora_inicio+' - '+det.hora_fin : '—'}</td>
                                <td>${det.tipo_clase || '—'}</td>
                                <td>${det.ambiente || '—'}</td>
                            </tr>`;
                        }).join('')}
                    </tbody>
                </table>
            </div>
        ` : `
            <div class="card" style="background:#FFF7ED;border:1px solid #FED7AA;">
                <p style="color:#92400E;font-size:0.9rem;">💡 Tu matrícula fue registrada pero aún no tiene cursos asignados en detalle.</p>
            </div>
        `}
    `;
}
