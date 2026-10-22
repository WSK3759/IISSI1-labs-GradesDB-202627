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

-- EJERCICIOS PROPUESTOS

-- 1. Estudiantes que nunca han suspendido (todas sus notas ≥ 5).

SELECT s.student_id , p.dni , p.first_name , g.grade_value 
FROM people p
JOIN students s 
JOIN grades g 
WHERE s.student_id = p.person_id AND s.student_id = g.student_id AND g.grade_value >= 5;