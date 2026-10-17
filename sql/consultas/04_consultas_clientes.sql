-- Archivo: sql/consultas/04_consultas_clientes.sql
-- Etapa IV Bloque 4: Consultas sobre clientes (CU10, CU11, CU12)
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 Grupo 50
-- Autor: [Escribe tu Nombre y Apellido aquí]
-- Motor: SQL Server (T-SQL)
-- Bases de Datos I (2026)

USE supermercado;
GO

-- CU10 Gasto total por cliente
-- Actor: Encargado / área comercial
-- Objetivo: ¿Cuántas compras hizo y cuánto gastó cada cliente?
-- Regla de negocio: RN04
SELECT c.id_cliente, c.apellido, c.nombre, COUNT(DISTINCT v.id_venta) AS cantidad_compras, SUM(d.subtotal) AS total_gastado
FROM cliente AS c
INNER JOIN venta AS v ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta AS d ON v.id_venta = d.id_venta
GROUP BY c.id_cliente, c.apellido, c.nombre
ORDER BY total_gastado DESC;
GO

-- CU11 Clientes sobre el promedio
-- Actor: Dueño / área comercial
-- Objetivo: ¿Qué clientes gastaron más que el promedio de gasto por cliente?
-- Regla de negocio: RN04
SELECT c.id_cliente, c.apellido, c.nombre, COUNT(DISTINCT v.id_venta) AS cantidad_compras, SUM(d.subtotal) AS total_gastado,
       (SELECT AVG(g.gasto) FROM (SELECT v2.id_cliente, SUM(d2.subtotal) AS gasto FROM venta AS v2 INNER JOIN detalle_venta AS d2 ON v2.id_venta = d2.id_venta GROUP BY v2.id_cliente) AS g) AS promedio_por_cliente
FROM cliente AS c
INNER JOIN venta AS v ON c.id_cliente = v.id_cliente
INNER JOIN detalle_venta AS d ON v.id_venta = d.id_venta
GROUP BY c.id_cliente, c.apellido, c.nombre
HAVING SUM(d.subtotal) > (SELECT AVG(g.gasto) FROM (SELECT v2.id_cliente, SUM(d2.subtotal) AS gasto FROM venta AS v2 INNER JOIN detalle_venta AS d2 ON v2.id_venta = d2.id_venta GROUP BY v2.id_cliente) AS g)
ORDER BY total_gastado DESC;
GO

-- CU12 Clientes sin compras
-- Actor: Área comercial
-- Objetivo: ¿Qué clientes registrados nunca hicieron una compra?
-- Regla de negocio: RN04
SELECT c.dni, c.apellido, c.nombre, c.telefono, c.email
FROM cliente AS c
WHERE NOT EXISTS (SELECT 1 FROM venta AS v WHERE v.id_cliente = c.id_cliente);
GO