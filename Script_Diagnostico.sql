--SCRIPT CREACION BASE DE DATOS DIAGNOSTICO
--CREADOR:
--FECHA CREACION:
--OBSERVACIONES:

CREATE TABLE lugares(
    id_lugar 		NUMBER(6) 						NOT NULL,
    id_ubica		NUMBER(6)								,
    nombre_lugar 	VARCHAR2(30) 					NOT NULL,
    tipo_lugar 		CHAR(1) 		DEFAULT 'M'		NOT NULL,
	CONSTRAINT lug_pk_idl PRIMARY KEY (id_lugar)
);

CREATE TABLE personas(
    id_persona 					NUMBER(10) 		NOT NULL,
    id_lugar_nacimiento 		NUMBER(6) 		NOT NULL,
    id_lugar_residencia_actual 	NUMBER(6) 		NOT NULL,
    primer_nombre 				VARCHAR2(15) 	NOT NULL,
    nombre_intermedio 			VARCHAR2(30)			,
    primer_apellido 			VARCHAR2(15) 	NOT NULL,
    segundo_apellido 			VARCHAR2(15) 	NOT NULL,
    telefono 					VARCHAR2(30) 	NOT NULL,
    email 						VARCHAR2(50) 	NOT NULL,
    fecha_nacimiento 			DATE 			NOT NULL,
	CONSTRAINT per_pk_idp PRIMARY KEY (id_persona)
);

CREATE TABLE residencias(
    id_lugar 		NUMBER(6) 					NOT NULL,
    id_persona 		NUMBER(10) 					NOT NULL,
    fecha_inicio 	DATE 		DEFAULT SYSDATE	NOT NULL,
    fecha_fin 		DATE 						NOT NULL,
	CONSTRAINT res_pk_idlidpfec PRIMARY KEY (id_lugar, id_persona, fecha_inicio)
);

ALTER TABLE lugares ADD(
    CONSTRAINT lug_fk_idu FOREIGN KEY (id_ubica) REFERENCES lugares (id_lugar),
    CONSTRAINT lug_ck_tip CHECK (tipo_lugar IN ('P'/*Pais*/, 'D'/*Departamento*/, 'C'/*Ciudad*/)),
	CONSTRAINT lug_ck_idl CHECK (id_lugar>0),
	CONSTRAINTS lug_uq_nom UNIQUE (nombre_lugar, tipo_lugar, id_ubica)
);

ALTER TABLE personas ADD(
    CONSTRAINT per_fk_idln FOREIGN KEY (id_lugar_nacimiento) REFERENCES lugares (id_lugar),
    CONSTRAINT per_fk_idlr FOREIGN KEY (id_lugar_residencia_actual) REFERENCES lugares (id_lugar)
);

ALTER TABLE residencias ADD( 
    CONSTRAINT res_fk_idp FOREIGN KEY (id_persona) REFERENCES personas (id_persona),
    CONSTRAINT res_fk_idl FOREIGN KEY (id_lugar) REFERENCES lugares (id_lugar),
    CONSTRAINT res_ck_fecfin CHECK (fecha_fin > fecha_inicio)
);

