--SCRIPT CREACION BASE DE DATOS PRUEBA
--CREADOR:
--FECHA CREACION:
--OBSERVACIONES:

CREATE TABLE departamentos(
    id_departamento			NUMBER(6) 						NOT NULL,
    id_persona				NUMBER(10)								,
    nombre_departamento 	VARCHAR2(30) 					NOT NULL,
	CONSTRAINT dep_pk_idd PRIMARY KEY (id_departamento)
);

CREATE TABLE personas(
    id_persona 			NUMBER(10) 		NOT NULL,
    id_departamento 	NUMBER(6) 		NOT NULL,
    nombre_persona 		VARCHAR2(30) 	NOT NULL,
    apellido_persona 	VARCHAR2(30) 	NOT NULL,
	fecha_nacimiento 	DATE 			NOT NULL,
    email_persona		VARCHAR2(50) 			,
	tipo_persona 		CHAR(1)			NOT NULL, 
    salario_interno		NUMBER(10,2)			,	
	CONSTRAINT per_pk_idp PRIMARY KEY (id_persona)
);

ALTER TABLE departamentos ADD(
    CONSTRAINT dep_fk_idp FOREIGN KEY (id_persona) REFERENCES personas (id_persona),    
	CONSTRAINT dep_ck_idd CHECK (id_departamento>0),
	CONSTRAINT dep_uq_nom UNIQUE (nombre_departamento)
);

ALTER TABLE personas ADD(
    CONSTRAINT per_fk_idd FOREIGN KEY (id_departamento) REFERENCES departamentos (id_departamento),
    CONSTRAINT per_ck_idp CHECK (id_persona>0),
	CONSTRAINT per_ck_tip CHECK (tipo_persona IN ('I'/*Interno*/,'E'/*Externo*/)),
	CONSTRAINT per_ck_sal CHECK (salario_interno>0)
);

INSERT INTO departamentos VALUES (1, NULL, 'VENTAS');
INSERT INTO personas VALUES (1, 1, 'JUAN','GONZALEZ','17/04/1989',NULL, 'E', NULL);
