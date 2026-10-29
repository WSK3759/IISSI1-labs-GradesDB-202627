-- 
-- Autor: [Tu Nombre]
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
SELECT DISTINCT s.subject_name
FROM


-- EJERCICIOS PROPUESTOS

-- 1. Estudiantes que nunca han suspendido (todas sus notas ≥ 5).
SELECT p.first_name, p.last_name, AVG(g.grade_value) AS average_grade
FROM people p 
JOIN students s ON s.student_id = p.person_id 
JOIN grades g ON g.student_id = s.student_id 
WHERE g.grade_value >= 5
GROUP BY p.person_id;

-- 2. Profesores que solo imparten teoría (no laboratorios).
SELECT p.first_name, p.last_name
FROM people p
JOIN professors prf ON prf.professor_id = p.person_id 
JOIN teaching_loads tl ON tl.professor_id = prf.professor_id 
JOIN groups g ON g.group_id = tl.group_id 
WHERE g.activity = 'Teoría'
GROUP BY p.person_id;

-- 3. Asignaturas sin grupos creados (usar LEFT JOIN)
SELECT DISTINCT sb.subject_id, sb.subject_name
FROM subjects sb
LEFT JOIN groups g ON g.subject_id <> sb.subject_id
ORDER BY sb.subject_id ASC;

-- 4. Nota media de cada grado en el año 2024.

-- 5. Estudiantes con la mejor nota de cada asignatura.
SELECT p.first_name, p.last_name, AVG(grd.grade_value) AS student_grade
FROM people p
JOIN students s ON s.student_id = p.person_id 
JOIN grades grd ON grd.student_id = s.student_id
JOIN subject_enrollments se ON se.student_id = grd.student_id 
GROUP BY se.subject_id
ORDER BY student_grade DESC;


