CREATE TABLE Estudiantes (
documento_identidad NUMBER(15) NOT NULL,
nombre VARCHAR2(100) NOT NULL,
apellidos VARCHAR2(100) NOT NULL,
universidad VARCHAR2(100) NOT NULL,
programa VARCHAR2(100) NOT NULL,
correo_institucional VARCHAR2(100) NOT NULL,
numero_celular NUMBER(15) NOT NULL
);

ALTER TABLE Estudiantes
ADD CONSTRAINT PK_estudiantes PRIMARY KEY (documento_identidad);

ALTER TABLE Estudiantes
ADD CONSTRAINT UQ_estudiantes_correo UNIQUE (correo_institucional);


CREATE TABLE Conductores (
documento_identidad NUMBER(15) NOT NULL
);

ALTER TABLE Conductores
ADD CONSTRAINT PK_conductores PRIMARY KEY (documento_identidad);

ALTER TABLE Conductores
ADD CONSTRAINT FK_conductores_estudiante
FOREIGN KEY (documento_identidad)
REFERENCES Estudiantes(documento_identidad)
DEFERRABLE INITIALLY IMMEDIATE;


CREATE TABLE Pasajeros (
documento_identidad NUMBER(15) NOT NULL
);

ALTER TABLE Pasajeros
ADD CONSTRAINT PK_pasajeros PRIMARY KEY (documento_identidad);

ALTER TABLE Pasajeros
ADD CONSTRAINT FK_pasajeros_estudiante
FOREIGN KEY (documento_identidad)
REFERENCES Estudiantes(documento_identidad)
DEFERRABLE INITIALLY IMMEDIATE;


CREATE TABLE Modelos (
modelo VARCHAR2(30) NOT NULL,
marca VARCHAR2(30) NOT NULL
);

ALTER TABLE Modelos
ADD CONSTRAINT PK_modelos PRIMARY KEY (modelo);


CREATE TABLE Vehiculos (
placa VARCHAR2(6) NOT NULL,
modelo VARCHAR2(30) NOT NULL,
anio NUMBER(4) NOT NULL,
color VARCHAR2(15) NOT NULL,
cupos_disponibles NUMBER(2) NOT NULL,
documento_conductor NUMBER(15) NOT NULL
);

ALTER TABLE Vehiculos
ADD CONSTRAINT PK_vehiculos PRIMARY KEY (placa);

ALTER TABLE Vehiculos
ADD CONSTRAINT FK_vehiculos_modelo
FOREIGN KEY (modelo)
REFERENCES Modelos(modelo);

ALTER TABLE Vehiculos
ADD CONSTRAINT FK_vehiculos_conductor
FOREIGN KEY (documento_conductor)
REFERENCES Conductores(documento_identidad)
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE Vehiculos
ADD CONSTRAINT CK_vehiculos_anio
CHECK (anio > 1900);

ALTER TABLE Vehiculos
ADD CONSTRAINT CK_vehiculos_cupos
CHECK (cupos_disponibles > 0);


CREATE TABLE Viajes (
placa VARCHAR2(6) NOT NULL,
fecha DATE NOT NULL,
hora_salida DATE NOT NULL,
punto_origen VARCHAR2(100) NOT NULL,
ruta_general VARCHAR2(200) NOT NULL,
cupos_disponibles NUMBER(2) NOT NULL,
tarifa NUMBER(10,2) NOT NULL,
estado VARCHAR2(15) NOT NULL,
distancia NUMBER(6,2) NOT NULL,
duracion NUMBER(4) NOT NULL
);

ALTER TABLE Viajes
ADD CONSTRAINT PK_viajes PRIMARY KEY (placa, fecha, hora_salida);

ALTER TABLE Viajes
ADD CONSTRAINT FK_viajes_vehiculo
FOREIGN KEY (placa)
REFERENCES Vehiculos(placa);

ALTER TABLE Viajes
ADD CONSTRAINT CK_viajes_cupos
CHECK (cupos_disponibles >= 0);

ALTER TABLE Viajes
ADD CONSTRAINT CK_viajes_tarifa
CHECK (tarifa > 0);

ALTER TABLE Viajes
ADD CONSTRAINT CK_viajes_estado
CHECK (estado IN ('Programado', 'En curso', 'Completado', 'Cancelado'));

ALTER TABLE Viajes
ADD CONSTRAINT CK_viajes_distancia
CHECK (distancia > 0);

ALTER TABLE Viajes
ADD CONSTRAINT CK_viajes_duracion
CHECK (duracion > 0);


CREATE TABLE Lugares (
punto_recogida VARCHAR2(150) NOT NULL,
localidad VARCHAR2(100) NOT NULL
);

ALTER TABLE Lugares
ADD CONSTRAINT PK_lugares PRIMARY KEY (punto_recogida);


CREATE TABLE Paradas (
placa VARCHAR2(6) NOT NULL,
fecha DATE NOT NULL,
hora_salida DATE NOT NULL,
punto_recogida VARCHAR2(150) NOT NULL
);

ALTER TABLE Paradas
ADD CONSTRAINT PK_paradas
PRIMARY KEY (placa, fecha, hora_salida, punto_recogida);

ALTER TABLE Paradas
ADD CONSTRAINT FK_paradas_viaje
FOREIGN KEY (placa, fecha, hora_salida)
REFERENCES Viajes(placa, fecha, hora_salida);

ALTER TABLE Paradas
ADD CONSTRAINT FK_paradas_lugar
FOREIGN KEY (punto_recogida)
REFERENCES Lugares(punto_recogida);


CREATE TABLE Solicitudes (
doc_pasajero NUMBER(15) NOT NULL,
placa VARCHAR2(6) NOT NULL,
fecha DATE NOT NULL,
hora_salida DATE NOT NULL,
punto_recogida VARCHAR2(150) NOT NULL,
estado_solicitud VARCHAR2(15) NOT NULL,
fecha_solicitud DATE NOT NULL
);

ALTER TABLE Solicitudes
ADD CONSTRAINT PK_solicitudes
PRIMARY KEY (doc_pasajero, placa, fecha, hora_salida);

ALTER TABLE Solicitudes
ADD CONSTRAINT FK_solicitudes_pasajero
FOREIGN KEY (doc_pasajero)
REFERENCES Pasajeros(documento_identidad)
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE Solicitudes
ADD CONSTRAINT FK_solicitudes_viaje
FOREIGN KEY (placa, fecha, hora_salida)
REFERENCES Viajes(placa, fecha, hora_salida);

ALTER TABLE Solicitudes
ADD CONSTRAINT FK_solicitudes_parada
FOREIGN KEY (placa, fecha, hora_salida, punto_recogida)
REFERENCES Paradas(placa, fecha, hora_salida, punto_recogida);

ALTER TABLE Solicitudes
ADD CONSTRAINT CK_solicitudes_estado
CHECK (estado_solicitud IN ('Pendiente', 'Aceptada', 'Rechazada', 'Cancelada'));

CREATE TABLE APP_USUARIO_ROL (
    id NUMBER,
    apex_username VARCHAR2(100) NOT NULL,
    documento_identidad NUMBER,
    rol VARCHAR2(20) NOT NULL,
    contrasena VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_APP_USUARIO_ROL PRIMARY KEY (id),
    CONSTRAINT UQ_APP_USUARIO_ROL_USERNAME UNIQUE (apex_username),
    CONSTRAINT CHK_APP_USUARIO_ROL_ROL
        CHECK (rol IN ('ADMINISTRADOR', 'CONDUCTOR', 'PASAJERO'))
);

CREATE SEQUENCE SEQ_APP_USUARIO_ROL
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    INCREMENT BY 1
    START WITH 482
    NOCACHE
    NOORDER
    NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_APP_USUARIO_ROL_BI
BEFORE INSERT ON APP_USUARIO_ROL
FOR EACH ROW
WHEN (NEW.ID IS NULL)
BEGIN
    :NEW.ID := SEQ_APP_USUARIO_ROL.NEXTVAL;
END;
/

CREATE OR REPLACE FUNCTION fn_login_drinkadvisor (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM APP_USUARIO_ROL
    WHERE UPPER(TRIM(apex_username)) = UPPER(TRIM(p_username))
      AND contrasena = p_password;

    RETURN (v_count > 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
/
