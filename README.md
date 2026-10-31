# 🛒 Sistema de Gestión de Ventas de un Supermercado

Proyecto académico de Bases de Datos I — 2026

Comisión: 3

Grupo: 50

Institución: Facultad de Ciencias Exactas y Naturales y Agrimensura (FaCENA)

Universidad: Universidad Nacional del Nordeste (UNNE)

Repositorio académico dedicado al diseño, implementación y documentación de una base de datos relacional para gestionar las operaciones de un supermercado mediante SQL Server.

Repositorio académico que contiene el diseño, la implementación y la documentación de una base de datos relacional destinada a gestionar las operaciones principales de un supermercado.

El sistema organiza la información de productos, categorías, proveedores, clientes, stock, ventas, detalles de venta, facturación y métodos de pago. El desarrollo comprende el modelado de datos, la normalización, la implementación mediante SQL Server y la elaboración de consultas y objetos programables de base de datos.

🔗 **Repositorio:** [proyecto-bdl-equipo-50](https://github.com/ramiroyunes12-sudo/proyecto-bdl-equipo-50)


## 📖 Descripción del proyecto

El proyecto consiste en diseñar e implementar una base de datos relacional para administrar las principales operaciones de un supermercado.

La solución busca centralizar y organizar la información comercial, permitiendo representar los productos disponibles, sus categorías, los proveedores que los suministran, los clientes y las ventas realizadas.

Cada venta cuenta con un detalle que registra los productos adquiridos, las cantidades y los precios unitarios aplicados en el momento de la compra. De esta manera, se conserva el historial comercial incluso cuando los precios actuales de los productos se modifican.

Asimismo, el diseño contempla el control del stock, la gestión de los métodos de pago y el registro de la información correspondiente a la facturación.

La base de datos se estructura mediante entidades relacionadas, claves primarias, claves foráneas y reglas de integridad, procurando reducir la redundancia de información y mantener la consistencia de los datos.

### Alcance

El trabajo comprende las siguientes áreas:

- Análisis de requerimientos y reglas de negocio.
- Diseño del modelo conceptual mediante un Diagrama Entidad-Relación (DER).
- Transformación al modelo relacional.
- Normalización de las estructuras de datos.
- Implementación de tablas y relaciones en SQL Server.
- Carga y validación de datos de prueba.
- Desarrollo de consultas SQL.
- Elaboración de procedimientos almacenados y funciones.
- Desarrollo de otros objetos de base de datos contemplados en las etapas técnicas.

---

## 🎯 Objetivos

### Objetivo general

Diseñar e implementar una base de datos relacional para gestionar las operaciones de un supermercado, garantizando una organización adecuada de la información y la integridad de los datos.

### Objetivos específicos

- Identificar los requerimientos funcionales y las reglas de negocio.
- Modelar las entidades, atributos y relaciones del sistema.
- Aplicar técnicas de normalización para reducir redundancias.
- Definir claves primarias y foráneas para establecer las relaciones entre las tablas.
- Implementar la estructura de la base de datos utilizando SQL Server y Transact-SQL.
- Representar las relaciones entre productos y proveedores.
- Mantener el historial de precios aplicados en las ventas.
- Establecer reglas para el control del stock.
- Desarrollar consultas para recuperar y analizar información.
- Implementar procedimientos almacenados y funciones para resolver operaciones específicas.
- Verificar el comportamiento de la base de datos mediante pruebas.

---

## 📌 Reglas de negocio

El diseño parte de los requerimientos funcionales establecidos para el sistema.

| Código | Regla de negocio | Descripción |
|---|---|---|
| RN01 | Gestión de productos | Cada producto debe contar con un identificador único, nombre, precio actual y categoría. |
| RN02 | Gestión de proveedores | Un proveedor puede suministrar varios productos y un mismo producto puede ser suministrado por diferentes proveedores. |
| RN03 | Gestión de stock | El sistema debe actualizar las existencias después de las ventas y evitar vender cantidades superiores al stock disponible. |
| RN04 | Registro de clientes | Los clientes deben contar con un identificador único y sus datos básicos. Un cliente puede realizar múltiples compras. |
| RN05 | Detalle de las ventas | Cada producto vendido debe registrarse con su cantidad, precio unitario aplicado y subtotal. |
| RN06 | Métodos de pago | El sistema debe registrar los métodos de pago utilizados en las ventas. |

### Consideraciones importantes

**Control de existencias:** el stock debe reflejar las cantidades disponibles de cada producto. Las operaciones de venta deben respetar las existencias registradas.

**Precios históricos:** el precio aplicado a una venta debe conservarse en su detalle. Una modificación posterior del precio actual del producto no debe alterar las operaciones anteriores.

**Integridad de los datos:** las relaciones entre las entidades deben evitar referencias a registros inexistentes y contribuir a mantener la consistencia de la información.

**Relación entre proveedores y productos:** un producto puede estar vinculado con distintos proveedores, por lo que se necesita una estructura que represente esta relación muchos a muchos.

---

## 🗃️ Modelo de datos

El modelo relacional contempla nueve tablas principales.

| Tabla | Responsabilidad |
|---|---|
| `PRODUCTO` | Almacena los productos comercializados, sus precios actuales, categorías y existencias. |
| `CLIENTE` | Contiene la información de los clientes. |
| `VENTA` | Registra la información general de cada operación comercial. |
| `DETALLEVENTA` | Almacena los productos incluidos en cada venta, las cantidades y los precios unitarios históricos. |
| `PROVEEDOR` | Contiene la información de los proveedores. |
| `CATEGORIA` | Organiza los productos según su categoría. |
| `METODO_PAGO` | Centraliza la información de los métodos de pago. |
| `FACTURA` | Representa la información asociada a la facturación de las ventas. |
| `PRODUCTO_PROVEEDOR` | Relaciona los productos con sus proveedores. |

### Relaciones principales

El modelo contempla las siguientes relaciones:

- **Categoría y producto:** una categoría puede agrupar varios productos.
- **Cliente y venta:** un cliente puede realizar múltiples compras.
- **Venta y detalle de venta:** una venta puede contener varios artículos.
- **Producto y detalle de venta:** un producto puede aparecer en diferentes ventas.
- **Producto y proveedor:** la relación muchos a muchos se resuelve mediante `PRODUCTO_PROVEEDOR`.
- **Venta y factura:** la factura se relaciona con la venta correspondiente.
- **Métodos de pago y ventas:** el sistema contempla el registro de los métodos utilizados en las operaciones comerciales.

Las relaciones se implementan mediante claves primarias y foráneas, de acuerdo con el modelo relacional definido para el proyecto.

> Para consultar el modelo conceptual, el modelo relacional y la documentación de las decisiones de diseño, revisar los documentos correspondientes de la segunda etapa.

---

## 🏗️ Decisiones de diseño

El modelo relacional incorpora decisiones destinadas a organizar la información, reducir la redundancia y facilitar el mantenimiento de la base de datos.

### 1. Claves primarias subrogadas

Se utilizan identificadores numéricos artificiales para identificar los registros de las entidades.

Entre ellos se encuentran identificadores para clientes, ventas, productos, categorías, proveedores, métodos de pago, facturas y detalles de venta.

Esta decisión simplifica las relaciones entre tablas y evita depender de atributos comerciales que podrían cambiar.

### 2. Relación muchos a muchos entre productos y proveedores

La relación entre `PRODUCTO` y `PROVEEDOR` se resuelve mediante la tabla intermedia `PRODUCTO_PROVEEDOR`.

Esta estructura permite representar que un producto puede ser suministrado por diferentes proveedores y que un proveedor puede suministrar varios productos.

Además, permite asociar información específica de la relación, como el precio de compra y la fecha de compra.

### 3. Separación entre cabecera y detalle de venta

La operación comercial se divide en dos entidades:

- `VENTA`: almacena los datos generales de la operación.
- `DETALLEVENTA`: registra los artículos incluidos en la compra.

Esta separación permite representar ventas con varios productos sin repetir innecesariamente la información general de la transacción.

### 4. Conservación de precios históricos

El atributo `precioUnitario` se almacena en `DETALLEVENTA`.

De esta manera, cada artículo conserva el precio aplicado en el momento de la venta, independientemente de las modificaciones posteriores del precio actual en `PRODUCTO`.

### 5. Facturación y métodos de pago

La entidad `FACTURA` se relaciona con `VENTA` mediante el identificador de la venta.

Los métodos de pago se organizan en una entidad independiente, `METODO_PAGO`, para centralizar su información y facilitar su administración.

La cardinalidad concreta de las relaciones debe consultarse en el modelo relacional implementado.

### 6. Organización del stock

El stock se almacena como un atributo de `PRODUCTO`.

El diseño contempla su actualización durante las ventas y la restricción de operaciones que superen las existencias disponibles.

La implementación efectiva de estas reglas depende de las restricciones y de la lógica programada en la base de datos.

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Aplicación |
|---|---|
| Microsoft SQL Server | Sistema gestor de bases de datos. |
| Transact-SQL (T-SQL) | Lenguaje utilizado para definir y manipular los datos. |
| SQL DDL | Definición de tablas, estructuras y restricciones. |
| SQL DML | Inserción, actualización y manipulación de registros. |
| Git | Control de versiones del proyecto. |
| GitHub | Alojamiento del repositorio y colaboración del equipo. |

### Conceptos de bases de datos aplicados

- Modelo Entidad-Relación.
- Modelo relacional.
- Claves primarias y foráneas.
- Relaciones uno a muchos y muchos a muchos.
- Normalización.
- Integridad referencial.
- Consultas SQL.
- Procedimientos almacenados.
- Funciones.
- Programación de objetos de base de datos.

---

## 📁 Estructura del repositorio

El repositorio organiza la documentación académica y los scripts SQL correspondientes a las distintas etapas del trabajo.

```text
proyecto-bdl-equipo-50/
│
├── docs/
│   ├── etapa-01/
│   │   └── Requerimientos y reglas de negocio
│   │
│   ├── etapa-02/
│   │   └── DER, modelo relacional y decisiones de diseño
│   │
│   ├── etapa-03/
│   │   └── Documentación de implementación y pruebas
│   │
│   ├── etapa-04/
│   │   └── Documentación de consultas SQL
│   │
│   └── etapa-05/
│       └── Documentación técnica
│
├── sql/
│   ├── ddl/
│   │   └── Definición de estructuras y tablas
│   │
│   ├── dml/
│   │   └── Carga y manipulación de datos
│   │
│   ├── consultas/
│   │   └── Consultas SQL del proyecto
│   │
│   └── tecnico/
│       └── Procedimientos y funciones
│
└── README.md
```

*Nota: el árbol anterior representa la organización lógica del proyecto. Los nombres exactos de los archivos y subdirectorios deben verificarse en el repositorio.*

---

## 💻 Instalación y ejecución

### Requisitos previos

Para trabajar con el proyecto se necesita:

- Microsoft SQL Server instalado y funcionando.
- Una instancia de SQL Server accesible.
- SQL Server Management Studio (SSMS) u otra herramienta compatible para ejecutar scripts.
- Git para clonar el repositorio.

### 1. Clonar el repositorio

Desde una terminal, ejecutar:

```bash
git clone https://github.com/ramiroyunes12-sudo/proyecto-bdl-equipo-50.git
```

### 2. Ingresar al directorio

```bash
cd proyecto-bdl-equipo-50
```

### 3. Abrir SQL Server Management Studio

Iniciar SSMS y conectarse a la instancia de SQL Server que se utilizará para ejecutar los scripts.

### 4. Revisar la documentación

Antes de ejecutar los archivos SQL, consultar la documentación de las etapas para identificar los requisitos, el orden de ejecución y las dependencias entre scripts.

### 5. Ejecutar los scripts SQL

Abrir los scripts correspondientes al proyecto y ejecutarlos en el orden establecido por la documentación de implementación.

En términos generales, el proceso contempla:

1. Crear la estructura de la base de datos.
2. Crear las tablas y definir sus relaciones.
3. Incorporar las restricciones correspondientes.
4. Cargar los datos de prueba.
5. Ejecutar las pruebas iniciales.
6. Ejecutar las consultas SQL.
7. Probar los procedimientos almacenados y las funciones desarrolladas.

**Importante:** los nombres de los archivos y la secuencia exacta de ejecución deben confirmarse en los scripts del repositorio. No se debe asumir que todos los archivos pueden ejecutarse de manera independiente ni en cualquier orden.

---

## 📚 Etapas del proyecto

El trabajo se organiza en cinco etapas académicas.

### Etapa I — Análisis de requerimientos

Se define el problema que debe resolver el sistema, su alcance y las reglas de negocio que condicionan las operaciones del supermercado.

**Aspectos principales:**
- Descripción del caso.
- Identificación de los requerimientos.
- Definición de reglas de negocio.
- Delimitación del alcance.

### Etapa II — Diseño de la base de datos

Se define la estructura de los datos a partir de los requerimientos identificados.

**Aspectos principales:**
- Elaboración del Diagrama Entidad-Relación.
- Transformación al modelo relacional.
- Identificación de entidades y atributos.
- Definición de claves primarias y foráneas.
- Resolución de relaciones muchos a muchos.
- Normalización.
- Documentación de las decisiones de diseño.

### Etapa III — Implementación y pruebas

Se lleva el modelo diseñado a SQL Server y se prepara la base de datos para verificar su funcionamiento.

**Aspectos principales:**
- Creación de tablas.
- Definición de relaciones y restricciones.
- Carga de datos.
- Preparación de pruebas.
- Verificación de la integridad de la información.

### Etapa IV — Consultas SQL

Se desarrollan consultas para recuperar, relacionar y analizar la información almacenada.

**Aspectos principales:**
- Consultas sobre las entidades del sistema.
- Combinación de tablas mediante relaciones.
- Obtención de información comercial.
- Consultas para responder preguntas del negocio.

### Etapa V — Procedimientos y funciones almacenadas

Se trabaja con objetos programables de SQL Server para implementar y organizar operaciones de base de datos.

**Aspectos principales:**
- Procedimientos almacenados.
- Funciones definidas por el usuario.
- Parámetros y valores de retorno, según corresponda.
- Ejecución y validación de los objetos desarrollados.

Para conocer las funcionalidades específicas implementadas en cada etapa, consultar los scripts SQL y sus respectivos documentos.

---

## 👥 Integrantes

**Asignatura:** Bases de Datos I  
**Año:** 2026  
**Comisión:** 3  
**Grupo:** 50  
**Institución:** Facultad de Ciencias Exactas y Naturales y Agrimensura (FaCENA) — Universidad Nacional del Nordeste (UNNE).

### Equipo de trabajo

- **Lopez Machado Victor Roman**
- Valenzuela Joaquin Ignacio
- Yunes Ramiro Ruben
- Vargas Hernan Ezequiel
- Aquino Luciano Ramiro

---

## 🎓 Aprendizajes y competencias

El desarrollo de este proyecto permite aplicar conocimientos de diseño e implementación de bases de datos relacionales en un caso práctico.

Entre los principales aprendizajes se encuentran:

- Análisis y traducción de requerimientos a estructuras de datos.
- Diseño de modelos conceptuales y relacionales.
- Normalización de bases de datos.
- Definición de claves y relaciones entre entidades.
- Implementación de estructuras mediante SQL Server.
- Manipulación y consulta de información con SQL.
- Uso de procedimientos almacenados y funciones.
- Validación de reglas de negocio.
- Documentación técnica.
- Trabajo colaborativo y control de versiones con Git y GitHub.

---

## 🔗 Enlaces del proyecto

- **Repositorio:** [GitHub — proyecto-bdl-equipo-50](https://github.com/ramiroyunes12-sudo/proyecto-bdl-equipo-50)
- **Documentación:** disponible en el directorio `docs/`.
- **Scripts SQL:** disponibles en el directorio `sql/`.

  Comisión 3 · Grupo 50
  FaCENA — Universidad Nacional del Nordeste
