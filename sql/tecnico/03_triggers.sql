-- =========================================================================
-- Archivo: sql/tecnico/03_triggers.sql
-- Etapa V - Tema 3: Triggers de auditoría
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Motor: SQL Server Express (T-SQL)
-- Requisito: haber ejecutado los scripts de sql/ddl y sql/dml (Etapa III)
-- =========================================================================

USE supermercado;
GO

-- =========================================================================
-- PARTE 0. Limpieza para poder ejecutar el script más de una vez
-- Se apagan los triggers (si ya existen) para que el borrado de los
-- productos de prueba de una ejecución anterior no quede auditado.
-- =========================================================================
IF OBJECT_ID('dbo.trg_producto_auditoria_update', 'TR') IS NOT NULL
    DISABLE TRIGGER dbo.trg_producto_auditoria_update ON dbo.producto;
IF OBJECT_ID('dbo.trg_producto_auditoria_delete', 'TR') IS NOT NULL
    DISABLE TRIGGER dbo.trg_producto_auditoria_delete ON dbo.producto;
GO

DELETE FROM dbo.producto WHERE nombre LIKE 'Prueba auditoría%';
GO

-- =========================================================================
-- PARTE 1. Tabla auxiliar de auditoría
-- Guarda una copia de cómo estaba la fila de PRODUCTO antes de cada
-- modificación o borrado, más la operación, la fecha y hora, y el usuario
-- de la base que la hizo. Para los UPDATE también guarda el precio y el
-- stock nuevos, así se ve qué cambió.
-- No tiene FK a PRODUCTO a propósito: tiene que conservar los datos de
-- los productos aunque se borren.
-- =========================================================================
IF OBJECT_ID('dbo.auditoria_producto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.auditoria_producto (
        id_auditoria          INT IDENTITY(1,1) NOT NULL,
        operacion             VARCHAR(10)   NOT NULL,
        fecha_hora            DATETIME2(0)  NOT NULL
            CONSTRAINT DF_auditoria_producto_fecha_hora DEFAULT SYSDATETIME(),
        usuario               NVARCHAR(128) NOT NULL
            CONSTRAINT DF_auditoria_producto_usuario DEFAULT SUSER_SNAME(),
        -- Valores anteriores (copia completa de la fila de producto)
        id_producto           INT           NOT NULL,
        nombre                VARCHAR(150)  NOT NULL,
        descripcion           VARCHAR(255)  NULL,
        precio_anterior       DECIMAL(10,2) NOT NULL,
        estado_anterior       VARCHAR(20)   NOT NULL,
        stock_anterior        INT           NOT NULL,
        id_categoria_anterior INT           NOT NULL,
        -- Valores nuevos (solo en los UPDATE)
        precio_nuevo          DECIMAL(10,2) NULL,
        stock_nuevo           INT           NULL,
        CONSTRAINT PK_auditoria_producto PRIMARY KEY (id_auditoria),
        CONSTRAINT CK_auditoria_producto_operacion CHECK (operacion IN ('UPDATE', 'DELETE'))
    );
END;
GO

-- =========================================================================
-- PARTE 2. Triggers de auditoría sobre PRODUCTO
-- Se usan AFTER: se ejecutan después de que la operación se hizo bien.
-- Dentro del trigger, la tabla virtual "deleted" tiene las filas como
-- estaban antes, e "inserted" como quedaron (solo en los UPDATE).
-- Los dos triggers trabajan con conjuntos de filas: si un UPDATE o un
-- DELETE afecta a varios productos, se audita cada uno.
-- =========================================================================

-- 2.1 Auditoría de modificaciones ------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_producto_auditoria_update
ON dbo.producto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.auditoria_producto
        (operacion, fecha_hora, usuario,
         id_producto, nombre, descripcion, precio_anterior, estado_anterior,
         stock_anterior, id_categoria_anterior, precio_nuevo, stock_nuevo)
    SELECT 'UPDATE', SYSDATETIME(), SUSER_SNAME(),
           d.id_producto, d.nombre, d.descripcion, d.precio, d.estado,
           d.stock, d.id_categoria, i.precio, i.stock
      FROM deleted AS d
           INNER JOIN inserted AS i ON i.id_producto = d.id_producto;
END;
GO

-- 2.2 Auditoría de borrados ------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_producto_auditoria_delete
ON dbo.producto
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.auditoria_producto
        (operacion, fecha_hora, usuario,
         id_producto, nombre, descripcion, precio_anterior, estado_anterior,
         stock_anterior, id_categoria_anterior)
    SELECT 'DELETE', SYSDATETIME(), SUSER_SNAME(),
           d.id_producto, d.nombre, d.descripcion, d.precio, d.estado,
           d.stock, d.id_categoria
      FROM deleted AS d;
END;
GO

-- Se vuelven a encender (por si quedaron apagados en la Parte 0)
ENABLE TRIGGER dbo.trg_producto_auditoria_update ON dbo.producto;
ENABLE TRIGGER dbo.trg_producto_auditoria_delete ON dbo.producto;
GO

-- =========================================================================
-- PARTE 3. Trigger que impide borrar facturas
-- Regla de negocio: una factura emitida es un comprobante fiscal y no se
-- puede borrar. Se usa INSTEAD OF: el trigger se ejecuta EN LUGAR del
-- DELETE, muestra un mensaje y no borra nada.
-- =========================================================================
CREATE OR ALTER TRIGGER dbo.trg_factura_no_borrar
ON dbo.factura
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM deleted)
        THROW 50010, 'Operación no permitida: las facturas emitidas no se pueden borrar.', 1;
END;
GO

-- =========================================================================
-- PARTE 4. Pruebas de los triggers de auditoría
-- Se trabaja con dos productos de prueba para no cambiar los precios y el
-- stock de los productos reales, que usan las consultas de la Etapa IV.
-- =========================================================================

-- 4.1 Productos de prueba (el INSERT no se audita: no hay trigger de INSERT)
INSERT INTO dbo.producto (nombre, descripcion, precio, estado, stock, id_categoria) VALUES
('Prueba auditoría - Café molido 500 g', 'Producto de prueba', 6200.00, 'Activo', 30, 1),
('Prueba auditoría - Jugo de naranja 1 L', 'Producto de prueba', 1800.00, 'Activo', 45, 2);
GO

SELECT id_producto, nombre, precio, stock, estado
  FROM dbo.producto
 WHERE nombre LIKE 'Prueba auditoría%';
GO

-- 4.2 UPDATE de una fila: cambio de precio del café
UPDATE dbo.producto
   SET precio = 6900.00
 WHERE nombre = 'Prueba auditoría - Café molido 500 g';
GO

-- 4.3 UPDATE de varias filas a la vez: aumento del 10 % a los dos productos
--     de prueba (el trigger tiene que registrar dos filas)
UPDATE dbo.producto
   SET precio = ROUND(precio * 1.10, 2)
 WHERE nombre LIKE 'Prueba auditoría%';
GO

-- 4.4 UPDATE de stock: se venden 5 jugos
UPDATE dbo.producto
   SET stock = stock - 5
 WHERE nombre = 'Prueba auditoría - Jugo de naranja 1 L';
GO

-- 4.5 DELETE: se da de baja el jugo
DELETE FROM dbo.producto
 WHERE nombre = 'Prueba auditoría - Jugo de naranja 1 L';
GO

-- 4.6 Resultado: lo que quedó registrado en la tabla de auditoría
SELECT id_auditoria, operacion, fecha_hora, usuario, id_producto, nombre,
       precio_anterior, precio_nuevo, stock_anterior, stock_nuevo, estado_anterior
  FROM dbo.auditoria_producto
 WHERE nombre LIKE 'Prueba auditoría%'
 ORDER BY id_auditoria;
GO

-- 4.7 Un DELETE que falla no deja nada auditado: el producto 1 (yerba)
--     tiene proveedores y ventas, una FK (producto_proveedor o
--     detalle_venta) frena el borrado y, como el trigger es AFTER, no
--     llega a ejecutarse.
DECLARE @antes INT = (SELECT COUNT(*) FROM dbo.auditoria_producto);

BEGIN TRY
    DELETE FROM dbo.producto WHERE id_producto = 1;
END TRY
BEGIN CATCH
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

SELECT @antes AS filas_auditoria_antes,
       (SELECT COUNT(*) FROM dbo.auditoria_producto) AS filas_auditoria_despues;
GO

-- =========================================================================
-- PARTE 5. Prueba del trigger que impide borrar facturas
-- =========================================================================

-- 5.1 Factura antes del intento
SELECT id_factura, numero, fecha, tipo, id_venta
  FROM dbo.factura
 WHERE id_factura = 9;
GO

-- 5.2 Intento de borrado: el trigger muestra el mensaje y no borra
BEGIN TRY
    DELETE FROM dbo.factura WHERE id_factura = 9;
END TRY
BEGIN CATCH
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- 5.3 La factura sigue estando, y la cantidad total de facturas no cambió
SELECT id_factura, numero, fecha, tipo, id_venta
  FROM dbo.factura
 WHERE id_factura = 9;

SELECT COUNT(*) AS facturas_en_la_base FROM dbo.factura;
GO

-- 5.4 Tampoco se puede borrar más de una a la vez
BEGIN TRY
    DELETE FROM dbo.factura WHERE tipo = 'B';
END TRY
BEGIN CATCH
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

SELECT COUNT(*) AS facturas_en_la_base FROM dbo.factura;
GO

-- =========================================================================
-- PARTE 6. Triggers creados en la base
-- =========================================================================
SELECT t.name                     AS trigger_nombre,
       OBJECT_NAME(t.parent_id)   AS tabla,
       CASE WHEN t.is_instead_of_trigger = 1 THEN 'INSTEAD OF' ELSE 'AFTER' END AS tipo,
       te.type_desc               AS evento,
       CASE WHEN t.is_disabled = 1 THEN 'Desactivado' ELSE 'Activo' END AS estado
  FROM sys.triggers AS t
       INNER JOIN sys.trigger_events AS te ON te.object_id = t.object_id
 WHERE t.parent_class = 1
 ORDER BY tabla, trigger_nombre;
GO
