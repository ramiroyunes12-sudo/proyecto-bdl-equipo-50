-- ====================================================================
-- Etapa V - Tema 4: Seguridad (Usuarios y Roles)
-- Base de Datos I - Comisión 3 - Grupo 50
-- Autor: Lopez Machado Victor Roman
-- ====================================================================

USE supermercado;
GO

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

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_cajero' AND type = 'R')
    CREATE ROLE rol_cajero;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'rol_auditoria' AND type = 'R')
    CREATE ROLE rol_auditoria;
GO

ALTER ROLE rol_cajero ADD MEMBER usuario_operario;
ALTER ROLE rol_auditoria ADD MEMBER usuario_auditor;
GO

GRANT SELECT ON dbo.producto TO rol_cajero;
GRANT SELECT ON dbo.cliente TO rol_cajero;
GRANT SELECT, INSERT ON dbo.venta TO rol_cajero;
GRANT SELECT, INSERT ON dbo.detalle_venta TO rol_cajero;

DENY INSERT ON dbo.cliente TO rol_cajero;

GRANT EXECUTE ON dbo.sp_cliente_insertar TO rol_cajero;

GRANT SELECT ON dbo.producto TO rol_auditoria;
GRANT SELECT ON dbo.cliente TO rol_auditoria;
GRANT SELECT ON dbo.venta TO rol_auditoria;
GRANT SELECT ON dbo.detalle_venta TO rol_auditoria;
GRANT SELECT ON dbo.proveedor TO rol_auditoria;
GRANT SELECT ON dbo.categoria TO rol_auditoria;
GO

PRINT '--- INICIANDO PRUEBAS DE SEGURIDAD ---';

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