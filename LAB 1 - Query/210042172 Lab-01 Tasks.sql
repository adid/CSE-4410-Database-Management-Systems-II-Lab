--1--
select name from
Instructor
Where dept_name = 'Biology';

--2--
Select course_id, title
From course
Where course_id IN
(SELECT course_id 
From takes
Where  ID= '12345');

--3--
SELECT name, dept_name
From Student
Where ID IN
(SELECT distinct ID
From takes Left JOIN course 
ON course.course_id =takes.course_id
Where dept_name = 'Comp. Sci.'  
);

--4--
SELECT name
From Student
Where ID IN
(SELECT distinct ID
From takes 
Where course_id = 'CS-101' AND semester = 'Spring' AND year = '2018');

--5--
SELECT name
FROM Student
WHERE ID IN (
SELECT ID
FROM (
        SELECT ID, RANK() OVER (ORDER BY COUNT(DISTINCT course_id) DESC) as rank
        FROM takes
        WHERE course_id LIKE 'CS%'
        GROUP BY ID
    )
    WHERE rank = 1
);

--6--
SELECT name
FROM Student
WHERE ID IN (
Select takes.ID
From takes,teaches,instructor
Where takes.course_id = teaches.course_id AND teaches.ID = instructor.ID
Group By takes.ID
Having COUNT(distinct instructor.ID)>=3);


--7--
SELECT * FROM 
(SELECT c.title, s.sec_id, COUNT(t.ID) AS enrollment_count
FROM course c JOIN section s ON c.course_id = s.course_id
LEFT JOIN takes t ON s.course_id = t.course_id AND s.sec_id = t.sec_id
GROUP BY s.sec_id, c.title
HAVING COUNT(t.ID) > 0
ORDER BY enrollment_count
)
WHERE ROWNUM = 1;


--8--
Select Max(instructor.name) as name, Max(instructor.dept_name) as department, COUNT(NVL(student.ID,0)) as No_of_Student
From instructor,advisor,Student
Where advisor.s_id= student.ID AND advisor.i_id = instructor.ID
Group By instructor.ID;

--9--
SELECT name, dept_name
From Student
Where ID IN
(SELECT distinct takes.ID
From takes Left JOIN course 
ON course.course_id =takes.course_id
Group By takes.ID
Having COUNT(course.course_id) > (SELECT Avg(COUNT(course.course_id))
From takes Left JOIN course 
ON course.course_id =takes.course_id
Group By takes.ID)
); 

--10--
UPDATE Student
SET tot_cred = 0
WHERE ID IN (SELECT ID FROM Instructor);

INSERT INTO Student (ID, name, dept_name, tot_cred)
SELECT ID, name, dept_name, 0 AS tot_cred
FROM Instructor;

--11--
DELETE FROM Student
WHERE ID IN (SELECT ID FROM Instructor);

--12--
UPDATE Student
SET tot_cred = NVL
(
    (SELECT SUM(course.credits) AS credits
     FROM takes
     LEFT JOIN course ON takes.course_id = course.course_id
     WHERE takes.ID = Student.ID), 0
);

SELECT * FROM Student;

--13--
UPDATE instructor
SET salary = 10000 * (
    SELECT COUNT(DISTINCT teaches.sec_id)
    FROM teaches
    WHERE teaches.ID = instructor.ID
    HAVING COUNT(DISTINCT teaches.sec_id)>2
);

--14--
CREATE TABLE grade_mappings (
    grade CHAR(1) PRIMARY KEY,
    grade_point NUMBER
);

INSERT INTO grade_mappings (grade, grade_point) VALUES ('A', 10);
INSERT INTO grade_mappings (grade, grade_point) VALUES ('B', 8);
INSERT INTO grade_mappings (grade, grade_point) VALUES ('C', 6);
INSERT INTO grade_mappings (grade, grade_point) VALUES ('D', 4);
INSERT INTO grade_mappings (grade, grade_point) VALUES ('F', 0);

SELECT ID,
       SUM(NVL(grade_mappings.grade_point, 0)) / COUNT(DISTINCT takes.course_id) AS CPI
FROM takes
LEFT JOIN grade_mappings ON takes.grade = grade_mappings.grade
GROUP BY ID;
