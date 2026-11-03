-- ==============================================================================
-- Archivo: sql/tecnico/02_transacciones.sql
-- Tema 2: Manejo de Transacciones
-- Proyecto: Sistema de Gestión de Ventas en un Supermercado
-- Comisión 3 - Grupo 50 | Bases de Datos I (2026)
-- Motor: SQL Server (T-SQL)
-- ==============================================================================

USE supermercado;
GO

/*
================================================================================
1. DEFINICIÓN Y OBJETIVO
================================================================================
Una transacción es un conjunto de operaciones SQL que se ejecutan como una única 
unidad lógica de trabajo[cite: 9]. El objetivo principal es garantizar la atomicidad, 
consistencia, aislamiento y durabilidad (propiedades ACID)[cite: 9], asegurando que 
si una operación intermedia falla, todas las anteriores se desechen mediante un 
`ROLLBACK`[cite: 9], evitando información incompleta o estados inconsistentes[cite: 9].

================================================================================
2. VENTAJAS Y APLICACIONES
================================================================================
- Garantiza la integridad referencial y de negocio al procesar operaciones complejas.
- Evita registros parciales (por ejemplo, guardar una venta sin descontar el stock 
  o generar un detalle sin cabecera).
- Aplicación crítica: Procesamiento de ventas comerciales, control de stock en 
  tiempo real y gestión de pagos.

================================================================================
3. IMPLEMENTACIÓN EN SQL SERVER EXPRESS
================================================================================
En SQL Server Express se implementa mediante bloques de control explícitos:
- `BEGIN TRANSACTION`: Inicia formalmente la unidad de trabajo.
- `COMMIT TRANSACTION`: Confirma y persiste los cambios si todo es exitoso.
- `ROLLBACK TRANSACTION`: Revierte todos los cambios si ocurre un error o validación fallida.
- Estructura `BEGIN TRY ... BEGIN CATCH` para la captura centralizada de errores.

================================================================================
4. CASO CONCRETO APLICADO AL SISTEMA DE VENTAS
================================================================================
Escenario: Un cliente realiza la compra de productos en el supermercado. 
La transacción debe ejecutar de forma atómica lo siguiente:
1. Validar que el producto tenga stock suficiente[cite: 10].
2. Registrar la cabecera de la venta en la tabla `venta`[cite: 10].
3. Registrar el ítem comercial en la tabla `detalle_venta`[cite: 10].
4. Descontar las unidades adquiridas del stock en la tabla `producto`[cite: 10].
Si el stock es insuficiente o ocurre un fallo, se cancela y revierte toda la operación[cite: 10].
*/

-- ==============================================================================
-- 5. SCRIPT DE DEMOSTRACIÓN Y CASOS DE PRUEBA
-- ==============================================================================

-- Creación del procedimiento almacenado transaccional para gestionar ventas con stock
CREATE OR ALTER PROCEDURE dbo.sp_registrar_venta_transaccional
    @id_cliente INT,
    @id_producto INT,
    @cantidad INT
AS
BEGIN
    -- Asegurar el aborto de la transacción ante errores graves de ejecución
    SET XACT_ABORT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @stock_actual INT;
        DECLARE @precio_unitario DECIMAL(10,2);
        DECLARE @id_venta_generada INT;

        -- 1. Consultar stock y precio actual bloqueando el registro para lectura concurrente segura
        SELECT @stock_actual = stock, @precio_unitario = precio
        FROM producto WITH (UPDLOCK)
        WHERE id_producto = @id_producto;

        -- Validar existencia del producto
        IF @stock_actual IS NULL
        BEGIN
            RAISERROR('El producto indicado no se encuentra registrado en el sistema.', 16, 1);
        END

        -- 2. Validar la regla de negocio: existencia de stock suficiente[cite: 10]
        IF @stock_actual < @cantidad
        BEGIN
            RAISERROR('Stock insuficiente para completar la venta. Transacción abortada.', 16, 1);
        END

        -- 3. Registrar la cabecera de la venta[cite: 10]
        INSERT INTO venta (fecha, id_cliente)
        VALUES (GETDATE(), @id_cliente);

        -- Obtener el identificador autoincremental de la venta creada
        SET @id_venta_generada = SCOPE_IDENTITY();

        -- 4. Registrar el detalle de la venta[cite: 10]
        INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
        VALUES (@id_venta_generada, @id_producto, @cantidad, @precio_unitario);

        -- 5. Actualizar (descontar) el stock del producto[cite: 10]
        UPDATE producto
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto;

        -- Confirmar los cambios si todo transcurrió correctamente[cite: 10]
        COMMIT TRANSACTION;
        PRINT 'ÉXITO: Transacción confirmada. Venta registrada y stock actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, se revierten todos los cambios parciales (Atomicidad)[cite: 9, 10]
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Propagar el mensaje de error capturado
        DECLARE @MensajeError NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@MensajeError, 16, 1);
    END CATCH
END;
GO


-- ==============================================================================
-- PRUEBAS DE DEMOSTRACIÓN (EJECUCIÓN REQUERIDA POR LA GUÍA)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PRUEBA 1: CASO CORRECTO (Producto con stock suficiente)[cite: 10]
-- ------------------------------------------------------------------------------
PRINT '--- INICIANDO PRUEBA 1: CASO CORRECTO (Stock suficiente) ---';

-- Consultar stock inicial del Producto 1 (Yerba mate 1 kg)
SELECT id_producto, nombre, stock FROM producto WHERE id_producto = 1;

-- Ejecutar procedimiento de venta exitosa (comprar 3 unidades)
EXEC dbo.sp_registrar_venta_transaccional 
    @id_cliente = 1, 
    @id_producto = 1, 
    @cantidad = 3;

-- Verificar resultados obtenidos: stock disminuido y registros generados[cite: 10]
SELECT id_producto, nombre, stock FROM producto WHERE id_producto = 1;
SELECT TOP 1 * FROM venta ORDER BY id_venta DESC;
SELECT TOP 1 * FROM detalle_venta ORDER BY id_detalle_venta DESC;
GO


-- ------------------------------------------------------------------------------
-- PRUEBA 2: CASO INCORRECTO (Producto con stock insuficiente -> ROLLBACK)[cite: 10]
-- ------------------------------------------------------------------------------
PRINT '--- INICIANDO PRUEBA 2: CASO INCORRECTO (Stock insuficiente) ---';

-- Consultar stock del Producto 2 (Arroz largo fino 1 kg)
SELECT id_producto, nombre, stock FROM producto WHERE id_producto = 2;

-- Intentar comprar una cantidad excesiva (9999 unidades) que excede el stock actual
BEGIN TRY
    EXEC dbo.sp_registrar_venta_transaccional 
        @id_cliente = 2, 
        @id_producto = 2, 
        @cantidad = 9999;
END TRY
BEGIN CATCH
    PRINT 'Resultado de prueba capturado: ' + ERROR_MESSAGE();
END CATCH;

-- Verificar resultados obtenidos: el stock permanece intacto y NO se registra venta parcial[cite: 10]
SELECT id_producto, nombre, stock FROM producto WHERE id_producto = 2;
GO
