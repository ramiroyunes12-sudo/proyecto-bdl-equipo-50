-- =========================================================================
-- Archivo: sql/consultas/05_consultas_proveedores.sql
-- Etapa IV - Bloque 5: Consultas sobre proveedores y precios (CU13, CU14, CU15)
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Autor: Luciano Ramiro Aquino
-- Motor: SQL Server (T-SQL)
-- Requisito: haber ejecutado antes los scripts de sql/ddl y sql/dml
--            (con la corrección de proveedores de 02_carga_ventas.sql)
-- =========================================================================

USE supermercado;
GO

-- -------------------------------------------------------------------------
-- CU13 - Margen de ganancia por producto
-- Actor: dueño / encargado de compras
-- Objetivo: saber cuánto se gana con cada producto, comparando el precio de
--           venta actual con el precio al que se le compró al proveedor.
-- Regla de negocio: RN02 (gestión de proveedores)
--
-- margen     = precio de venta - precio de compra (en pesos)
-- margen_pct = margen sobre el costo, en porcentaje
-- Se multiplica por 100 ANTES de dividir para no perder decimales, y se
-- redondea a 2 decimales con CAST ... AS DECIMAL(6,2).
-- Un producto puede comprarse varias veces a distinto precio. Para comparar
-- contra el costo vigente, la subconsulta correlacionada del WHERE se queda
-- solo con la compra más reciente de cada producto (MAX(fecha_compra)).
-- -------------------------------------------------------------------------
SELECT p.nombre                                              AS producto,
       pr.razon_social                                       AS proveedor,
       p.precio                                              AS precio_venta,
       pp.precio_compra,
       p.precio - pp.precio_compra                           AS margen,
       CAST((p.precio - pp.precio_compra) * 100 / pp.precio_compra
            AS DECIMAL(6,2))                                 AS margen_pct
  FROM producto AS p
       INNER JOIN producto_proveedor AS pp
       ON pp.id_producto = p.id_producto
       INNER JOIN proveedor AS pr
       ON pr.id_proveedor = pp.id_proveedor
 WHERE pp.fecha_compra = (SELECT MAX(pp2.fecha_compra)
                            FROM producto_proveedor AS pp2
                           WHERE pp2.id_producto = p.id_producto)
 ORDER BY margen_pct DESC;
GO

-- -------------------------------------------------------------------------
-- CU14 - Productos sin proveedor asignado
-- Actor: encargado de compras
-- Objetivo: detectar productos que no tienen ningún proveedor cargado,
--           porque no se sabe a quién pedirlos cuando se terminan.
-- Regla de negocio: RN02
--
-- LEFT JOIN conserva todos los productos; los que no encuentran fila en
-- producto_proveedor quedan con NULL en las columnas de esa tabla.
-- La condición de unión va en el ON y el filtro IS NULL en el WHERE.
-- Se usa IS NULL y no "= NULL": cualquier comparación con NULL da
-- desconocido y la consulta no devolvería nada.
-- -------------------------------------------------------------------------
SELECT p.nombre   AS producto,
       c.nombre   AS categoria,
       p.estado,
       p.stock
  FROM producto AS p
       INNER JOIN categoria AS c
       ON c.id_categoria = p.id_categoria
       LEFT JOIN producto_proveedor AS pp
       ON pp.id_producto = p.id_producto
 WHERE pp.id_producto IS NULL
 ORDER BY p.nombre;
GO

-- -------------------------------------------------------------------------
-- CU15 - Ventas cobradas a un precio distinto del actual
-- Actor: dueño / administración
-- Objetivo: encontrar los renglones de venta en los que se cobró un precio
--           distinto del que tiene hoy el producto (porque el precio cambió
--           después de la venta).
-- Regla de negocio: RN05 (detalle de las ventas)
--
-- Muestra por qué detalle_venta guarda su propio precio_unitario: si se
-- usara el precio actual, la venta 1 (2 yerbas a 4500) pasaría a valer
-- 9700 en lugar de los 9000 que realmente se cobraron.
-- diferencia_total = cuánto más valdría ese renglón con el precio de hoy.
-- -------------------------------------------------------------------------
SELECT v.id_venta,
       v.fecha,
       p.nombre                                       AS producto,
       d.cantidad,
       d.precio_unitario                              AS precio_cobrado,
       p.precio                                       AS precio_actual,
       p.precio - d.precio_unitario                   AS diferencia_unitaria,
       d.cantidad * (p.precio - d.precio_unitario)    AS diferencia_total
  FROM venta AS v
       INNER JOIN detalle_venta AS d
       ON d.id_venta = v.id_venta
       INNER JOIN producto AS p
       ON p.id_producto = d.id_producto
 WHERE d.precio_unitario <> p.precio
 ORDER BY v.fecha, p.nombre;
GO
