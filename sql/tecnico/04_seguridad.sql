-- ====================================================================
-- Etapa V - Tema 4: Seguridad (Usuarios y Roles)
-- Base de Datos I - Comisión 3 - Grupo 50
-- Autor: Lopez Machado Victor Roman
-- ====================================================================

USE supermercado;
GO

-- 1. CREACIÓN DE LOGINS Y USUARIOS DE BASE DE DATOS
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_operario')
    CREATE LOGIN login_operario WITH PASSWORD = 'PasswordSeguro123!';
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuario_operario')
    CREATE USER usuario_operario FOR LOGIN login_operario;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'login_auditor')
    CREATE LOGIN login_auditor WITH PASSWORD = 'PasswordSeguro123!';
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usuario_auditor')
    CREATE USER usuario_auditor FOR LOGIN login_auditor;
GO


-- 2. CREACIÓN DE ROLES PERSONALIZADOS DE BASE DE DATOS
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_cajero' AND type = 'R')
    CREATE ROLE rol_cajero;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_auditoria' AND type = 'R')
    CREATE ROLE rol_auditoria;
GO


-- 3. ASIGNACIÓN DE MIEMBROS A LOS ROLES
ALTER ROLE rol_cajero ADD MEMBER usuario_operario;
ALTER ROLE rol_auditoria ADD MEMBER usuario_auditor;
GO


-- 4. CONFIGURACIÓN DE PERMISOS (GRANT, DENY)
-- Rol Cajero / Operario:
-- - Permisos de lectura sobre productos y clientes.
-- - Permisos de lectura y registro en ventas y detalles (`detalle_venta`).
-- - Denegación explícita de INSERT directo en la tabla cliente.
-- - Otorgamiento de ejecución sobre el Stored Procedure `dbo.sp_cliente_insertar`.

GRANT SELECT ON dbo.producto TO rol_cajero;
GRANT SELECT ON dbo.cliente TO rol_cajero;
GRANT SELECT, INSERT ON dbo.venta TO rol_cajero;
GRANT SELECT, INSERT ON dbo.detalle_venta TO rol_cajero;

-- Denegar INSERT directo sobre la tabla cliente para forzar el uso del SP
DENY INSERT ON dbo.cliente TO rol_cajero;

-- Otorgar permiso de ejecución sobre el procedimiento almacenado
GRANT EXECUTE ON dbo.sp_cliente_insertar TO rol_cajero;

-- Rol Auditoría:
-- - Acceso de sólo lectura (SELECT) a las tablas principales del sistema.
GRANT SELECT ON dbo.producto TO rol_auditoria;
GRANT SELECT ON dbo.cliente TO rol_auditoria;
GRANT SELECT ON dbo.venta TO rol_auditoria;
GRANT SELECT ON dbo.detalle_venta TO rol_auditoria;
GRANT SELECT ON dbo.proveedor TO rol_auditoria;
GRANT SELECT ON dbo.categoria TO rol_auditoria;
GO


-- 5. SCRIPT DE PRUEBA Y VALIDACIÓN DE SEGURIDAD (TESTS)
PRINT '--- INICIANDO PRUEBAS DE SEGURIDAD ---';

-- Prueba 1: Simular usuario operario intentando insertar directamente en la tabla cliente (Debe FALLAR por DENY)
EXECUTE AS USER = 'usuario_operario';
BEGIN TRY
    INSERT INTO dbo.cliente (dni, nombre, apellido, telefono, email) 
    VALUES ('40111222', 'Test', 'Directo', '3794111111', 'test@mail.com');
    PRINT 'ERROR: El INSERT directo fue permitido (Debería estar denegado).';
END TRY
BEGIN CATCH
    PRINT 'ÉXITO (PRUEBA 1): Se bloqueó correctamente el INSERT directo en la tabla cliente. Mensaje: ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- Prueba 2: Simular usuario operario utilizando el SP autorizado `dbo.sp_cliente_insertar` (Debe SER EXITOSO)
EXECUTE AS USER = 'usuario_operario';
BEGIN TRY
    EXEC dbo.sp_cliente_insertar 
        @dni = '40999888', 
        @nombre = 'Juan', 
        @apellido = 'Pérez', 
        @telefono = '3794999999', 
        @email = 'juan.perez@mail.com';
    PRINT 'ÉXITO (PRUEBA 2): El procedimiento almacenado se ejecutó correctamente y registró al cliente.';
END TRY
BEGIN CATCH
    PRINT 'ERROR (PRUEBA 2): Falló la ejecución del SP: ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- Prueba 3: Simular usuario auditor intentando realizar un INSERT (Debe FALLAR por falta de permisos de escritura)
EXECUTE AS USER = 'usuario_auditor';
BEGIN TRY
    INSERT INTO dbo.categoria (nombre, descripcion) VALUES ('Test Auditor', 'No permitido');
    PRINT 'ERROR: El auditor pudo insertar datos.';
END TRY
BEGIN CATCH
    PRINT 'ÉXITO (PRUEBA 3): El auditor tiene restringidos los permisos de escritura correctamente. Mensaje: ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

PRINT '--- FIN DE LAS PRUEBAS DE SEGURIDAD ---';