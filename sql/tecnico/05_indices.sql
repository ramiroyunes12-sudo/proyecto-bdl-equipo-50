-- Archivo: sql/tecnico/05_indices.sql
-- Etapa V - Tema 5: Índices (carga masiva y rendimiento)
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 Grupo 50
-- Autor: Vargas, Hernan Ezequiel
-- Motor: SQL Server (T-SQL)

USE supermercado;
GO

-- 1. Creación de tabla para la prueba de volumen
PRINT '1. Creando tabla historico_precios...';
IF OBJECT_ID('historico_precios', 'U') IS NOT NULL DROP TABLE historico_precios;
CREATE TABLE historico_precios (
    id_historico INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT,
    precio DECIMAL(10,2),
    fecha_registro DATETIME
);
GO

-- 2. Creación de Procedimiento Almacenado para la carga masiva
-- Encapsulamos la lógica para mantener el código ordenado y reutilizable
CREATE OR ALTER PROCEDURE sp_cargar_millon_precios
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Iniciando carga masiva mediante CTE (Tally Table)...';
    
    WITH 
      L0   AS (SELECT 1 AS c UNION ALL SELECT 1),
      L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
      L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
      L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
      L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
      L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
      Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
    
    INSERT INTO historico_precios (id_producto, precio, fecha_registro)
    SELECT TOP (1000000)
        (n % 12) + 1, 
        (n % 5000) + 100.00,
        DATEADD(MINUTE, -n, GETDATE())
    FROM Nums;
    
    PRINT 'Carga de 1.000.000 de filas finalizada con éxito.';
END;
GO

-- 3. Ejecución de la carga y verificación de espacio
EXEC sp_cargar_millon_precios;
GO

PRINT '--- ESPACIO OCUPADO POR LA TABLA ---';
EXEC sp_spaceused 'historico_precios';
GO

-- 4. Habilitar estadísticas de rendimiento de SQL Server
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- =========================================================
-- PRUEBA 1: RENDIMIENTO ANTES DE CREAR EL ÍNDICE (TABLE SCAN)
-- =========================================================
PRINT '--- PRUEBA 1A: AGRUPACIÓN SIN ÍNDICE ---';
SELECT id_producto, AVG(precio) AS precio_promedio
FROM historico_precios
WHERE fecha_registro >= DATEADD(DAY, -100, GETDATE())
GROUP BY id_producto;
GO

PRINT '--- PRUEBA 1B: BÚSQUEDA EXACTA SIN ÍNDICE ---';
SELECT id_historico, id_producto, precio, fecha_registro
FROM historico_precios
WHERE fecha_registro = CAST(GETDATE() AS DATE);
GO

-- =========================================================
-- 5. CREACIÓN DEL ÍNDICE COVERING (NONCLUSTERED)
-- =========================================================
PRINT 'Creando índice IX_historico_fecha_incl (Covering Index)...';
-- Se indexa la fecha (filtro) y se INCLUYEN las columnas de proyección
-- para evitar viajes a la tabla principal (Key Lookups)
CREATE NONCLUSTERED INDEX IX_historico_fecha_incl 
ON historico_precios (fecha_registro) 
INCLUDE (id_producto, precio);
GO

-- =========================================================
-- PRUEBA 2: RENDIMIENTO DESPUÉS DE CREAR EL ÍNDICE (INDEX SEEK)
-- =========================================================
PRINT '--- PRUEBA 2A: AGRUPACIÓN CON ÍNDICE ---';
SELECT id_producto, AVG(precio) AS precio_promedio
FROM historico_precios
WHERE fecha_registro >= DATEADD(DAY, -100, GETDATE())
GROUP BY id_producto;
GO

PRINT '--- PRUEBA 2B: BÚSQUEDA EXACTA CON ÍNDICE ---';
SELECT id_historico, id_producto, precio, fecha_registro
FROM historico_precios
WHERE fecha_registro = CAST(GETDATE() AS DATE);
GO

-- 6. Apagar estadísticas
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO