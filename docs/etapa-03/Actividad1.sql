
CREATE DATABASE EmpresaDB;
GO

USE EmpresaDB;
GO

CREATE TABLE Cliente (
    id INT IDENTITY(1,1) PRIMARY KEY, 
    apellido VARCHAR(50) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    correo_electronico VARCHAR(100) NULL,
    fecha_alta DATE DEFAULT '2026-01-01'
);
GO


ALTER TABLE Cliente 
ADD CONSTRAINT uk_correo_unico UNIQUE (correo_electronico);
GO


INSERT INTO Cliente (apellido, nombre, correo_electronico, fecha_alta) 
VALUES ('Valenzuela', 'Joaquin', 'joaquin.valenzuela@gmail.com', '2026-02-15');

INSERT INTO Cliente (apellido, nombre, correo_electronico) 
VALUES ('Yunes', 'Ramiro', NULL);

INSERT INTO Cliente (apellido, nombre, correo_electronico) 
VALUES ('Aquino', 'Ramiro', 'ramiro.aquino@gmail.com');

INSERT INTO Cliente (apellido, nombre, correo_electronico) 
VALUES ('Vargas', 'Hernan', 'null');

GO

SELECT * FROM Cliente;
GO

INSERT INTO Cliente (apellido, nombre, correo_electronico) 
VALUES ('Lopez', 'Roman', 'joaquin.valenzuela@gmail.com');
GO