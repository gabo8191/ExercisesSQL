-- 1. Muestre el nombre y el salario de todos los empleados que ganen más que el promedio de salario de la compañía (incluyendo comisión) y que trabajen en el mismo departamento de un empleado cuyo nombre sea William.
SELECT E.FIRST_NAME||' '||E.LAST_NAME NOMBRE,
    E.SALARY
FROM HR.EMPLOYEES E
WHERE(SELECT AVG(E.SALARY+E.SALARY*NVL(E.COMMISSION_PCT,0)) FROM HR.EMPLOYEES E) < (E.SALARY+E.SALARY*NVL(E.COMMISSION_PCT,0))
    AND E.DEPARTMENT_ID IN (select E.DEPARTMENT_ID
FROM HR.EMPLOYEES E
WHERE UPPER(E.FIRST_NAME) = 'WILLIAM');

-- 2. Genere el historial de trabajos desempeñados por un empleado ingresado por el usuario, incluyendo el actual.
SELECT 
    E.EMPLOYEE_ID,
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    J.JOB_TITLE
FROM 
    HR.EMPLOYEES E
JOIN 
    HR.JOB_HISTORY JH ON E.EMPLOYEE_ID = JH.EMPLOYEE_ID
JOIN
    HR.JOBS J ON JH.JOB_ID = J.JOB_ID
WHERE 
    E.EMPLOYEE_ID = 101
UNION
SELECT 
    E.EMPLOYEE_ID,
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    J.JOB_TITLE
    FROM 
    HR.EMPLOYEES E, HR.JOBS J
    WHERE E.EMPLOYEE_ID = 101
    AND E.JOB_ID = J.JOB_ID

-- 3. Cree una tabla llamada salary_grades para almacenar los siguientes registros: grade lowest_salary highest_salary
-- A 0 3000
-- B 3001 6000
-- C 6001 9000
-- D 9001 12000
-- E 12001 15000
-- F 15001 18000
-- G 18001 99999
-- Posteriormente, haciendo uso de joins, elabore una consulta que retorne: el nombre completo del empleado, grado salarial y nombre del departamento, para todos los empleados ubicados en la región ‘Americas’.

CREATE TABLE SALARY_GRADES(
    GRADE VARCHAR(20),
    LOWEST_SALARY INT,
    HIGHEST_SALARY INT
)

INSERT INTO SALARY_GRADES VALUES('A', 0, 3000);
INSERT INTO SALARY_GRADES VALUES('B', 3001, 6000);
INSERT INTO SALARY_GRADES VALUES('C' ,6001, 9000);
INSERT INTO SALARY_GRADES VALUES( 'D' ,9001 ,12000);
INSERT INTO SALARY_GRADES VALUES( 'E', 12001, 15000);
INSERT INTO SALARY_GRADES VALUES('F' ,15001 ,18000);
INSERT INTO SALARY_GRADES VALUES('G' ,18001 ,99999);

SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    S.GRADE,
    D.DEPARTMENT_NAME
FROM HR.EMPLOYEES E
JOIN HR.DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
JOIN HR.LOCATIONS L ON L.LOCATION_ID = D.LOCATION_ID
JOIN HR.COUNTRIES C ON C.COUNTRY_ID = L.COUNTRY_ID
JOIN HR.REGIONS R ON R.REGION_ID = C.REGION_ID
JOIN SALARY_GRADES S ON E.SALARY BETWEEN S.LOWEST_SALARY AND S.HIGHEST_SALARY
WHERE R.REGION_NAME = 'Americas';

-- 4. Liste los nombres de los empleados que fueron contratados en un mes ingresado por el usuario (el usuario ingresa el nombre del mes).

SELECT 
    E.EMPLOYEE_ID,
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    TO_CHAR(E.HIRE_DATE, 'Month') AS FECHA_CONTRATO
FROM 
    HR.EMPLOYEES E
JOIN 
    HR.JOBS J ON J.JOB_ID = E.JOB_ID
WHERE 
    UPPER(TO_CHAR(E.HIRE_DATE, 'Month')) LIKE '%JUNE%'

-- 5. Muestre el nombre completo y el nombre de la región, de los empleados cuyo sexto digito de teléfono es 3, 
-- ganan más de 4000 dólares y trabaja en el departamento en el que existe el que también labora un empleado con el trabajo de ‘Programmer’
SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
	R.REGION_NAME

