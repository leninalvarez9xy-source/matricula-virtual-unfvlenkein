# 🎓 Sistema de Matrícula Virtual — UNFV FIIS (EPIS)

Sistema de matrícula virtual para la Escuela Profesional de Ingeniería de Sistemas de la Universidad Nacional Federico Villarreal.

## 🛠️ Tecnologías

- **Frontend:** HTML, CSS, JavaScript (Vanilla) + Vite
- **Backend/BD:** Supabase (PostgreSQL + Auth)
- **Iconos:** Lucide Icons

## 📋 Requisitos previos

- [Node.js](https://nodejs.org/) (v18 o superior)
- Acceso a internet (conexión a Supabase)

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/leninalvarez9xy-source/matricula-virtual-unfvlenkein.git
cd matricula-virtual-unfvlenkein
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

Copia el archivo de ejemplo y reemplaza la clave:

```bash
copy .env.example .env
```

Abre `.env` y coloca la **ANON KEY** de Supabase que te compartió el equipo:

```
VITE_SUPABASE_URL=https://qaqdphucwvsfzzkceiar.supabase.co
VITE_SUPABASE_ANON_KEY=PEGAR_AQUI_LA_CLAVE
```

> ⚠️ **No subas el archivo `.env` a GitHub.** Pide la clave al administrador del proyecto.

### 4. Ejecutar el proyecto

```bash
npm run dev
```

Se abrirá en `http://localhost:5173`

## 👤 Credenciales de prueba

| Rol    | Código / Usuario        | Contraseña |
|--------|------------------------|------------|
| Alumno | `2024203953`           | `papoi`    |
| Admin  | `admin`                | `papoi`    |

## 📁 Estructura del proyecto

```
├── index.html              # Página de login
├── dashboard-alumno.html   # Panel del alumno
├── dashboard-admin.html    # Panel del administrador
├── js/
│   ├── supabase.js         # Conexión a Supabase
│   ├── auth.js             # Autenticación y roles
│   ├── login.js            # Lógica del login
│   ├── alumno.js           # Panel del alumno (matrícula, cursos, horarios)
│   └── admin.js            # Panel del administrador (tablas, dashboard)
├── css/
│   ├── login.css           # Estilos del login
│   ├── dashboard.css       # Estilos de los paneles
│   └── styles.css          # Estilos generales
├── assets/img/             # Logos e imágenes
├── .env.example            # Plantilla de variables de entorno
└── package.json
```

## 🎯 Funcionalidades

### Panel del Alumno
- ✅ Inicio con resumen académico
- ✅ Perfil del alumno (DNI, escuela, plan)
- ✅ Plan de estudios por semestre (1-10)
- ✅ Catálogo de cursos con búsqueda y filtros
- ✅ Horarios disponibles con secciones
- ✅ Matrícula virtual en 4 pasos
- ✅ Mi horario (cursos matriculados)

### Panel del Administrador
- ✅ Dashboard con estadísticas en tiempo real
- ✅ Gestión de: escuelas, planes, cursos, alumnos, profesores, periodos, secciones, horarios, matrículas

## 📊 Base de datos (Supabase)

Tablas principales:
`escuela` · `plan_estudio` · `curso` · `plan_curso` · `prerrequisito` · `alumno` · `profesor` · `periodo_academico` · `seccion` · `horario_cabecera` · `horario_detalle` · `matricula` · `detalle_matricula`

## 👥 Equipo

- Lenin Allister Alvarez Jara — Desarrollo

---

*Proyecto académico — Diseño de Base de Datos — UNFV FIIS 2026*

