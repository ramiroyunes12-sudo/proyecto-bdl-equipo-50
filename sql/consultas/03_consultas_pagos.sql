-- =========================================================================
-- Archivo: sql/consultas/03_consultas_pagos.sql
-- Etapa IV - Bloque 3: Consultas sobre pagos y facturación (CU07, CU08, CU09)
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Autor: Joaquín Ignacio Valenzuela
-- Motor: SQL Server (T-SQL)
-- Requisito: haber ejecutado antes los scripts de sql/ddl y sql/dml
-- =========================================================================

USE supermercado;
GO

-- -------------------------------------------------------------------------
-- CU07 - Recaudación por método de pago
-- Actor: encargado de caja / administración
-- Objetivo: saber cuánto se cobró con cada forma de pago. Tienen que
--           aparecer TODOS los métodos, aunque no se hayan usado (con 0).
-- Regla de negocio: RN06 (métodos de pago)
--
-- Se parte de metodo_pago y se hace LEFT JOIN con venta_pago para que los
-- métodos sin pagos no desaparezcan del resultado.
-- COUNT(vp.id_venta) y no COUNT(*): con LEFT JOIN, un método sin uso trae
-- una fila con NULL, y COUNT(*) la contaría como 1. COUNT(columna) ignora
-- los NULL. ISNULL(SUM(...), 0) muestra 0 en lugar de NULL.
-- -------------------------------------------------------------------------
SELECT m.nombre                    AS metodo_pago,
       COUNT(vp.id_venta)          AS cantidad_ventas,
       ISNULL(SUM(vp.monto), 0)    AS recaudacion
  FROM metodo_pago AS m
       LEFT JOIN venta_pago AS vp
       ON vp.id_metodo_pago = m.id_metodo_pago
 GROUP BY m.id_metodo_pago, m.nombre
 ORDER BY recaudacion DESC, m.nombre;
GO

-- -------------------------------------------------------------------------
-- CU08 - Ventas con pago mixto
-- Actor: encargado de caja
-- Objetivo: identificar las ventas que se pagaron con más de un método.
-- Regla de negocio: RN06
--
-- Se agrupa por venta y se filtra con HAVING, porque la condición es sobre
-- el grupo (cuántos métodos tiene cada venta). WHERE no sirve: se ejecuta
-- antes de agrupar y no puede usar COUNT.
-- STRING_AGG (SQL Server 2017 o posterior) junta los nombres de los métodos
-- en una sola columna.
-- -------------------------------------------------------------------------
SELECT v.id_venta,
       v.fecha,
       COUNT(*)                       AS cantidad_metodos,
       STRING_AGG(m.nombre, ', ')     AS metodos,
       SUM(vp.monto)                  AS total_pagado
  FROM venta AS v
       INNER JOIN venta_pago AS vp
       ON vp.id_venta = v.id_venta
       INNER JOIN metodo_pago AS m
       ON m.id_metodo_pago = vp.id_metodo_pago
 GROUP BY v.id_venta, v.fecha
HAVING COUNT(*) > 1
 ORDER BY v.id_venta;
GO

-- -------------------------------------------------------------------------
-- CU09 - Ventas sin facturar
-- Actor: administración
-- Objetivo: detectar las ventas que todavía no tienen factura emitida.
-- Regla de negocio: RN08 (facturación)
--
-- LEFT JOIN con factura conserva todas las ventas; las que no tienen
-- factura quedan con NULL y se filtran con IS NULL (nunca "= NULL", que no
-- da error pero devuelve 0 filas porque comparar con NULL da desconocido).
-- Con los datos actuales devuelve 0 filas: las 9 ventas están facturadas.
-- Por eso se agrega 9.b, un control que muestra el estado general.
-- -------------------------------------------------------------------------

-- 9.a Ventas sin factura, con cliente e importe a facturar
SELECT v.id_venta,
       v.fecha,
       c.apellido + ', ' + c.nombre  AS cliente,
       SUM(d.subtotal)               AS total_venta
  FROM venta AS v
       INNER JOIN cliente AS c
       ON c.id_cliente = v.id_cliente
       INNER JOIN detalle_venta AS d
       ON d.id_venta = v.id_venta
       LEFT JOIN factura AS f
       ON f.id_venta = v.id_venta
 WHERE f.id_factura IS NULL
 GROUP BY v.id_venta, v.fecha, c.apellido, c.nombre
 ORDER BY v.fecha;

-- 9.b Control: total de ventas, cuántas tienen factura y cuántas no
SELECT COUNT(*)                AS total_ventas,
       COUNT(f.id_factura)     AS ventas_facturadas,
       COUNT(*) - COUNT(f.id_factura) AS ventas_sin_facturar
  FROM venta AS v
       LEFT JOIN factura AS f
       ON f.id_venta = v.id_venta;
GO
