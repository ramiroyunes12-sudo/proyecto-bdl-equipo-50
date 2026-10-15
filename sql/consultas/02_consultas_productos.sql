-- Etapa IV Bloque 2: Consultas sobre productos (CU04, CU05, CU06)
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 Grupo 50
-- Autor: Víctor Román López Machado
-- Motor: SQL Server (T-SQL)
-- Bases de Datos I (2026)

USE supermercado;
GO

DECLARE @stock_minimo INT = 50;

SELECT 
    c.nombre AS categoria,
    p.nombre AS producto,
    p.stock,
    CASE 
        WHEN p.estado = 'Inactivo' THEN 'Inactivo'
        WHEN p.stock = 0 THEN 'Sin stock'
        ELSE 'Reponer'
    END AS situacion
FROM producto AS p
INNER JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE p.stock <= @stock_minimo OR p.estado = 'Inactivo'
ORDER BY c.nombre ASC, p.stock ASC;
GO

SELECT TOP 3 WITH TIES
    p.nombre AS producto,
    SUM(d.cantidad) AS unidades_vendidas,
    SUM(d.subtotal) AS importe_vendido
FROM detalle_venta AS d
INNER JOIN producto AS p ON p.id_producto = d.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY SUM(d.cantidad) DESC;
GO

SELECT 
    p.nombre AS producto,
    c.nombre AS categoria,
    p.estado,
    p.stock
FROM producto AS p
INNER JOIN categoria AS c ON c.id_categoria = p.id_categoria
WHERE NOT EXISTS (
    SELECT 1 
    FROM detalle_venta AS d 
    WHERE d.id_producto = p.id_producto
);
GO