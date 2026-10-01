CREATE DATABASE supermercado;
GO

USE supermercado;
GO

CREATE TABLE categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT PK_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_categoria_nombre UNIQUE (nombre)
);
GO

CREATE TABLE cliente (
    id_cliente INT IDENTITY(1,1) NOT NULL,
    dni VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(100) NULL,
    CONSTRAINT PK_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_cliente_dni UNIQUE (dni)
);
GO

CREATE TABLE proveedor (
    id_proveedor INT IDENTITY(1,1) NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    cuit VARCHAR(20) NOT NULL,
    telefono VARCHAR(30) NULL,
    email VARCHAR(100) NULL,
    direccion VARCHAR(200) NULL,
    CONSTRAINT PK_proveedor PRIMARY KEY (id_proveedor),
    CONSTRAINT UQ_proveedor_cuit UNIQUE (cuit)
);
GO

CREATE TABLE metodo_pago (
    id_metodo_pago INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT PK_metodo_pago PRIMARY KEY (id_metodo_pago),
    CONSTRAINT UQ_metodo_pago_nombre UNIQUE (nombre)
);
GO

CREATE TABLE producto (
    id_producto INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    stock INT NOT NULL,
    id_categoria INT NOT NULL,
    CONSTRAINT PK_producto PRIMARY KEY (id_producto),
    CONSTRAINT CK_producto_precio CHECK (precio > 0),
    CONSTRAINT CK_producto_stock CHECK (stock >= 0),
    CONSTRAINT CK_producto_estado CHECK (estado IN ('Activo', 'Inactivo')),
    CONSTRAINT FK_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);
GO

CREATE TABLE producto_proveedor (
    id_producto_proveedor INT IDENTITY(1,1) NOT NULL,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    fecha_compra DATE NOT NULL,
    CONSTRAINT PK_producto_proveedor PRIMARY KEY (id_producto_proveedor),
    CONSTRAINT FK_producto_proveedor_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT FK_producto_proveedor_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
);
GO