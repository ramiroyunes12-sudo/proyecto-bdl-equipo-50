-- Proyecto BD I 2026 - Grupo 50 - Supermercado
-- Etapa III - Parte 3: carga de las tablas maestras
-- Autor: Ramiro Yunes
-- Antes hay que ejecutar los scripts de sql/ddl

USE supermercado;
GO

-- Categorías
INSERT INTO categoria (nombre, descripcion) VALUES
('Almacén', 'Alimentos secos y no perecederos'),
('Bebidas', 'Bebidas con y sin alcohol'),
('Lácteos', 'Leches, yogures y quesos'),
('Carnicería', 'Carnes vacunas, de cerdo y pollo'),
('Verdulería', 'Frutas y verduras'),
('Panadería', 'Pan y facturas'),
('Limpieza', 'Artículos de limpieza'),
('Perfumería', 'Higiene personal'),
('Congelados', 'Productos congelados'),
('Fiambrería', 'Fiambres y embutidos');
GO

-- Clientes
INSERT INTO cliente (dni, nombre, apellido, telefono, email) VALUES
('30125478', 'María', 'González', '3794551201', 'maria.gonzalez@mail.com'),
('32458796', 'Juan', 'Fernández', '3794551202', 'juan.fernandez@mail.com'),
('35698741', 'Lucía', 'Romero', '3794551203', 'lucia.romero@mail.com'),
('28741236', 'Carlos', 'Benítez', '3794551204', 'carlos.benitez@mail.com'),
('40125896', 'Sofía', 'Acosta', '3794551205', 'sofia.acosta@mail.com'),
('38965412', 'Martín', 'Sosa', '3794551206', 'martin.sosa@mail.com'),
('42365874', 'Valentina', 'Ramírez', '3794551207', 'valentina.ramirez@mail.com'),
('25896314', 'Jorge', 'Gómez', '3794551208', 'jorge.gomez@mail.com'),
('44789632', 'Camila', 'Ojeda', '3794551209', 'camila.ojeda@mail.com'),
('33654789', 'Diego', 'Maidana', '3794551210', 'diego.maidana@mail.com');
GO

-- Proveedores
INSERT INTO proveedor (razon_social, cuit, telefono, email, direccion) VALUES
('Distribuidora del Litoral S.A.', '30711234561', '3794421100', 'ventas@dlitoral.com.ar', 'Av. 3 de Abril 1250'),
('Bebidas del Nordeste S.R.L.', '30712345672', '3794432200', 'pedidos@bebidasnea.com.ar', 'Ruta 12 km 1030'),
('Lácteos La Pampeana S.A.', '30713456783', '3794443300', 'ventas@lapampeana.com.ar', 'Av. Maipú 3400'),
('Frigorífico Río Paraná S.A.', '30714567894', '3794454400', 'ventas@frigoriparana.com.ar', 'Ruta 12 km 1045'),
('Mercado Frutihortícola Ctes.', '30715678905', '3794465500', 'info@mfcorrientes.com.ar', 'Av. Independencia 5800'),
('Panificadora San Juan S.R.L.', '30716789016', '3794476600', 'pedidos@pansanjuan.com.ar', 'Junín 1850'),
('Química Hogar S.A.', '30717890127', '3704481700', 'ventas@quimicahogar.com.ar', 'Av. Gutnisky 2100, Formosa'),
('Cosmética Norte S.R.L.', '30718901238', '3624492800', 'contacto@cosmeticanorte.com.ar', 'Av. Alberdi 950, Resistencia');
GO

-- Métodos de pago (los 5 de la RN06 y 3 más de uso común)
INSERT INTO metodo_pago (nombre, descripcion) VALUES
('Efectivo', 'Pago en la caja'),
('Tarjeta de débito', 'Débito en cuenta'),
('Tarjeta de crédito', 'En una o más cuotas'),
('Transferencia', 'Transferencia bancaria'),
('Billetera virtual', 'Pago desde el celular'),
('Código QR', 'Escaneando el QR de la caja'),
('Vale de compra', 'Vale emitido por el supermercado'),
('Tarjeta prepaga', 'Tarjeta recargable');
GO

-- Productos (la categoría es el número de la lista de arriba)
INSERT INTO producto (nombre, descripcion, precio, estado, stock, id_categoria) VALUES
('Yerba mate 1 kg', 'Con palo', 4850.00, 'Activo', 120, 1),
('Arroz largo fino 1 kg', NULL, 1650.00, 'Activo', 200, 1),
('Gaseosa cola 2,25 L', NULL, 3200.00, 'Activo', 90, 2),
('Agua mineral 2 L', 'Sin gas', 1100.00, 'Activo', 150, 2),
('Leche entera 1 L', 'Sachet', 1350.00, 'Activo', 180, 3),
('Queso cremoso 1 kg', NULL, 9800.00, 'Activo', 40, 3),
('Carne picada 1 kg', NULL, 7500.00, 'Activo', 60, 4),
('Tomate 1 kg', NULL, 2400.00, 'Activo', 80, 5),
('Pan lactal 550 g', NULL, 2900.00, 'Activo', 70, 6),
('Lavandina 1 L', NULL, 950.00, 'Activo', 110, 7),
('Shampoo 400 ml', NULL, 4300.00, 'Activo', 50, 8),
('Fideos tallarines 500 g', 'Discontinuado', 1450.00, 'Inactivo', 0, 1);
GO

-- Control: cuántas filas quedaron en cada tabla
SELECT 'categoria' AS tabla, COUNT(*) AS filas FROM categoria
UNION ALL SELECT 'cliente', COUNT(*) FROM cliente
UNION ALL SELECT 'proveedor', COUNT(*) FROM proveedor
UNION ALL SELECT 'metodo_pago', COUNT(*) FROM metodo_pago
UNION ALL SELECT 'producto', COUNT(*) FROM producto;
