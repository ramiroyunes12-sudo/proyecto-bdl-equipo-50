-- =========================================================================
-- Archivo: sql/consultas/01_consultas_ventas.sql
-- Etapa IV - Bloque 1: Consultas sobre ventas (CU01, CU02, CU03, CU16)
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Autor: Ramiro Yunes
-- Motor: SQL Server (T-SQL)
-- Requisito: haber ejecutado antes los scripts de sql/ddl y sql/dml
-- =========================================================================

USE supermercado;
GO

-- -------------------------------------------------------------------------
-- CU01 - Ticket de una venta
-- Actor: cajero / atención al cliente
-- Objetivo: reconstruir el comprobante de una venta: cabecera, productos y
--           forma de pago. El total NO está guardado en la tabla venta
--           (es un atributo derivado), se obtiene sumando los subtotales.
-- Regla de negocio: RN05 (detalle de las ventas) y RN06 (métodos de pago)
-- Para ver otra venta, cambiar el valor de @id_venta.
-- -------------------------------------------------------------------------
DECLARE @id_venta INT = 4;

-- 1.a Cabecera: fecha, cliente, factura y total de la venta
--     LEFT JOIN con factura: una venta puede no estar facturada todavía (RN08)
SELECT v.id_venta,
       v.fecha,
       c.apellido + ', ' + c.nombre      AS cliente,
       c.dni,
       ISNULL(f.tipo + ' ' + f.numero, 'Sin facturar') AS factura,
       SUM(d.subtotal)                   AS total_venta
  FROM venta AS v
       INNER JOIN cliente AS c
       ON c.id_cliente = v.id_cliente
       INNER JOIN detalle_venta AS d
       ON d.id_venta = v.id_venta
       LEFT JOIN factura AS f
       ON f.id_venta = v.id_venta
 WHERE v.id_venta = @id_venta
 GROUP BY v.id_venta, v.fecha, c.apellido, c.nombre, c.dni, f.tipo, f.numero;

-- 1.b Renglones del ticket: el precio que se muestra es el precio histórico
--     (detalle_venta.precio_unitario), no el precio actual del producto
SELECT p.nombre            AS producto,
       d.cantidad,
       d.precio_unitario,
       d.subtotal
  FROM detalle_venta AS d
       INNER JOIN producto AS p
       ON p.id_producto = d.id_producto
 WHERE d.id_venta = @id_venta
 ORDER BY p.nombre;

-- 1.c Forma de pago (puede haber más de un método: pago mixto)
SELECT m.nombre AS metodo_pago,
       vp.monto
  FROM venta_pago AS vp
       INNER JOIN metodo_pago AS m
       ON m.id_metodo_pago = vp.id_metodo_pago
 WHERE vp.id_venta = @id_venta
 ORDER BY vp.monto DESC;
GO

-- -------------------------------------------------------------------------
-- CU02 - Control de cobro: total de productos vs. total pagado
-- Actor: encargado de caja / administración
-- Objetivo: verificar en cada venta que lo cobrado coincida con lo vendido,
--           para detectar cobros incompletos o en exceso.
-- Regla de negocio: RN05 + RN06
--
-- Cada total se calcula en su propia subconsulta (tabla derivada) ANTES de
-- unirlos. Si se hiciera JOIN directo de venta con detalle_venta y con
-- venta_pago, cada renglón del detalle se multiplicaría por cada pago y las
-- sumas saldrían infladas (la venta 2, con 2 productos y 2 pagos, daría
-- 11000 en lugar de 5500).
-- -------------------------------------------------------------------------
SELECT v.id_venta,
       v.fecha,
       ISNULL(t.total_productos, 0)                           AS total_productos,
       ISNULL(p.total_pagado, 0)                              AS total_pagado,
       ISNULL(p.total_pagado, 0) - ISNULL(t.total_productos, 0) AS diferencia,
       CASE
           WHEN ISNULL(p.total_pagado, 0) = ISNULL(t.total_productos, 0) THEN 'Correcta'
           WHEN ISNULL(p.total_pagado, 0) < ISNULL(t.total_productos, 0) THEN 'Pago incompleto'
           ELSE 'Pago en exceso'
       END                                                    AS estado
  FROM venta AS v
       LEFT JOIN (SELECT id_venta,
                         SUM(subtotal) AS total_productos
                    FROM detalle_venta
                   GROUP BY id_venta) AS t
       ON t.id_venta = v.id_venta
       LEFT JOIN (SELECT id_venta,
                         SUM(monto) AS total_pagado
                    FROM venta_pago
                   GROUP BY id_venta) AS p
       ON p.id_venta = v.id_venta
 ORDER BY estado DESC, v.id_venta;
GO

-- -------------------------------------------------------------------------
-- CU03 - Recaudación por franja horaria en un período
-- Actor: encargado / dueño del supermercado
-- Objetivo: saber en qué momento del día se vende más, para organizar
--           turnos y cajas abiertas.
-- Franjas: Mañana (antes de las 13 h) - Tarde (13 a 19 h) - Noche (desde 19 h)
-- Para otro período, cambiar @desde y @hasta (@hasta no se incluye).
--
-- Se usa una tabla derivada porque primero hay que calcular el total de
-- cada venta y recién después agruparlas por franja. Además, el alias
-- "franja" no se puede usar en el GROUP BY de la misma consulta: según el
-- orden lógico de procesamiento, GROUP BY se ejecuta antes que SELECT.
-- -------------------------------------------------------------------------
DECLARE @desde DATETIME = '2026-09-01';
DECLARE @hasta DATETIME = '2026-10-01';

SELECT t.franja,
       COUNT(*)                          AS cantidad_ventas,
       SUM(t.total)                      AS recaudacion,
       CAST(AVG(t.total) AS DECIMAL(12,2)) AS ticket_promedio
  FROM (SELECT v.id_venta,
               DATEPART(HOUR, v.fecha) AS hora,
               CASE
                   WHEN DATEPART(HOUR, v.fecha) < 13 THEN 'Mañana'
                   WHEN DATEPART(HOUR, v.fecha) < 19 THEN 'Tarde'
                   ELSE 'Noche'
               END                     AS franja,
               SUM(d.subtotal)         AS total
          FROM venta AS v
               INNER JOIN detalle_venta AS d
               ON d.id_venta = v.id_venta
         WHERE v.fecha >= @desde
           AND v.fecha <  @hasta
         GROUP BY v.id_venta, v.fecha) AS t
 GROUP BY t.franja
 ORDER BY MIN(t.hora);
GO

-- -------------------------------------------------------------------------
-- CU16 - Ventas por categoría de producto en un período
-- Actor: encargado / dueño del supermercado
-- Objetivo: saber qué rubros venden más en un rango de fechas: cuántas
--           ventas incluyeron productos de cada categoría, cuántas unidades
--           se vendieron y cuánto se recaudó.
-- Regla de negocio: RN01 (productos y categorías) + RN05 (detalle)
-- Para otro período, cambiar @desde y @hasta (@hasta no se incluye).
--
-- COUNT(DISTINCT v.id_venta): si una venta tiene dos productos de la misma
-- categoría, aparece en dos renglones del detalle; con DISTINCT esa venta
-- se cuenta una sola vez para esa categoría.
-- Las categorías sin ventas en el período no aparecen (INNER JOIN).
-- -------------------------------------------------------------------------
DECLARE @desde DATETIME = '2026-09-01';
DECLARE @hasta DATETIME = '2026-10-01';

SELECT c.nombre                    AS categoria,
       COUNT(DISTINCT v.id_venta)  AS cantidad_ventas,
       SUM(d.cantidad)             AS unidades_vendidas,
       SUM(d.subtotal)             AS recaudacion
  FROM venta AS v
       INNER JOIN detalle_venta AS d
       ON d.id_venta = v.id_venta
       INNER JOIN producto AS p
       ON p.id_producto = d.id_producto
       INNER JOIN categoria AS c
       ON c.id_categoria = p.id_categoria
 WHERE v.fecha >= @desde
   AND v.fecha <  @hasta
 GROUP BY c.id_categoria, c.nombre
 ORDER BY recaudacion DESC;
GO
