--PUNTO 1
SELECT
  FIRST_NAME || ' ' || LAST_NAME "NOMBRE COMPLETO",
  TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) "TIEMPO ANIOS",
  SALARY SALARIO,
  REPLACE(TO_CHAR(HIRE_DATE, 'DD-Month-YY'), ' ') "FECHA CONTRATO",
  DECODE(SALARY, 10000, 'A', 5000, 'B', 1000, 'C', 'D') CATEGORIA
FROM
  EMPLOYEES;

--PUNTO 2
SELECT
  first_name || ' ' || last_name Nombre
FROM
  employees
WHERE
  UPPER(job_id) IN ('IT_PROG', 'SA_MAN')
  AND EXTRACT(
    YEAR
    FROM
      hire_date
  ) BETWEEN 2005
  AND 2010;

--PUNTO 3
SELECT
  DEPARTMENT_NAME "DEPARTMENTS"
FROM
  DEPARTMENTS
WHERE
  MANAGER_ID IS NULL;

--PUNTO 4
SELECT
  first_name || ' ' || last_name "Nombre completo"
FROM
  employees
WHERE
  MOD(
    (SUBSTR(phone_number, 1, 1)) +(SUBSTR(phone_number, 2, 1)) +(SUBSTR(phone_number, 3, 1)),
    2
  ) = 0;

--PUNTO 5
SELECT
  JOB_TITLE
FROM
  JOBS
WHERE
  (MAX_SALARY - MIN_SALARY) > 10000;

--PUNTO 6
SELECT
  COUNTRY_NAME
FROM
  COUNTRIES
WHERE
  REGION_ID = 4;

--PUNTO 7
SELECT
  (first_name || ' ' || last_name) "Nombre Completo"
FROM
  employees
WHERE
  (salary > 6500)
  AND UPPER(email) LIKE 'S%';

--PUNTO 8
SELECT
  first_name || ' ' || last_name "NOMBRE COMPLETO",
  NVL2(commission_pct, 'SI', 'NO') "COMISION"
FROM
  EMPLOYEES;
