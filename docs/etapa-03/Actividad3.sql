USE EmpresaDB;
GO

CREATE TABLE Empleado (
    codigo_empleado INT IDENTITY(1,1) PRIMARY KEY,
    apellido VARCHAR(50) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    dni INT NOT NULL,
    fecha_ingreso DATE NOT NULL
);
GO

ALTER TABLE Empleado 
ADD CONSTRAINT uk_dni_empleado UNIQUE (dni);
GO

INSERT INTO Empleado (apellido, nombre, dni, fecha_ingreso) 
VALUES ('Machado', 'Victor', 45760030, '2022-03-15');

INSERT INTO Empleado (apellido, nombre, dni, fecha_ingreso) 
VALUES ('Valenzuela', 'Ignacio', 46244454, '2023-06-10');

INSERT INTO Empleado (apellido, nombre, dni, fecha_ingreso) 
VALUES ('Aquino', 'Luciano', 46152680, '2024-01-20');

INSERT INTO Empleado (apellido, nombre, dni, fecha_ingreso) 
VALUES ('Vargas', 'Ezequiel', 38573772, '2025-09-01');
GO

SELECT * FROM Empleado;
GO

INSERT INTO Empleado (apellido, nombre, dni, fecha_ingreso) 
VALUES ('Yunes', 'Ruben', 46152680, '2026-02-14');
GO

UPDATE Empleado 
SET dni = 46244454 
WHERE codigo_empleado = 1; 
GO