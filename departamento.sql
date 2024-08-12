-- Script: PERSONAS - DEPARTAMENTOS
-- SEMANA 2 BASES
CREATE TABLE personas (
    id_persona NUMBER(10) NOT NULL,
    id_departamento NUMBER(10),
    primer_nombre VARCHAR2(15) NOT NULL,
    nombre_intermedio VARCHAR2(15),
    primer_apellido VARCHAR2(15) NOT NULL,
    segundo_apellido VARCHAR2(15) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    email_persona VARCHAR2(50),
    tipo_persona CHAR(1) NOT NULL,
    salario NUMBER(15) DEFAULT 0,
    CONSTRAINT PK_PERSONAS PRIMARY KEY(id_persona)
);

CREATE TABLE departamentos (
    id_departamento NUMBER(10) NOT NULL,
    id_persona NUMBER(10),
    nombre_departamento VARCHAR2(20) NOT NULL,
    CONSTRAINT PK_DEPARTAMENTO PRIMARY KEY(id_departamento)
);

ALTER TABLE
    personas
ADD
    CONSTRAINT CK_ID_PERSONA CHECK(id_persona > 0);

ALTER TABLE
    personas
ADD
    CONSTRAINT CK_TIPO_PERSONA CHECK(tipo_persona IN ('E', 'I'));

ALTER TABLE
    personas
ADD
    CONSTRAINT CK_SALARIO CHECK(
        (
            tipo_persona = 'I'
            AND salario >= 0
        )
        OR tipo_persona = 'E'
    );

ALTER TABLE
    personas
ADD
    CONSTRAINT CK_EMAIL UNIQUE(email_persona);

ALTER TABLE
    departamentos
ADD
    CONSTRAINT CK_ID_DEPARTAMENTO CHECK(id_departamento > 0);

ALTER TABLE
    personas
ADD
    CONSTRAINT FK_PERSONAS_DEPARTAMENTO FOREIGN KEY(id_departamento) REFERENCES departamentos(id_departamento);

ALTER TABLE
    departamentos
ADD
    CONSTRAINT FK_DEPARTAMENTO_PERSONAS FOREIGN KEY(id_persona) REFERENCES personas(id_persona);

-- Inserción de datos
-- Inserción en la tabla departamentos
INSERT INTO
    departamentos
VALUES
    (1, NULL, 'RH');

-- Inserción en la tabla personas referenciando un departamento existente
INSERT INTO
    personas
VALUES
    (
        1,
        1,
        'Gabriel',
        'Fernando',
        'Castillo',
        'Mendieta',
        TO_DATE('2001-01-03', 'YYYY-MM-DD'),
        'gabo@gmail.com',
        'I',
        100000
    );

SELECT
    *
FROM
    departamentos;

SELECT
    *
FROM
    personas;
