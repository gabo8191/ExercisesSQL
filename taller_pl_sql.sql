SET
    SERVEROUTPUT ON -- 1. Cree una tabla con los sub-gerentes (dependientes directos de los dependientes de King).
    CREATE TABLE subgerentes AS(
        SELECT
            *
        FROM
            HR.EMPLOYEES
        WHERE
            MANAGER_ID IN(
                SELECT
                    EMPLOYEE_ID
                FROM
                    HR.EMPLOYEES
                WHERE
                    MANAGER_ID IS NULL
                    AND UPPER(LAST_NAME) = 'KING'
            )
    );

SELECT
    *
FROM
    subgerentes;

-- MODIFICACION: Cree la tabla escalvos (los que no son jefes de ningun empleado ni departamento)
CREATE TABLE esclavos AS(
    SELECT
        *
    FROM
        HR.EMPLOYEES
    WHERE
        EMPLOYEE_ID NOT IN(
            SELECT
                MANAGER_ID
            FROM
                HR.EMPLOYEES
        )
        AND EMPLOYEE_ID NOT IN(
            SELECT
                MANAGER_ID
            FROM
                HR.DEPARTMENTS
        )
);

--2 Elabore un programa PL/SQL que muestre los empleados de un id
--de regi�n ingresado por el usuario y que nunca han cambiado de
--trabajos. El reporte debe mostrar lo siguiente:
-- - Nombre completo (Nombre y Apellido) - Nombre del trabajo
-- - Antig�edad (en meses) **/
DECLARE v_region_id hr.REGIONS.REGION_ID % TYPE := 1;

v_nombre_completo VARCHAR2(100);

v_job_title VARCHAR2(100);

v_antiguedad_en_meses NUMBER(3);

CURSOR c_empleados IS
SELECT
    nombre,
    trabajo,
    antiguedad
FROM
    (
        SELECT
            edv.first_name || ' ' || edv.last_name AS nombre,
            edv.job_title AS trabajo,
            TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date)) AS antiguedad
        FROM
            HR.EMPLOYEES e
            JOIN HR.EMP_DETAILS_VIEW edv ON e.employee_id = edv.employee_id
            JOIN HR.DEPARTMENTS d ON e.department_id = d.department_id
            JOIN HR.LOCATIONS l ON d.location_id = l.location_id
            JOIN HR.COUNTRIES c ON l.country_id = c.country_id
        WHERE
            c.region_id = v_region_id
            AND e.employee_id NOT IN (
                SELECT
                    employee_id
                FROM
                    HR.JOB_HISTORY
            )
    );

BEGIN FOR empleado IN c_empleados LOOP v_nombre_completo := empleado.nombre;

v_job_title := empleado.trabajo;

v_antiguedad_en_meses := empleado.antiguedad;

DBMS_OUTPUT.PUT_LINE('Nombre completo: ' || v_nombre_completo);

DBMS_OUTPUT.PUT_LINE('Trabajo: ' || v_job_title);

DBMS_OUTPUT.PUT_LINE(
    'Antig�edad (en meses): ' || v_antiguedad_en_meses
);

DBMS_OUTPUT.PUT_LINE('-' || RPAD('-', 50, '-'));

END LOOP;

END;

-- PUNTO MODIFICADO CON PROCEDIMIENTO ALMACENADO Y CON PAÍS
/ / --3 Reporte el nombre de los pa�ses con la cantidad de departamentos
--por pa�s que no tienen empleados asignados.
DECLARE CURSOR c_departamentos_sin_empleados IS
SELECT
    c.country_name,
    COUNT(d.department_id) AS num_departamentos
FROM
    HR.COUNTRIES c
    JOIN HR.LOCATIONS l ON c.country_id = l.country_id
    JOIN HR.DEPARTMENTS d ON l.location_id = d.location_id
    LEFT JOIN HR.EMPLOYEES e ON d.department_id = e.department_id
WHERE
    e.employee_id IS NULL
GROUP BY
    c.country_name;

BEGIN DBMS_OUTPUT.PUT_LINE('Pa�s | Departamentos sin empleados');

DBMS_OUTPUT.PUT_LINE('----------------------------------');

FOR registro IN c_departamentos_sin_empleados LOOP DBMS_OUTPUT.PUT_LINE(
    registro.country_name || ' | ' || registro.num_departamentos
);

END LOOP;

END;

/ --4 Cree una vista llamada Proyecci�n, en la cual se ingresar�
--el nombre completo de los empleados, tel�fono, regi�n a la
-- que pertenece y nuevo salario. Lo anterior teniendo en cuenta
--que el nuevo salario se determina bajo las siguientes condiciones:
--- Si el empleado gana menos que el promedio de salario del
-- departamento al que pertenece, en el nuevo salario se le
-- incrementar� el 10% del salario actual, - Si gana m�s que el
-- promedio al que pertenece se le incrementar� el 5%, - Si no
--cumple ninguna de las dos condiciones se le mantendr� el
--salario actual.
CREATE
OR REPLACE VIEW Proyecci � n AS
SELECT
    edv.first_name || ' ' || edv.last_name AS nombre_completo,
    e.phone_number AS tel � fono,
    edv.region_name AS regi � n,
    CASE
        WHEN edv.salary < (
            SELECT
                AVG(edv2.salary)
            FROM
                HR.EMP_DETAILS_VIEW edv2
            WHERE
                edv2.department_id = edv.department_id
        ) THEN edv.salary + (edv.salary * 0.10)
        WHEN edv.salary > (
            SELECT
                AVG(edv3.salary)
            FROM
                HR.EMP_DETAILS_VIEW edv3
            WHERE
                edv3.department_id = edv.department_id
        ) THEN edv.salary + (edv.salary * 0.05)
        ELSE edv.salary
    END AS nuevo_salario
FROM
    HR.EMP_DETAILS_VIEW edv
    JOIN HR.EMPLOYEES e ON edv.EMPLOYEE_ID = e.EMPLOYEE_ID;

SELECT
    *
FROM
    Proyecci � n;

CREATE
OR REPLACE VIEW Proyección AS
SELECT
    edv.first_name || ' ' || edv.last_name AS nombre_completo,
    e.phone_number AS teléfono,
    edv.country_name AS pais,
    CASE
        WHEN edv.salary <= (
            SELECT
                AVG(e2.salary)
            FROM
                HR.EMPLOYEES e2
                JOIN HR.DEPARTMENTS d2 ON e2.department_id = d2.department_id
            WHERE
                d2.department_id = edv.department_id
        ) THEN (
            SELECT
                MAX_SALARY
            FROM
                HR.JOBS
            WHERE
                JOB_ID = edv.job_id
        )
        WHEN edv.salary > (
            SELECT
                AVG(e3.salary)
            FROM
                HR.EMPLOYEES e3
                JOIN HR.DEPARTMENTS d3 ON e3.department_id = d3.department_id
            WHERE
                d3.department_id = edv.department_id
        ) THEN (
            SELECT
                MIN_SALARY
            FROM
                HR.JOBS
            WHERE
                JOB_ID = edv.job_id
        )
        ELSE edv.salary
    END AS nuevo_salario
FROM
    HR.EMP_DETAILS_VIEW edv
    JOIN HR.EMPLOYEES e ON edv.employee_id = e.employee_id;

SELECT
    *
FROM
    Proyección --5
    --Haciendo uso de JOINS, elabore una consulta que retorne la cantidad
    -- de empleados y el promedio de salario por ciudad. Para las ciudades
    -- en las cuales no hay empleados debe mostrarse al frente el n�mero
    -- �0�. No tenga en cuenta los empleados que fueron contratados en
    -- un mes impar.
    DECLARE CURSOR c_empleados_por_ciudad IS
SELECT
    l.city,
    NVL(COUNT(e.employee_id), 0) AS cantidad_empleados,
    NVL(AVG(e.salary), 0) AS promedio_salario
FROM
    HR.LOCATIONS l
    LEFT JOIN HR.DEPARTMENTS d ON l.location_id = d.location_id
    LEFT JOIN HR.EMPLOYEES e ON d.department_id = e.department_id
WHERE
    MOD(
        EXTRACT(
            MONTH
            FROM
                e.hire_date
        ),
        2
    ) = 0
    OR e.hire_date IS NULL
GROUP BY
    l.city;

BEGIN DBMS_OUTPUT.PUT_LINE(
    'Ciudad | Cantidad de Empleados | Promedio de Salario'
);

DBMS_OUTPUT.PUT_LINE(
    '--------------------------------------------------------'
);

FOR registro IN c_empleados_por_ciudad LOOP DBMS_OUTPUT.PUT_LINE(
    registro.city || ' | ' || registro.cantidad_empleados || ' | ' || registro.promedio_salario
);

END LOOP;

END;

/ --6. Haga un programa PL/SQL que solicite un EMPLOYEE_ID y con base en esto imprima si el salario del empleado en menci�n est�
-- por debajo, igual o por encima del promedio de los salarios del trabajo que desempe�a. No haga uso de CASE.
DECLARE v_employee_id HR.EMPLOYEES.EMPLOYEE_ID % TYPE := '&ID';

v_job_title HR.JOBS.JOB_TITLE % TYPE;

v_salary HR.EMPLOYEES.SALARY % TYPE;

v_promedio_salario NUMBER (8, 2);

BEGIN
SELECT
    j.job_title,
    e.salary INTO v_job_title,
    v_salary
FROM
    HR.EMPLOYEES e
    JOIN HR.JOBS j ON e.job_id = j.job_id
WHERE
    e.employee_id = v_employee_id;

SELECT
    AVG(salary) INTO v_promedio_salario
FROM
    HR.EMPLOYEES
WHERE
    job_id = (
        SELECT
            job_id
        FROM
            HR.JOBS
        WHERE
            job_title = v_job_title
    );

IF v_salary < v_promedio_salario THEN DBMS_OUTPUT.PUT_LINE(
    'El salario del empleado est� por debajo del promedio.'
);

ELSIF v_salary = v_promedio_salario THEN DBMS_OUTPUT.PUT_LINE('El salario del empleado es igual al promedio.');

ELSE DBMS_OUTPUT.PUT_LINE(
    'El salario del empleado est� por encima del promedio.'
);

END IF;

END;

/ --7. Cree una tabla con la misma estructura de la tabla EMPLOYEES, posterior a esto elabore una estructura
-- PL/SQL que, al eliminarse un empleado de la tabla, lo inserte en la tabla creada, adicionalmente controle
-- que si el empleado es jefe no se podr� eliminar.
CREATE TABLE EMPLEADOS_COPIA AS
SELECT
    *
FROM
    HR.EMPLOYEES
WHERE
    1 = 0;

CREATE
OR REPLACE PROCEDURE borrar_empleado(
    p_employee_id HR.EMPLOYEES.EMPLOYEE_ID % TYPE
) IS v_manager_id HR.EMPLOYEES.MANAGER_ID % TYPE;

BEGIN
SELECT
    MANAGER_ID INTO v_manager_id
FROM
    HR.EMPLOYEES
WHERE
    EMPLOYEE_ID = p_employee_id;

IF v_manager_id IS NULL THEN raise_application_error(
    -20001,
    'No se puede eliminar un empleado que es jefe.'
);

RETURN;

END IF;

INSERT INTO
    EMPLEADOS_COPIA
SELECT
    *
FROM
    HR.EMPLOYEES
WHERE
    EMPLOYEE_ID = p_employee_id;

DELETE FROM
    HR.EMPLOYEES
WHERE
    EMPLOYEE_ID = p_employee_id;

DBMS_OUTPUT.PUT_LINE('Empleado eliminado y respaldado correctamente.');

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(
    'Empleado con ID ' || p_employee_id || ' no encontrado.'
);

END;

/ --Para eliminar empleado
BEGIN borrar_empleado(200);

END;

/ -- VERSION DE FUNCI�N
CREATE TABLE EMPLEADOS_COPIA AS
SELECT
    *
FROM
    HR.EMPLOYEES
WHERE
    1 = 0;

select
    *
from
    empleados_copia;

CREATE
OR REPLACE FUNCTION borrar_empleado_func(
    p_employee_id HR.EMPLOYEES.EMPLOYEE_ID % TYPE
) RETURN VARCHAR2 IS v_manager_id HR.EMPLOYEES.MANAGER_ID % TYPE;

v_message VARCHAR2(200);

BEGIN
SELECT
    MANAGER_ID INTO v_manager_id
FROM
    HR.EMPLOYEES
WHERE
    EMPLOYEE_ID = p_employee_id;

IF v_manager_id IS NULL THEN RETURN 'No se puede eliminar un empleado que es jefe.';

END IF;

INSERT INTO
    EMPLEADOS_COPIA
SELECT
    *
FROM
    HR.EMPLOYEES
WHERE
    EMPLOYEE_ID = p_employee_id;

DELETE FROM
    HR.EMPLOYEES
WHERE
    EMPLOYEE_ID = p_employee_id;

v_message := 'Empleado eliminado y respaldado correctamente.';

RETURN v_message;

EXCEPTION
WHEN NO_DATA_FOUND THEN RETURN 'Empleado con ID ' || p_employee_id || ' no encontrado.';

END;

/ -- Para usar la funci�n
DECLARE v_result VARCHAR2(200);

BEGIN v_result := borrar_empleado_func(200);

DBMS_OUTPUT.PUT_LINE(v_result);

END;

--8Cree una estructura PL/SQL para con base en un c�digo de empleado ingresado el usuario, se pueda conocer:
-- - El n�mero de veces que el empleado ha cambiado de trabajo, - El n�mero de veces que el empleado ha
-- cambiado de departamento. Se debe imprimir en pantalla un mensaje como el siguiente: �El empleado Pedro
-- P�rez ha cambiado 5 veces de trabajo y 2 veces de departamento�
DECLARE v_employee_id hr.employees.employee_id % TYPE := 150;

v_no_trabajos NUMBER(3);

v_no_departamentos NUMBER(3);

v_employee_name VARCHAR2(100);

BEGIN
SELECT
    first_name || ' ' || last_name INTO v_employee_name
FROM
    hr.employees
WHERE
    employee_id = v_employee_id;

SELECT
    COUNT(DISTINCT JH.JOB_ID) INTO v_no_trabajos
FROM
    HR.JOB_HISTORY JH
WHERE
    JH.EMPLOYEE_ID = v_employee_id;

SELECT
    COUNT(*) INTO v_no_departamentos
FROM
    HR.JOB_HISTORY JH
WHERE
    JH.EMPLOYEE_ID = v_employee_id
    AND (
        JH.END_DATE IS NOT NULL
        OR JH.END_DATE IS NULL
    );

DBMS_OUTPUT.PUT_LINE(
    'El empleado ' || v_employee_name || ' ha cambiado ' || v_no_trabajos || ' veces de trabajo y ' || v_no_departamentos || ' veces de departamento'
);

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(
    'No se encontraron datos para el empleado proporcionado.'
);

END;

/ --9
--Elabore una estructura PL/SQL que retorne el salario de un empleado, considerando las siguientes reglas:
-- - Si el NOMBRE tiene una longitud par el salario debe incluir la comisi�n, de lo contrario solo se imprime el salario.
-- - Si el C�DIGO termina en un numero par, descuente al salario anterior 500, de lo contrario sume 1000.
select
    *
from
    hr.employees;

DECLARE v_employee_name VARCHAR2(100);

v_employee_id HR.EMPLOYEES.EMPLOYEE_ID % TYPE := 116;

v_salary HR.EMPLOYEES.SALARY % TYPE;

v_commission HR.EMPLOYEES.COMMISSION_PCT % TYPE;

v_final_salary NUMBER;

BEGIN
SELECT
    first_name || ' ' || last_name INTO v_employee_name
FROM
    hr.employees
WHERE
    employee_id = v_employee_id;

SELECT
    salary,
    commission_pct INTO v_salary,
    v_commission
FROM
    hr.employees
WHERE
    employee_id = v_employee_id;

IF LENGTH(v_employee_name) MOD 2 = 0 THEN v_final_salary := v_salary + COALESCE(v_salary * v_commission, 0);

ELSE v_final_salary := v_salary;

END IF;

IF MOD(v_employee_id, 2) = 0 THEN v_final_salary := v_final_salary - 500;

ELSE
