-- Nombre de los empleados que atienden clientes fuera de América.
SELECT
    DISTINCT E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME
FROM
    HR.EMPLOYEES E
    JOIN OE.CUSTOMERS C ON E.EMPLOYEE_ID = C.ACCOUNT_MGR_ID
WHERE
    UPPER(C.NLS_TERRITORY) NOT LIKE UPPER('AMERICA') -- Nombre del producto más vendido, en cuanto a cantidad, a clientes en el
    -- periodo 2000 a 2005
SELECT
    p.product_name "NOMBRE DEL PRODUCTO",
    SUM(o.quantity) "CANTIDAD"
FROM
    OE.order_items o
    JOIN OE.product_information p ON p.product_id = o.product_id
    JOIN OE.orders o2 ON o2.order_id = o.order_id
WHERE
    extract (
        YEAR
        FROM
            o2.order_date
    ) BETWEEN 2000
    AND 2005
GROUP BY
    p.product_name
ORDER BY
    cantidad DESC
FETCH FIRST
    1 ROWS ONLY -- CORREGIR FETCH-> CONSULTA ANIDADA
    -- Nombre de las Ordenes que fueron Canceladas por clientes de América.
SELECT
    O.ORDER_ID,
    O.ORDER_DATE,
    O.ORDER_STATUS,
    PI.PRODUCT_NAME,
    C.NLS_TERRITORY,
    C.CUST_FIRST_NAME || ' ' || C.CUST_LAST_NAME
FROM
    OE.CUSTOMERS C
    JOIN OE.ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
    JOIN OE.ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
    JOIN OE.PRODUCT_INFORMATION PI ON OI.PRODUCT_ID = PI.PRODUCT_ID
WHERE
    UPPER(C.NLS_TERRITORY) LIKE UPPER('AMERICA')
    AND O.ORDER_STATUS = 3 -- Producto que se ha vendido más veces en un precio menor al sugerido
SELECT
    COUNT(o.product_id) "CANTIDAD",
    p.product_name "NOMBRE"
FROM
    OE.order_items o
    JOIN OE.product_information p ON p.product_id = o.product_id
WHERE
    o.unit_price < p.list_price
GROUP BY
    p.product_name
ORDER BY
    cantidad DESC
FETCH FIRST
    1 ROW ONLY;

-- Nombre del empleado “roba clientes”, es decir, aquel que pese a que no es
-- el que atendió al cliente fue el que finalmente realizo la venta
SELECT
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_ATTEND,
    E1.FIRST_NAME || ' ' || E1.LAST_NAME AS EMPLOYEE_SELL,
    O.ORDER_ID
FROM
    OE.ORDERS O
    JOIN OE.CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
    JOIN HR.EMPLOYEES E ON C.ACCOUNT_MGR_ID = E.EMPLOYEE_ID
    JOIN HR.EMPLOYEES E1 ON O.SALES_REP_ID = E1.EMPLOYEE_ID
WHERE
    E.EMPLOYEE_ID != E1.EMPLOYEE_ID -- Producto que más se ha vendido por mes
    -- y año, en el periodo 2001 a 2006
SELECT
    *
FROM
    (
        SELECT
            EXTRACT(
                YEAR
                FROM
                    O.ORDER_DATE
            ) AS AÑO,
            TO_CHAR(O.ORDER_DATE, 'MONTH') AS MES,
            PI.PRODUCT_NAME
        FROM
            OE.ORDERS O
            INNER JOIN OE.ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
            INNER JOIN OE.PRODUCT_INFORMATION PI ON OI.PRODUCT_ID = PI.PRODUCT_ID
        WHERE
            EXTRACT(
                YEAR
                FROM
                    O.ORDER_DATE
            ) BETWEEN 2001
            AND 2006
        GROUP BY
            EXTRACT(
                YEAR
                FROM
                    O.ORDER_DATE
            ),
            TO_CHAR(O.ORDER_DATE, 'MONTH'),
            PI.PRODUCT_NAME
    ) PIVOT (
        MAX(PRODUCT_NAME) FOR AÑO IN (
            '2001' AS "2001",
            '2002' AS "2002",
            '2003' AS "2003",
            '2004' AS "2004",
            '2005' AS "2005",
            '2006' AS "2006"
        )
    )
ORDER BY
    TO_DATE(MES, 'MONTH');

-- Producto más comprado por los clientes casados que tienen entre 45 y 50
-- años. Excluya de este reporte a los clientes que fueron atendidos por
-- empleados que ganas más que el promedio de salario del departamento al
-- que pertenecen.
SELECT
    PI.PRODUCT_NAME,
    COUNT(OI.QUANTITY)
FROM
    OE.CUSTOMERS C
    JOIN OE.ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
    JOIN OE.ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
    JOIN OE.PRODUCT_INFORMATION PI ON OI.PRODUCT_ID = PI.PRODUCT_ID
    JOIN HR.EMPLOYEES E ON C.ACCOUNT_MGR_ID = E.EMPLOYEE_ID
WHERE
    UPPER(C.MARITAL_STATUS) = 'MARRIED'
    AND TRUNC(
        MONTHS_BETWEEN(SYSDATE, TO_DATE(C.DATE_OF_BIRTH)) / 12
    ) BETWEEN 45
    AND 50
    AND E.EMPLOYEE_ID NOT IN (
        SELECT
            EMPLOYEE_ID
        FROM
            HR.EMPLOYEES
        WHERE
            (DEPARTMENT_ID, SALARY) IN (
                SELECT
                    DEPARTMENT_ID,
                    AVG(SALARY) AS AVG_SALARY
                FROM
                    HR.EMPLOYEES
                GROUP BY
                    DEPARTMENT_ID
            )
    )
GROUP BY
    PI.PRODUCT_NAME;

-- Clientes que más compraron “online” el producto que menos ganancias le ha
-- dejado a la empresa.
SELECT
    C.CUST_FIRST_NAME || ' ' || C.CUST_LAST_NAME CUSTOMER_NAME,
    O.ORDER_MODE,
    COUNT(O.ORDER_ID)
FROM
    OE.CUSTOMERS C
    JOIN OE.ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
    JOIN OE.ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
    JOIN OE.PRODUCT_INFORMATION PI ON OI.PRODUCT_ID = PI.PRODUCT_ID
WHERE
    UPPER(O.ORDER_MODE) LIKE 'ONLINE'
    AND PI.LIST_PRICE = (
        SELECT
            MIN(PI.LIST_PRICE)
        FROM
            OE.CUSTOMERS C
            JOIN OE.ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
            JOIN OE.ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
            JOIN OE.PRODUCT_INFORMATION PI ON OI.PRODUCT_ID = PI.PRODUCT_ID
        WHERE
            UPPER(O.ORDER_MODE) LIKE 'ONLINE'
    ) -- (SELECT MIN(PI.LIST_PRICE)
    -- FROM OE.PRODUCT_INFORMATION PI
    -- ORDER BY 1 DESC)
GROUP BY
    C.CUST_FIRST_NAME || ' ' || C.CUST_LAST_NAME,
    O.ORDER_MODE
ORDER BY
    3 DESC -- Nombre del empleado de América con mayor número de clientes que han
    -- realizado compras en la modalidad “direct” del producto más vendido de cada
    -- categoría.
SELECT
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    R.REGION_NAME,
    D.DEPARTMENT_NAME,
    TP.CATEGORY_NAME,
    TP.PRODUCT_NAME
FROM
    (
        SELECT
            E.EMPLOYEE_ID,
            COUNT(DISTINCT O.CUSTOMER_ID) AS NUM_CUSTOMERS
        FROM
            HR.EMPLOYEES E
            JOIN HR.DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
            JOIN HR.LOCATIONS L ON L.LOCATION_ID = D.LOCATION_ID
            JOIN HR.COUNTRIES C ON C.COUNTRY_ID = L.COUNTRY_ID
            JOIN HR.REGIONS R ON R.REGION_ID = C.REGION_ID
            JOIN OE.ORDERS O ON O.SALES_REP_ID = E.EMPLOYEE_ID
        WHERE
            R.REGION_NAME = 'Americas'
        GROUP BY
            E.EMPLOYEE_ID
    ) EC
    JOIN HR.EMPLOYEES E ON E.EMPLOYEE_ID = EC.EMPLOYEE_ID
    JOIN HR.DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
    JOIN HR.LOCATIONS L ON L.LOCATION_ID = D.LOCATION_ID
    JOIN HR.COUNTRIES C ON C.COUNTRY_ID = L.COUNTRY_ID
    JOIN HR.REGIONS R ON R.REGION_ID = C.REGION_ID
    JOIN (
        SELECT
            CT.CATEGORY_NAME,
            PI.PRODUCT_NAME,
            COUNT(DISTINCT O.CUSTOMER_ID) AS NUM_CUSTOMERS
        FROM
            OE.ORDERS O
            JOIN OE.ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
            JOIN OE.PRODUCT_INFORMATION PI ON PI.PRODUCT_ID = OI.PRODUCT_ID
            JOIN OE.CATEGORIES_TAB CT ON CT.CATEGORY_ID = PI.CATEGORY_ID
        WHERE
            UPPER(O.ORDER_MODE) LIKE 'DIRECT'
        GROUP BY
            CT.CATEGORY_NAME,
            PI.PRODUCT_NAME
    ) TP ON TP.NUM_CUSTOMERS = EC.NUM_CUSTOMERS
ORDER BY
    EC.NUM_CUSTOMERS DESC
FETCH FIRST
    1 ROWS ONLY;

-- Valor de la nómina a pagar por empleado del departamento de ventas en el
-- mes de enero de 2018. La consulta debe mostrar:
-- - Nombre completo del empleado
-- - Salario base
-- - Valor de la comisión, la cual se calcula sobre las ventas realizadas en el
-- mes.
-- - Salario total (salario base + comisión)
SELECT
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    E.SALARY AS BASE_SALARY,
    NVL(SUM(NVL(O.ORDER_TOTAL, 0) * E.COMMISSION_PCT), 0) AS COMMISSION,
    E.SALARY + NVL(SUM(NVL(O.ORDER_TOTAL, 0) * E.COMMISSION_PCT), 0) AS TOTAL_SALARY
FROM
    HR.EMPLOYEES E
    LEFT JOIN OE.ORDERS O ON E.EMPLOYEE_ID = O.SALES_REP_ID
    JOIN HR.DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
WHERE
    EXTRACT(
        MONTH
        FROM
            NVL(O.ORDER_DATE, DATE '2006-01-01')
    ) = 1
    AND EXTRACT(
        YEAR
        FROM
            NVL(O.ORDER_DATE, DATE '2006-01-01')
    ) = 2006
    AND UPPER(D.DEPARTMENT_NAME) = 'SALES'
GROUP BY
    E.FIRST_NAME,
    E.LAST_NAME,
    E.SALARY;

-- calcular el total de ventas por pais para el año 2008
SELECT
    C.COUNTRY_NAME AS PAIS,
    SUM(O.ORDER_TOTAL) AS TOTAL_VENTAS
FROM
    HR.EMPLOYEES E
    JOIN HR.DEPARTMENTS D ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
    JOIN HR.LOCATIONS L ON L.LOCATION_ID = D.LOCATION_ID
    JOIN HR.COUNTRIES C ON C.COUNTRY_ID = L.COUNTRY_ID
    JOIN OE.ORDERS O ON E.EMPLOYEE_ID = O.SALES_REP_ID
WHERE
    EXTRACT(
        YEAR
        FROM
            O.ORDER_DATE
    ) = 2008
GROUP BY
    C.COUNTRY_NAME;

SELECT
    O.ORDER_DATE
FROM
    OE.ORDERS O
