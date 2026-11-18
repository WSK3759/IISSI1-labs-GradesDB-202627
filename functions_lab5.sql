USE grados;

-- Ejemplo 1: Función para calcular nota media de un estudiante

-- Devuelve la nota media del alumno (0 si no tiene notas)
DELIMITER //
CREATE OR REPLACE FUNCTION f_student_average (p_student_id INT) 
RETURNS DECIMAL(4,2)
BEGIN
    DECLARE v_average DECIMAL(4,2) DEFAULT 0;

    -- Sin notas, AVG devuelve NULL: COALESCE lo cambia por 0
    SELECT COALESCE(AVG(grade_value), 0) INTO v_average
    FROM grades
    WHERE student_id = p_student_id;

    RETURN v_average;
END //
DELIMITER ;

-- Para ejecutarla:
-- Usar en una consulta SELECT
SELECT f_student_average(6) AS 'Promedio del estudiante 6';

-- Usarla junto con otros datos
SELECT p.person_id, p.first_name, p.last_name,
       f_student_average(s.student_id) AS promedio
FROM people p
JOIN students s ON s.student_id = p.person_id
ORDER BY promedio DESC;

-- Usar en una cláusula WHERE
SELECT p.first_name, p.last_name
FROM people p
JOIN students s ON s.student_id = p.person_id
WHERE f_student_average(s.student_id) >= 7.0;

-- Ejemplo 2: Función para verificar si un estudiante está matriculado en una asignatura
-- Esta es una función booleana (devuelve TRUE/FALSE) útil para validaciones. Su definición se incorpora al archivo functions.sql.

-- RN07: indica si el alumno está matriculado en la asignatura.
-- La usa el trigger t_biu_students_groups_rn04_rn07
DELIMITER //
CREATE OR REPLACE FUNCTION f_is_student_enrolled(
    p_student_id INT,
    p_subject_id INT
)
RETURNS BOOLEAN
DETERMINISTIC -- La funcion siempre devuelve el mismo resultado para los mismos parámetros
READS SQL DATA -- Indica que la funcion lee datos pero no los modifica
BEGIN
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists
    FROM students s
    JOIN subject_enrollments se ON s.student_id = se.student_id 
    JOIN subjects sb ON se.subject_id = sb.subject_id 
    WHERE se.student_id = p_student_id
      AND se.subject_id = p_subject_id;
    RETURN v_exists > 0;
END //
DELIMITER ;

-- Listar asignaturas con indicador de matrícula del estudiante 6 del grado 3
SELECT s.subject_id, s.subject_name,
       f_is_student_enrolled(6, s.subject_id) AS matriculado
FROM subjects s
WHERE s.degree_id = 3;

-- Usar en un WHERE
SELECT s.subject_name
FROM subjects s
WHERE f_is_student_enrolled(6, s.subject_id) = TRUE;


-- Ejemplo 3: Función para verificar límite de grupos por asignatura
-- Esta función verifica si una asignatura ha alcanzado el número máximo de grupos permitidos 
-- para un tipo de actividad (1 para Teoría, 2 para Laboratorio) en un año académico específico.

-- RN06: indica si la asignatura ya tiene en ese año académico el máximo de
-- grupos de la actividad (uno de teoría o dos de laboratorio)
-- La usa el trigger t_biu_groups_rn06
DELIMITER //
CREATE OR REPLACE FUNCTION f_subject_group_limit_reached (
	p_subject_id INT,
	p_activity VARCHAR(15),
	p_academic_year YEAR
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE v_count INT; -- cuenta el numero de grupos de actividad = p_activity
	DECLARE v_result BOOLEAN DEFAULT FALSE;

	-- Grupos que ya tiene la asignatura de esa actividad en ese año
	SELECT COUNT(*) INTO v_count
	FROM groups g
	WHERE g.subject_id = p_subject_id
		AND g.activity = p_activity
		AND g.academic_year = p_academic_year;
	
	-- El maximo depende de la actividad
	IF p_activity = 'Teoría' THEN
		SET v_result = (v_count >= 1);
	ELSEIF p_activity = 'Laboratorio' THEN
		SET v_result = (v_count >= 2);
	END IF;
	
	RETURN v_result;
END //
DELIMITER ;

-- Para ejecutar:
-- Verificar si la asignatura 1 ya tiene el máximo de grupos de teoría en 2025
SELECT f_subject_group_limit_reached (1, 'Teoría', 2025) AS 'Límite alcanzado';


-- Lista asignaturas que han alcanzado el limite de grupos de teoria
SELECT s.subject_id, s.subject_name, s.acronym
FROM subjects s 
WHERE f_subject_group_limit_reached (s.subject_id , 'Teoría', 2024) = TRUE;

-- FUNCIONES AUXILIARES PARA TRIGGERS
-- Función: f_student_group_limit

-- RN04: indica si el alumno ya está en un grupo de la actividad (teoría o laboratorio)
-- en la asignatura, con limite 1 para teoria o 1 grupo de laboratorio por asignatura.
-- La usa el trigger t_biu_students_groups_rn04_rn07
DELIMITER //
CREATE OR REPLACE FUNCTION f_student_group_limit (
	p_student_id INT,
	p_subject_id INT,
	p_activity VARCHAR(15)
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN 
	DECLARE v_count INT;
	-- Grupos de esa asignatura y actividad en los que ya está el alumno
	SELECT COUNT(*) INTO v_count
	FROM group_enrollments ge
	JOIN groups g ON g.group_id = ge.group_id 
	WHERE ge.student_id  = p_student_id
		AND g.subject_id = p_subject_id
		AND g.activity   = p_activity;

	-- RN04: como máximo un grupo de cada actividad (teoria o laboratorio)
	RETURN v_count >= 1;
END //
DELIMITER ;







