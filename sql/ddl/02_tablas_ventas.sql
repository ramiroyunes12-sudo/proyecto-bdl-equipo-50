-- =========================================================================
-- Archivo: sql/ddl/02_tablas_ventas.sql
-- Parte 2: Creación de tablas transaccionales y de gestión de ventas
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Motor: SQL Server (T-SQL)
-- =========================================================================

-- Asegurar el contexto de la base de datos
USE supermercado;
GO

-- ----------------------------------------------------------------
-- 1 -- Tabla VENTA (Cabecera de la transacción comercial)
-- ----------------------------------------------------------------
CREATE TABLE venta (
    id_venta INT IDENTITY(1,1) NOT NULL,
    fecha DATETIME NOT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT PK_venta PRIMARY KEY (id_venta),
    CONSTRAINT FK_venta_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);
GO

-- ----------------------------------------------------------------
-- 2. Tabla DETALLE_VENTA (Ítems individuales asociados a cada venta)
-- Incorpora el precio histórico y columna calculada para el subtotal.
-- ----------------------------------------------------------------
CREATE TABLE detalle_venta (
    id_detalle_venta INT IDENTITY(1,1) NOT NULL,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal AS (cantidad * precio_unitario), -- Columna calculada automáticamente
    CONSTRAINT PK_detalle_venta PRIMARY KEY (id_detalle_venta),
    CONSTRAINT FK_detalle_venta_venta FOREIGN KEY (id_venta) 
        REFERENCES venta(id_venta) ON DELETE CASCADE, -- Borrado en cascada
    CONSTRAINT FK_detalle_venta_producto FOREIGN KEY (id_producto) 
        REFERENCES producto(id_producto),
    CONSTRAINT CK_detalle_venta_cantidad CHECK (cantidad > 0)
);
GO

-- ----------------------------------------------------------------
-- 3. Tabla VENTA_PAGO (Relación N:M resuelta entre venta y método de pago)
-- Permite que una venta pueda abonarse utilizando uno o más métodos de pago.
-- ----------------------------------------------------------------
CREATE TABLE venta_pago (
    id_venta INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_venta_pago PRIMARY KEY (id_venta, id_metodo_pago), -- Clave primaria compuesta
    CONSTRAINT FK_venta_pago_venta FOREIGN KEY (id_venta) 
        REFERENCES venta(id_venta) ON DELETE CASCADE, -- Borrado en cascada
    CONSTRAINT FK_venta_pago_metodo_pago FOREIGN KEY (id_metodo_pago) 
        REFERENCES metodo_pago(id_metodo_pago),
    CONSTRAINT CK_venta_pago_monto CHECK (monto > 0)
);
GO

-- ----------------------------------------------------------------
-- 4. Tabla FACTURA (Comprobante fiscal asociado en relación 1 a 1 con la venta)
-- ----------------------------------------------------------------
CREATE TABLE factura (
    id_factura INT IDENTITY(1,1) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    fecha DATETIME NOT NULL,
    tipo CHAR(1) NOT NULL,
    id_venta INT NOT NULL,
    CONSTRAINT PK_factura PRIMARY KEY (id_factura),
    CONSTRAINT UQ_factura_numero UNIQUE (numero),
    CONSTRAINT UQ_factura_id_venta UNIQUE (id_venta), -- Garantiza la relación estricta 1 a 1 con venta
    CONSTRAINT FK_factura_venta FOREIGN KEY (id_venta) REFERENCES venta(id_venta),
    CONSTRAINT CK_factura_tipo CHECK (tipo IN ('A', 'B', 'C'))
);
GO