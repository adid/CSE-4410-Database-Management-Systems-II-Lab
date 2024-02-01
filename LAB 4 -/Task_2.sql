--*****a*****--

CREATE OR REPLACE PROCEDURE update_instructor_salaries AS
   CURSOR C_instructor IS SELECT ID, name, salary  
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


--*****b*****--

DECLARE
   course_title VARCHAR2(50);
   student_name VARCHAR2(50);

BEGIN
   FOR course_rec 
   IN (
        SELECT c.title AS course_title, s.name AS student_name
            FROM course c LEFT JOIN prereq p ON c.course_id = p.course_id AND c.course_id = p.prereq_id
                LEFT JOIN takes t ON p.prereq_id = t.course_id AND p.course_id = t.course_id
                LEFT JOIN student s ON t.ID = s.ID) LOOP
      
      course_title := course_rec.course_title;
      student_name := course_rec.student_name;
      
      DBMS_OUTPUT.PUT_LINE('Course Title: ' || course_title || ', Student Name: ' || student_name);
   END LOOP;
END;
/


--*****c*****--



--*****d*****--


--*****e*****--

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