SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;

-----------------------------------------------------------------* Task 1 *---------------------------------------------------------------------------------------------

------------------------------------------------------------------ a ----------------------------------------------------------------------------------------------
BEGIN
DBMS_OUTPUT.PUT_LINE('Adid Al Mahamud Shazid');
END;
/

------------------------------------------------------------------ b ----------------------------------------------------------------------------------------------
DECLARE
ID VARCHAR2 (20);
BEGIN
ID := '&Student_Id';
DBMS_OUTPUT.PUT_LINE('Student Id Length: ' || LENGTH(ID));
END;
/


-----------------------------------------------------------------* Task 2 *---------------------------------------------------------------------------------------------

------------------------------------------------------------------ a ----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE update_instructor_salaries AS
   CURSOR C_instructor 
   IS SELECT ID, name, salary  
   FROM instructor;

   total_credits NUMBER := 0;
   updated_salary NUMBER;

BEGIN
   FOR instructor_rec IN C_instructor 
   LOOP
      SELECT NVL(SUM(c.credits), 0) INTO total_credits
      FROM teaches t LEFT JOIN course c ON t.course_id = c.course_id
      WHERE t.ID = instructor_rec.ID;

      updated_salary := 9000 * total_credits;

      IF updated_salary <> instructor_rec.salary 
      THEN
         UPDATE instructor
         SET salary = updated_salary
         WHERE ID = instructor_rec.ID;
      ELSE
         DBMS_OUTPUT.PUT_LINE('Salary remains unchanged for ' || instructor_rec.name);
      END IF;
   END LOOP;
END update_instructor_salaries;
/

BEGIN
   update_instructor_salaries;
END;
/


------------------------------------------------------------------ b ----------------------------------------------------------------------------------------------

DECLARE
   course_title VARCHAR2(50);
   student_name VARCHAR2(50);

BEGIN
   FOR course_rec IN (
      SELECT * FROM course
   ) LOOP
      
      FOR student_rec IN (
         SELECT s.name AS student_name
         FROM student s 
         JOIN takes t ON t.ID = s.ID
         JOIN course c ON c.course_id = t.course_id
         JOIN prereq p ON c.course_id = p.prereq_id
         WHERE p.course_id = course_rec.course_id
      ) LOOP
      
         course_title := course_rec.title;
         student_name := student_rec.student_name;
      
         DBMS_OUTPUT.PUT_LINE('Course Title: ' || course_title || ', Student Name: ' || student_name);
      END LOOP;
   END LOOP;
END;
/

------------------------------------------------------------------ c ----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE print_weekly_routine(student_name IN VARCHAR2) AS
   day_of_week VARCHAR2(15);
   start_time NUMBER;
   end_time NUMBER;
   course_id VARCHAR2(8);
   course_title VARCHAR2(50);
   building VARCHAR2(15);
   room VARCHAR2(7);

BEGIN
   FOR schedule_rec IN (
      SELECT ts.day, ts.start_hr, ts.start_min, ts.end_hr, ts.end_min, s.course_id, c.title, s.building, s.room_number
      FROM student st
      JOIN takes t ON st.ID = t.ID
      JOIN section s ON t.course_id = s.course_id AND t.sec_id = s.sec_id
      JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id
      JOIN course c ON s.course_id = c.course_id
      WHERE st.name = student_name
      ORDER BY ts.day, ts.start_hr, ts.start_min
   ) LOOP
      day_of_week := schedule_rec.day;
      start_time := schedule_rec.start_hr + schedule_rec.start_min / 100;
      end_time := schedule_rec.end_hr + schedule_rec.end_min / 100;
      course_id := schedule_rec.course_id;
      course_title := schedule_rec.title;
      building := schedule_rec.building;
      room := schedule_rec.room_number;

      DBMS_OUTPUT.PUT_LINE(day_of_week);
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(start_time, '99.99') || ' - ' || TO_CHAR(end_time, '99.99'));
      DBMS_OUTPUT.PUT_LINE(course_id || ' - ' || course_title);
      DBMS_OUTPUT.PUT_LINE(building || ' - ' || room);
      DBMS_OUTPUT.PUT_LINE('-----------------------------');
   END LOOP;

END print_weekly_routine;
/

DECLARE
   student_name VARCHAR2(50);
BEGIN
   student_name := '&Student_Name';
   print_weekly_routine(student_name);
END;
/


------------------------------------------------------------------ d ----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE assign_students_to_instructors AS
BEGIN

   FOR instructor_rec IN (
      SELECT i.ID AS instructor_id, i.name AS instructor_name, i.dept_name
      FROM instructor i
      WHERE i.ID NOT IN (
            SELECT i_ID
            FROM advisor
      )
   ) LOOP

      FOR student_rec IN (
         SELECT s.ID AS student_id, s.name AS student_name, s.dept_name, s.tot_cred
            FROM student s
            WHERE s.dept_name = instructor_rec.dept_name
            AND s.ID NOT IN (
                SELECT s_ID
                FROM advisor
            )
            ORDER BY s.tot_cred ASC
      ) LOOP
            INSERT INTO advisor(s_ID, i_ID) VALUES (student_rec.student_id, instructor_rec.instructor_id);
            EXIT;
      END LOOP;
   END LOOP;

   FOR instructor_rec IN (
      SELECT name
      FROM instructor
      WHERE ID NOT IN (
            SELECT i_ID
            FROM advisor
      )
   ) LOOP
        DBMS_OUTPUT.PUT_LINE('Instructor without students: ' || instructor_rec.name);
   END LOOP;
END assign_students_to_instructors;
/

BEGIN
   assign_students_to_instructors;
END;
/


------------------------------------------------------------------ e ----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_new_instructor AS
   new_instructor_id VARCHAR2(5);
   new_instructor_name VARCHAR2(20) := 'John Doe';
   new_instructor_department VARCHAR2(20);
   new_instructor_salary NUMBER;

   CURSOR c_highest_student_department IS
    SELECT dept_name FROM (
        SELECT dept_name, COUNT(*) AS student_count
        FROM student
        GROUP BY dept_name
        ORDER BY student_count ASC
        )
    WHERE ROWNUM = 1;

BEGIN
   
   OPEN c_highest_student_department;
   FETCH c_highest_student_department INTO new_instructor_department;
   CLOSE c_highest_student_department;

   SELECT MIN(ID) INTO new_instructor_id FROM instructor;

   SELECT AVG(salary) INTO new_instructor_salary
   FROM instructor
   WHERE dept_name = new_instructor_department;

   INSERT INTO instructor (ID, name, dept_name, salary) VALUES (TO_CHAR(TO_NUMBER(new_instructor_id) - 1), new_instructor_name, new_instructor_department, new_instructor_salary);

   DBMS_OUTPUT.PUT_LINE('New Instructor Information:');
   DBMS_OUTPUT.PUT_LINE('ID: ' || TO_CHAR(TO_NUMBER(new_instructor_id) - 1));
   DBMS_OUTPUT.PUT_LINE('Name: ' || new_instructor_name);
   DBMS_OUTPUT.PUT_LINE('Department: ' || new_instructor_department);
   DBMS_OUTPUT.PUT_LINE('Salary: ' || TO_CHAR(new_instructor_salary));

   COMMIT;

END insert_new_instructor;
/

BEGIN
insert_new_instructor;
END;
/