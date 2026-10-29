-- =========================================================================
-- Archivo: sql/tecnico/01_procedimientos_funciones.sql
-- Etapa V - Tema 1: Procedimientos y funciones almacenadas
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Autor: Ramiro Yunes
-- Motor: SQL Server Express (T-SQL)
-- Requisito: haber ejecutado los scripts de sql/ddl y sql/dml (Etapa III)
-- =========================================================================

USE supermercado;
GO

-- =========================================================================
-- PARTE 0. Limpieza para poder ejecutar el script más de una vez
-- Borra solo los clientes de prueba de este script (DNI 5xxxxxxx), que
-- nunca tienen ventas, así que no hay problema con las FK.
-- =========================================================================
DELETE FROM dbo.cliente WHERE dni LIKE '5%';
GO

-- =========================================================================
-- PARTE 1. Procedimientos almacenados sobre la tabla CLIENTE
-- Se eligió CLIENTE porque los clientes nuevos no tienen ventas: se pueden
-- insertar, modificar y borrar sin chocar con las FK de VENTA.
-- =========================================================================

-- 1.1 Insertar un cliente --------------------------------------------------
-- Valida que el DNI no exista (además de la restricción UNIQUE) y devuelve
-- el id generado en un parámetro de salida opcional.
CREATE OR ALTER PROCEDURE dbo.sp_cliente_insertar
    @dni        VARCHAR(20),
    @nombre     VARCHAR(100),
    @apellido   VARCHAR(100),
    @telefono   VARCHAR(30)  = NULL,
    @email      VARCHAR(100) = NULL,
    @id_cliente INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.cliente WHERE dni = @dni)
        THROW 50001, 'Ya existe un cliente con ese DNI.', 1;

    INSERT INTO dbo.cliente (dni, nombre, apellido, telefono, email)
    VALUES (@dni, @nombre, @apellido, @telefono, @email);

    SET @id_cliente = SCOPE_IDENTITY();
END;
GO

-- 1.2 Modificar un cliente -------------------------------------------------
-- Cambia los datos de contacto y el nombre. El DNI no se modifica porque
-- identifica a la persona.
CREATE OR ALTER PROCEDURE dbo.sp_cliente_modificar
    @id_cliente INT,
    @nombre     VARCHAR(100),
    @apellido   VARCHAR(100),
    @telefono   VARCHAR(30)  = NULL,
    @email      VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.cliente WHERE id_cliente = @id_cliente)
        THROW 50002, 'No existe un cliente con ese id.', 1;

    UPDATE dbo.cliente
       SET nombre   = @nombre,
           apellido = @apellido,
           telefono = @telefono,
           email    = @email
     WHERE id_cliente = @id_cliente;
END;
GO

-- 1.3 Borrar un cliente ----------------------------------------------------
-- Regla de negocio: un cliente con compras no se borra, porque sus ventas
-- y facturas tienen que quedar en el historial.
CREATE OR ALTER PROCEDURE dbo.sp_cliente_borrar
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.cliente WHERE id_cliente = @id_cliente)
        THROW 50002, 'No existe un cliente con ese id.', 1;

    IF EXISTS (SELECT 1 FROM dbo.venta WHERE id_cliente = @id_cliente)
        THROW 50003, 'El cliente tiene ventas registradas y no se puede borrar.', 1;

    DELETE FROM dbo.cliente WHERE id_cliente = @id_cliente;
END;
GO

-- =========================================================================
-- PARTE 2. Funciones almacenadas
-- =========================================================================

-- 2.1 Total de una venta (función escalar) ---------------------------------
-- El total es un atributo derivado: no se guarda en VENTA, se calcula
-- sumando los subtotales del detalle (igual que el CU01 de la Etapa IV).
CREATE OR ALTER FUNCTION dbo.fn_total_venta (@id_venta INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN (
        SELECT ISNULL(SUM(dv.subtotal), 0)
          FROM dbo.detalle_venta AS dv
         WHERE dv.id_venta = @id_venta
    );
END;
GO

-- 2.2 Descuento para clientes frecuentes (función escalar) -----------------
-- Basada en el ejemplo de la guía de la cátedra. Los montos se adaptaron a
-- la escala de nuestros datos de prueba (la guía usa 500.000 y 200.000):
--   acumulado >= 12.000 -> 10 %
--   acumulado >=  8.000 ->  5 %
--   en otro caso        ->  0 %
CREATE OR ALTER FUNCTION dbo.fn_descuento_cliente (@id_cliente INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @acumulado DECIMAL(12,2);

    SELECT @acumulado = ISNULL(SUM(dv.subtotal), 0)
      FROM dbo.venta AS v
           INNER JOIN dbo.detalle_venta AS dv ON dv.id_venta = v.id_venta
     WHERE v.id_cliente = @id_cliente;

    RETURN CASE
               WHEN @acumulado >= 12000 THEN 0.10
               WHEN @acumulado >=  8000 THEN 0.05
               ELSE 0.00
           END;
END;
GO

-- 2.3 Productos de una categoría con sus unidades vendidas -----------------
-- Función con valor de tabla (inline): devuelve un conjunto de filas y se
-- usa en el FROM como si fuera una tabla.
CREATE OR ALTER FUNCTION dbo.fn_productos_categoria (@id_categoria INT)
RETURNS TABLE
AS
RETURN (
    SELECT p.id_producto,
           p.nombre,
           p.precio,
           p.stock,
           p.estado,
           ISNULL((SELECT SUM(dv.cantidad)
                     FROM dbo.detalle_venta AS dv
                    WHERE dv.id_producto = p.id_producto), 0) AS unidades_vendidas
      FROM dbo.producto AS p
     WHERE p.id_categoria = @id_categoria
);
GO

-- =========================================================================
-- PARTE 3. Lote de datos con INSERT directo
-- =========================================================================
INSERT INTO dbo.cliente (dni, nombre, apellido, telefono, email) VALUES
('50111001', 'Agustina', 'Medina',   '3794551301', 'agustina.medina@mail.com'),
('50111002', 'Facundo',  'Ledesma',  '3794551302', 'facundo.ledesma@mail.com'),
('50111003', 'Rocío',    'Cabrera',  '3794551303', NULL),
('50111004', 'Nicolás',  'Aguirre',  '3794551304', 'nicolas.aguirre@mail.com'),
('50111005', 'Milagros', 'Escobar',  NULL,         'milagros.escobar@mail.com');
GO

SELECT id_cliente, dni, nombre, apellido, telefono, email
  FROM dbo.cliente
 WHERE dni LIKE '50111%'
 ORDER BY id_cliente;
GO

-- =========================================================================
-- PARTE 4. Lote de datos invocando el procedimiento de inserción
-- =========================================================================
DECLARE @nuevo INT;

EXEC dbo.sp_cliente_insertar @dni = '50222001', @nombre = 'Tomás',    @apellido = 'Villalba',
     @telefono = '3794551401', @email = 'tomas.villalba@mail.com', @id_cliente = @nuevo OUTPUT;
PRINT 'Cliente insertado con id ' + CAST(@nuevo AS VARCHAR(10));

EXEC dbo.sp_cliente_insertar @dni = '50222002', @nombre = 'Florencia', @apellido = 'Duarte',
     @telefono = '3794551402', @email = 'florencia.duarte@mail.com', @id_cliente = @nuevo OUTPUT;
PRINT 'Cliente insertado con id ' + CAST(@nuevo AS VARCHAR(10));

EXEC dbo.sp_cliente_insertar @dni = '50222003', @nombre = 'Gonzalo',  @apellido = 'Paredes',
     @telefono = '3794551403', @id_cliente = @nuevo OUTPUT;
PRINT 'Cliente insertado con id ' + CAST(@nuevo AS VARCHAR(10));

EXEC dbo.sp_cliente_insertar @dni = '50222004', @nombre = 'Julieta',  @apellido = 'Benítez',
     @email = 'julieta.benitez@mail.com', @id_cliente = @nuevo OUTPUT;
PRINT 'Cliente insertado con id ' + CAST(@nuevo AS VARCHAR(10));

EXEC dbo.sp_cliente_insertar @dni = '50222005', @nombre = 'Lautaro',  @apellido = 'Ríos',
     @telefono = '3794551405', @email = 'lautaro.rios@mail.com', @id_cliente = @nuevo OUTPUT;
PRINT 'Cliente insertado con id ' + CAST(@nuevo AS VARCHAR(10));
GO

-- Validación del SP: un DNI repetido se rechaza con un mensaje propio
BEGIN TRY
    EXEC dbo.sp_cliente_insertar @dni = '50222001', @nombre = 'Repetido', @apellido = 'Prueba';
END TRY
BEGIN CATCH
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT id_cliente, dni, nombre, apellido, telefono, email
  FROM dbo.cliente
 WHERE dni LIKE '50222%'
 ORDER BY id_cliente;
GO

-- =========================================================================
-- PARTE 5. UPDATE y DELETE invocando los procedimientos
-- Se trabaja sobre clientes de los dos lotes, buscándolos por DNI para no
-- depender del valor del IDENTITY.
-- =========================================================================
DECLARE @id_a INT = (SELECT id_cliente FROM dbo.cliente WHERE dni = '50111003');
DECLARE @id_b INT = (SELECT id_cliente FROM dbo.cliente WHERE dni = '50222003');
DECLARE @id_c INT = (SELECT id_cliente FROM dbo.cliente WHERE dni = '50111005');
DECLARE @id_d INT = (SELECT id_cliente FROM dbo.cliente WHERE dni = '50222004');

-- Antes
SELECT 'ANTES' AS momento, id_cliente, dni, nombre, apellido, telefono, email
  FROM dbo.cliente
 WHERE id_cliente IN (@id_a, @id_b, @id_c, @id_d)
 ORDER BY id_cliente;

-- Modificar: se completan los datos de contacto que faltaban
EXEC dbo.sp_cliente_modificar @id_cliente = @id_a, @nombre = 'Rocío', @apellido = 'Cabrera',
     @telefono = '3794551303', @email = 'rocio.cabrera@mail.com';
EXEC dbo.sp_cliente_modificar @id_cliente = @id_b, @nombre = 'Gonzalo', @apellido = 'Paredes',
     @telefono = '3794559999', @email = 'gonzalo.paredes@mail.com';

-- Borrar: dos clientes sin compras
EXEC dbo.sp_cliente_borrar @id_cliente = @id_c;
EXEC dbo.sp_cliente_borrar @id_cliente = @id_d;

-- Después: los dos primeros cambiaron y los otros dos ya no están
SELECT 'DESPUÉS' AS momento, id_cliente, dni, nombre, apellido, telefono, email
  FROM dbo.cliente
 WHERE id_cliente IN (@id_a, @id_b, @id_c, @id_d)
 ORDER BY id_cliente;
GO

-- Validación del SP: un cliente con ventas no se puede borrar (cliente 1)
BEGIN TRY
    EXEC dbo.sp_cliente_borrar @id_cliente = 1;
END TRY
BEGIN CATCH
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- =========================================================================
-- PARTE 6. Uso de las funciones
-- =========================================================================

-- 6.1 Total de cada venta con la función escalar
SELECT v.id_venta,
       v.fecha,
       c.nombre + ' ' + c.apellido AS cliente,
       dbo.fn_total_venta(v.id_venta) AS total
  FROM dbo.venta AS v
       INNER JOIN dbo.cliente AS c ON c.id_cliente = v.id_cliente
 ORDER BY v.id_venta;

-- 6.2 Descuento que le corresponde a cada cliente con compras
--     (el acumulado se muestra sumando fn_total_venta de sus ventas)
SELECT c.id_cliente,
       c.nombre + ' ' + c.apellido AS cliente,
       (SELECT SUM(dbo.fn_total_venta(v.id_venta))
          FROM dbo.venta AS v
         WHERE v.id_cliente = c.id_cliente) AS total_acumulado,
       dbo.fn_descuento_cliente(c.id_cliente) * 100 AS descuento_porcentaje
  FROM dbo.cliente AS c
 WHERE EXISTS (SELECT 1 FROM dbo.venta AS v WHERE v.id_cliente = c.id_cliente)
 ORDER BY descuento_porcentaje DESC, total_acumulado DESC;

-- 6.3 Productos de Almacén (categoría 1) con la función de tabla
SELECT *
  FROM dbo.fn_productos_categoria(1)
 ORDER BY unidades_vendidas DESC;

-- La misma función, ahora para Bebidas (categoría 2)
SELECT *
  FROM dbo.fn_productos_categoria(2)
 ORDER BY unidades_vendidas DESC;
GO

-- =========================================================================
-- PARTE 7. Comparación de eficiencia
-- 7.1 Inserción: 1000 INSERT directos contra 1000 llamadas al SP.
--     Se repite 3 veces (rondas) para que el resultado no dependa de una
--     sola medición. Cada ronda va dentro de una transacción que se
--     deshace al final, para no dejar 2000 clientes de prueba en la base.
--     (El IDENTITY no vuelve atrás: quedan números sin usar, lo cual no
--     afecta a nada.)
-- 7.2 Consulta: total por venta con la función escalar contra el mismo
--     cálculo con JOIN y GROUP BY.
-- =========================================================================
SET NOCOUNT ON;

DECLARE @ronda INT = 1, @i INT, @inicio DATETIME2, @dni VARCHAR(20),
        @ms_directo INT, @ms_sp INT;
DECLARE @mediciones TABLE (ronda INT, ms_insert_directo INT, ms_exec_sp INT);

WHILE @ronda <= 3
BEGIN
    BEGIN TRANSACTION;

        -- Directo
        SET @i = 1;
        SET @inicio = SYSDATETIME();
        WHILE @i <= 1000
        BEGIN
            SET @dni = '5300' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4);
            INSERT INTO dbo.cliente (dni, nombre, apellido) VALUES (@dni, 'Prueba', 'Directo');
            SET @i += 1;
        END;
        SET @ms_directo = DATEDIFF(MILLISECOND, @inicio, SYSDATETIME());

        -- Por procedimiento
        SET @i = 1;
        SET @inicio = SYSDATETIME();
        WHILE @i <= 1000
        BEGIN
            SET @dni = '5400' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4);
            EXEC dbo.sp_cliente_insertar @dni = @dni, @nombre = 'Prueba', @apellido = 'Procedimiento';
            SET @i += 1;
        END;
        SET @ms_sp = DATEDIFF(MILLISECOND, @inicio, SYSDATETIME());

    ROLLBACK TRANSACTION;

    INSERT INTO @mediciones VALUES (@ronda, @ms_directo, @ms_sp);
    SET @ronda += 1;
END;

SELECT CAST(ronda AS VARCHAR(10)) AS ronda, ms_insert_directo, ms_exec_sp
  FROM @mediciones
UNION ALL
SELECT 'Promedio', AVG(ms_insert_directo), AVG(ms_exec_sp)
  FROM @mediciones;
GO

SET NOCOUNT OFF;
SET STATISTICS TIME ON;

-- Con la función escalar (se ejecuta una vez por cada venta)
SELECT v.id_venta, dbo.fn_total_venta(v.id_venta) AS total
  FROM dbo.venta AS v;

-- Mismo resultado con JOIN y GROUP BY (una sola pasada)
SELECT v.id_venta, ISNULL(SUM(dv.subtotal), 0) AS total
  FROM dbo.venta AS v
       LEFT JOIN dbo.detalle_venta AS dv ON dv.id_venta = v.id_venta
 GROUP BY v.id_venta;

SET STATISTICS TIME OFF;
GO

-- Control final: los clientes de prueba que quedan en la base
-- (10 de los dos lotes menos 2 borrados por el SP = 8)
SELECT COUNT(*) AS clientes_de_prueba FROM dbo.cliente WHERE dni LIKE '5%';
GO
