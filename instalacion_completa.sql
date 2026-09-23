-- ==============================================================================
-- 1. DROP DE LA BASE DE DATOS (BORRA TODO EL ESQUEMA PUBLIC)
-- ==============================================================================
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- ==============================================================================
-- 2. CREACIÓN DE TABLAS
-- ==============================================================================

CREATE TABLE ESCUELA (
    cod_escuela varchar(10) PRIMARY KEY,
    nom_escuela varchar(100) NOT NULL
);

CREATE TABLE PLAN_ESTUDIO (
    cod_plan varchar(10) PRIMARY KEY,
    nombre_plan varchar(100) NOT NULL,
    anio_plan int NOT NULL,
    estado varchar(15) DEFAULT 'ACTIVO',
    cod_escuela varchar(10) NOT NULL REFERENCES ESCUELA(cod_escuela)
);

CREATE TABLE CURSO (
    cod_curso varchar(15) PRIMARY KEY,
    nom_curso varchar(100) NOT NULL,
    creditos int NOT NULL,
    codigo_asignatura varchar(15)
);

CREATE TABLE PLAN_CURSO (
    cod_plan varchar(10) NOT NULL REFERENCES PLAN_ESTUDIO(cod_plan),
    cod_curso varchar(15) NOT NULL REFERENCES CURSO(cod_curso),
    semestre int NOT NULL,
    tipo_curso varchar(20),
    PRIMARY KEY (cod_plan, cod_curso)
);

CREATE TABLE PRERREQUISITO (
    cod_curso varchar(15) NOT NULL REFERENCES CURSO(cod_curso),
    cod_curso_req varchar(15) NOT NULL REFERENCES CURSO(cod_curso),
    PRIMARY KEY (cod_curso, cod_curso_req)
);

CREATE TABLE ALUMNO (
    cod_alumno char(10) PRIMARY KEY,
    dni char(8) UNIQUE NOT NULL,
    nombres varchar(60) NOT NULL,
    apellidos varchar(60) NOT NULL,
    cod_escuela varchar(10) NOT NULL REFERENCES ESCUELA(cod_escuela),
    cod_plan varchar(10) NOT NULL REFERENCES PLAN_ESTUDIO(cod_plan),
    semestre_actual int
);

CREATE TABLE PERIODO_ACADEMICO (
    cod_periodo varchar(6) PRIMARY KEY,
    nombre_periodo varchar(50),
    fecha_inicio date,
    fecha_fin date,
    estado varchar(15) DEFAULT 'ACTIVO'
);

CREATE TABLE HISTORIAL_NOTAS (
    id_historial serial PRIMARY KEY,
    cod_alumno char(10) NOT NULL REFERENCES ALUMNO(cod_alumno),
    cod_curso varchar(15) NOT NULL REFERENCES CURSO(cod_curso),
    cod_periodo varchar(6) NOT NULL REFERENCES PERIODO_ACADEMICO(cod_periodo),
    nota numeric(4,2),
    estado varchar(15) NOT NULL
);

CREATE TABLE PROFESOR (
    cod_profesor varchar(10) PRIMARY KEY,
    nombres varchar(60) NOT NULL,
    apellidos varchar(60) NOT NULL,
    especialidad varchar(100)
);

CREATE TABLE SECCION (
    id_seccion int PRIMARY KEY,
    grupo char(1) NOT NULL,
    cupos_max int NOT NULL,
    cupos_disp int NOT NULL,
    cod_curso varchar(15) NOT NULL REFERENCES CURSO(cod_curso),
    cod_periodo varchar(6) NOT NULL REFERENCES PERIODO_ACADEMICO(cod_periodo),
    cod_profesor varchar(10) REFERENCES PROFESOR(cod_profesor),
    UNIQUE (cod_curso, cod_periodo, grupo)
);

CREATE TABLE HORARIO_CABECERA (
    id_horario serial PRIMARY KEY,
    id_seccion int NOT NULL REFERENCES SECCION(id_seccion),
    cod_periodo varchar(6) NOT NULL REFERENCES PERIODO_ACADEMICO(cod_periodo)
);

CREATE TABLE HORARIO_DETALLE (
    id_detalle serial PRIMARY KEY,
    id_horario int NOT NULL REFERENCES HORARIO_CABECERA(id_horario),
    dia_semana varchar(10) NOT NULL,
    hora_inicio time NOT NULL,
    hora_fin time NOT NULL,
    tipo_clase varchar(20) NOT NULL,
    ambiente varchar(50)
);

CREATE TABLE MATRICULA (
    num_matricula serial PRIMARY KEY,
    fecha_registro timestamp DEFAULT now(),
    cod_alumno char(10) NOT NULL REFERENCES ALUMNO(cod_alumno),
    cod_periodo varchar(6) NOT NULL REFERENCES PERIODO_ACADEMICO(cod_periodo),
    UNIQUE (cod_alumno, cod_periodo)
);

CREATE TABLE DETALLE_MATRICULA (
    num_matricula int NOT NULL REFERENCES MATRICULA(num_matricula),
    id_seccion int NOT NULL REFERENCES SECCION(id_seccion),
    estado_curso varchar(20) DEFAULT 'MATRICULADO',
    PRIMARY KEY (num_matricula, id_seccion)
);

-- ==============================================================================
-- 3. PERMISOS RLS (PARA PODER LEER DESDE LA WEB SIN LOGIN)
-- ==============================================================================
ALTER TABLE ESCUELA ENABLE ROW LEVEL SECURITY;
ALTER TABLE PLAN_ESTUDIO ENABLE ROW LEVEL SECURITY;
ALTER TABLE CURSO ENABLE ROW LEVEL SECURITY;
ALTER TABLE PLAN_CURSO ENABLE ROW LEVEL SECURITY;
ALTER TABLE PRERREQUISITO ENABLE ROW LEVEL SECURITY;
ALTER TABLE ALUMNO ENABLE ROW LEVEL SECURITY;
ALTER TABLE PERIODO_ACADEMICO ENABLE ROW LEVEL SECURITY;
ALTER TABLE HISTORIAL_NOTAS ENABLE ROW LEVEL SECURITY;
ALTER TABLE PROFESOR ENABLE ROW LEVEL SECURITY;
ALTER TABLE SECCION ENABLE ROW LEVEL SECURITY;
ALTER TABLE HORARIO_CABECERA ENABLE ROW LEVEL SECURITY;
ALTER TABLE HORARIO_DETALLE ENABLE ROW LEVEL SECURITY;
ALTER TABLE MATRICULA ENABLE ROW LEVEL SECURITY;
ALTER TABLE DETALLE_MATRICULA ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable ALL for anon users" ON ESCUELA FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON PLAN_ESTUDIO FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON CURSO FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON PLAN_CURSO FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON PRERREQUISITO FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON ALUMNO FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON PERIODO_ACADEMICO FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON HISTORIAL_NOTAS FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON PROFESOR FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON SECCION FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON HORARIO_CABECERA FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON HORARIO_DETALLE FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON MATRICULA FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anon users" ON DETALLE_MATRICULA FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- 4. INSERCIÓN DE DATOS ESTRUCTURALES BASE (OBLIGATORIO)
-- ==============================================================================

-- Escuela y Plan
INSERT INTO ESCUELA (cod_escuela, nom_escuela) VALUES ('FIIS', 'Ingenieria de Sistemas');
INSERT INTO PLAN_ESTUDIO (cod_plan, nombre_plan, anio_plan, cod_escuela) VALUES ('PLAN2019', 'Plan 2019 FIIS', 2019, 'FIIS');
INSERT INTO PLAN_ESTUDIO (cod_plan, nombre_plan, anio_plan, cod_escuela) VALUES ('PLAN2010', 'Plan 2010 FIIS', 2010, 'FIIS');

-- Periodo
INSERT INTO PERIODO_ACADEMICO (cod_periodo, nombre_periodo, fecha_inicio, fecha_fin) VALUES ('2026-1', 'Periodo Academico 2026-I', '2026-03-01', '2026-07-15');
INSERT INTO PERIODO_ACADEMICO (cod_periodo, nombre_periodo, fecha_inicio, fecha_fin) VALUES ('2026-2', 'Periodo Academico 2026-II', '2026-08-01', '2026-12-15');
INSERT INTO PERIODO_ACADEMICO (cod_periodo, nombre_periodo, fecha_inicio, fecha_fin, estado) VALUES ('2025-2', 'Periodo Academico 2025-II', '2025-08-01', '2025-12-15', 'INACTIVO');


BEGIN;

-- =========================================================
-- 1. PROFESORES NUEVOS Y EXISTENTES
-- =========================================================
INSERT INTO profesor (cod_profesor, nombres, apellidos, especialidad)
VALUES
('PROF001', 'Carmen', 'Salazar Deza', 'Ingles'),
('PROF002', 'Cesar Gerardo', 'Leon Velarde', 'Lenguaje y Comunicacin'),
('PROF003', 'Oscar Hugo', 'Mujica Ruiz', 'Metodologa'),
('PROF004', 'Jorge Alberto', 'Vales Carrillo', 'Matematica'),
('PROF005', 'Jorge Victor', 'Mayhuasca Guerra', 'Ingeniera de Sistemas'),
('PROF006', 'Noemi', 'Ramirez Saavedra', 'Estadstica'),
('PROF007', 'Heddy', 'Colca Garcia', 'Sistemas'),
('PROF008', 'Pablo R.', 'Aparicio Montenegro', 'Estadstica y Programacin'),
('PROF009', 'Manuel', 'Narro Andrade', 'Sistemas'),
('PROF010', 'Armando Ricardo', 'Huapaya Sotero', 'Programacin'),
('PROF011', 'Jose Orlando', 'Alvarado Alvarado', 'Ingeniera de Sistemas'),
('PROF012', 'Julio', 'Sotomayor Abarca', 'Sistemas'),
('PROF013', 'Jorge', 'Lira Camargo', 'Sistemas'),
('PROF014', 'Efren S.', 'Michue Salguedo', 'Sistemas'),
('PROF015', 'Juan Oswaldo', 'Alfaro Bernedo', 'Sistemas'),
('PROF016', 'Ivan Carlo', 'Petrlik Azabache', 'Programacin'),
('PROF017', 'Luis', 'Soto Soto', 'Bases de Datos'),
('PROF018', 'Luis Avelino', 'Muoz Ramos', 'Procesos de Negocios'),
('PROF019', 'Hernan O.', 'Villafuerte Barreto', 'Redes'),
('PROF020', 'Adolfo O.', 'Acevedo Borrego', 'Sistemas'),
('PROF021', 'Jose Antonio', 'Ogosi Auqui', 'Sistemas'),
('PROF022', 'Karin', 'Rojas Romero', 'Sistemas'),
('PROF023', 'Daniel A.', 'Yucra Sotomayor', 'Bases de Datos'),
('PROF024', 'Pedro Martin', 'Lezama Gonzales', 'Sistemas'),
('PROF025', 'Wilfredo E.', 'Carranza Barrena', 'Sistemas'),
('PROF026', 'Martin Sabino', 'Gavino Ramos', 'Bases de Datos'),
('PROF027', 'Santos Ciriaco', 'Sotelo Antaurco', 'Redes'),
('PROF028', 'Bertha Beatriz', 'Lopez Juarez', 'Sistemas'),
('PROF029', 'Orestes', 'Cachay Boza', 'Investigacin'),
('PROF030', 'Rogelio G.', 'Cohello Aguirre', 'Programacin'),
('PROF031', 'Carlos Miguel', 'Franco Del Carpio', 'Sistemas'),
('PROF032', 'Karen', 'Rojas Romero', 'Sistemas'),
('PROF033', 'Julio', 'Sotomayor Abarca', 'Sistemas'),
('PROF034', 'Jaime Demetrio', 'Cano Espada', 'Matematica'),
('PROF035', 'Lucio', 'Jara Bautista', 'Ingeniera Industrial'),
('PROF036', 'Heriberto Reginaldo', 'Magallanes Villaverde', 'Fsica'),
('PROF037', 'Fernando', 'Hernandez Conde', 'Ingeniera Industrial')
ON CONFLICT (cod_profesor) DO NOTHING;

-- =========================================================
-- 2. MALLA 2010 (CURSOS E INSERCI"N A PLAN)
-- =========================================================
INSERT INTO curso (cod_curso, nom_curso, creditos, codigo_asignatura) VALUES
('P10-001', 'L"GICA Y ALGORITMOS', 3, '2A0125'),
('P10-002', 'ALGEBRA LINEAL', 2, '3B0058'),
('P10-003', 'COMPUTACI"N E INFORM?TICA BASICA', 4, '5A0060'),
('P10-004', 'LENGUAJE Y REDACCI"N', 4, '2C0187'),
('P10-005', 'METODOLOG?A DE LA INVESTIGACI"N', 3, '6C0037'),
('P10-006', 'INTRODUCCION A LA INGENIERIA DE SISTEMAS', 2, '8B0116'),
('P10-007', 'MATEM?TICA BASICA', 5, '3B0103'),
('P10-008', 'FISICA', 4, '3A0014'),
('P10-009', 'ECONOMIA', 3, '7C0080'),
('P10-010', 'CALCULO DIFERENCIAL E INTEGRAL', 5, '3B0165'),
('P10-011', 'ALGORITMOS Y ESTRUCTURA DE DATOS', 4, '8B0109'),
('P10-012', 'CONTABILIDAD GENERAL', 3, '7B0192'),
('P10-013', 'ADMINISTRACION DE NEGOCIOS', 3, '7A0472'),
('P10-014', 'ELECTROMAGNETISMO Y ONDAS', 4, '8F0123'),
('P10-015', 'ESTADISTICA Y PROBABILIDADES', 4, '5B0110'),
('P10-016', 'ECUACIONES DIFERENCIALES', 4, '3B0166'),
('P10-017', 'LENGUAJE DE PROGRAMACION ESTRUCTURADO', 4, '8E0035'),
('P10-018', 'TEORIA DE SISTEMAS', 3, '8B0073'),
('P10-019', 'PROGRAMACION LINEAL', 3, '8E0039'),
('P10-020', 'SISTEMAS DIGITALES', 4, '8F0127'),
('P10-021', 'ESTADISTICA INFERENCIAL', 4, '5B0021'),
('P10-022', 'MATEMATICAS DISCRETAS', 4, '3B0170'),
('P10-023', 'LENGUAJE DE PROGRAMACION ORIENTADO A OBJETOS', 4, '8E0036'),
('P10-024', 'INVESTIGACION OPERATIVA', 3, '6C0006'),
('P10-025', 'COSTOS Y PRESUPUESTOS', 3, '7B0184'),
('P10-026', 'FUNDAMENTOS DE BASE DE DATOS', 4, '5A0063'),
('P10-027', 'LENGUAJE DE PROGRAMACION ORIENTADO A WEB', 3, '8E0037'),
('P10-028', 'SISTEMAS OPERATIVOS', 4, '8E0003'),
('P10-029', 'INGENIERIA DE PROCESOS DE NEGOCIOS', 4, '7B0197'),
('P10-030', 'ARQUITECTURA DEL COMPUTADOR', 3, '5A0015'),
('P10-031', 'ANALISIS Y DISENO DE SISTEMAS DE INFORMACION', 4, '8B0110'),
('P10-032', 'FUNDAMENTOS DE COMUNICACIONES', 4, '2H0033'),
('P10-033', 'INGENIERIA ECONOMICA', 3, '7C0081'),
('P10-034', 'SISTEMAS DE BASE DE DATOS', 4, '8B0068'),
('P10-035', 'FILOSOFIA Y ETICA', 4, '2A0124'),
('P10-036', 'SISTEMAS DE GESTION DEL POTENCIAL HUMANO', 3, '2D0109'),
('P10-037', 'INGENIERIA DE SOFTWARE I', 4, '8B0059'),
('P10-038', 'ARQUITECTURA Y CONECTIVIDAD DE REDES', 3, '8B0111'),
('P10-039', 'MARKETING EMPRESARIAL', 3, '7A0480'),
('P10-040', 'DINAMICA DE SISTEMAS', 3, '8B0085'),
('P10-041', 'ADMINISTRACION FINANCIERA', 3, '7A0013'),
('P10-042', 'INGENIERIA DE SOFTWARE II', 3, '8B0114'),
('P10-043', 'TALLER DE BASE DE DATOS', 4, '8B0071'),
('P10-044', 'GEOPOLITICA Y DEFENSA NACIONAL', 3, '2I0230'),
('P10-045', 'ADMINISTRACION DE REDES', 4, '8B0108'),
('P10-046', 'DERECHO INFORMATICO Y EMPRESARIAL', 3, '2I0229'),
('P10-047', 'TALLER DE INTEGRACION DE SISTEMAS', 4, '8B0072'),
('P10-048', 'PLANEAMIENTO ESTRATEGICO DE NEGOCIOS', 4, '7A0482'),
('P10-049', 'SIMULACION DE SISTEMAS', 3, '8B0067'),
('P10-050', 'NEGOCIOS ELECTRONICOS', 4, '8F0126'),
('P10-051', 'PRACTICAS PRE PROFESIONALES I', 6, 'GA0062'),
('P10-052', 'LIDERAZGO Y CREATIVIDAD EMPRESARIAL', 3, '7A0477'),
('P10-053', 'FORMULACION Y VALUACION DE PROYECTOS INFORMATICOS', 4, '5A0062'),
('P10-054', 'TOPICOS ESPECIALES EN INGENIERIA DE SISTEMAS I', 3, '8B0074'),
('P10-055', 'INTELIGENCIA ARTIFICIAL', 4, '8F0124'),
('P10-056', 'SEGURIDAD EN REDES Y SISTEMAS DE INFORMACION', 3, '8B0118'),
('P10-057', 'PRACTICAS PRE PROFESIONALES II', 6, 'GA0063'),
('P10-058', 'SEMINARIO DE TESIS', 2, 'HC0107'),
('P10-059', 'GESTION DEL CONOCIMIENTO', 3, 'BA0328'),
('P10-060', 'GERENCIA DE PROYECTOS DE TECNOLOGIA DE INFORMACION Y COMUNICACIONES', 4, '8B0112'),
('P10-061', 'TOPICOS ESPECIALES EN INGENIERIA DE SISTEMAS II', 4, '8B0121'),
('P10-062', 'AUDITORIA DE SISTEMAS', 4, '8B0003')
ON CONFLICT (cod_curso) DO NOTHING;

INSERT INTO plan_curso (cod_plan, cod_curso, semestre, tipo_curso) VALUES
('PLAN2010', 'P10-001', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-002', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-003', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-004', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-005', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-006', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-007', 1, 'OBLIGATORIO'),
('PLAN2010', 'P10-008', 2, 'OBLIGATORIO'),
('PLAN2010', 'P10-009', 2, 'OBLIGATORIO'),
('PLAN2010', 'P10-010', 2, 'OBLIGATORIO'),
('PLAN2010', 'P10-011', 2, 'OBLIGATORIO'),
('PLAN2010', 'P10-012', 2, 'OBLIGATORIO'),
('PLAN2010', 'P10-013', 2, 'OBLIGATORIO'),
('PLAN2010', 'P10-014', 3, 'OBLIGATORIO'),
('PLAN2010', 'P10-015', 3, 'OBLIGATORIO'),
('PLAN2010', 'P10-016', 3, 'OBLIGATORIO'),
('PLAN2010', 'P10-017', 3, 'OBLIGATORIO'),
('PLAN2010', 'P10-018', 3, 'OBLIGATORIO'),
('PLAN2010', 'P10-019', 3, 'OBLIGATORIO'),
('PLAN2010', 'P10-020', 4, 'OBLIGATORIO'),
('PLAN2010', 'P10-021', 4, 'OBLIGATORIO'),
('PLAN2010', 'P10-022', 4, 'OBLIGATORIO'),
('PLAN2010', 'P10-023', 4, 'OBLIGATORIO'),
('PLAN2010', 'P10-024', 4, 'OBLIGATORIO'),
('PLAN2010', 'P10-025', 4, 'OBLIGATORIO'),
('PLAN2010', 'P10-026', 5, 'OBLIGATORIO'),
('PLAN2010', 'P10-027', 5, 'OBLIGATORIO'),
('PLAN2010', 'P10-028', 5, 'OBLIGATORIO'),
('PLAN2010', 'P10-029', 5, 'OBLIGATORIO'),
('PLAN2010', 'P10-030', 5, 'OBLIGATORIO'),
('PLAN2010', 'P10-031', 5, 'OBLIGATORIO'),
('PLAN2010', 'P10-032', 6, 'OBLIGATORIO'),
('PLAN2010', 'P10-033', 6, 'OBLIGATORIO'),
('PLAN2010', 'P10-034', 6, 'OBLIGATORIO'),
('PLAN2010', 'P10-035', 6, 'OBLIGATORIO'),
('PLAN2010', 'P10-036', 6, 'OBLIGATORIO'),
('PLAN2010', 'P10-037', 6, 'OBLIGATORIO'),
('PLAN2010', 'P10-038', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-039', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-040', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-041', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-042', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-043', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-044', 7, 'OBLIGATORIO'),
('PLAN2010', 'P10-045', 8, 'OBLIGATORIO'),
('PLAN2010', 'P10-046', 8, 'OBLIGATORIO'),
('PLAN2010', 'P10-047', 8, 'OBLIGATORIO'),
('PLAN2010', 'P10-048', 8, 'OBLIGATORIO'),
('PLAN2010', 'P10-049', 8, 'OBLIGATORIO'),
('PLAN2010', 'P10-050', 8, 'OBLIGATORIO'),
('PLAN2010', 'P10-051', 9, 'OBLIGATORIO'),
('PLAN2010', 'P10-052', 9, 'OBLIGATORIO'),
('PLAN2010', 'P10-053', 9, 'OBLIGATORIO'),
('PLAN2010', 'P10-054', 9, 'OBLIGATORIO'),
('PLAN2010', 'P10-055', 9, 'OBLIGATORIO'),
('PLAN2010', 'P10-056', 9, 'OBLIGATORIO'),
('PLAN2010', 'P10-057', 10, 'OBLIGATORIO'),
('PLAN2010', 'P10-058', 10, 'OBLIGATORIO'),
('PLAN2010', 'P10-059', 10, 'OBLIGATORIO'),
('PLAN2010', 'P10-060', 10, 'OBLIGATORIO'),
('PLAN2010', 'P10-061', 10, 'OBLIGATORIO'),
('PLAN2010', 'P10-062', 10, 'OBLIGATORIO')
ON CONFLICT DO NOTHING;


-- 5. SECCIONES - 2026-1 (CICLOS I, III, V, VII, IX)
-- =========================================================
INSERT INTO seccion (id_seccion, grupo, cupos_max, cupos_disp, cod_curso, cod_periodo, cod_profesor) VALUES
-- I CICLO
(1, 'A', 35, 35, '1', '2026-1', 'PROF001'),
(2, 'B', 35, 35, '1', '2026-1', 'PROF001'),
(3, 'C', 35, 35, '1', '2026-1', 'PROF001'),
(4, 'A', 35, 35, '2', '2026-1', 'PROF002'),
(5, 'B', 35, 35, '2', '2026-1', 'PROF001'),
(6, 'C', 35, 35, '2', '2026-1', 'PROF006'),
(7, 'A', 35, 35, '3', '2026-1', 'PROF002'), 
(8, 'B', 35, 35, '3', '2026-1', 'PROF004'),
(9, 'C', 35, 35, '3', '2026-1', 'PROF009'),
(10, 'A', 35, 35, '4', '2026-1', 'PROF034'), 
(11, 'B', 35, 35, '4', '2026-1', 'PROF034'),
(12, 'C', 35, 35, '4', '2026-1', 'PROF034'),
(13, 'A', 35, 35, '5', '2026-1', 'PROF003'),
(14, 'B', 35, 35, '5', '2026-1', 'PROF002'),
(15, 'C', 35, 35, '5', '2026-1', 'PROF010'),
(16, 'A', 35, 35, '6', '2026-1', 'PROF003'), 
(17, 'B', 35, 35, '6', '2026-1', 'PROF003'),
(18, 'C', 35, 35, '6', '2026-1', 'PROF003'),
(19, 'A', 35, 35, '7', '2026-1', 'PROF037'), 
(20, 'B', 35, 35, '7', '2026-1', 'PROF037'),
(21, 'C', 35, 35, '7', '2026-1', 'PROF037'),
(22, 'A', 35, 35, '8', '2026-1', 'PROF005'),
(23, 'B', 35, 35, '8', '2026-1', 'PROF003'),
(24, 'C', 35, 35, '8', '2026-1', 'PROF011'),

-- III CICLO
(25, 'A', 35, 35, '17', '2026-1', 'PROF001'),
(26, 'B', 35, 35, '17', '2026-1', 'PROF001'),
(27, 'C', 35, 35, '17', '2026-1', 'PROF001'),
(28, 'A', 35, 35, '18', '2026-1', 'PROF007'),
(29, 'B', 35, 35, '18', '2026-1', 'PROF012'),
(30, 'C', 35, 35, '18', '2026-1', 'PROF002'),
(31, 'A', 35, 35, '19', '2026-1', 'PROF006'),
(32, 'B', 35, 35, '19', '2026-1', 'PROF008'),
(33, 'C', 35, 35, '19', '2026-1', 'PROF014'),
(34, 'A', 35, 35, '20', '2026-1', 'PROF006'),
(35, 'B', 35, 35, '20', '2026-1', 'PROF035'), 
(36, 'C', 35, 35, '20', '2026-1', 'PROF030'), 
(37, 'A', 35, 35, '21', '2026-1', 'PROF003'),
(38, 'B', 35, 35, '21', '2026-1', 'PROF013'),
(39, 'C', 35, 35, '21', '2026-1', 'PROF015'),
(40, 'A', 35, 35, '22', '2026-1', 'PROF036'), 
(41, 'B', 35, 35, '22', '2026-1', 'PROF036'),
(42, 'C', 35, 35, '22', '2026-1', 'PROF036'),
(43, 'A', 35, 35, '23', '2026-1', 'PROF034'), 
(44, 'B', 35, 35, '23', '2026-1', 'PROF034'),
(45, 'C', 35, 35, '23', '2026-1', 'PROF034'),
(46, 'A', 35, 35, '24', '2026-1', 'PROF010'),
(47, 'B', 35, 35, '24', '2026-1', 'PROF008'),
(48, 'C', 35, 35, '24', '2026-1', 'PROF016'),

-- V CICLO
(49, 'A', 35, 35, '31', '2026-1', 'PROF010'),
(50, 'B', 35, 35, '31', '2026-1', 'PROF016'),
(51, 'C', 35, 35, '31', '2026-1', 'PROF022'),
(52, 'A', 35, 35, '32', '2026-1', 'PROF011'),
(53, 'B', 35, 35, '32', '2026-1', 'PROF035'), 
(54, 'C', 35, 35, '32', '2026-1', 'PROF012'),
(55, 'A', 35, 35, '33', '2026-1', 'PROF017'),
(56, 'B', 35, 35, '33', '2026-1', 'PROF031'),
(57, 'C', 35, 35, '33', '2026-1', 'PROF004'),
(58, 'A', 35, 35, '34', '2026-1', 'PROF018'),
(59, 'B', 35, 35, '34', '2026-1', 'PROF011'),
(60, 'C', 35, 35, '34', '2026-1', 'PROF020'),
(61, 'A', 35, 35, '35', '2026-1', 'PROF007'),
(62, 'B', 35, 35, '35', '2026-1', 'PROF019'), 
(63, 'C', 35, 35, '35', '2026-1', 'PROF019'),
(64, 'A', 35, 35, '36', '2026-1', 'PROF016'),
(65, 'B', 35, 35, '36', '2026-1', 'PROF011'), 
(66, 'C', 35, 35, '36', '2026-1', 'PROF012'),
(67, 'A', 35, 35, '37', '2026-1', 'PROF004'),
(68, 'B', 35, 35, '37', '2026-1', 'PROF021'),
(69, 'C', 35, 35, '37', '2026-1', 'PROF009'), 

-- VII CICLO
(70, 'A', 35, 35, '46', '2026-1', 'PROF021'),
(71, 'B', 35, 35, '46', '2026-1', 'PROF023'),
(72, 'C', 35, 35, '46', '2026-1', 'PROF023'),
(73, 'A', 35, 35, '47', '2026-1', 'PROF029'), 
(74, 'B', 35, 35, '47', '2026-1', 'PROF030'),
(75, 'C', 35, 35, '47', '2026-1', 'PROF022'),
(76, 'A', 35, 35, '48', '2026-1', 'PROF026'),
(77, 'B', 35, 35, '48', '2026-1', 'PROF019'),
(78, 'C', 35, 35, '48', '2026-1', 'PROF031'),
(79, 'A', 35, 35, '49', '2026-1', 'PROF031'),
(80, 'B', 35, 35, '49', '2026-1', 'PROF020'),
(81, 'C', 35, 35, '49', '2026-1', 'PROF030'),
(82, 'A', 35, 35, '50', '2026-1', 'PROF027'),
(83, 'B', 35, 35, '50', '2026-1', 'PROF009'),
(84, 'C', 35, 35, '50', '2026-1', 'PROF022'),
(85, 'A', 35, 35, '51', '2026-1', 'PROF027'),
(86, 'B', 35, 35, '51', '2026-1', 'PROF025'),
(87, 'C', 35, 35, '51', '2026-1', 'PROF021'), 
(88, 'A', 35, 35, '52', '2026-1', 'PROF025'),
(89, 'B', 35, 35, '52', '2026-1', 'PROF013'),
(90, 'C', 35, 35, '52', '2026-1', 'PROF009'),

-- IX CICLO
(91, 'A', 35, 35, '60', '2026-1', 'PROF029'),
(92, 'B', 35, 35, '60', '2026-1', 'PROF030'),
(93, 'C', 35, 35, '60', '2026-1', 'PROF028'),
(94, 'A', 35, 35, '61', '2026-1', 'PROF024'),
(95, 'B', 35, 35, '61', '2026-1', 'PROF008'),
(96, 'C', 35, 35, '61', '2026-1', 'PROF025'),
(97, 'A', 35, 35, '62', '2026-1', 'PROF024'),
(98, 'B', 35, 35, '62', '2026-1', 'PROF027'),
(99, 'C', 35, 35, '62', '2026-1', 'PROF007'),
(100, 'A', 35, 35, '63', '2026-1', 'PROF025'),
(101, 'B', 35, 35, '63', '2026-1', 'PROF030'),
(102, 'C', 35, 35, '63', '2026-1', 'PROF007'),
(103, 'A', 35, 35, '64', '2026-1', 'PROF026'),
(104, 'B', 35, 35, '64', '2026-1', 'PROF019'),
(105, 'C', 35, 35, '64', '2026-1', 'PROF030'),
(106, 'A', 35, 35, '65', '2026-1', 'PROF028'),
(107, 'B', 35, 35, '65', '2026-1', 'PROF015'),
(108, 'C', 35, 35, '65', '2026-1', 'PROF029')
ON CONFLICT DO NOTHING;

-- =========================================================
-- 6. SECCIONES - 2026-2 (CICLOS II, IV, VIII, X)
-- =========================================================
INSERT INTO seccion (id_seccion, grupo, cupos_max, cupos_disp, cod_curso, cod_periodo, cod_profesor) VALUES
-- II CICLO
(109,'A',35,35,'9','2026-2','PROF001'),
(110,'B',35,35,'9','2026-2','PROF001'),
(111,'C',35,35,'9','2026-2','PROF001'),
(112,'A',35,35,'10','2026-2','PROF003'),
(113,'B',35,35,'10','2026-2','PROF002'),
(114,'C',35,35,'10','2026-2','PROF033'),
(115,'A',35,35,'11','2026-2','PROF004'),
(116,'B',35,35,'11','2026-2','PROF003'),
(117,'C',35,35,'11','2026-2','PROF002'),
(118,'A',35,35,'12','2026-2','PROF016'),
(119,'B',35,35,'12','2026-2','PROF007'),
(120,'C',35,35,'12','2026-2','PROF009'),
(121,'A',35,35,'13','2026-2','PROF002'),
(122,'B',35,35,'13','2026-2','PROF001'),
(123,'C',35,35,'13','2026-2','PROF004'),
(124,'A',35,35,'14','2026-2','PROF003'),
(125,'B',35,35,'14','2026-2','PROF005'),
(126,'C',35,35,'14','2026-2','PROF015'),
(127,'A',35,35,'15','2026-2','PROF034'),
(128,'B',35,35,'15','2026-2','PROF034'),
(129,'C',35,35,'15','2026-2','PROF034'),
(130,'A',35,35,'16','2026-2','PROF016'),
(131,'B',35,35,'16','2026-2','PROF007'),
(132,'C',35,35,'16','2026-2','PROF010'),

-- IV CICLO
(133,'A',35,35,'25','2026-2','PROF010'),
(134,'B',35,35,'25','2026-2','PROF008'),
(135,'C',35,35,'25','2026-2','PROF016'),
(136,'A',35,35,'26','2026-2','PROF011'),
(137,'B',35,35,'26','2026-2','PROF035'),
(138,'C',35,35,'26','2026-2','PROF035'),
(139,'A',35,35,'27','2026-2','PROF006'),
(140,'B',35,35,'27','2026-2','PROF006'),
(141,'C',35,35,'27','2026-2','PROF014'),
(142,'A',35,35,'28','2026-2','PROF011'),
(143,'B',35,35,'28','2026-2','PROF007'),
(144,'C',35,35,'28','2026-2','PROF008'),
(145,'A',35,35,'29','2026-2','PROF036'),
(146,'B',35,35,'29','2026-2','PROF036'),
(147,'C',35,35,'29','2026-2','PROF036'),
(148,'A',35,35,'30','2026-2','PROF034'),
(149,'B',35,35,'30','2026-2','PROF034'),
(150,'C',35,35,'30','2026-2','PROF034'),

-- VIII CICLO
(151,'A',35,35,'54','2026-2','PROF029'),
(152,'B',35,35,'54','2026-2','PROF029'),
(153,'C',35,35,'54','2026-2','PROF020'),
(154,'A',35,35,'55','2026-2','PROF023'),
(155,'B',35,35,'55','2026-2','PROF024'),
(156,'C',35,35,'55','2026-2','PROF031'),
(157,'A',35,35,'56','2026-2','PROF019'),
(158,'B',35,35,'56','2026-2','PROF019'),
(159,'C',35,35,'56','2026-2','PROF025'),
(160,'A',35,35,'57','2026-2','PROF031'),
(161,'B',35,35,'57','2026-2','PROF024'),
(162,'C',35,35,'57','2026-2','PROF026'),
(163,'A',35,35,'58','2026-2','PROF019'),
(164,'B',35,35,'58','2026-2','PROF009'),
(165,'C',35,35,'58','2026-2','PROF027'),
(166,'A',35,35,'59','2026-2','PROF008'),
(167,'B',35,35,'59','2026-2','PROF027'),
(168,'C',35,35,'59','2026-2','PROF009'),

-- X CICLO
(169,'A',35,35,'66','2026-2','PROF027'),
(170,'B',35,35,'66','2026-2','PROF025'),
(171,'C',35,35,'66','2026-2','PROF030'),
(172,'A',35,35,'67','2026-2','PROF023'),
(173,'B',35,35,'67','2026-2','PROF030'),
(174,'C',35,35,'67','2026-2','PROF026'),
(175,'A',35,35,'68','2026-2','PROF013'),
(176,'B',35,35,'68','2026-2','PROF025'),
(177,'C',35,35,'68','2026-2','PROF020'),
(178,'A',35,35,'69','2026-2','PROF019'),
(179,'B',35,35,'69','2026-2','PROF007'),
(180,'C',35,35,'69','2026-2','PROF013'),
(181,'A',35,35,'70','2026-2','PROF029'),
(182,'B',35,35,'70','2026-2','PROF015'),
(183,'C',35,35,'70','2026-2','PROF026')
ON CONFLICT DO NOTHING;

-- =========================================================
-- 7. HORARIOS CABECERA (AMBOS PERIODOS)
-- =========================================================
INSERT INTO horario_cabecera (id_horario, id_seccion, cod_periodo) VALUES
-- 2026-1
(25,25,'2026-1'),(26,26,'2026-1'),(27,27,'2026-1'),(28,28,'2026-1'),(29,29,'2026-1'),
(30,30,'2026-1'),(31,31,'2026-1'),(32,32,'2026-1'),(33,33,'2026-1'),(34,34,'2026-1'),
(35,35,'2026-1'),(36,36,'2026-1'),(37,37,'2026-1'),(38,38,'2026-1'),(39,39,'2026-1'),
(40,40,'2026-1'),(41,41,'2026-1'),(42,42,'2026-1'),(43,43,'2026-1'),(44,44,'2026-1'),
(45,45,'2026-1'),(46,46,'2026-1'),(47,47,'2026-1'),(48,48,'2026-1'),(49,49,'2026-1'),
(50,50,'2026-1'),(51,51,'2026-1'),(52,52,'2026-1'),(53,53,'2026-1'),(54,54,'2026-1'),
(55,55,'2026-1'),(56,56,'2026-1'),(57,57,'2026-1'),(58,58,'2026-1'),(59,59,'2026-1'),
(60,60,'2026-1'),(61,61,'2026-1'),(62,62,'2026-1'),(63,63,'2026-1'),(64,64,'2026-1'),
(65,65,'2026-1'),(66,66,'2026-1'),(67,67,'2026-1'),(68,68,'2026-1'),(69,69,'2026-1'),
(70,70,'2026-1'),(71,71,'2026-1'),(72,72,'2026-1'),(73,73,'2026-1'),(74,74,'2026-1'),
(75,75,'2026-1'),(76,76,'2026-1'),(77,77,'2026-1'),(78,78,'2026-1'),(79,79,'2026-1'),
(80,80,'2026-1'),(81,81,'2026-1'),(82,82,'2026-1'),(83,83,'2026-1'),(84,84,'2026-1'),
(85,85,'2026-1'),(86,86,'2026-1'),(87,87,'2026-1'),(88,88,'2026-1'),(89,89,'2026-1'),
(90,90,'2026-1'),(91,91,'2026-1'),(92,92,'2026-1'),(93,93,'2026-1'),(94,94,'2026-1'),
(95,95,'2026-1'),(96,96,'2026-1'),(97,97,'2026-1'),(98,98,'2026-1'),(99,99,'2026-1'),
(100,100,'2026-1'),(101,101,'2026-1'),(102,102,'2026-1'),(103,103,'2026-1'),(104,104,'2026-1'),
(105,105,'2026-1'),(106,106,'2026-1'),(107,107,'2026-1'),(108,108,'2026-1'),

-- 2026-2
(109,109,'2026-2'),(110,110,'2026-2'),(111,111,'2026-2'),(112,112,'2026-2'),(113,113,'2026-2'),
(114,114,'2026-2'),(115,115,'2026-2'),(116,116,'2026-2'),(117,117,'2026-2'),(118,118,'2026-2'),
(119,119,'2026-2'),(120,120,'2026-2'),(121,121,'2026-2'),(122,122,'2026-2'),(123,123,'2026-2'),
(124,124,'2026-2'),(125,125,'2026-2'),(126,126,'2026-2'),(127,127,'2026-2'),(128,128,'2026-2'),
(129,129,'2026-2'),(130,130,'2026-2'),(131,131,'2026-2'),(132,132,'2026-2'),
(133,133,'2026-2'),(134,134,'2026-2'),(135,135,'2026-2'),(136,136,'2026-2'),(137,137,'2026-2'),
(138,138,'2026-2'),(139,139,'2026-2'),(140,140,'2026-2'),(141,141,'2026-2'),(142,142,'2026-2'),
(143,143,'2026-2'),(144,144,'2026-2'),(145,145,'2026-2'),(146,146,'2026-2'),(147,147,'2026-2'),
(148,148,'2026-2'),(149,149,'2026-2'),(150,150,'2026-2'),
(151,151,'2026-2'),(152,152,'2026-2'),(153,153,'2026-2'),(154,154,'2026-2'),(155,155,'2026-2'),
(156,156,'2026-2'),(157,157,'2026-2'),(158,158,'2026-2'),(159,159,'2026-2'),(160,160,'2026-2'),
(161,161,'2026-2'),(162,162,'2026-2'),(163,163,'2026-2'),(164,164,'2026-2'),(165,165,'2026-2'),
(166,166,'2026-2'),(167,167,'2026-2'),(168,168,'2026-2'),
(169,169,'2026-2'),(170,170,'2026-2'),(171,171,'2026-2'),(172,172,'2026-2'),(173,173,'2026-2'),
(174,174,'2026-2'),(175,175,'2026-2'),(176,176,'2026-2'),(177,177,'2026-2'),(178,178,'2026-2'),
(179,179,'2026-2'),(180,180,'2026-2'),(181,181,'2026-2'),(182,182,'2026-2'),(183,183,'2026-2')
ON CONFLICT DO NOTHING;

-- =========================================================
-- 8. HORARIOS DETALLE (AMBOS PERIODOS)
-- =========================================================
INSERT INTO horario_detalle (id_horario, dia_semana, hora_inicio, hora_fin, tipo_clase, ambiente) VALUES
-- ================== 2026-1 ==================
-- Ingles III
(25,'MARTES','09:40:00','11:20:00','PRACTICA','LAB 1'),
(26,'JUEVES','12:10:00','13:50:00','PRACTICA','LAB 1'),
(27,'MARTES','14:40:00','16:20:00','PRACTICA','LAB 1'),

-- Psicologa Organizacional
(28,'JUEVES','08:50:00','11:20:00','TEORIA','D-203'),
(29,'LUNES','07:10:00','09:40:00','TEORIA','D-204'),
(30,'LUNES','13:00:00','15:30:00','TEORIA','D-308'),

-- Estadstica
(31,'LUNES','09:40:00','11:20:00','TEORIA','LAB 2'),
(31,'MARTES','11:20:00','13:00:00','TEORIA','LAB 2'),
(32,'LUNES','11:20:00','13:00:00','TEORIA','LAB 2'),
(32,'MIERCOLES','09:40:00','11:20:00','TEORIA','LAB 2'),
(33,'MARTES','14:40:00','16:20:00','TEORIA','LAB 2'),
(33,'MIERCOLES','15:30:00','17:10:00','TEORIA','LAB 2'),

-- Geopoltica y Realidad Nacional
(34,'MARTES','11:20:00','13:00:00','TEORIA','D-203'),
(34,'MIERCOLES','11:20:00','13:00:00','TEORIA','D-203'),
(35,'MARTES','11:20:00','13:00:00','TEORIA','D-204'),
(35,'MIERCOLES','11:20:00','13:00:00','TEORIA','D-204'),
(36,'MARTES','16:20:00','18:00:00','TEORIA','D-308'),
(36,'MIERCOLES','16:20:00','18:00:00','TEORIA','D-308'),

-- Metodologa de la Investigacin Cientfica
(37,'LUNES','09:40:00','11:20:00','TEORIA','D-203'),
(37,'MIERCOLES','09:40:00','11:20:00','TEORIA','D-203'),
(38,'LUNES','08:00:00','09:40:00','TEORIA','D-204'),
(38,'MIERCOLES','08:00:00','09:40:00','TEORIA','D-204'),
(39,'MARTES','14:40:00','16:20:00','TEORIA','D-308'),
(39,'MIERCOLES','14:40:00','16:20:00','TEORIA','D-308'),

-- Fsica
(40,'LUNES','08:00:00','09:40:00','PRACTICA','LAB FISICA'),
(40,'MIERCOLES','08:00:00','09:40:00','PRACTICA','LAB FISICA'),
(41,'MARTES','09:40:00','11:20:00','PRACTICA','LAB FISICA'),
(41,'MIERCOLES','09:40:00','11:20:00','PRACTICA','LAB FISICA'),
(42,'LUNES','13:00:00','14:40:00','PRACTICA','LAB FISICA'),
(42,'MIERCOLES','13:00:00','14:40:00','PRACTICA','LAB FISICA'),

-- Ecuaciones Diferenciales
(43,'LUNES','07:10:00','09:40:00','TEORIA','D-203'),
(43,'MIERCOLES','07:10:00','09:40:00','TEORIA','D-203'),
(44,'LUNES','09:40:00','12:10:00','TEORIA','D-204'),
(44,'MIERCOLES','09:40:00','12:10:00','TEORIA','D-204'),
(45,'LUNES','12:10:00','14:40:00','TEORIA','D-308'),
(45,'MIERCOLES','12:10:00','14:40:00','TEORIA','D-308'),

-- Fundamentos de Programacin II
(46,'MARTES','11:20:00','13:00:00','PRACTICA','LAB 2'),
(46,'MIERCOLES','11:20:00','13:00:00','PRACTICA','LAB 2'),
(47,'LUNES','08:00:00','09:40:00','PRACTICA','LAB 2'),
(47,'MIERCOLES','08:00:00','09:40:00','PRACTICA','LAB 2'),
(48,'MARTES','16:20:00','18:00:00','PRACTICA','LAB 2'),
(48,'MIERCOLES','16:20:00','18:00:00','PRACTICA','LAB 2'),

-- Programacin Aplicada II
(49,'MARTES','16:20:00','18:00:00','PRACTICA','LAB5'),
(49,'MIERCOLES','16:20:00','18:00:00','PRACTICA','LAB5'),
(50,'MARTES','16:20:00','18:00:00','PRACTICA','LAB6'),
(50,'MIERCOLES','16:20:00','18:00:00','PRACTICA','LAB6'),
(51,'MARTES','20:30:00','22:10:00','PRACTICA','LAB1'),
(51,'MIERCOLES','20:30:00','22:10:00','PRACTICA','LAB1'),

-- Ingeniera de Costos y Presupuestos
(52,'MARTES','13:00:00','14:40:00','TEORIA','D-203'),
(52,'MIERCOLES','13:00:00','14:40:00','TEORIA','D-203'),
(53,'MARTES','13:00:00','14:40:00','TEORIA','D-204'),
(53,'MIERCOLES','13:00:00','14:40:00','TEORIA','D-204'),
(54,'MARTES','17:10:00','18:50:00','TEORIA','LAB504'),
(54,'MIERCOLES','17:10:00','18:50:00','TEORIA','LAB504'),

-- Fundamentos de Base de Datos
(55,'MARTES','16:20:00','18:00:00','PRACTICA','LAB5'),
(55,'MIERCOLES','16:20:00','18:00:00','PRACTICA','LAB5'),
(56,'MARTES','16:20:00','18:00:00','PRACTICA','LAB6'),
(56,'MIERCOLES','16:20:00','18:00:00','PRACTICA','LAB6'),
(57,'MARTES','20:30:00','22:10:00','PRACTICA','LAB1'),
(57,'MIERCOLES','20:30:00','22:10:00','PRACTICA','LAB1'),

-- Ingeniera de Procesos de Negocios
(58,'MARTES','14:40:00','16:20:00','TEORIA','B-505'),
(58,'MIERCOLES','14:40:00','16:20:00','TEORIA','B-505'),
(59,'MARTES','14:40:00','16:20:00','TEORIA','B-504'),
(59,'MIERCOLES','14:40:00','16:20:00','TEORIA','B-504'),
(60,'MARTES','18:50:00','20:30:00','TEORIA','B-504'),
(60,'MIERCOLES','18:50:00','20:30:00','TEORIA','B-504'),

-- Sistemas Digitales y Arquitectura de Computadoras
(61,'MARTES','13:00:00','14:40:00','PRACTICA','LAB ELEC'),
(61,'MIERCOLES','13:00:00','14:40:00','PRACTICA','LAB ELEC'),
(62,'MARTES','13:00:00','14:40:00','PRACTICA','LAB6'),
(62,'MIERCOLES','13:00:00','14:40:00','PRACTICA','LAB6'),
(63,'MARTES','17:10:00','18:50:00','PRACTICA','LAB ELEC'),
(63,'MIERCOLES','17:10:00','18:50:00','PRACTICA','LAB ELEC'),

-- Sistemas Operativos
(64,'MARTES','14:40:00','16:20:00','PRACTICA','LAB5'),
(64,'MIERCOLES','14:40:00','16:20:00','PRACTICA','LAB5'),
(65,'MARTES','14:40:00','16:20:00','PRACTICA','LAB6'),
(65,'MIERCOLES','14:40:00','16:20:00','PRACTICA','LAB6'),
(66,'MARTES','18:50:00','20:30:00','PRACTICA','LAB1'),
(66,'MIERCOLES','18:50:00','20:30:00','PRACTICA','LAB1'),

-- Dinǭmica de Sistemas
(67,'MARTES','13:00:00','15:30:00','PRACTICA','LAB5'),
(68,'MARTES','13:00:00','15:30:00','PRACTICA','LAB6'),
(69,'MARTES','17:10:00','19:40:00','PRACTICA','LAB1'),

-- Ingeniera de Software
(70,'LUNES','17:10:00','18:50:00','TEORIA','B-503'),
(70,'MIERCOLES','17:10:00','18:50:00','TEORIA','B-503'),
(71,'LUNES','17:10:00','18:50:00','TEORIA','D-203'),
(71,'MIERCOLES','17:10:00','18:50:00','TEORIA','D-203'),
(72,'LUNES','17:10:00','18:50:00','TEORIA','D-204'),
(72,'MIERCOLES','17:10:00','18:50:00','TEORIA','D-204'),

-- Investigacin Aplicada
(73,'LUNES','17:10:00','18:50:00','TEORIA','B-505'),
(74,'LUNES','17:10:00','18:50:00','TEORIA','D-203'),
(75,'LUNES','17:10:00','18:50:00','TEORIA','D-204'),

-- Administracin y Gestin de Base de Datos
(76,'LUNES','18:50:00','20:30:00','PRACTICA','LAB2'),
(76,'MIERCOLES','18:50:00','20:30:00','PRACTICA','LAB2'),
(77,'LUNES','18:50:00','20:30:00','PRACTICA','LAB3'),
(77,'MIERCOLES','18:50:00','20:30:00','PRACTICA','LAB3'),
(78,'LUNES','18:50:00','20:30:00','PRACTICA','LAB3'),
(78,'MIERCOLES','18:50:00','20:30:00','PRACTICA','LAB3'),

-- Planeamiento de Recursos Empresariales
(79,'LUNES','20:30:00','22:10:00','TEORIA','B-503'),
(79,'MIERCOLES','20:30:00','22:10:00','TEORIA','B-503'),
(80,'LUNES','20:30:00','22:10:00','TEORIA','D-203'),
(80,'MIERCOLES','20:30:00','22:10:00','TEORIA','D-203'),
(81,'LUNES','20:30:00','22:10:00','TEORIA','D-204'),
(81,'MIERCOLES','20:30:00','22:10:00','TEORIA','D-204'),

-- Arquitectura y Conectividad de Redes
(82,'LUNES','18:50:00','20:30:00','TEORIA','B-503'),
(82,'MIERCOLES','18:50:00','20:30:00','TEORIA','B-503'),
(83,'LUNES','18:50:00','20:30:00','TEORIA','D-203'),
(83,'MIERCOLES','18:50:00','20:30:00','TEORIA','D-203'),
(84,'LUNES','18:50:00','20:30:00','TEORIA','D-204'),
(84,'MIERCOLES','18:50:00','20:30:00','TEORIA','D-204'),

-- Ingeniera del Conocimiento
(85,'LUNES','19:40:00','22:10:00','TEORIA','B-503'),
(86,'LUNES','19:40:00','22:10:00','TEORIA','D-203'),
(87,'LUNES','19:40:00','22:10:00','TEORIA','D-204'),

-- Simulacin de Sistemas
(88,'LUNES','20:30:00','22:10:00','PRACTICA','LAB2'),
(88,'MIERCOLES','20:30:00','22:10:00','PRACTICA','LAB2'),
(89,'LUNES','20:30:00','22:10:00','PRACTICA','LAB3'),
(89,'MIERCOLES','20:30:00','22:10:00','PRACTICA','LAB3'),
(90,'LUNES','20:30:00','22:10:00','PRACTICA','LAB3'),
(90,'MIERCOLES','20:30:00','22:10:00','PRACTICA','LAB3'),

-- Taller de Tesis II
(91,'LUNES','18:00:00','19:40:00','TEORIA','D-308'),
(91,'MIERCOLES','18:00:00','19:40:00','TEORIA','D-308'),
(92,'LUNES','18:00:00','19:40:00','TEORIA','B-505'),
(92,'MIERCOLES','18:00:00','19:40:00','TEORIA','B-505'),
(93,'LUNES','19:40:00','21:20:00','TEORIA','LAB2'),
(93,'MIERCOLES','19:40:00','21:20:00','TEORIA','LAB2'),

-- Evaluacin de Proyectos de TI
(94,'LUNES','17:10:00','18:50:00','TEORIA','D-308'),
(94,'JUEVES','19:40:00','21:20:00','TEORIA','D-308'),
(95,'LUNES','17:10:00','18:50:00','TEORIA','LAB ELEC'),
(95,'JUEVES','19:40:00','21:20:00','TEORIA','LAB ELEC'),
(96,'LUNES','18:00:00','19:40:00','TEORIA','LAB2'),
(96,'JUEVES','17:10:00','18:50:00','TEORIA','LAB2'),

-- Tpicos Especiales de BigData
(97,'LUNES','18:50:00','20:30:00','TEORIA','D-308'),
(97,'MIERCOLES','18:50:00','20:30:00','TEORIA','D-308'),
(98,'LUNES','18:50:00','20:30:00','TEORIA','D-203'),
(98,'MIERCOLES','18:50:00','20:30:00','TEORIA','D-203'),
(99,'LUNES','18:50:00','20:30:00','TEORIA','B-504'),
(99,'MIERCOLES','18:50:00','20:30:00','TEORIA','B-504'),

-- Arquitectura Empresarial
(100,'LUNES','19:40:00','22:10:00','TEORIA','D-308'),
(101,'LUNES','19:40:00','22:10:00','TEORIA','LAB ELEC'),
(102,'LUNES','17:10:00','19:40:00','TEORIA','LAB2'),

-- Ciberseguridad
(103,'LUNES','20:30:00','22:10:00','TEORIA','D-308'),
(103,'MIERCOLES','20:30:00','22:10:00','TEORIA','D-308'),
(104,'LUNES','20:30:00','22:10:00','TEORIA','D-203'),
(104,'MIERCOLES','20:30:00','22:10:00','TEORIA','D-203'),
(105,'LUNES','20:30:00','22:10:00','TEORIA','LAB ELEC'),
(105,'MIERCOLES','20:30:00','22:10:00','TEORIA','LAB ELEC'),

-- Prǭcticas Pre-Profesionales I
(106,'LUNES','18:50:00','22:10:00','PRACTICA','D-308'),
(106,'SABADO','10:30:00','13:50:00','PRACTICA','D-308'),
(107,'LUNES','18:50:00','22:10:00','PRACTICA','B-505'),
(108,'LUNES','18:50:00','22:10:00','PRACTICA','B-504'),
(108,'SABADO','10:30:00','13:50:00','PRACTICA','B-504'),

-- ================== 2026-2 ==================
-- INGLES II
(109,'MARTES','10:30:00','12:10:00','PRACTICA','LAB 1'),
(110,'MIERCOLES','12:10:00','13:50:00','PRACTICA','LAB 1'),
(111,'MARTES','14:40:00','16:20:00','PRACTICA','LAB 1'),

-- LIDERAZGO
(112,'LUNES','08:00:00','09:40:00','TEORIA','B-505'),
(112,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-505'),
(113,'LUNES','08:00:00','09:40:00','TEORIA','B-504'),
(113,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-504'),
(114,'LUNES','13:00:00','14:40:00','TEORIA','B-505'),
(114,'MIERCOLES','13:00:00','14:40:00','TEORIA','B-505'),

-- MEDIO AMBIENTE
(115,'MARTES','11:20:00','13:00:00','TEORIA','B-505'),
(115,'MIERCOLES','11:20:00','13:00:00','TEORIA','B-505'),
(116,'MARTES','11:20:00','13:00:00','TEORIA','B-504'),
(116,'MIERCOLES','11:20:00','13:00:00','TEORIA','B-504'),
(117,'MARTES','16:20:00','18:00:00','TEORIA','B-505'),
(117,'MIERCOLES','16:20:00','18:00:00','TEORIA','B-505'),

-- TIC
(118,'MARTES','11:20:00','13:50:00','PRACTICA','LAB 1'),
(119,'MARTES','11:20:00','13:50:00','PRACTICA','LAB 2'),
(120,'MARTES','16:20:00','18:50:00','PRACTICA','D-203'),

-- SOCIOLOGIA
(121,'MARTES','11:20:00','13:50:00','TEORIA','B-503'),
(122,'MARTES','11:20:00','13:50:00','TEORIA','B-504'),
(123,'MARTES','16:20:00','18:50:00','TEORIA','B-505'),

-- TEORIA DE SISTEMAS
(124,'LUNES','09:40:00','11:20:00','TEORIA','B-505'),
(124,'MIERCOLES','09:40:00','11:20:00','TEORIA','B-505'),
(125,'LUNES','09:40:00','11:20:00','TEORIA','B-504'),
(125,'MIERCOLES','09:40:00','11:20:00','TEORIA','B-504'),
(126,'LUNES','14:40:00','16:20:00','TEORIA','B-505'),
(126,'MIERCOLES','14:40:00','16:20:00','TEORIA','B-505'),

-- CALCULO DIFERENCIAL E INTEGRAL
(127,'LUNES','08:00:00','09:40:00','TEORIA','B-505'),
(127,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-505'),
(127,'JUEVES','07:00:00','09:40:00','TEORIA','B-505'),
(128,'LUNES','09:40:00','11:20:00','TEORIA','B-504'),
(128,'MIERCOLES','09:40:00','11:20:00','TEORIA','B-504'),
(128,'JUEVES','09:40:00','12:10:00','TEORIA','B-504'),
(129,'LUNES','13:00:00','14:40:00','TEORIA','B-505'),
(129,'MIERCOLES','13:00:00','14:40:00','TEORIA','B-505'),
(129,'JUEVES','12:10:00','14:40:00','TEORIA','B-505'),

-- FUNDAMENTOS DE PROGRAMACION I
(130,'LUNES','09:40:00','11:20:00','PRACTICA','LAB 1'),
(130,'MIERCOLES','09:40:00','11:20:00','PRACTICA','LAB 1'),
(131,'LUNES','08:00:00','09:40:00','PRACTICA','LAB 1'),
(131,'MIERCOLES','08:00:00','09:40:00','PRACTICA','LAB 1'),
(132,'LUNES','14:40:00','16:20:00','PRACTICA','LAB 1'),
(132,'MIERCOLES','14:40:00','16:20:00','PRACTICA','LAB 1'),

-- PROGRAMACION APLICADA I
(133,'LUNES','10:30:00','13:00:00','PRACTICA','LAB3'),
(133,'MIERCOLES','10:30:00','13:00:00','PRACTICA','LAB3'),
(134,'LUNES','08:00:00','10:30:00','PRACTICA','LAB3'),
(134,'MIERCOLES','08:00:00','10:30:00','PRACTICA','LAB3'),
(135,'LUNES','15:30:00','18:00:00','PRACTICA','LAB2'),
(135,'MIERCOLES','15:30:00','18:00:00','PRACTICA','LAB2'),

-- GESTION CONTABLE
(136,'LUNES','12:10:00','13:50:00','TEORIA','D-203'),
(136,'MIERCOLES','08:00:00','09:40:00','TEORIA','D-203'),
(137,'LUNES','12:10:00','13:50:00','TEORIA','D-204'),
(137,'MIERCOLES','09:40:00','11:20:00','TEORIA','D-204'),
(138,'LUNES','17:10:00','18:50:00','TEORIA','B-503'),
(138,'MIERCOLES','13:00:00','14:40:00','TEORIA','B-503'),

-- ESTADISTICA II
(139,'LUNES','12:10:00','13:50:00','TEORIA','LAB3'),
(139,'MIERCOLES','09:40:00','11:20:00','TEORIA','LAB3'),
(140,'LUNES','12:10:00','13:50:00','TEORIA','LAB3'),
(140,'MIERCOLES','08:00:00','09:40:00','TEORIA','LAB3'),
(141,'LUNES','17:10:00','18:50:00','TEORIA','LAB2'),
(141,'MIERCOLES','14:40:00','16:20:00','TEORIA','LAB2'),

-- INVESTIGACION OPERATIVA
(142,'LUNES','09:40:00','12:10:00','TEORIA','D-203'),
(142,'MIERCOLES','09:40:00','12:10:00','TEORIA','D-203'),
(143,'LUNES','07:10:00','09:40:00','TEORIA','D-204'),
(143,'MIERCOLES','07:10:00','09:40:00','TEORIA','D-204'),
(144,'LUNES','14:40:00','17:10:00','TEORIA','B-503'),
(144,'MIERCOLES','14:40:00','17:10:00','TEORIA','B-503'),

-- ELECTROMAGNETISMO
(145,'LUNES','08:00:00','10:30:00','PRACTICA','LAB ELEC'),
(145,'MIERCOLES','08:00:00','10:30:00','PRACTICA','LAB ELEC'),
(146,'LUNES','10:30:00','13:00:00','PRACTICA','LAB ELEC'),
(146,'MIERCOLES','10:30:00','13:00:00','PRACTICA','LAB ELEC'),
(147,'LUNES','13:00:00','15:30:00','PRACTICA','LAB ELEC'),
(147,'MIERCOLES','13:00:00','15:30:00','PRACTICA','LAB ELEC'),

-- MATEMATICAS DISCRETAS
(148,'LUNES','07:10:00','09:40:00','TEORIA','D-203'),
(148,'MIERCOLES','07:10:00','09:40:00','TEORIA','D-203'),
(149,'LUNES','09:40:00','12:10:00','TEORIA','D-204'),
(149,'MIERCOLES','09:40:00','12:10:00','TEORIA','D-204'),
(150,'LUNES','12:10:00','14:40:00','TEORIA','B-503'),
(150,'MIERCOLES','12:10:00','14:40:00','TEORIA','B-503'),

-- TALLER DE TESIS I
(151,'LUNES','19:40:00','21:20:00','TEORIA','D-204'),
(151,'MIERCOLES','19:40:00','21:20:00','TEORIA','D-204'),
(152,'LUNES','19:40:00','21:20:00','TEORIA','LAB 1'),
(152,'MIERCOLES','19:40:00','21:20:00','TEORIA','LAB 1'),
(153,'LUNES','19:40:00','21:20:00','TEORIA','B-504'),
(153,'MIERCOLES','19:40:00','21:20:00','TEORIA','B-504'),

-- TALLER DE INTEGRACION DE SISTEMAS
(154,'LUNES','18:00:00','19:40:00','PRACTICA','LAB5'),
(154,'MIERCOLES','18:00:00','19:40:00','PRACTICA','LAB5'),
(155,'LUNES','18:00:00','19:40:00','PRACTICA','LAB1'),
(155,'MIERCOLES','18:00:00','19:40:00','PRACTICA','LAB1'),
(156,'LUNES','18:00:00','19:40:00','PRACTICA','LAB6'),
(156,'MIERCOLES','18:00:00','19:40:00','PRACTICA','LAB6'),

-- TOPICOS ESPECIALES DE IOT
(157,'LUNES','19:40:00','22:10:00','TEORIA','B-505'),
(157,'MIERCOLES','19:40:00','22:10:00','TEORIA','B-505'),
(158,'LUNES','19:40:00','22:10:00','TEORIA','D-203'),
(158,'MIERCOLES','19:40:00','22:10:00','TEORIA','D-203'),
(159,'LUNES','19:40:00','22:10:00','TEORIA','B-504'),
(159,'MIERCOLES','19:40:00','22:10:00','TEORIA','B-504'),

-- INTELIGENCIA DE NEGOCIOS
(160,'LUNES','18:00:00','19:40:00','TEORIA','B-505'),
(160,'MIERCOLES','18:00:00','19:40:00','TEORIA','B-505'),
(161,'LUNES','18:00:00','19:40:00','TEORIA','D-203'),
(161,'MIERCOLES','18:00:00','19:40:00','TEORIA','D-203'),
(162,'LUNES','18:00:00','19:40:00','TEORIA','B-504'),
(162,'MIERCOLES','18:00:00','19:40:00','TEORIA','B-504'),

-- SEGURIDAD EN REDES Y SISTEMAS DE INFORMACION
(163,'LUNES','19:40:00','21:20:00','TEORIA','LAB4'),
(163,'MIERCOLES','19:40:00','21:20:00','TEORIA','LAB4'),
(163,'SABADO','11:20:00','13:00:00','TEORIA','LAB4'),
(164,'LUNES','19:40:00','21:20:00','TEORIA','LAB5'),
(164,'MIERCOLES','19:40:00','21:20:00','TEORIA','LAB5'),
(165,'LUNES','19:40:00','21:20:00','TEORIA','LAB6'),
(165,'MIERCOLES','19:40:00','21:20:00','TEORIA','LAB6'),

-- INTELIGENCIA ARTIFICIAL
(166,'LUNES','18:00:00','19:40:00','TEORIA','LAB4'),
(166,'SABADO','09:40:00','11:20:00','TEORIA','LAB4'),
(167,'LUNES','18:00:00','19:40:00','TEORIA','LAB5'),
(167,'SABADO','09:40:00','11:20:00','TEORIA','LAB5'),
(168,'LUNES','18:00:00','19:40:00','TEORIA','LAB6'),
(168,'SABADO','09:40:00','11:20:00','TEORIA','LAB6'),

-- AUDITORIA DE SISTEMAS DE INFORMACION
(169,'LUNES','19:40:00','21:20:00','TEORIA','B-503'),
(169,'MIERCOLES','19:40:00','21:20:00','TEORIA','B-503'),
(170,'LUNES','18:00:00','19:40:00','TEORIA','D-308'),
(170,'MIERCOLES','18:00:00','19:40:00','TEORIA','D-308'),
(171,'LUNES','19:40:00','21:20:00','TEORIA','LAB ELEC'),
(171,'MIERCOLES','19:40:00','21:20:00','TEORIA','LAB ELEC'),

-- GERENCIA DE PROYECTOS DE TI
(172,'LUNES','19:40:00','22:10:00','TEORIA','B-503'),
(172,'MIERCOLES','19:40:00','22:10:00','TEORIA','B-503'),
(173,'LUNES','19:40:00','22:10:00','TEORIA','D-308'),
(173,'MIERCOLES','19:40:00','22:10:00','TEORIA','D-308'),
(174,'LUNES','19:40:00','22:10:00','TEORIA','LAB ELEC'),
(174,'MIERCOLES','19:40:00','22:10:00','TEORIA','LAB ELEC'),

-- FUNDAMENTOS DE BUSINESS ANALYTICS
(175,'LUNES','18:00:00','19:40:00','TEORIA','B-503'),
(175,'MIERCOLES','18:00:00','19:40:00','TEORIA','B-503'),
(176,'LUNES','19:40:00','21:20:00','TEORIA','D-308'),
(176,'MIERCOLES','19:40:00','21:20:00','TEORIA','D-308'),
(177,'LUNES','18:00:00','19:40:00','TEORIA','LAB ELEC'),
(177,'MIERCOLES','18:00:00','19:40:00','TEORIA','LAB ELEC'),

-- TECNOLOGIAS EMERGENTES E INNOVACION TECNOLOGICA
(178,'LUNES','18:00:00','19:40:00','TEORIA','B-503'),
(178,'MIERCOLES','18:00:00','19:40:00','TEORIA','B-503'),
(179,'LUNES','18:00:00','19:40:00','TEORIA','D-308'),
(179,'MIERCOLES','18:00:00','19:40:00','TEORIA','D-308'),
(180,'LUNES','18:00:00','19:40:00','TEORIA','LAB ELEC'),
(180,'MIERCOLES','18:00:00','19:40:00','TEORIA','LAB ELEC'),

-- PRACTICAS PRE-PROFESIONALES II
(181,'LUNES','18:50:00','22:10:00','PRACTICA','B-503'),
(181,'SABADO','08:00:00','11:20:00','PRACTICA','B-503'),
(182,'LUNES','18:50:00','22:10:00','PRACTICA','D-308'),
(182,'SABADO','08:00:00','11:20:00','PRACTICA','D-308'),
(183,'LUNES','18:50:00','22:10:00','PRACTICA','LAB ELEC'),
(183,'SABADO','08:00:00','11:20:00','PRACTICA','LAB ELEC')
ON CONFLICT DO NOTHING;

-- =========================================================
-- VI CICLO (AUTOCOMPLETADO)
-- =========================================================
INSERT INTO seccion (id_seccion, grupo, cupos_max, cupos_disp, cod_curso, cod_periodo, cod_profesor) VALUES
(184,'A',35,35,'38','2026-2','PROF020'),
(185,'B',35,35,'38','2026-2','PROF021'),
(186,'C',35,35,'38','2026-2','PROF022'),
(187,'A',35,35,'39','2026-2','PROF020'),
(188,'B',35,35,'39','2026-2','PROF021'),
(189,'C',35,35,'39','2026-2','PROF022'),
(190,'A',35,35,'40','2026-2','PROF020'),
(191,'B',35,35,'40','2026-2','PROF021'),
(192,'C',35,35,'40','2026-2','PROF022'),
(193,'A',35,35,'41','2026-2','PROF020'),
(194,'B',35,35,'41','2026-2','PROF021'),
(195,'C',35,35,'41','2026-2','PROF022'),
(196,'A',35,35,'42','2026-2','PROF020'),
(197,'B',35,35,'42','2026-2','PROF021'),
(198,'C',35,35,'42','2026-2','PROF022'),
(199,'A',35,35,'43','2026-2','PROF020'),
(200,'B',35,35,'43','2026-2','PROF021'),
(201,'C',35,35,'43','2026-2','PROF022'),
(202,'A',35,35,'44','2026-2','PROF020'),
(203,'B',35,35,'44','2026-2','PROF021'),
(204,'C',35,35,'44','2026-2','PROF022'),
(205,'A',35,35,'45','2026-2','PROF020'),
(206,'B',35,35,'45','2026-2','PROF021'),
(207,'C',35,35,'45','2026-2','PROF022')
ON CONFLICT DO NOTHING;

INSERT INTO horario_cabecera (id_horario, id_seccion, cod_periodo) VALUES
(184,184,'2026-2'),(185,185,'2026-2'),(186,186,'2026-2'),(187,187,'2026-2'),
(188,188,'2026-2'),(189,189,'2026-2'),(190,190,'2026-2'),(191,191,'2026-2'),
(192,192,'2026-2'),(193,193,'2026-2'),(194,194,'2026-2'),(195,195,'2026-2'),
(196,196,'2026-2'),(197,197,'2026-2'),(198,198,'2026-2'),(199,199,'2026-2'),
(200,200,'2026-2'),(201,201,'2026-2'),(202,202,'2026-2'),(203,203,'2026-2'),
(204,204,'2026-2'),(205,205,'2026-2'),(206,206,'2026-2'),(207,207,'2026-2')
ON CONFLICT DO NOTHING;

INSERT INTO horario_detalle (id_horario, dia_semana, hora_inicio, hora_fin, tipo_clase, ambiente) VALUES
(184,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(184,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(185,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(185,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(186,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(186,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(187,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(187,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(188,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(188,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(189,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(189,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(190,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(190,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(191,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(191,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(192,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(192,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(193,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(193,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(194,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(194,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(195,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(195,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(196,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(196,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(197,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(197,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(198,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(198,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(199,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(199,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(200,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(200,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(201,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(201,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(202,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(202,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(203,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(203,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(204,'LUNES','08:00:00','09:40:00','TEORIA','B-501'),
(204,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(205,'MARTES','08:00:00','09:40:00','TEORIA','B-501'),
(205,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(206,'MIERCOLES','08:00:00','09:40:00','TEORIA','B-501'),
(206,'VIERNES','08:00:00','09:40:00','TEORIA','B-501'),
(207,'JUEVES','08:00:00','09:40:00','TEORIA','B-501'),
(207,'LUNES','08:00:00','09:40:00','TEORIA','B-501')
ON CONFLICT DO NOTHING;


-- =========================================================
-- 2 USUARIOS ADICIONALES (LUIS Y LENIN)
-- =========================================================

-- LUÍS ARTURO ALVARADO PUYEN (4TO CICLO)
INSERT INTO alumno (cod_alumno, dni, nombres, apellidos, cod_escuela, cod_plan, semestre_actual)
VALUES ('2024023935', '70243935', 'Luis Arturo', 'Alvarado Puyen', 'FIIS', 'PLAN2019', 4)
ON CONFLICT (cod_alumno) DO NOTHING;

-- LENIN ALVAREZ JARA LENIN ALLISTER (6TO CICLO)
INSERT INTO alumno (cod_alumno, dni, nombres, apellidos, cod_escuela, cod_plan, semestre_actual)
VALUES ('2024023953', '70243953', 'Lenin Allister', 'Alvarez Jara', 'FIIS', 'PLAN2019', 6)
ON CONFLICT (cod_alumno) DO NOTHING;

-- HISTORIAL DE LUIS (Aprobó ciclo 1 y 2 completos, jaló 1 del ciclo 3)
-- Cursos Ciclo 1 (1,2,3,4,5,6,7)
-- Cursos Ciclo 2 (8,9,10,11,12,13,14,15,16)
-- Cursos Ciclo 3 (17,18,19,20,21,22,23,24)
INSERT INTO HISTORIAL_NOTAS (cod_alumno, cod_curso, cod_periodo, nota, estado) VALUES
('2024023935', '1', '2025-2', 14, 'APROBADO'),
('2024023935', '2', '2025-2', 15, 'APROBADO'),
('2024023935', '3', '2025-2', 16, 'APROBADO'),
('2024023935', '4', '2025-2', 13, 'APROBADO'),
('2024023935', '5', '2025-2', 14, 'APROBADO'),
('2024023935', '6', '2025-2', 15, 'APROBADO'),
('2024023935', '7', '2025-2', 16, 'APROBADO'),
('2024023935', '8', '2025-2', 14, 'APROBADO'),
('2024023935', '9', '2025-2', 15, 'APROBADO'),
('2024023935', '10', '2025-2', 16, 'APROBADO'),
('2024023935', '11', '2025-2', 13, 'APROBADO'),
('2024023935', '12', '2025-2', 14, 'APROBADO'),
('2024023935', '13', '2025-2', 15, 'APROBADO'),
('2024023935', '14', '2025-2', 16, 'APROBADO'),
('2024023935', '15', '2025-2', 14, 'APROBADO'),
('2024023935', '16', '2025-2', 15, 'APROBADO'),
('2024023935', '17', '2025-2', 14, 'APROBADO'),
('2024023935', '18', '2025-2', 15, 'APROBADO'),
('2024023935', '19', '2025-2', 16, 'APROBADO'),
('2024023935', '20', '2025-2', 13, 'APROBADO'),
('2024023935', '21', '2025-2', 14, 'APROBADO'),
('2024023935', '22', '2025-2', 15, 'APROBADO'),
('2024023935', '23', '2025-2', 16, 'APROBADO'),
('2024023935', '24', '2025-2', 08, 'REPROBADO') -- Jaló FISICA II
ON CONFLICT DO NOTHING;

-- HISTORIAL DE LENIN (Aprobó ciclo 1 al 4 completos, jaló 1 del ciclo 5)
-- Cursos Ciclo 1 a 4 (1 a 31)
-- Cursos Ciclo 5 (32,33,34,35,36,37)
INSERT INTO HISTORIAL_NOTAS (cod_alumno, cod_curso, cod_periodo, nota, estado) VALUES
('2024023953', '1', '2025-2', 14, 'APROBADO'),('2024023953', '2', '2025-2', 15, 'APROBADO'),
('2024023953', '3', '2025-2', 16, 'APROBADO'),('2024023953', '4', '2025-2', 13, 'APROBADO'),
('2024023953', '5', '2025-2', 14, 'APROBADO'),('2024023953', '6', '2025-2', 15, 'APROBADO'),
('2024023953', '7', '2025-2', 16, 'APROBADO'),('2024023953', '8', '2025-2', 14, 'APROBADO'),
('2024023953', '9', '2025-2', 15, 'APROBADO'),('2024023953', '10', '2025-2', 16, 'APROBADO'),
('2024023953', '11', '2025-2', 13, 'APROBADO'),('2024023953', '12', '2025-2', 14, 'APROBADO'),
('2024023953', '13', '2025-2', 15, 'APROBADO'),('2024023953', '14', '2025-2', 16, 'APROBADO'),
('2024023953', '15', '2025-2', 14, 'APROBADO'),('2024023953', '16', '2025-2', 15, 'APROBADO'),
('2024023953', '17', '2025-2', 14, 'APROBADO'),('2024023953', '18', '2025-2', 15, 'APROBADO'),
('2024023953', '19', '2025-2', 16, 'APROBADO'),('2024023953', '20', '2025-2', 13, 'APROBADO'),
('2024023953', '21', '2025-2', 14, 'APROBADO'),('2024023953', '22', '2025-2', 15, 'APROBADO'),
('2024023953', '23', '2025-2', 16, 'APROBADO'),('2024023953', '24', '2025-2', 14, 'APROBADO'),
('2024023953', '25', '2025-2', 15, 'APROBADO'),('2024023953', '26', '2025-2', 16, 'APROBADO'),
('2024023953', '27', '2025-2', 13, 'APROBADO'),('2024023953', '28', '2025-2', 14, 'APROBADO'),
('2024023953', '29', '2025-2', 15, 'APROBADO'),('2024023953', '30', '2025-2', 16, 'APROBADO'),
('2024023953', '31', '2025-2', 14, 'APROBADO'),('2024023953', '32', '2025-2', 15, 'APROBADO'),
('2024023953', '33', '2025-2', 16, 'APROBADO'),('2024023953', '34', '2025-2', 13, 'APROBADO'),
('2024023953', '35', '2025-2', 14, 'APROBADO'),('2024023953', '36', '2025-2', 15, 'APROBADO'),
('2024023953', '37', '2025-2', 09, 'REPROBADO') -- Jaló SISTEMAS OPERATIVOS
ON CONFLICT DO NOTHING;


-- =========================================================
-- 2 USUARIOS ADICIONALES (LUIS Y LENIN)
-- =========================================================

-- LUÍS ARTURO ALVARADO PUYEN (4TO CICLO)
INSERT INTO alumno (cod_alumno, dni, nombres, apellidos, cod_escuela, cod_plan, semestre_actual)
VALUES ('2024023935', '70243935', 'Luis Arturo', 'Alvarado Puyen', 'FIIS', 'PLAN2019', 4)
ON CONFLICT (cod_alumno) DO NOTHING;

-- LENIN ALVAREZ JARA LENIN ALLISTER (6TO CICLO)
INSERT INTO alumno (cod_alumno, dni, nombres, apellidos, cod_escuela, cod_plan, semestre_actual)
VALUES ('2024023953', '70243953', 'Lenin Allister', 'Alvarez Jara', 'FIIS', 'PLAN2019', 6)
ON CONFLICT (cod_alumno) DO NOTHING;

-- HISTORIAL DE LUIS (Aprobó ciclo 1 y 2 completos, jaló 1 del ciclo 3)
-- Cursos Ciclo 1 (1,2,3,4,5,6,7)
-- Cursos Ciclo 2 (8,9,10,11,12,13,14,15,16)
-- Cursos Ciclo 3 (17,18,19,20,21,22,23,24)
INSERT INTO HISTORIAL_NOTAS (cod_alumno, cod_curso, cod_periodo, nota, estado) VALUES
('2024023935', '1', '2025-2', 14, 'APROBADO'),
('2024023935', '2', '2025-2', 15, 'APROBADO'),
('2024023935', '3', '2025-2', 16, 'APROBADO'),
('2024023935', '4', '2025-2', 13, 'APROBADO'),
('2024023935', '5', '2025-2', 14, 'APROBADO'),
('2024023935', '6', '2025-2', 15, 'APROBADO'),
('2024023935', '7', '2025-2', 16, 'APROBADO'),
('2024023935', '8', '2025-2', 14, 'APROBADO'),
('2024023935', '9', '2025-2', 15, 'APROBADO'),
('2024023935', '10', '2025-2', 16, 'APROBADO'),
('2024023935', '11', '2025-2', 13, 'APROBADO'),
('2024023935', '12', '2025-2', 14, 'APROBADO'),
('2024023935', '13', '2025-2', 15, 'APROBADO'),
('2024023935', '14', '2025-2', 16, 'APROBADO'),
('2024023935', '15', '2025-2', 14, 'APROBADO'),
('2024023935', '16', '2025-2', 15, 'APROBADO'),
('2024023935', '17', '2025-2', 14, 'APROBADO'),
('2024023935', '18', '2025-2', 15, 'APROBADO'),
('2024023935', '19', '2025-2', 16, 'APROBADO'),
('2024023935', '20', '2025-2', 13, 'APROBADO'),
('2024023935', '21', '2025-2', 14, 'APROBADO'),
('2024023935', '22', '2025-2', 15, 'APROBADO'),
('2024023935', '23', '2025-2', 16, 'APROBADO'),
('2024023935', '24', '2025-2', 08, 'REPROBADO');


-- HISTORIAL DE LENIN (Aprobó ciclo 1 al 4 completos, jaló 1 del ciclo 5)
-- Cursos Ciclo 1 a 4 (1 a 31)
-- Cursos Ciclo 5 (32,33,34,35,36,37)
INSERT INTO HISTORIAL_NOTAS (cod_alumno, cod_curso, cod_periodo, nota, estado) VALUES
('2024023953', '1', '2025-2', 14, 'APROBADO'),('2024023953', '2', '2025-2', 15, 'APROBADO'),
('2024023953', '3', '2025-2', 16, 'APROBADO'),('2024023953', '4', '2025-2', 13, 'APROBADO'),
('2024023953', '5', '2025-2', 14, 'APROBADO'),('2024023953', '6', '2025-2', 15, 'APROBADO'),
('2024023953', '7', '2025-2', 16, 'APROBADO'),('2024023953', '8', '2025-2', 14, 'APROBADO'),
('2024023953', '9', '2025-2', 15, 'APROBADO'),('2024023953', '10', '2025-2', 16, 'APROBADO'),
('2024023953', '11', '2025-2', 13, 'APROBADO'),('2024023953', '12', '2025-2', 14, 'APROBADO'),
('2024023953', '13', '2025-2', 15, 'APROBADO'),('2024023953', '14', '2025-2', 16, 'APROBADO'),
('2024023953', '15', '2025-2', 14, 'APROBADO'),('2024023953', '16', '2025-2', 15, 'APROBADO'),
('2024023953', '17', '2025-2', 14, 'APROBADO'),('2024023953', '18', '2025-2', 15, 'APROBADO'),
('2024023953', '19', '2025-2', 16, 'APROBADO'),('2024023953', '20', '2025-2', 13, 'APROBADO'),
('2024023953', '21', '2025-2', 14, 'APROBADO'),('2024023953', '22', '2025-2', 15, 'APROBADO'),
('2024023953', '23', '2025-2', 16, 'APROBADO'),('2024023953', '24', '2025-2', 14, 'APROBADO'),
('2024023953', '25', '2025-2', 15, 'APROBADO'),('2024023953', '26', '2025-2', 16, 'APROBADO'),
('2024023953', '27', '2025-2', 13, 'APROBADO'),('2024023953', '28', '2025-2', 14, 'APROBADO'),
('2024023953', '29', '2025-2', 15, 'APROBADO'),('2024023953', '30', '2025-2', 16, 'APROBADO'),
('2024023953', '31', '2025-2', 14, 'APROBADO'),('2024023953', '32', '2025-2', 15, 'APROBADO'),
('2024023953', '33', '2025-2', 16, 'APROBADO'),('2024023953', '34', '2025-2', 13, 'APROBADO'),
('2024023953', '35', '2025-2', 14, 'APROBADO'),('2024023953', '36', '2025-2', 15, 'APROBADO'),
('2024023953', '37', '2025-2', 09, 'REPROBADO');


COMMIT;

