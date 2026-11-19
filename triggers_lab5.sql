USE grados;

-- DISPARADORES (Triggers)

-- Sintaxis básica:

/*

DELIMITER //
CREATE OR REPLACE TRIGGER nombre_trigger
{BEFORE | AFTER} {INSERT | UPDATE | DELETE | INSERT OR UPDATE} ON nombre_tabla
FOR EACH ROW
BEGIN
    -- Código del trigger
    -- Puede usar NEW.columna (valor nuevo)
    -- Puede usar OLD.columna (valor antiguo en UPDATE/DELETE)
END //
DELIMITER ;

*/

-- TRIGGER RN08: Edad mínima para selectividad
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_students_rn08
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
BEGIN
	DECLARE v_age TINYINT;
	IF NEW.access_method = 'Selectividad' THEN
		-- La edad esta en people: el id del alumno es el de la persona (herencia)
		SELECT age INTO v_age FROM people WHERE person_id = NEW.student_id;
		IF v_age < 16 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'RN08: No se puede acceder por Selectividad con menos de 16 años';
		END IF;
	END IF;
	
END //
DELIMITER ;

-- TRIGGER RN02: Nota solo en grupos donde este matriculado
-- RN02: un alumno solo puede tener notas en grupos a los que pertenece
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_grades_rn02
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW
BEGIN 
	DECLARE v_count INT;
	-- ¿Está el alumno en el grupo de la nota?
	SELECT COUNT(*) INTO v_count
	FROM group_enrollments ge 
	WHERE ge.student_id = NEW.student_id
		AND ge.group_id = NEW.group_id;

	IF v_count = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'RN02: El alumno no pertenece al grupo indicado';
	END IF;
END //
DELIMITER ;

-- trigger RN17: una nota por asignatura, convocatoria y año
-- RN17: un alumno no puede tener más de una nota para la misma asignatura,
-- convocatoria y año académico (aunque sean de grupos distintos)
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_grades_rn17
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW
BEGIN
	DECLARE v_exists INT;
	DECLARE v_subject_id INT;
	DECLARE v_academic_year YEAR;
	
	-- calcular la asignatura y año academico para el grupo de la nota
	SELECT subject_id, academic_year INTO v_subject_id, v_academic_year
	FROM groups g 
	WHERE g.group_id = NEW.group_id;
	
	-- otras notas del alumno en esa asignatura, convocatoria y año, en cualquier grupo
	SELECT COUNT(*) INTO v_exists
	FROM grades g
	JOIN groups gr ON gr.group_id = g.group_id
	WHERE g.student_id = NEW.student_id
		AND g.exam_call = NEW.exam_call
		AND gr.subject_id = v_subject_id
		AND gr.academic_year = v_academic_year
		-- excluye la propia fila al actualizar (en INSERT, NEW.grade_id vale 0)
		AND g.grade_id <> NEW.grade_id;
	
	IF v_exists > 0 THEN
	 SIGNAL SQLSTATE '45000'
	 	SET MESSAGE_TEXT = 'RN17: Ya existe una nota para la misma asignatura, convocatoria y año academico';
	END IF;

END //
DELIMITER ;

-- TRIGGER RN05: Límite de cambio en notas
-- RN05: una nota no puede modificarse en más de 4 puntos solo en UPDATE (al insertar no hay valor anterior)
DELIMITER //
CREATE OR REPLACE TRIGGER t_bu_grades_rn05
BEFORE UPDATE ON grades -- SOLO EN UPDATE
FOR EACH ROW
BEGIN
	DECLARE new_grade INT;
	DECLARE old_grade INT;
	
	-- guardar la nota nueva insertada o actualizada
	SELECT g.grade_value INTO new_grade
	FROM grades g
	WHERE g.grade_id = NEW.grade_id;
	
	-- guardar la antigua nota 
	SELECT g.grade_value INTO old_grade
	FROM grades g
	WHERE g.grade_id = OLD.grade_id;
	
	-- comprobar que la variación (en UPDATE) es <= 4
	IF ABS(new_grade - old_grade) > 4 THEN 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'RN05: una nota no puede modificarse en más de 4 puntos';
	END IF;		
END //
DELIMITER ;

-- TRIGGER RN03: Máximo de profesores por grupo
-- RN03: un grupo no puede tener más de 2 profesores asignados
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_teaching_loads_rn03
BEFORE INSERT OR UPDATE ON teaching_loads
FOR EACH ROW
BEGIN
	DECLARE v_count_pf INT;
	
	-- Se comprueba solo si la asignación entra en un grupo:
    -- - en INSERT, OLD.group_id vale NULL: entra siempre
	-- - EN UPDATE: entra si cambia de grupo (<=> trata NULL como un valor)
	IF NOT (NEW.group_id <=> OLD.group_id) THEN
		SELECT COUNT(*) INTO v_count_pf
		FROM teaching_loads
		WHERE group_id = NEW.group_id;
		
		-- comprobar que no hay mas de 2 profesores por grupo
		IF v_count_pf > 2 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'RN03: un grupo no puede tener más de 2 profesores asignados';
		END IF;
	END IF;
END //
DELIMITER ;

-- Triggers RN04 y RN07: Límites de grupos por estudiante
-- RN04: un alumno solo puede estar en un grupo de teoría y en uno de
-- laboratorio por asignatura
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_students_groups_rn04_rn07
BEFORE INSERT OR UPDATE ON group_enrollments
FOR EACH ROW
BEGIN 
	-- 1. seleccionar el subject id la nueva asignatura
	DECLARE v_new_subject INT;
	
	SELECT s.subject_id INTO v_new_subject
	FROM subjects s 
	JOIN groups
	
	-- IF f_student_group_limit (NEW.student_)
	
	
END //
DELIMITER ;









	
