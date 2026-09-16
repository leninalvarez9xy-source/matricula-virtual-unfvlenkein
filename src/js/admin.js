import { checkAuth, logout } from './auth.js';
import { supabase } from './supabase.js';

document.addEventListener('DOMContentLoaded', async () => {
    const userData = await checkAuth('admin');
    if (!userData) return;

    // Logout
    document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
        e.preventDefault();
        await logout();
    });

    // Navigation
    const menuLinks = document.querySelectorAll('#admin-menu a[data-target]');
    const sections = document.querySelectorAll('.view-section');

    menuLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            menuLinks.forEach(l => l.classList.remove('active'));
            sections.forEach(s => s.classList.remove('active'));
            link.classList.add('active');
            const targetId = link.getAttribute('data-target');
            document.getElementById(targetId).classList.add('active');
            loadAdminSection(targetId);
        });
    });

    loadAdminSection('dashboard');
});

async function loadAdminSection(section) {
    if (section === 'dashboard') {
        loadDashboard();
    } else {
        await loadTable(section);
    }
}

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────
async function loadDashboard() {
    // Stats
    const [
        { count: cAlumnos },
        { count: cProfesores },
        { count: cCursos },
        { count: cMatriculas }
    ] = await Promise.all([
        supabase.from('alumno').select('*', { count: 'exact', head: true }),
        supabase.from('profesor').select('*', { count: 'exact', head: true }),
        supabase.from('curso').select('*', { count: 'exact', head: true }),
        supabase.from('matricula').select('*', { count: 'exact', head: true })
    ]);

    const setEl = (id, val) => { const el = document.getElementById(id); if(el) el.textContent = val ?? 0; };
    setEl('stat-alumnos', cAlumnos);
    setEl('stat-profesores', cProfesores);
    setEl('stat-cursos', cCursos);
    setEl('stat-matriculas', cMatriculas);

    // Actividad reciente
    const actividadEl = document.getElementById('actividad-reciente');
    if (actividadEl) {
        const { data: ultimasMatriculas } = await supabase
            .from('matricula')
            .select('num_matricula, cod_alumno, cod_periodo, fecha_matricula')
            .order('fecha_matricula', { ascending: false })
            .limit(5);

        if (ultimasMatriculas && ultimasMatriculas.length > 0) {
            actividadEl.innerHTML = ultimasMatriculas.map(m => `
                <div style="display:flex;align-items:center;gap:1rem;padding:0.75rem 0;border-bottom:1px solid var(--border-color);">
                    <div style="width:36px;height:36px;background:#FEF3C7;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:1rem;flex-shrink:0;">📝</div>
                    <div style="flex:1;">
                        <div style="font-size:0.9rem;font-weight:500;">Matrícula de alumno <strong>${m.cod_alumno}</strong></div>
                        <div style="font-size:0.8rem;color:var(--text-secondary);">Periodo: ${m.cod_periodo} • ${new Date(m.fecha_matricula).toLocaleDateString('es-PE')}</div>
                    </div>
                </div>
            `).join('');
        } else {
            actividadEl.innerHTML = `
                <div style="text-align:center;padding:2rem;">
                    <div style="font-size:2.5rem;margin-bottom:0.5rem;">📋</div>
                    <p style="color:var(--text-secondary);font-size:0.9rem;">No hay actividad reciente</p>
                </div>
            `;
        }
    }

    lucide.createIcons();
}

// ─────────────────────────────────────────────
// TABLAS GENÉRICAS
// ─────────────────────────────────────────────
const tableConfig = {
    'escuelas':      { table: 'escuela',           label: 'Escuelas' },
    'planes':        { table: 'plan_estudio',       label: 'Planes de estudio' },
    'cursos':        { table: 'curso',              label: 'Cursos' },
    'prerrequisitos':{ table: 'prerrequisito',      label: 'Prerrequisitos' },
    'alumnos':       { table: 'alumno',             label: 'Alumnos' },
    'profesores':    { table: 'profesor',           label: 'Profesores' },
    'periodos':      { table: 'periodo_academico',  label: 'Periodos académicos' },
    'secciones':     { table: 'seccion',            label: 'Secciones', select: '*, curso(nombre), profesor(nombres,apellidos)' },
    'horarios':      { table: 'horario_cabecera',   label: 'Horarios', select: '*, horario_detalle(*), seccion(cod_curso,cod_periodo)' },
    'matriculas':    { table: 'matricula',          label: 'Matrículas' },
};

async function loadTable(section) {
    const config = tableConfig[section];
    if (!config) return;

    const container = document.getElementById(`content-${section}`);
    if (!container) return;

    container.innerHTML = '<div class="loader-container"><div class="spinner"></div></div>';

    const query = supabase.from(config.table).select(config.select || '*').limit(100);
    const { data, error } = await query;

    if (error) {
        container.innerHTML = `<div style="color:red;padding:1rem;">Error: ${error.message}</div>`;
        return;
    }

    if (!data || data.length === 0) {
        container.innerHTML = `
            <div style="text-align:center;padding:3rem;color:var(--text-secondary);">
                <div style="font-size:3rem;margin-bottom:1rem;">📭</div>
                <p>No hay registros en <strong>${config.label}</strong>.</p>
            </div>
        `;
        return;
    }

    // Aplanar objetos anidados para la tabla
    const flatData = data.map(row => flattenRow(row));
    const keys = Object.keys(flatData[0]);

    container.innerHTML = `
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;flex-wrap:wrap;gap:0.5rem;">
            <div style="display:flex;align-items:center;gap:0.5rem;border:1.5px solid var(--border-color);border-radius:8px;padding:0.4rem 0.75rem;background:#fff;flex:1;max-width:300px;">
                <i data-lucide="search" style="color:#9CA3AF;width:16px;"></i>
                <input type="text" placeholder="Buscar..." style="border:none;outline:none;font-size:0.85rem;width:100%;" oninput="filtrarTabla(this.value, '${section}')">
            </div>
            <span style="font-size:0.85rem;color:var(--text-secondary);">${data.length} registros</span>
        </div>
        <div style="overflow-x:auto;" id="table-wrapper-${section}">
            ${renderModernTable(keys, flatData)}
        </div>
    `;
    window[`_tableData_${section}`] = flatData;
    lucide.createIcons();
}

function flattenRow(row, prefix = '') {
    const flat = {};
    for (const [key, val] of Object.entries(row)) {
        if (val && typeof val === 'object' && !Array.isArray(val)) {
            // Objeto anidado (join): mostrar como texto compuesto
            const joined = Object.values(val).filter(v => v !== null && typeof v !== 'object').join(' ');
            flat[prefix + key] = joined;
        } else if (Array.isArray(val)) {
            flat[prefix + key] = `[${val.length} items]`;
        } else {
            flat[prefix + key] = val;
        }
    }
    return flat;
}

function renderModernTable(keys, data) {
    const formatVal = (val) => {
        if (val === null || val === undefined) return '<span style="color:#D1D5DB;">—</span>';
        if (typeof val === 'boolean') return val ? '✅' : '❌';
        const str = String(val);
        if (str.length > 60) return `<span title="${str}">${str.substring(0,57)}...</span>`;
        return str;
    };

    return `
        <table class="modern-table">
            <thead>
                <tr>
                    ${keys.map(k => `<th>${k.replace(/_/g,' ').toUpperCase()}</th>`).join('')}
                </tr>
            </thead>
            <tbody>
                ${data.map(row => `
                    <tr>
                        ${keys.map(k => `<td>${formatVal(row[k])}</td>`).join('')}
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
}

window.filtrarTabla = function(query, section) {
    const data = window[`_tableData_${section}`] || [];
    const q = query.toLowerCase();
    const filtered = data.filter(row =>
        Object.values(row).some(v => String(v).toLowerCase().includes(q))
    );
    const wrapper = document.getElementById(`table-wrapper-${section}`);
    if (wrapper) wrapper.innerHTML = filtered.length > 0
        ? renderModernTable(Object.keys(data[0]), filtered)
        : '<p style="color:var(--text-secondary);padding:1rem;">No se encontraron resultados.</p>';
}
