# Proyecto BD I 2026 — Equipo 50

**Sistema de gestión de ventas en un supermercado**
Bases de Datos I · Comisión 3 · FaCENA – UNNE

## Integrantes

- Lopez Machado Victor Roman
- Valenzuela Joaquin Ignacio
- Yunes Ramiro Ruben
- Vargas Hernan Ezequiel
- Aquino Luciano Ramiro

## Estructura del repositorio

```
docs/
  etapa-01/   Requerimientos: descripción del caso, alcance y reglas de negocio
  etapa-02/   Modelado: DER, modelo relacional y normalización
  etapa-03/   Implementación: orden de ejecución y pruebas de restricciones
  etapa-04/   Consultas
  etapa-05/   Temas técnicos
sql/
  ddl/        Creación de la base y de las tablas
  dml/        Carga de datos y pruebas
  consultas/  Consultas (Etapa IV)
  tecnico/    Procedimientos, triggers, índices, etc. (Etapa V)
```

## Cómo ejecutar (SQL Server)

1. `sql/ddl/1_tablas_maestras.sql`
2. `sql/ddl/02_tablas_ventas.sql`
3. `sql/dml/01_carga_maestras.sql`
4. `sql/dml/02_carga_ventas.sql`
5. `sql/dml/03_pruebas.sql`

El detalle de cada script y de las pruebas está en `docs/etapa-03/README.md`.
