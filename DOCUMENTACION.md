# Sistema de Matrícula Virtual - UNFV FIIS

## 1. Descripción General del Proyecto
Este proyecto es una plataforma web para la **Matrícula Virtual** de los estudiantes de la Facultad de Ingeniería Industrial y de Sistemas (FIIS) de la Universidad Nacional Federico Villarreal (UNFV). 

El sistema permite la gestión de los planes de estudio, secciones, cupos, prerrequisitos, y cuenta con un asistente interactivo que guía al estudiante durante su proceso de matrícula, validando automáticamente las reglas de negocio de la universidad.

### Tecnologías Utilizadas:
* **Frontend:** HTML5, CSS3, y Vanilla JavaScript (ES6+). Empaquetado y servido a través de **Vite**.
* **Backend y Base de Datos:** **Supabase** (PostgreSQL). Se encarga de la autenticación, el almacenamiento de datos en tiempo real y la gestión de la lógica relacional.

---

## 2. Roles del Sistema

El sistema maneja dos roles principales, cada uno con su propio panel (Dashboard):

### A. Administrador (Admin)
* **Acceso:** Mediante correo específico (ej. `admin@fiis.unfv.edu.pe`).
* **Funciones principales:**
  * Gestión de Alumnos y Docentes.
  * Gestión de Planes de Estudio (ej. PLAN2010, PLAN2019) y asignación de cursos por semestre.
  * Apertura de Periodos Académicos (ej. 2026-I, 2026-II) marcando cuál es el "ACTIVO".
  * Creación y administración de Secciones, incluyendo cupos máximos y asignación de horarios/ambientes.

### B. Alumno
* **Acceso:** Con sus credenciales asignadas o correo institucional.
* **Funciones principales:**
  * Visualización de su **Plan de Estudios** (malla curricular).
  * Revisión de su **Historial de Notas** y cursos aprobados/reprobados.
  * **Proceso de Matrícula** guiado en 4 pasos con validación estricta de reglas.
  * Visualización de su horario final tras concretar la matrícula.
  * Advertencias de convalidación automática para alumnos de planes antiguos (ej. PLAN2010 que ingresan a ver cursos del PLAN2019).

---

## 3. Lógica y Reglas de Matrícula (Core del Sistema)

El sistema de matrícula (`alumno.js`) es el corazón del proyecto. Utiliza un asistente (Wizard) de 4 pasos que implementa las siguientes validaciones automatizadas:

### Paso 1: Selección de Cursos
El sistema calcula dinámicamente qué cursos mostrar basándose en el historial del estudiante:
1. **Regla de Avance (Ciclo + 1):** El alumno solo puede ver los cursos correspondientes a su semestre actual y, como máximo, los del semestre inmediato superior (ej. Si está en 3er ciclo, ve cursos hasta el 4to ciclo).
2. **Cursos Reprobados:** Si el alumno jaló un curso (estado `REPROBADO`), este aparecerá obligatoriamente disponible para ser llevado de nuevo.
3. **Bloqueo por Cursos Aprobados:** Los cursos que ya tienen estado `APROBADO` se ocultan de la lista de selección.
4. **Validación de Prerrequisitos:** Un curso solo se muestra si el alumno **ha aprobado todos los prerrequisitos** exigidos por la malla curricular (verificado contra la tabla `prerrequisito`).
5. **Límite de Créditos:** El estudiante puede seleccionar un máximo de **22 créditos por semestre** y un tope general de **44 créditos en total** por todo el proceso de matrícula. Si se excede, el sistema deshace la selección y pide solicitar extensión de créditos.

### Paso 2: Selección de Secciones
* El estudiante elige en qué grupo/sección matricularse para los cursos seleccionados en el Paso 1.
* El sistema muestra en tiempo real: Profesor, Día, Hora, Ambiente y **Cupos Disponibles**.
* Si una sección llega a 0 cupos, no se puede seleccionar.

### Paso 3: Revisión y Resumen
* Se muestra una tabla consolidada con todos los cursos elegidos, sus horarios, el total de créditos acumulados y los profesores asignados.
* Sirve como confirmación final antes de registrar la matrícula en la base de datos.

### Paso 4: Confirmación
* Se guarda la información en la base de datos (tablas `matricula_cabecera` y `matricula_detalle`).
* Se reduce automáticamente el número de `cupos_disp` (cupos disponibles) de las secciones elegidas.
* Se felicita al usuario y se le permite visualizar su nuevo horario.

---

## 4. Estructura de la Base de Datos (Supabase)

El sistema cuenta con un esquema relacional optimizado. Las tablas principales son:

* **`alumno`**: Guarda datos personales, correo, y a qué `cod_plan` y `semestre_actual` pertenece.
* **`plan_estudio` / `plan_curso`**: Define la malla curricular. Relaciona los cursos con el semestre en el que se deben llevar según el plan (ej. 2019).
* **`prerrequisito`**: Tabla puente que indica qué `cod_curso` exige tener aprobado un `cod_curso_req` antes de poder cursarlo.
* **`historial_notas`**: Almacena las notas históricas del alumno. Sus estados (`APROBADO` o `REPROBADO`) son la clave que desbloquea o bloquea los cursos en la matrícula.
* **`periodo_academico`**: Define el semestre activo (ej. 2026-II).
* **`seccion` / `horario_cabecera` / `horario_detalle`**: Estructura donde se asignan los cursos a grupos específicos, estableciendo cupos, profesores, días, horas y ambientes.
* **`matricula_cabecera` / `matricula_detalle`**: Registra la transacción final de matrícula del alumno con las secciones elegidas.

---

## 5. Puntos Fuertes a Destacar en la Exposición

1. **Automatización Integral:** El sistema no requiere que el operador humano decida qué cursos puede llevar un alumno; el algoritmo cruza el historial de notas con la malla curricular y los prerrequisitos de forma instantánea.
2. **Seguridad y Trazabilidad:** Al basarse en Supabase, la información está centralizada en la nube con reglas de seguridad.
3. **UX/UI Moderna:** Interfaz amigable, paso a paso, con notificaciones y alertas claras (ej. alertas de exceso de créditos o convalidación de mallas antiguas).
4. **Escalabilidad:** Está diseñado de tal manera que agregar un nuevo plan de estudios (ej. PLAN 2024) solo requiere llenar las tablas correspondientes, sin tocar el código central de matrícula.
