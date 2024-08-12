-- 1. Se desea proyectar un cambio en las comisiones de los empleados, el reporte
-- que se le pide debe mostrar lo siguiente:
-- - Nombre Completo del empleado
-- - Tiempo en años completos cumplidos trabajando para la compañía
-- - Salario
-- - Fecha de Contratación (Número día – Nombre Mes en alemán-Dos últimos dígitos
-- del año)
-- - Comisión actual
-- - Nuevo porcentaje de comisión, bajo las siguientes condiciones: Si el empleado
-- lleva trabajando más de 20 años se incrementará en 50%, si trabajando entre 10 y
-- 20 años el incremento será de 25%, y para los demás será de 5%.
SELECT
    E.FIRST_NAME || ' ' || E.LAST_NAME AS "NOMBRE COMPLETO",
    ROUND((MONTHS_BETWEEN(SYSDATE, E.HIRE_DATE) / 12), 0) AS "TIEMPO EN AÑOS",
    E.SALARY AS "SALARIO",
    TO_CHAR(
        E.HIRE_DATE,
        'DD-MON-YY',
        'NLS_DATE_LANGUAGE=GERMAN'
    ) AS "FECHA DE CONTRATACION",
    E.COMMISSION_PCT AS "COMISION ACTUAL",
    CASE
        WHEN ROUND((MONTHS_BETWEEN(SYSDATE, E.HIRE_DATE) / 12), 0) > 20 THEN E.COMMISSION_PCT + 0.5
        WHEN ROUND((MONTHS_BETWEEN(SYSDATE, E.HIRE_DATE) / 12), 0) BETWEEN 10
        AND 20 THEN E.COMMISSION_PCT + 0.25
        ELSE E.COMMISSION_PCT + 0.05
    END AS "NUEVO PORCENTAJE DE COMISION"
FROM
    HR.EMPLOYEES E -- Muestre el valor de la nómina a pagar por departamento en un mes y un año
    -- especifico (estos dos datos serán ingresados por el usuario).
SELECT
    D.DEPARTMENT_ID,
    D.DEPARTMENT_NAME,
    TO_CHAR(
        TO_DATE(06 || '-' || 2010, 'MM-YYYY'),
        'Month YYYY'
    ) AS MES_Y_ANIO,
    NVL(SUM(E.SALARY), 0) AS NOMINA_TOTAL
FROM
    HR.DEPARTMENTS D
    LEFT JOIN HR.EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
WHERE
    TO_DATE(06 || '-' || 2010, 'MM-YYYY') BETWEEN TRUNC(E.HIRE_DATE)
    AND SYSDATE
GROUP BY
    D.DEPARTMENT_ID,
    D.DEPARTMENT_NAME;

-- Muestre una consulta que presente la cantidad de empleados contratados en
-- cada ciudad por año, en el periodo 2005 – 2010, así:
SELECT
    *
FROM
    (
        SELECT
            EXTRACT(
                YEAR
                FROM
                    hire_date
            ) AS year,
            d.department_id,
            l.city,
            COUNT(e.employee_id) AS total_employees
        FROM
            hr.employees e
            JOIN hr.departments d ON e.department_id = d.department_id
            JOIN hr.locations l ON d.location_id = l.location_id
        WHERE
            EXTRACT(
                YEAR
                FROM
                    hire_date
            ) BETWEEN 2005
            AND 2010
        GROUP BY
            EXTRACT(
                YEAR
                FROM
                    hire_date
            ),
            d.department_id,
            l.city
    ) PIVOT (
        SUM(total_employees) FOR year IN (2005, 2006, 2007, 2008, 2009, 2010)
    )
ORDER BY
    city;

-- Muestre la cadena de jerarquía de jefes de cada empleado (haga uso de la
-- función CONNECT BY PRIOR).
SELECT
    employee_id,
    last_name,
    level AS hierarchy_level,
    CONNECT_BY_ROOT employee_id AS root_employee_id,
    SYS_CONNECT_BY_PATH(last_name, ' -> ') AS hierarchy_path
FROM
    hr.employees START WITH manager_id IS NULL CONNECT BY PRIOR employee_id = manager_id
ORDER BY
    hierarchy_level,
    employee_id;

--  Muestre el Top 5 de empleados que más ganan en la compañía (Se sugiere
-- consultar el uso de la función RANK)
SELECT
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary
FROM
    (
        SELECT
            employee_id,
            first_name,
            last_name,
            salary,
            RANK() OVER (
                ORDER BY
                    salary DESC
            ) AS salary_rank
        FROM
            hr.employees
    )
WHERE
    salary_rank <= 5;

-- Reporte el total de la nómina por país, incluyendo solo los empleados cuyo código
-- es impar. Si en el país no hay ningún empleado el reporte debe mostrar “No hay
-- empleados” en la columna de la nómina.
SELECT
    country_name AS país,
    CASE
        WHEN COUNT(
            CASE
                WHEN MOD(employee_id, 2) = 1 THEN 1
            END
        ) = 0 THEN 'No hay empleados'
        ELSE TO_CHAR(SUM(salary))
    END AS nómina_total
FROM
    hr.employees
    JOIN hr.departments USING (department_id)
    JOIN hr.locations USING (location_id)
    JOIN hr.countries USING (country_id)
GROUP BY
    country_name;

-- Reporte el porcentaje de empleados que trabajan en cada departamento de la compañía.
SELECT
    department_name AS departamento,
    COUNT(*) AS total_empleados,
    ROUND(
        (COUNT(*) * 100.0) / (
            SELECT
                COUNT(*)
            FROM
                hr.employees
        ),
        2
    ) AS porcentaje_empleados
FROM
    hr.employees
    JOIN hr.departments USING (department_id)
GROUP BY
    department_name -- Nombre de los países en los que por lo menos dos empleados fueron contratados
    -- en la misma fecha que el jefe del departamento al que pertenece.
SELECT
    c.country_name AS país
FROM
    hr.employees e
    JOIN hr.departments d ON e.department_id = d.department_id
    JOIN hr.locations l ON d.location_id = l.location_id
    JOIN hr.countries c ON l.country_id = c.country_id
WHERE
    TRUNC(e.hire_date) IN (
        SELECT
            TRUNC(e2.hire_date)
        FROM
            hr.departments d2
            JOIN hr.employees e2 ON d2.manager_id = e2.employee_id
        WHERE
            d.department_id = d2.department_id
    )
GROUP BY
    c.country_name
HAVING
    COUNT(*) >= 2;

-- Muestre el tiempo en meses que lleva trabajando el empleado con mayor salario
-- en un departamento ingresado por el usuario.
SELECT
    MONTHS_BETWEEN(SYSDATE, e.hire_date) AS tiempo_en_meses
FROM
    hr.employees e
WHERE
    e.department_id = 10
    AND e.salary = (
        SELECT
            MAX(salary)
        FROM
            hr.employees
        WHERE
            department_id = 10
    );

-- Nombre del primer y el ultimo empleado contratado en cada departamento,
-- agregando una columna en el reporte que diga cuál es el último y cuál es el primero.
SELECT
    department_name AS departamento,
    employee_id,
    first_name || ' ' || last_name AS nombre_empleado,
    CASE
        WHEN rn_first = 1 THEN 'Primero'
        ELSE 'Último'
    END AS tipo_empleado
FROM
    (
        SELECT
            d.department_id,
            d.department_name,
            e.employee_id,
            e.first_name,
            e.last_name,
            ROW_NUMBER() OVER (
                PARTITION BY d.department_id
                ORDER BY
                    e.hire_date
            ) AS rn_first,
            ROW_NUMBER() OVER (
                PARTITION BY d.department_id
                ORDER BY
                    e.hire_date DESC
            ) AS rn_last
        FROM
            hr.employees e
            JOIN hr.departments d ON e.department_id = d.department_id
    ) emp
WHERE
    rn_first = 1
    OR rn_last = 1;

