SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;

--a--
BEGIN
DBMS_OUTPUT.PUT_LINE('Adid Al Mahamud Shazid');
END;
/

--b--
DECLARE
ID VARCHAR2 (20);
BEGIN
ID := '&Student_Id';
DBMS_OUTPUT.PUT_LINE('Student Id Length: ' || LENGTH(ID));
END;
/
