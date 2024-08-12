-- 2. Muestre el valor de la nómina a pagar por departamento en un mes y un año
-- especifico (estos dos datos serán ingresados por el usuario).

SELECT
    d.department_name,
    ROUND(
        NVL(
            SUM(
                CASE
                    WHEN EXTRACT(MONTH FROM e.hire_date) = 06 AND EXTRACT(YEAR FROM e.hire_date) = 2003 THEN
                        e.salary * (LAST_DAY(e.hire_date) - e.hire_date + 1)
                    WHEN EXTRACT(MONTH FROM e.hire_date) < 06 AND EXTRACT(YEAR FROM e.hire_date) = 2003 THEN
                        e.salary / 30
                    ELSE
                        0
                END
            ), 0
        ), 2
    ) AS total_salary
FROM
    hr.employees e
JOIN
    hr.departments d ON e.department_id = d.department_id
GROUP BY
    d.department_name;

-- 9. Muestre el tiempo en meses que lleva trabajando el empleado con mayor salario
-- en un departamento ingresado por el usuario.

SELECT 
    MONTHS_BETWEEN(SYSDATE, e.hire_date) AS tiempo_en_meses, e.first_name || ' ' || e.last_name
FROM 
    hr.employees e
WHERE 
    e.department_id = (SELECT d.department_id FROM hr.departments d WHERE UPPER(d.department_name) like 'SALES')
AND 
    e.salary = (SELECT MAX(salary) FROM hr.employees WHERE department_id = (SELECT d.department_id FROM hr.departments d WHERE UPPER(d.department_name) like 'SALES'));
