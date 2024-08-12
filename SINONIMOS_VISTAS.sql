-- PUNTO 1
CREATE SYNONYM EMPLEADOS FOR HR.EMPLOYEES;

CREATE SYNONYM DEPARTAMENTOS FOR HR.DEPARTMENTS;

Select
    d.department_name,
    avg(e.salary)
from
    EMPLEADOS e,
    DEPARTAMENTOS d
where
    e.department_id = d.department_id
group by
    d.department_name
having
    avg(e.salary) < 15000;

--
-- PUNTO 2
CREATE VIEW it_department_employees AS
SELECT
    E.FIRST_NAME || ' ' || E.LAST_NAME AS FULL_NAME,
    E.SALARY,
    E.JOB_ID
FROM
    DEPARTAMENTOS D,
    EMPLEADOS E
WHERE
    E.DEPARTMENT_ID = D.DEPARTMENT_ID
    AND D.DEPARTMENT_NAME LIKE 'IT';

CREATE VIEW it_department_employees_MAX_MIN_SALARY AS
SELECT
    ide.FULL_NAME,
    ide.SALARY,
    j.min_salary,
    j.max_salary
FROM
    it_department_employees ide,
    hr.jobs j
WHERE
    ide.job_id = j.job_id;

--
-- PUNTO 3
CREATE VIEW high_value_orders AS
SELECT
    *
FROM
    OE.ORDERS o
WHERE
    o.ORDER_TOTAL > 1000;

CREATE SYNONYM hv_orders FOR high_value_orders;

SELECT
    e.EMPLOYEE_ID,
    e.FIRST_NAME || ' ' || e.LAST_NAME AS FULL_NAME,
    o.ORDER_ID,
    o.CUSTOMER_ID
FROM
    EMPLEADOS e
    JOIN hv_orders o ON e.EMPLOYEE_ID = o.SALES_REP_ID;

--
-- PUNTO 4
CREATE VIEW emp_dep_view AS
SELECT
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    E.SALARY,
    D.DEPARTMENT_NAME,
    (
        SELECT
            FIRST_NAME || ' ' || LAST_NAME
        FROM
            HR.EMPLOYEES M
        WHERE
            M.EMPLOYEE_ID = D.MANAGER_ID
    ) AS MANAGER_NAME
FROM
    HR.EMPLOYEES E
    JOIN HR.DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID;

SELECT
    *
FROM
    emp_dep_view;

SELECT
    DEPARTMENT_NAME,
    COUNT(*) AS NUM_EMPLOYEES
FROM
    emp_dep_view
GROUP BY
    DEPARTMENT_NAME
ORDER BY
    NUM_EMPLOYEES DESC;

-- CO - EVALUACIÓN: 4.5
