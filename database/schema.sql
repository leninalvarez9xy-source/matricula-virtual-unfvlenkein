-- ====================================================================
-- SISTEMA DE MATRÍCULA VIRTUAL FIIS - UNFV
-- Esquema de Base de Datos para PostgreSQL / Supabase
-- ====================================================================

-- 1. TABLA: ESCUELA
CREATE TABLE IF NOT EXISTS public.escuela (
    id_escuela SERIAL PRIMARY KEY,
    nom_escuela VARCHAR(100) NOT NULL
);

-- 2. TABLA: PLAN DE ESTUDIOS
CREATE TABLE IF NOT EXISTS public.plan_estudios (
    id_plan SERIAL PRIMARY KEY,
    id_escuela INT REFERENCES public.escuela(id_escuela) ON DELETE CASCADE,
    nombre_plan VARCHAR(50) NOT NULL,
    anio_inicio INT NOT NULL
);

-- 3. TABLA: CURSO
CREATE TABLE IF NOT EXISTS public.curso (
    id_curso SERIAL PRIMARY KEY,
    id_plan INT REFERENCES public.plan_estudios(id_plan) ON DELETE CASCADE,
    cod_curso VARCHAR(20) NOT NULL UNIQUE,
    nom_curso VARCHAR(150) NOT NULL,
    ciclo INT NOT NULL,
    creditos NUMERIC(4, 2) NOT NULL,
    tipo_curso VARCHAR(30) DEFAULT 'Obligatorio',
    horas_teoria INT DEFAULT 0,
    horas_practica INT DEFAULT 0
);

-- 4. TABLA: PRERREQUISITO
CREATE TABLE IF NOT EXISTS public.prerrequisito (
    id_curso INT REFERENCES public.curso(id_curso) ON DELETE CASCADE,
    id_prerrequisito INT REFERENCES public.curso(id_curso) ON DELETE CASCADE,
    PRIMARY KEY (id_curso, id_prerrequisito)
);

-- 5. TABLA: ALUMNO
CREATE TABLE IF NOT EXISTS public.alumno (
    id_alumno SERIAL PRIMARY KEY,
    id_escuela INT REFERENCES public.escuela(id_escuela),
    id_plan INT REFERENCES public.plan_estudios(id_plan),
    cod_alumno VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    ape_paterno VARCHAR(100) NOT NULL,
    ape_materno VARCHAR(100) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    email_institucional VARCHAR(150) NOT NULL UNIQUE,
    ciclo_actual INT DEFAULT 1,
    estado_academico VARCHAR(30) DEFAULT 'Regular',
    cred_acumulados NUMERIC(5, 2) DEFAULT 0
);

-- 6. TABLA: PROFESOR
CREATE TABLE IF NOT EXISTS public.profesor (
    id_profesor SERIAL PRIMARY KEY,
    id_escuela INT REFERENCES public.escuela(id_escuela),
    cod_profesor VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    ape_paterno VARCHAR(100) NOT NULL,
    ape_materno VARCHAR(100) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    email_institucional VARCHAR(150) NOT NULL UNIQUE,
    categoria VARCHAR(50) DEFAULT 'Principal'
);

-- 7. TABLA: PERIODO ACADEMICO
CREATE TABLE IF NOT EXISTS public.periodo_academico (
    id_periodo SERIAL PRIMARY KEY,
    nombre_periodo VARCHAR(20) NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'Activo'
);

-- 8. TABLA: SECCION
CREATE TABLE IF NOT EXISTS public.seccion (
    id_seccion SERIAL PRIMARY KEY,
    id_curso INT REFERENCES public.curso(id_curso) ON DELETE CASCADE,
    id_periodo INT REFERENCES public.periodo_academico(id_periodo) ON DELETE CASCADE,
    id_profesor INT REFERENCES public.profesor(id_profesor) ON DELETE SET NULL,
    letra_sec VARCHAR(5) NOT NULL,
    cupos_totales INT NOT NULL DEFAULT 40,
    cupos_disp INT NOT NULL DEFAULT 40,
    aula VARCHAR(50) DEFAULT 'Lab 1',
    turno VARCHAR(20) DEFAULT 'Mañana'
);

-- 9. TABLA: HORARIO
CREATE TABLE IF NOT EXISTS public.horario (
    id_horario SERIAL PRIMARY KEY,
    id_seccion INT REFERENCES public.seccion(id_seccion) ON DELETE CASCADE,
    dia_semana VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    tipo_clase VARCHAR(30) DEFAULT 'Teoría'
);

-- 10. TABLA: MATRICULA
CREATE TABLE IF NOT EXISTS public.matricula (
    id_matricula SERIAL PRIMARY KEY,
    id_alumno INT REFERENCES public.alumno(id_alumno) ON DELETE CASCADE,
    id_periodo INT REFERENCES public.periodo_academico(id_periodo) ON DELETE CASCADE,
    fecha_matricula TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    estado_matricula VARCHAR(30) DEFAULT 'Confirmada'
);

-- 11. TABLA: DETALLE DE MATRICULA
CREATE TABLE IF NOT EXISTS public.detalle_matricula (
    id_detalle SERIAL PRIMARY KEY,
    id_matricula INT REFERENCES public.matricula(id_matricula) ON DELETE CASCADE,
    id_seccion INT REFERENCES public.seccion(id_seccion) ON DELETE CASCADE
);

-- 12. TABLA: AUDITORIA
CREATE TABLE IF NOT EXISTS public.auditoria_matricula (
    id_auditoria SERIAL PRIMARY KEY,
    id_matricula INT REFERENCES public.matricula(id_matricula) ON DELETE SET NULL,
    accion VARCHAR(100) NOT NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    ip_usuario VARCHAR(50)
);

-- ====================================================================
-- HABILITACIÓN DE ROW LEVEL SECURITY (RLS) Y POLÍTICAS DE LECTURA PÚBLICA
-- ====================================================================
ALTER TABLE public.escuela ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plan_estudios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.curso ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prerrequisito ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alumno ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profesor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.periodo_academico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seccion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.horario ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matricula ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_matricula ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria_matricula ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura publica escuela" ON public.escuela FOR SELECT USING (true);
CREATE POLICY "Lectura publica plan_estudios" ON public.plan_estudios FOR SELECT USING (true);
CREATE POLICY "Lectura publica curso" ON public.curso FOR SELECT USING (true);
CREATE POLICY "Lectura publica prerrequisito" ON public.prerrequisito FOR SELECT USING (true);
CREATE POLICY "Lectura publica alumno" ON public.alumno FOR SELECT USING (true);
CREATE POLICY "Lectura publica profesor" ON public.profesor FOR SELECT USING (true);
CREATE POLICY "Lectura publica periodo_academico" ON public.periodo_academico FOR SELECT USING (true);
CREATE POLICY "Lectura publica seccion" ON public.seccion FOR SELECT USING (true);
CREATE POLICY "Lectura publica horario" ON public.horario FOR SELECT USING (true);
CREATE POLICY "Lectura publica matricula" ON public.matricula FOR SELECT USING (true);
CREATE POLICY "Lectura publica detalle_matricula" ON public.detalle_matricula FOR SELECT USING (true);
CREATE POLICY "Lectura publica auditoria" ON public.auditoria_matricula FOR SELECT USING (true);

