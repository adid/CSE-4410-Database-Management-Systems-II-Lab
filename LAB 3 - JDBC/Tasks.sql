--1--
SELECT COUNT(*) as altered_dept
FROM department
WHERE budget <= 99999;

UPDATE department
SET budget = budget * 0.9
WHERE budget > 99999;
--2--

SELECT DISTINCT i.name
FROM instructor i JOIN teaches t ON i.ID = t.ID 
    JOIN section s ON t.course_id = s.course_id
    JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id
WHERE ts.day = '?' AND ts.start_hr <= '?' AND ts.end_hr >= '?';

--3--

SELECT * FROM (
    SELECT s.ID, s.name, s.dept_name, COUNT(t.course_id) AS num_courses
    FROM student s
    LEFT JOIN takes t ON s.ID = t.ID
    GROUP BY s.ID, s.name, s.dept_name
    ORDER BY num_courses DESC
) WHERE ROWNUM <= N;

--4--
SELECT dept_name
FROM (
    SELECT dept_name, COUNT(*) AS student_count
    FROM student
    GROUP BY dept_name
    ORDER BY student_count ASC
)
WHERE ROWNUM = 1;

SELECT MAX(TO_NUMBER(ID)) AS max_id FROM student;

INSERT INTO student(ID, name, dept_name, tot_cred) VALUES (?, 'Jane Doe', ?, 0);

--5--

SELECT s.ID, s.name, s.dept_name
FROM student s
WHERE s.ID NOT IN (
    SELECT a.s_ID
    FROM advisor a
);

SELECT * FROM (
    SELECT i.ID AS i_ID, i.name, COUNT(a.s_ID) AS num_students_advised
    FROM instructor i
    JOIN advisor a ON a.i_ID = i.ID
    WHERE i.dept_name = '?'
    GROUP BY i.ID, i.name
    ORDER BY num_students_advised ASC
)
WHERE ROWNUM <= 1;




CREATE OR REPLACE PROCEDURE insert_jane_doe AS
    v_dept_name student.dept_name%TYPE;
    v_max_id NUMBER;
BEGIN
    -- Find the department with the lowest number of students
    SELECT dept_name
    INTO v_dept_name
    FROM (
        SELECT dept_name, COUNT(*) AS student_count
        FROM student
        GROUP BY dept_name
        ORDER BY COUNT(*) ASC
    )
    WHERE ROWNUM = 1;

    -- Find the highest existing student ID
    SELECT MAX(TO_NUMBER(ID)) INTO v_max_id FROM student;

    -- Insert Jane Doe into the database
    INSERT INTO student(ID, name, dept_name, tot_cred) 
    VALUES (v_max_id + 1, 'Jane Doe', v_dept_name, 0);

    -- Commit the transaction
    COMMIT;
    
    -- Output success message
    DBMS_OUTPUT.PUT_LINE('Jane Doe successfully inserted into ' || v_dept_name || ' department.');
EXCEPTION
    WHEN OTHERS THEN
        -- Output error message
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK;
END;
/
