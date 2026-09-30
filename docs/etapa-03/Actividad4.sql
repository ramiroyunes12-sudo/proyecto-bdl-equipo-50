USE EmpresaDB;
GO

CREATE TABLE Pedido (
    numero_pedido INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    importe DECIMAL(10, 2) NOT NULL,
    codigo_cliente INT NOT NULL
);
GO

INSERT INTO Pedido (fecha, importe, codigo_cliente) 
VALUES ('2026-09-20', 15500.50, 1); 

INSERT INTO Pedido (fecha, importe, codigo_cliente) 
VALUES ('2026-09-22', 8200.00, 1);  

INSERT INTO Pedido (fecha, importe, codigo_cliente) 
VALUES ('2026-09-25', 45000.00, 3); 

INSERT INTO Pedido (fecha, importe, codigo_cliente) 
VALUES ('2026-09-26', 12300.75, 4); 
GO

SELECT * FROM Pedido;
GO

ALTER TABLE Pedido 
ADD CONSTRAINT fk_pedido_cliente 
FOREIGN KEY (codigo_cliente) REFERENCES Cliente(id);
GO

INSERT INTO Pedido (fecha, importe, codigo_cliente) 
VALUES ('2026-09-27', 9999.00, 99);
GO