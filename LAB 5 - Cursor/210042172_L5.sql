SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;

-----------------------------------------------------1--------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE update_department_budget AS
    total_rows NUMBER(2);
BEGIN
    UPDATE department
    SET budget = budget * 0.9
    WHERE budget > 99999;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No Department satisfied the condition');
    ELSIF SQL%FOUND THEN 
        total_rows := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE(total_rows || ' Department updated');
    END IF; 
END;
/

BEGIN
    update_department_budget;
END;
/


-------------------------------------------------2-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE show_instructors(p_day VARCHAR2, p_start_hour NUMBER, p_end_hour NUMBER) 
AS
BEGIN
    FOR instructor_rec IN (
        SELECT DISTINCT i.name
        FROM instructor i
        JOIN teaches t ON i.ID = t.ID
        JOIN section s ON t.course_id = s.course_id AND t.sec_id = s.sec_id
        JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id
        WHERE ts.day = p_day
        AND (ts.start_hr < p_end_hour OR (ts.start_hr = p_end_hour AND ts.start_min = 0))
        AND (ts.end_hr > p_start_hour OR (ts.end_hr = p_start_hour AND ts.end_min = 0))
    ) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Instructor name: ' || instructor_rec.name);
    END LOOP;
END;
/

DECLARE
    day VARCHAR2(10);
    start_hr NUMBER;
    end_hr NUMBER;

BEGIN
    day:= '&day';
    start_hr:= &start_hour;
    end_hr:= &end_hour;

    show_instructors(day, start_hr, end_hr);
    
END;
/

-------------------------------------------------3----------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE top_students(N IN NUMBER) AS
    counter NUMBER := 0;
BEGIN
    FOR student_record IN (
        SELECT s.ID, s.name, s.dept_name, COUNT(t.course_id) AS num_courses
        FROM student s
        LEFT JOIN takes t ON s.ID = t.ID
        GROUP BY s.ID, s.name, s.dept_name
        ORDER BY num_courses DESC
    ) 
    LOOP
        counter := counter + 1;
        EXIT WHEN counter > N;
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || student_record.ID || ', Name: ' || student_record.name || ', Department: ' || student_record.dept_name || ', Num Courses: ' || student_record.num_courses);
    END LOOP;
END;
/

DECLARE
    student_count NUMBER;

BEGIN
    student_count:= &student_count;
    top_students(student_count);
END;
/


-----------------------------------------------4-----------------------------------------------------------------------------

DECLARE
    dept_name VARCHAR2(50);
    new_id NUMBER;

BEGIN
    SELECT dept_name INTO dept_name
    FROM (
        SELECT dept_name, COUNT(*) AS student_count
        FROM student
        GROUP BY dept_name
        ORDER BY student_count ASC
    )
    WHERE ROWNUM = 1;

    SELECT MAX(TO_NUMBER(ID)) + 1 INTO new_id FROM student;

    INSERT INTO student(ID, name, dept_name, tot_cred) 
    VALUES (new_id, 'Jane Doe', dept_name, 0);

    DBMS_OUTPUT.PUT_LINE('New student inserted successfully.');
END;
/

------------------------------------------------5---------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE assign_advisor AS
    std_id student.ID%TYPE;
    std_name student.name%TYPE;
    std_dept student.dept_name%TYPE;
    adv_id instructor.ID%TYPE;
    adv_name instructor.name%TYPE;
    num_students_advised NUMBER;

BEGIN

    FOR std_rec IN (
        SELECT s.ID, s.name, s.dept_name
        FROM student s
        WHERE s.ID NOT IN (SELECT a.s_ID FROM advisor a)
    )
    LOOP
        std_id := std_rec.ID;
        std_name := std_rec.name;
        std_dept := std_rec.dept_name;

        SELECT ID, name INTO adv_id, adv_name FROM(
            SELECT i.ID, i.name, COUNT(a.s_ID)
            FROM instructor i
            LEFT JOIN advisor a ON i.ID = a.i_ID
            WHERE i.dept_name = std_dept
            GROUP BY i.ID, i.name
            ORDER BY COUNT(a.s_ID) ASC
        )
        WHERE ROWNUM = 1;

        INSERT INTO advisor (s_ID, i_ID) VALUES (std_id, adv_id);

        SELECT COUNT(s_ID) AS num_advised into num_students_advised
        FROM advisor
        GROUP BY i_ID
        HAVING i_ID= adv_id;

        DBMS_OUTPUT.PUT_LINE('Student: ' || std_name || ', Advisor: ' || adv_name || ', Students advised by Advisor: ' || num_students_advised);
    END LOOP;

END;
/

BEGIN
    assign_advisor;
END;
/




