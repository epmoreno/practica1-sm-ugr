CREATE SCHEMA IF NOT EXISTS olap;

-- 1. DIMENSIÓN TIEMPO (Generada a partir de las fechas de ventas)
CREATE TABLE olap.dim_tiempo (
    tiempo_sk SERIAL PRIMARY KEY,
    fecha DATE UNIQUE,
    anio INT,
    trimestre INT,
    mes INT,
    dia_semana INT
);

INSERT INTO olap.dim_tiempo (fecha, anio, trimestre, mes, dia_semana)
SELECT DISTINCT 
    DATE(fecha_pedido),
    EXTRACT(YEAR FROM fecha_pedido),
    EXTRACT(QUARTER FROM fecha_pedido),
    EXTRACT(MONTH FROM fecha_pedido),
    EXTRACT(ISODOW FROM fecha_pedido)
FROM oltp_ventas.pedidos;

-- 2. DIMENSIÓN CLIENTE (Con control de versiones SCD Tipo 2)
CREATE TABLE olap.dim_cliente (
    cliente_sk SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL, -- Natural Key del OLTP
    nif VARCHAR(9),
    nombre_completo VARCHAR(150),
    direccion VARCHAR(250),
    -- Control SCD Tipo 2
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin DATE DEFAULT '9999-12-31',
    activo BOOLEAN DEFAULT TRUE
);

INSERT INTO olap.dim_cliente (cliente_id, nif, nombre_completo, direccion)
SELECT cliente_id, nif, nombre_completo, direccion
FROM oltp_ventas.clientes;

-- 3. DIMENSIÓN PRODUCTO (Desnormalizada: Incluye Categoría y Proveedor)
CREATE TABLE olap.dim_producto (
    producto_sk SERIAL PRIMARY KEY,
    producto_id INT,
    sku VARCHAR(50),
    nombre_producto VARCHAR(150),
    categoria_nombre VARCHAR(100),
    proveedor_nombre VARCHAR(150),
    precio_base NUMERIC(10,2)
);

INSERT INTO olap.dim_producto (producto_id, sku, nombre_producto, 
                               categoria_nombre, proveedor_nombre, precio_base)
SELECT 
    p.producto_id, p.sku, p.nombre, 
    c.nombre, prov.nombre_empresa, p.precio_base
FROM oltp_inventario.productos p
JOIN oltp_inventario.categorias c ON p.categoria_id = c.categoria_id
JOIN oltp_inventario.proveedores prov ON p.proveedor_id = prov.proveedor_id;

-- 4. DIMENSIÓN EMPLEADO
CREATE TABLE olap.dim_empleado (
    empleado_sk SERIAL PRIMARY KEY,
    empleado_id INT,
    nombre_completo VARCHAR(150),
    departamento VARCHAR(100)
);

INSERT INTO olap.dim_empleado (empleado_id, nombre_completo, departamento)
SELECT e.empleado_id, e.nombre_completo, d.nombre
FROM oltp_rrhh.empleados e
JOIN oltp_rrhh.departamentos d ON e.dep_id = d.dep_id;