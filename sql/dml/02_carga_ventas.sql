-- ==============================================================================
-- Etapa 3 - Parte 4: Carga de ventas (Vargas)
-- Archivo: sql/dml/02_carga_ventas.sql
-- Motor: SQL Server
-- ==============================================================================
USE supermercado;
GO

INSERT INTO producto_proveedor (id_producto, id_proveedor, precio_compra, fecha_compra) VALUES
(1, 1, 3500.00, '2026-08-10'), -- Yerba (venta 4850)
(2, 2, 1100.00, '2026-08-11'), -- Arroz (venta 1650)
(3, 3, 2200.00, '2026-08-12'), -- Gaseosa (venta 3200)
(4, 3, 750.00,  '2026-08-12'), -- Agua (venta 1100)
(5, 4, 950.00,  '2026-08-15'), -- Leche (venta 1350)
(6, 4, 7200.00, '2026-08-15'), -- Queso (venta 9800)
(7, 5, 5500.00, '2026-08-18'), -- Carne (venta 7500)
(8, 6, 1500.00, '2026-08-20'), -- Tomate (venta 2400)
(9, 7, 1900.00, '2026-08-22'), -- Pan lactal (venta 2900)
(10, 8, 600.00, '2026-08-25'); -- Lavandina (venta 950)

INSERT INTO venta (fecha, id_cliente) VALUES
('2026-09-01 10:15:00', 1), -- Venta 1
('2026-09-02 11:30:00', 2), -- Venta 2
('2026-09-05 09:45:00', 3), -- Venta 3
('2026-09-10 16:20:00', 4), -- Venta 4
('2026-09-15 18:05:00', 5), -- Venta 5
('2026-09-20 12:10:00', 6), -- Venta 6
('2026-09-25 14:40:00', 7), -- Venta 7
('2026-09-28 19:55:00', 8), -- Venta 8
('2026-09-29 08:30:00', 9); -- Venta 9

INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
-- Venta 1: Yerba (4500 viejo) x 2 = 9000
(1, 1, 2, 4500.00),
-- Venta 2: Arroz (1500 viejo) x 3 = 4500 + Agua (1000 viejo) x 1 = 1000. Total = 5500
(2, 2, 3, 1500.00),
(2, 4, 1, 1000.00),
-- Venta 3: Carne (7500 actual) x 2 = 15000
(3, 7, 2, 7500.00),
-- Venta 4: Queso (9800 actual) x 1 = 9800 + Pan (2900 actual) x 1 = 2900. Total = 12700
(4, 6, 1, 9800.00),
(4, 9, 1, 2900.00),
-- Venta 5: Gaseosa (3200 actual) x 2 = 6400
(5, 3, 2, 3200.00),
-- Venta 6: Leche (1350) x 4 = 5400
(6, 5, 4, 1350.00),
-- Venta 7: Tomate (2400) x 2 = 4800
(7, 8, 2, 2400.00),
-- Venta 8: Lavandina (950) x 3 = 2850 + Shampoo (4300) x 1 = 4300. Total = 7150
(8, 10, 3, 950.00),
(8, 11, 1, 4300.00),
-- Venta 9: Yerba (4850) x 1 = 4850
(9, 1, 1, 4850.00);

INSERT INTO venta_pago (id_venta, id_metodo_pago, monto) VALUES
(1, 1, 9000.00),                         -- Venta 1: Efectivo
(2, 2, 3000.00), (2, 1, 2500.00),        -- Venta 2: Débito y Efectivo (Total 5500)
(3, 3, 15000.00),                        -- Venta 3: Crédito
(4, 5, 6000.00), (4, 4, 6700.00),        -- Venta 4: Billetera y Transferencia (Total 12700)
(5, 1, 6400.00),                         -- Venta 5: Efectivo
(6, 2, 5400.00),                         -- Venta 6: Débito
(7, 5, 4800.00),                         -- Venta 7: Billetera virtual
(8, 3, 7150.00),                         -- Venta 8: Crédito
(9, 6, 4850.00);                         -- Venta 9: QR

INSERT INTO factura (numero, fecha, tipo, id_venta) VALUES
('0001-00000001', '2026-09-01 10:15:00', 'B', 1),
('0001-00000002', '2026-09-02 11:30:00', 'B', 2),
('0001-00000003', '2026-09-05 09:45:00', 'A', 3),
('0001-00000004', '2026-09-10 16:20:00', 'B', 4),
('0001-00000005', '2026-09-15 18:05:00', 'B', 5),
('0001-00000006', '2026-09-20 12:10:00', 'C', 6),
('0001-00000007', '2026-09-25 14:40:00', 'B', 7),
('0001-00000008', '2026-09-28 19:55:00', 'A', 8),
('0001-00000009', '2026-09-29 08:30:00', 'B', 9);