USE EmpresaDB;
GO

CREATE TABLE Producto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    estado VARCHAR(10) DEFAULT 'ACTIVO'
);
GO

INSERT INTO Producto (descripcion, precio, estado) 
VALUES ('Teclado Inalámbrico', 45000.00, 'ACTIVO');

INSERT INTO Producto (descripcion, precio, estado) 
VALUES ('Mouse optico', 15000.00, 'INACTIVO');

INSERT INTO Producto (descripcion, precio) 
VALUES ('Pad mouse', 180000.00);

INSERT INTO Producto (descripcion, precio) 
VALUES ('Webcam HD', 35000.00);

INSERT INTO Producto (descripcion, precio, estado) 
VALUES ('Auriculares', 8500.00, 'ACTIVO');
GO

SELECT * FROM Producto;
GO

ALTER TABLE Producto 
ADD CONSTRAINT chk_precio_positivo CHECK (precio > 0);
GO

INSERT INTO Producto (descripcion, precio) 
VALUES ('Parlantes Usb', -500.00);
GO

UPDATE Producto 
SET precio = 48000.00 
WHERE id = 1; 
GO

SELECT * FROM Producto;
GO

UPDATE Producto 
SET precio = 0 
WHERE id = 2;
GO
