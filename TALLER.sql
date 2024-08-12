-- 1. Se desea generar una categoría a los empleados, el reporte que se le pide debe
-- mostrar lo siguiente:
-- - Nombre Completo
-- - Tiempo en años trabajando para la compañía
-- - Salario
-- - Fecha de Contratación (Formato Número de día del mes – Nombre del Mes -Dos
-- últimos dígitos del año)
-- - Categoría, A si gana 10000, B si gana 5000, C si gana 1000, D para los demás
-- salarios.
SELECT
  CONCAT (E.FIRST_NAME, CONCAT(' ', E.LAST_NAME)) NOMBRE_EMPLEADO,
  TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) ANTIGUEDAD_ANOS,
  E.SALARY SALARIO,
  REPLACE(TO_CHAR(E.HIRE_DATE, 'DD-MONTH-YY'), ' ') FECHA_CONTRATACION,
  CASE
    WHEN E.SALARY = 10000 THEN 'Categoria A'
    WHEN E.SALARY = 5000 THEN 'Categoria B'
    WHEN E.SALARY = 1000 THEN 'Categoria C'
    ELSE 'Categoria D'
  END AS CATEGORIA
FROM
  HR.EMPLOYEES E;

-- Muestre el nombre completo de los empleados que ocupan alguno de los
-- siguientes códigos de cargos 'IT_PROG', 'SA_MAN'; y fueron contratados entre el
-- año 2005 y 2010.
SELECT
  E.FIRST_NAME || ' ' || E.LAST_NAME NOMBRE_EMPLEADO,
  E.JOB_ID CARGO,
  EXTRACT(
    YEAR
    FROM
      E.HIRE_DATE
  ) AÑO
FROM
  HR.EMPLOYEES E
WHERE
  E.JOB_ID IN ('IT_PROG', 'SA_MAN')
  AND EXTRACT(
    YEAR
    FROM
      E.HIRE_DATE
  ) BETWEEN 2005
  AND 2010;

-- Nombre de los departamentos que no tienen jefe
SELECT
  D.DEPARTMENT_NAME
FROM
  HR.DEPARTMENTS D
WHERE
  D.MANAGER_ID IS NULL;

-- Nombre de los empleados cuya sumatoria de los tres primeros dígitos del teléfono
-- es par.
SELECT
  E.PHONE_NUMBER AS TELEFONO,
  SUBSTR(E.PHONE_NUMBER, 1, 1) AS FIRST_N,
  SUBSTR(E.PHONE_NUMBER, 2, 1) AS SECOND_N,
  SUBSTR(E.PHONE_NUMBER, 3, 1) AS THIRD_N,
  TO_NUMBER(SUBSTR(E.PHONE_NUMBER, 1, 1)) + TO_NUMBER(SUBSTR(E.PHONE_NUMBER, 2, 1)) + TO_NUMBER(SUBSTR(E.PHONE_NUMBER, 3, 1)) AS SUMA_NUMEROS
FROM
  HR.EMPLOYEES E
WHERE
  MOD(
    (
      TO_NUMBER(SUBSTR(E.PHONE_NUMBER, 1, 1)) + TO_NUMBER(SUBSTR(E.PHONE_NUMBER, 2, 1)) + TO_NUMBER(SUBSTR(E.PHONE_NUMBER, 3, 1))
    ),
    2
  ) = 0;

-- Muestre el nombre de los trabajos que tienen una diferencia de más de 10000
-- dólares entre el mínimo y el máximo salario sugerido.
SELECT
  J.JOB_TITLE TRABAJO
FROM
  HR.JOBS J
WHERE
  (J.MAX_SALARY - J.MIN_SALARY) > 10000;

-- Nombre de los países ubicados en la región 4.
SELECT
  C.COUNTRY_NAME
FROM
  HR.COUNTRIES C
WHERE
  C.REGION_ID = 4;

-- . Nombre de los empleados que ganan más de 6500 dólares y su correo inicia por
-- S.
SELECT
  E.FIRST_NAME || ' ' || E.LAST_NAME NOMBRE_EMPLEADO,
  E.EMAIL EMAIL,
  E.SALARY SALARIO
FROM
  HR.EMPLOYEES E
WHERE
  E.SALARY > 6500
  AND UPPER(E.EMAIL) LIKE 'S%';

-- Nombre de los empleados y una columna que diga si tiene o no comisión
SELECT
  E.FIRST_NAME || ' ' || E.LAST_NAME NOMBRE_EMPLEADO,
  E.COMMISSION_PCT COMISION,
  CASE
    WHEN E.COMMISSION_PCT IS NOT NULL
    OR E.COMMISSION_PCT > 0 THEN 'TIENE'
    ELSE 'NO TIENE'
  END AS TIENE_COMISION
FROM
  HR.EMPLOYEES E;

--  Inserte un registro en la tabla empleados solamente con los campos necesarios.
INSERT INTO
  EMPLOYEES
