-- Proyecto BD I 2026 - Grupo 50 - Supermercado
-- Etapa III - Parte 5: pruebas de restricciones
-- Autor: Luciano Ramiro Aquino
-- Se ejecuta al final, después de todos los scripts de ddl y dml.
-- Las pruebas marcadas "DEBE FALLAR" tienen que dar error: eso demuestra que la restricción funciona.

USE supermercado;
GO

------------------------------------------------------------
-- 1. Verificación de la carga
------------------------------------------------------------

-- Cantidad de filas por tabla (todas deberían tener 8 o más)
SELECT 'categoria' AS tabla, COUNT(*) AS filas FROM categoria
UNION ALL SELECT 'cliente', COUNT(*) FROM cliente
UNION ALL SELECT 'proveedor', COUNT(*) FROM proveedor
UNION ALL SELECT 'metodo_pago', COUNT(*) FROM metodo_pago
UNION ALL SELECT 'producto', COUNT(*) FROM producto
UNION ALL SELECT 'producto_proveedor', COUNT(*) FROM producto_proveedor
UNION ALL SELECT 'venta', COUNT(*) FROM venta
UNION ALL SELECT 'detalle_venta', COUNT(*) FROM detalle_venta
UNION ALL SELECT 'venta_pago', COUNT(*) FROM venta_pago
UNION ALL SELECT 'factura', COUNT(*) FROM factura;
GO

-- En cada venta, lo pagado tiene que ser igual al total de los productos
SELECT v.id_venta,
       (SELECT SUM(subtotal) FROM detalle_venta d WHERE d.id_venta = v.id_venta) AS total_productos,
       (SELECT SUM(monto) FROM venta_pago p WHERE p.id_venta = v.id_venta) AS total_pagado
FROM venta v;
GO

------------------------------------------------------------
-- 2. Venta de prueba para usar en las pruebas siguientes
------------------------------------------------------------
INSERT INTO venta (fecha, id_cliente) VALUES ('2026-09-30 12:00', 1);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
VALUES ((SELECT MAX(id_venta) FROM venta), 1, 2, 4850.00);
INSERT INTO venta_pago (id_venta, id_metodo_pago, monto)
VALUES ((SELECT MAX(id_venta) FROM venta), 1, 9700.00);
GO

------------------------------------------------------------
-- 3. Pruebas que DEBEN FALLAR
------------------------------------------------------------

-- 3.1 NOT NULL: cliente sin nombre
-- Error esperado: 515 (no se puede insertar NULL en la columna 'nombre')
INSERT INTO cliente (dni, nombre, apellido, telefono, email)
VALUES ('11111111', NULL, 'Prueba', '3794000000', 'prueba@mail.com');
GO

-- 3.2 PRIMARY KEY: el mismo método de pago dos veces en la misma venta
-- Error esperado: 2627 (violación de PRIMARY KEY)
INSERT INTO venta_pago (id_venta, id_metodo_pago, monto)
VALUES ((SELECT MAX(id_venta) FROM venta), 1, 100.00);
GO

-- 3.3 FOREIGN KEY: producto con una categoría que no existe
-- Error esperado: 547 (conflicto con la restricción FOREIGN KEY)
INSERT INTO producto (nombre, precio, estado, stock, id_categoria)
VALUES ('Producto de prueba', 1000.00, 'Activo', 10, 999);
GO

-- 3.4 UNIQUE: cliente con un DNI que ya existe
-- Error esperado: 2627 (violación de UNIQUE KEY)
INSERT INTO cliente (dni, nombre, apellido, telefono, email)
VALUES ('30125478', 'Otra', 'Persona', '3794000000', 'otra@mail.com');
GO

-- 3.5 CHECK: producto con precio negativo
-- Error esperado: 547 (conflicto con la restricción CHECK)
INSERT INTO producto (nombre, precio, estado, stock, id_categoria)
VALUES ('Producto de prueba', -500.00, 'Activo', 10, 1);
GO

-- 3.6 CHECK: factura con un tipo que no es A, B ni C
-- Error esperado: 547 (conflicto con la restricción CHECK)
INSERT INTO factura (numero, fecha, tipo, id_venta)
VALUES ('0001-99999998', GETDATE(), 'X', (SELECT MAX(id_venta) FROM venta));
GO

-- 3.7 UNIQUE (relación 1 a 1): segunda factura para la venta de prueba
-- La primera factura se carga bien; la segunda tiene que dar error 2627 (UNIQUE en id_venta)
INSERT INTO factura (numero, fecha, tipo, id_venta)
VALUES ('0001-99999999', GETDATE(), 'B', (SELECT MAX(id_venta) FROM venta));
GO

INSERT INTO factura (numero, fecha, tipo, id_venta)
VALUES ('0001-99999997', GETDATE(), 'B', (SELECT MAX(id_venta) FROM venta));
GO

-- 3.8 Borrar una categoría que tiene productos
-- Error esperado: 547 (la FK de producto no deja borrarla)
DELETE FROM categoria WHERE id_categoria = 1;
GO

------------------------------------------------------------
-- 4. Prueba que DEBE FUNCIONAR: borrado en cascada
------------------------------------------------------------

-- Primero se borra la factura de prueba (factura no tiene cascada)
DELETE FROM factura WHERE numero = '0001-99999999';

-- Guardamos el número de la venta de prueba antes de borrarla
DECLARE @venta INT = (SELECT MAX(id_venta) FROM venta);

DELETE FROM venta WHERE id_venta = @venta;

-- Las dos consultas tienen que devolver 0: el detalle y los pagos se borraron solos
SELECT COUNT(*) AS detalles_que_quedan FROM detalle_venta WHERE id_venta = @venta;
SELECT COUNT(*) AS pagos_que_quedan FROM venta_pago WHERE id_venta = @venta;
GO
