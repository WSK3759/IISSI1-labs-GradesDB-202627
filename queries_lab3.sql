-- 
-- Autor: Jesús Núñez Pelayo
-- Fecha: Enero 2026
-- Descripción: Consultas SQL de ejemplo para GradesDB
--              Cubre conceptos de consultas simples y avanzadas
-- 

USE grados;

-- C1: Recupera todos los campos de todas las asignaturas en la base de datos.

SELECT * 
FROM subjects;

-- C2: Busca la asignatura con acrónimo ‘IISSI-1’.
SELECT *
FROM subjects s 
WHERE s.acronym = 'IISSI-1';

-- C3: Recupera solo las columnas de nombre y acrónimo de todas las asignaturas.

SELECT s.subject_name nombre, s.acronym acrónimo
FROM subjects s;

-- C4: Filtra las asignaturas que son de tipo ‘Formación Básica’.
SELECT *
FROM subjects s 
WHERE s.subject_type = 'Formación Básica';

-- C5: Recupera los estudiantes que accedieron por Selectividad, mostrando su información personal completa.
SELECT p.dni DNI, p.first_name Nombre, p.last_name Apellido, p.age Edad, p.email Email
FROM people p 
JOIN students s 
WHERE s.student_id = p.person_id;

-- C6: Buscar todos los profesores con categoría 'Catedrático'
SELECT p.first_name, p.last_name, p.dni, pr.category 
FROM people p 
JOIN professors pr ON pr.professor_id = p.person_id 
WHERE pr.category = 'Catedrático';

-- V1: Vista v_professors -> Combina información de profesores con sus datos personales
CREATE OR REPLACE VIEW v_professors AS
SELECT pr.professor_id, pr.category, p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id;

SELECT * FROM v_professors;

-- V2: vista v_students -> Combina información de estudiantes con sus datos personales
CREATE OR REPLACE VIEW v_students AS
SELECT s.student_id, s.access_method, p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email
FROM students s
JOIN people p ON s.student_id = p.person_id;

SELECT * FROM v_students;

-- C7: Calcular la nota media del grupo con ID 1
SELECT AVG(g.grade_value) average_grade
FROM grades g 
WHERE g.group_id = 1;

-- C8: Sumar todos los créditos de las asignaturas del grado con ID 3 
-- (Tecnologías Informáticas)

SELECT SUM(sb.credits) total_credits
FROM subjects sb
WHERE sb.degree_id = 3;

-- C9: Contar cuántos estudiantes hay en la base de datos.
SELECT COUNT(*) total_students 
FROM students s;

-- C10: Contar cuántos grupos hay de cada tipo de actividad.
SELECT g.activity, COUNT(g.group_id) AS total_groups
FROM groups g 
GROUP BY g.activity;

-- C11: Encontrar la nota más alta registrada en la base de datos.
SELECT MAX(gr.grade_value) AS max_grade
FROM grades gr;

-- C12: Encontrar la nota más baja registrada.
SELECT MIN(g.grade_value) AS min_grade
FROM grades g;

-- C13: Buscar notas que sean suspensos (< 5) o excelentes (> 9).
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value < 5 OR g.grade_value > 9;

-- C14: Buscar notas entre 5 y 7 (aprobados y notables bajos).
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value BETWEEN 5 AND 7;

-- C15: Buscar asignaturas que tengan exactamente 6 o 12 créditos.
SELECT s.subject_id, s.subject_name, s.credits
FROM subjects s
WHERE s.credits IN (6,12);

-- C16: Buscar personas entre 20 y 30 años.
SELECT p.first_name, p.last_name, p.age
FROM people p 
WHERE p.age BETWEEN 20 AND 30;

-- C17: Obtener la lista de nombres de grupos sin repeticiones.
SELECT DISTINCT g.group_name 
FROM groups g
GROUP BY g.group_name;

-- C18: Listar los diferentes tipos de asignatura existentes.
SELECT DISTINCT sb.subject_type 
FROM subjects sb;

-- C19: Listar los años académicos para los que hay grupos creados, ordenados descendentemente.
SELECT DISTINCT g.academic_year, g.group_name  
FROM groups g
ORDER BY g.academic_year DESC;

-- C20: Encontrar la nota más alta del estudiante con ID 6.
SELECT MAX(gr.grade_value) AS max_grade
FROM grades gr 
WHERE gr.student_id = 6;

-- C21: Encontrar qué estudiantes están matriculados en grupos del año 2024.
SELECT DISTINCT ge.student_id
FROM group_enrollments ge
WHERE ge.group_id IN (
    SELECT g.group_id 
    FROM groups g 
    WHERE g.academic_year = 2024
);

-- C22: Encontrar asignaturas que tengan más créditos que el promedio.
-- 1. calcular el promedio de créditos para todas las asignaturas mediante subconsulta
-- 2. seleccionar las asignaturas con creditos > promedio calculado
SELECT s.subject_name, s.credits
FROM subjects s 
WHERE s.credits > (
	SELECT AVG(s2.credits) AS avg_subject_credits
	FROM subjects s2
);

-- C23: Buscar personas cuyo DNI termina en la letra A.
SELECT p.dni, p.first_name, p.last_name
FROM people p 
WHERE p.dni LIKE '%A';

-- C24: Filtrar asignaturas cuyo nombre empieza con la palabra “Fundamentos”.
SELECT s.subject_name
FROM subjects s
WHERE s.subject_name LIKE 'Fundamentos%';

-- C25: Buscar personas cuyo nombre tiene exactamente 5 letras.
SELECT p.dni, p.first_name, p.last_name
FROM people p 
WHERE p.first_name LIKE '_____';

-- C26: Buscar grupos del año académico 2024.
SELECT g.group_name, g.activity, g.academic_year 
FROM groups g 
WHERE g.academic_year = 2024;

-- C27: Buscar grupos entre 2020 y 2023, ordenados por año.
SELECT g.group_name, g.activity, g.academic_year
FROM groups g 
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;

-- VISTAS COMPLEJAS
-- V1: Filtra solo las notas con matrícula de honor.
CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call, g.with_honors
FROM grades g
WHERE g.with_honors = 1;

SELECT * FROM v_grades_with_honors;

-- V2: Información completa de notas de estudiantes.
CREATE OR REPLACE VIEW v_students_grades AS
SELECT p.person_id, 
	   p.first_name,
	   p.last_name, 
	   p.dni, 
	   g.grade_value, 
	   g.exam_call, 
	   g.with_honors, 
	   gr.group_name, 
	   gr.activity, 
	   gr.academic_year,
	   s.subject_name,
	   s.acronym,
	   s.credits
FROM people p  
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

SELECT * FROM v_students_grades;

-- V3: Información de profesores con sus cargas docentes.
CREATE OR REPLACE VIEW v_professors_loads AS
SELECT p.person_id,
	   p.first_name,
	   p.last_name,
	   pr.category,
	   gr.group_name,
	   gr.activity,
	   gr.academic_year,
	   s.subject_name,
	   s.acronym,
	   tl.credits AS teaching_credits
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

SELECT * FROM v_professors_loads;

-- V4: Estudiantes por grado con su información completa.
CREATE OR REPLACE VIEW v_degree_students_2 AS
SELECT DISTINCT
    d.degree_id,
    d.degree_name,
    p.person_id,
    p.first_name,
    p.last_name,
    st.access_method,
    gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;


SELECT * FROM v_degree_students;

	   
-- C28: Contar cuántas matrículas de honor hay en total usando la vista creada.
SELECT COUNT(*) AS total_honors
FROM v_grades_with_honors;

-- C29: Calcular la nota media de cada estudiante usando v_student_grades.
SELECT vsg.first_name, vsg.last_name, AVG(vsg.grade_value) AS student_mean
FROM v_students_grades AS vsg
GROUP BY vsg.person_id, vsg.first_name, vsg.last_name;

-- ORDER BY, LIMIT y OFFSET: Control de resultados
-- Estas cláusulas controlan el orden y paginación de los resultados.


-- C30: Ordenar todas las notas de menor a mayor valor.
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value ASC;

-- C31: Ordenar las notas de mayor a menor.
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC;

-- C32: Mostrar solo las 5 notas más altas.
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5;

-- C33: Listar notas aprobadas ordenadas por apellido y nombre del estudiante.
SELECT p.first_name, p.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN students s ON g.student_id = s.student_id 
JOIN people p ON s.student_id = p.person_id 
WHERE g.grade_value >= 5
ORDER BY p.last_name ASC, p.first_name ASC;

-- C34: Implementa paginación mostrando las notas 6-10 (segunda página de 5 elementos).
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 5;

-- C35: Mostrar las notas 11-15 (tercera página).
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 10;

-- C36: Ordenar grupos por año (descendente) y luego por nombre (ascendente).
SELECT gp.group_name, gp.activity, gp.academic_year 
FROM groups gp
ORDER BY gp.academic_year DESC, gp.group_name ASC;

-- JOIN: Consultas avanzadas con múltiples tablas
-- Los JOIN permiten combinar filas de diferentes tablas basándose en relaciones entre ellas.

-- C37: Listar estudiantes y los grupos en los que están matriculados.
-- 1. seleccionar nombres y apellidos de estudiantes y cada uno de los grupos en los que están matriculados
-- 2. necesito people, students y groups
-- 3. sin condiciones ni agregación

-- SELECT p.first_name, p.last_name, g.group_name, g.activity, g.academic_year
-- FROM groups g
-- JOIN group_enrollments ge ON g.group_id = ge.group_id
-- JOIN students s ON ge.student_id = s.student_id 
-- JOIN people p ON s.student_id = p.person_id;

-- Consulta 37: Estudiantes con sus grupos (INNER JOIN)
SELECT 
    st.first_name,
    st.last_name,
    gr.group_name,
    gr.activity,
    gr.academic_year
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id;

-- C38: Mostrar asignaturas junto con el nombre de su grado.
-- 1. COLUMNAS s.subject_name, d.degree_name (donde para cada grado habrá muchas asignaturas)
-- 2. relaciones: subjects y degrees
-- 3. Sin filtros ni agregaciones ni filtros de grupos resultantes

-- SELECT sb.subject_name, d.degree_name
-- FROM subjects sb 
-- JOIN degrees d ON sb.degree_id = d.degree_id
-- ORDER BY d.degree_name, sb.course ;

SELECT 
    d.degree_name,
    s.subject_name,
    s.acronym,
    s.credits,
    s.course,
    s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;

-- C39: Mostrar notas con nombres de estudiante y asignatura.
-- SELECT vsg.grade_value, vsg.first_name, vsg.last_name, vsg.subject_name 
-- FROM v_students_grades vsg ;

SELECT vs.first_name, vs.last_name, s.subject_name, s.acronym, g.grade_value
FROM grades g
JOIN v_students vs ON g.student_id = vs.student_id 
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- C40: Listar profesores y los grupos que enseñan.
-- columnas: nombre y apellidos de profesores e informacion completa de sus grupos
-- relaciones: vista v_proffesors, teaching_loads y groups
-- sin filtros ni agregaciones
SELECT vp.first_name, vp.last_name, vp.category, s.subject_name, gp.group_name, gp.activity, gp.academic_year 
FROM v_professors vp 
JOIN teaching_loads tl ON vp.professor_id = tl.professor_id 
JOIN groups gp ON tl.group_id = gp.group_id
JOIN subjects s ON gp.subject_id = s.subject_id ;

-- Consulta 40: Profesores con grupos que imparten
SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    s.subject_name,
    gr.group_name,
    gr.activity,
    tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- C41: Mostrar qué estudiantes están matriculados en qué asignaturas.
-- 1. columnas: informacion de estudiantes e información de asignaturas, 
-- 2. VISTA v_students, groups, subjects
-- SELECT DISTINCT vs.first_name, vs.last_name, sb.subject_name, sb.acronym, sb.subject_type, sb.credits, sb.course
-- FROM v_students vs 
-- JOIN group_enrollments ge ON vs.student_id = ge.student_id 
-- JOIN groups g ON ge.group_id = g.group_id 
-- JOIN subjects sb ON g.subject_id = sb.subject_id
-- ORDER BY vs.last_name, sb.subject_name ;

-- Consulta 41: Estudiantes matriculados en asignaturas (a través de grupos)
SELECT DISTINCT
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    gr.academic_year
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;

-- C42: Mostrar todos los estudiantes, incluso si no tienen notas registradas. (LEFT JOIN)
SELECT vs.first_name, vs.last_name, gr.grade_value, gr.exam_call 
FROM v_students vs 
LEFT JOIN grades gr ON vs.student_id = gr.student_id ;

-- C43: Calcular la nota media y total de notas por estudiante.
-- 1. select: calculo de grade.value, contar person_id por estudiante
-- 2. relaciones: grades, v_students_grades

-- SELECT vsg.first_name, vsg.last_name, AVG(vsg.grade_value) AS average_grade, COUNT(vsg.person_id) AS total_grades
-- FROM v_students_grades vsg 
-- GROUP BY vsg.person_id;

-- Consulta 43: Nota media de cada estudiante
SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name;

-- C44: Contar cuántos estudiantes hay por cada método de acceso.

-- SELECT s.access_method, COUNT(s.student_id) AS total_students
-- FROM students s 
-- GROUP BY s.access_method;

-- Consulta 44: Número de estudiantes por método de acceso
SELECT 
    st.access_method,
    COUNT(*) AS total_students
FROM students st
GROUP BY st.access_method;


-- C45: Contar cuántas asignaturas tiene cada grado.
-- 1. seleccionar: nombre de asignatura, acronimo, nombre de grado

-- SELECT DISTINCT d.degree_name, COUNT(s.subject_id) AS total_subjects
-- FROM degrees d 
-- JOIN subjects s ON s.degree_id = d.degree_id
-- GROUP BY d.degree_name 
-- ORDER BY d.degree_name, s.subject_name;

-- Consulta 45: Número de asignaturas por grado
SELECT 
    d.degree_name,
    COUNT(*) AS total_subjects
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
GROUP BY d.degree_id, d.degree_name;

-- C46: Contar cuántos grupos tiene cada asignatura.
-- 1. seleccionar: nombre asignatura, contar (group_id)
-- 2. relaciones: subjects, groups, 
-- 3. Agrupar por: asignatura
-- 4. ordenar alfabeticamente por asignatura

-- SELECT s.subject_name, COUNT(g.group_id) AS total_groups
-- FROM groups g
-- JOIN subjects s ON s.subject_id = g.subject_id 
-- GROUP BY s.subject_id, s.subject_name, s.acronym;

-- Consulta 46: Número de grupos por asignatura
SELECT 
    s.subject_name,
    s.acronym,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name, s.acronym;

-- C47: Calcular la nota media en cada convocatoria de examen.
-- 1. selecciono: grade_value, exam_call para saber la nota media en cada convocatoria
-- 2. relaciones: grades
-- 3. agrupacion: por exam_call (convocatoria)

-- SELECT g.exam_call, AVG(g.grade_value) AS avg_grade
-- FROM grades g
-- GROUP BY g.exam_call;

SELECT 
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
GROUP BY g.exam_call;

-- C48: Desglosa la nota media por asignatura y convocatoria.
-- 1. necesito: grade_value, la asignatura a la que corresponde dicha nota, y la su convocatoria
-- 2. relaciones: grades, groups, subjects
-- 3. agrupar por: primero asignatura, luego convocatoria
SELECT s.subject_name, g.exam_call, AVG(g.grade_value) AS avg_grade
FROM grades g 
JOIN groups gr ON g.group_id = gr.group_id 
JOIN subjects s ON gr.subject_id = s.subject_id 
GROUP BY s.subject_name , g.exam_call
ORDER BY s.subject_name , g.exam_call ;

-- C49: Contar cuántos estudiantes distintos hay en cada año académico.
-- 1. seleccionar DISTINTO: contar (student_id) distinto para cada año academico, perteneciente a un grupo
-- 2. relaciones: students, groups y group_enrollments
-- 3. agrupar por: año académico, luego grupo

-- SELECT DISTINCT g.academic_year, COUNT(st.student_id) AS total_students
-- FROM groups g
-- JOIN group_enrollments ge ON g.group_id = ge.group_id 
-- JOIN students st ON ge.student_id = st.student_id
-- GROUP BY g.academic_year;

-- Consulta 49: Número de estudiantes por año académico
SELECT gr.academic_year, COUNT(DISTINCT ge.student_id) AS total_students
FROM groups gr
JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.academic_year
ORDER BY gr.academic_year DESC;

-- C50: Sumar los créditos que imparte cada profesor.
-- 1. seleccionar: cada profesor con nombre y apellidos y categoria, SUM(credits de teaching_loads)
-- 2. relaciones: people, professors, teaching_loads
-- 3. agrupar por: group_id de teaching_loads
select p.first_name, p.last_name, pf.category, SUM(tl.credits) AS total_credits
FROM people p 
JOIN professors pf ON p.person_id = pf.professor_id 
JOIN teaching_loads tl ON pf.professor_id = tl.professor_id 
GROUP BY tl.professor_id;

-- C51: Mostrar solo estudiantes cuya nota media supera el 7.
-- 1. seleccionar: nombre y apellidos, AVG(nota media) para ese estudiante
-- 2. relaciones: v_students, grades
-- 3. agrupacion: agrupar por id de estudiante
-- 4. filtrado: teniendo que su nota_media > 7
SELECT st.first_name, st.last_name, AVG(g.grade_value) AS avg_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id 
GROUP BY st.student_id , st.first_name , st.last_name 
HAVING avg_grade > 7;

-- C52: Filtrar asignaturas que tienen más de 3 grupos creados.
-- 1. seleccion: nombre asignatura, COUNT(id grupo) AS total_groups
-- 2. relaciones: subjects, groups
-- 3. agrupar por: id_asignatura, nombre_asignatura
-- 4. filtrar por: teniendo total_groups > 3;
SELECT sb.subject_name, COUNT(gr.group_id) AS total_groups
FROM subjects sb 
JOIN groups gr ON sb.subject_id = gr.subject_id 
GROUP BY sb.subject_id , sb.subject_name 
HAVING total_groups > 3;

-- C53: Identificar grupos con más de 15 estudiantes matriculados.
-- 1. seleccionar: nombres de grupo, contar (id estudiante) asociado a cada grupo
-- 2. relaciones: groups, students, groups_enrollments
-- 3. agrupar por: id de grupo, nombre de grupo
-- 4. filtrar por: teniendo contar(id estudiante) > 15
SELECT g.group_name, g.activity , COUNT(ge.student_id) as total_students
FROM groups g
JOIN group_enrollments ge ON g.group_id = ge.group_id
GROUP BY ge.group_id, g.group_name 
HAVING total_students > 15;


-- C54: Filtrar asignaturas cuya nota media es superior a 5.5.
-- 1. seleccionar: nombre asignatura, acronimo, PROMEDIO(grade_value) asociando cada promedio calculado con el id de asignatura al que pertenece
-- 2. relaciones: subjects, grades, groups
-- 3. agrupar por: id de asignatura, nombre de asignatura
-- 4. filtrar por: PROMEDIO(grade_value) > 5.5
SELECT sb.subject_name, sb.acronym, AVG(g.grade_value) as average_grade
FROM subjects sb
JOIN groups gr ON sb.subject_id = gr.subject_id 
JOIN grades g ON gr.group_id = g.group_id
GROUP BY sb.subject_id , sb.subject_name 
HAVING average_grade > 5.5;

-- CONSULTAS COMPLEJAS COMBINADAS

-- C55: Encontrar las tres asignaturas con 
-- más estudiantes matriculados en grupos del año 2024.

-- 1. seleccionar: nombre_asignatura, acronimo, contar(id estudiante) enrolado en una asignatura
-- 2. relaciones: subjects, group_enrollments, groups
-- 3. agrupar por: asignatura id, nombre asignatura
-- 4. filtrar por (WHERE): año = 2024
-- 4. ordenar por: conteo numero estudiantes desc
-- 5. limitar: 3

SELECT sb.subject_name, COUNT(DISTINCT ge.student_id) AS total_students, gr.academic_year
FROM subjects sb 
JOIN groups gr ON sb.subject_id = gr.subject_id 
JOIN group_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY sb.subject_id, sb.subject_name 
ORDER BY total_students DESC
LIMIT 3;

-- COUNT(DISTINCT ge.student_id) evita contar varias veces 
-- a un estudiante que pertenezca a más de un grupo de 
-- la misma asignatura.

-- C56: Identificar estudiantes con más de 1 matrícula de honor.
-- 1. seleccionar: nombre, apellidos, COUNT(id estudiante), grade_value
-- 2. relaciones: people, students, grades
-- 3. filtrar (WHERE): filas que no cumplan with_honors = 1
-- 4. agrupar por: id estudiante
-- 5. filtrar por: contador > 1
SELECT p.first_name, p.last_name, COUNT(g.student_id) AS total_honor_grades
FROM people p 
JOIN students s ON p.person_id = s.student_id 
JOIN grades g ON s.student_id = g.student_id 
WHERE g.with_honors = 1
GROUP BY s.student_id, p.first_name, p.last_name 
HAVING total_honor_grades > 1;

-- C57: Ordenar grados por número de estudiantes matriculados en 2024.
-- 1. seleccionar: nombre grado, COUNT(id estudiante) matriculado en dicho grado, año academico
-- 2. relaciones: grades, groups, group_enrollments, subjects
-- 3. filtrar: where año academico = 2024
-- 4. agrupar por: id grado, nombre grados
-- 5. ordenar por: contador de estudiantes DESC

SELECT d.degree_name, COUNT(DISTINCT ge.student_id) AS total_degree_students
FROM degrees d 
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups g ON s.subject_id = g.subject_id
JOIN group_enrollments ge ON g.group_id = ge.group_id
WHERE g.academic_year = 2024
GROUP BY d.degree_id, d.degree_name 
ORDER BY total_degree_students DESC;

-- C58: Mostrar la nota más alta de cada estudiante, ordenada descendentemente.
-- 1. seleccionar: nombre, apellido, max(nota de un estudiante)
-- 2. relaciones: people, students, grades
-- 3. ordenar por: nota
SELECT p.first_name, p.last_name, MAX(g.grade_value) AS highest_grade
FROM people p
JOIN students s ON p.person_id = s.student_id 
JOIN grades g ON s.student_id = g.student_id
GROUP BY s.student_id , p.first_name , p.last_name 
ORDER BY highest_grade DESC;

-- C59: Identificar profesores que imparten en más de 1 grupo.
-- 1. seleccionar: nombre, apellido, categoria, COUNT(id grupo)
-- 2. relaciones: people, professors, teaching_loads, groups
-- 3. agrupar por: id profesor, nombre, apellido
-- 4. filtrar por: contador > 1
SELECT p.first_name, p.last_name, pf.category, COUNT(DISTINCT tl.group_id) AS total_groups
FROM people p 
JOIN professors pf ON p.person_id = pf.professor_id 
JOIN teaching_loads tl ON pf.professor_id = tl.professor_id 
JOIN groups g ON tl.group_id = g.group_id 
GROUP BY pf.professor_id , p.first_name , p.last_name 
HAVING total_groups > 1;

-- C60: Mostrar asignaturas que pertenecen a grados con más de 15 asignaturas
-- 1. selec: nombre asignatura, 
-- 2. relaciones: subjects, subconsulta
-- 3. subconsulta: 1. nombre grados, count(id asignatura)

SELECT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id 
WHERE d.degree_id IN (
	SELECT d2.degree_id
	FROM degrees d2 
	JOIN subjects s2 ON d2.degree_id = s2.degree_id 
	GROUP BY d2.degree_id, d2.degree_name 
	HAVING COUNT(DISTINCT s2.subject_id) > 15
	);

-- Consulta 60: Asignaturas que pertenecen a grados con más de 15 asignaturas
SELECT DISTINCT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id
WHERE d.degree_id IN (
    SELECT degree_id
    FROM subjects
    GROUP BY degree_id
    HAVING COUNT(*) > 15
);






-- EJERCICIOS PROPUESTOS

-- 1. Estudiantes que nunca han suspendido (todas sus notas ≥ 5).
SELECT p.first_name, p.last_name, AVG(g.grade_value) AS average_grade
FROM people p 
JOIN students s ON s.student_id = p.person_id 
JOIN grades g ON g.student_id = s.student_id 
GROUP BY p.person_id
HAVING MIN(g.grade_value) >= 5;

-- 2. Profesores que solo imparten teoría (no laboratorios).
SELECT DISTINCT p.first_name, p.last_name
FROM people p
JOIN professors prf ON prf.professor_id = p.person_id 
JOIN teaching_loads tl ON tl.professor_id = prf.professor_id 
JOIN groups g ON g.group_id = tl.group_id 
WHERE g.activity = 'Teoría'
	AND prf.professor_id NOT IN (
		SELECT tl_lab.professor_id
		FROM teaching_loads tl_lab
		JOIN groups g_lab ON g_lab.group_id = tl_lab.group_id 
		WHERE g_lab.activity = 'Laboratorio'
);

-- 3. Asignaturas sin grupos creados (usar LEFT JOIN)
SELECT sb.subject_id, sb.subject_name
FROM subjects sb
LEFT JOIN groups g ON g.subject_id = sb.subject_id
WHERE g.group_id IS NULL 
ORDER BY sb.subject_id ASC;

-- 4. Nota media de cada grado en el año 2024.

-- 5. Estudiantes con la mejor nota de cada asignatura.
-- 		A. Subconsulta para obtener la máxima nota por cada asignatura
-- 		B. Seleccionar los estudiantes agrupandolos junto a su nota para cada asignatura

SELECT p.first_name, p.last_name, max_grade, subject
FROM people p 
JOIN students s ON s.student_id = p.person_id
HAVING sbb.max_grade, sbb.subject IN (
	SELECT MAX(g.grade_value) AS max_grade, sb.subject_name AS subject
	FROM grades g
	JOIN groups gr ON g.group_id = gr.group_id
	JOIN subjects sb ON gr.subject_id = sb.subject_id
	GROUP BY sb.subject_id, sb.subject_name
) AS sbb;



