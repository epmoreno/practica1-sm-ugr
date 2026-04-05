CREATE SCHEMA IF NOT EXISTS oltp_inventario;

DROP TABLE IF EXISTS oltp_inventario.almacen CASCADE;
DROP TABLE IF EXISTS oltp_inventario.productos CASCADE;
DROP TABLE IF EXISTS oltp_inventario.categorias CASCADE;
DROP TABLE IF EXISTS oltp_inventario.proveedores CASCADE;

CREATE TABLE oltp_inventario.proveedores (
    proveedor_id SERIAL PRIMARY KEY,
    cif VARCHAR(9) UNIQUE NOT NULL,
    nombre_empresa VARCHAR(150) NOT NULL
);

CREATE TABLE oltp_inventario.categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE oltp_inventario.productos (
    producto_id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    proveedor_id INT REFERENCES oltp_inventario.proveedores(proveedor_id) ON DELETE RESTRICT,
    categoria_id INT REFERENCES oltp_inventario.categorias(categoria_id) ON DELETE RESTRICT,
    precio_base NUMERIC(10,2) CHECK (precio_base > 0)
);
CREATE INDEX idx_producto_sku ON oltp_inventario.productos(sku);

CREATE TABLE oltp_inventario.almacen (
    stock_id SERIAL PRIMARY KEY,
    producto_id INT NOT NULL REFERENCES oltp_inventario.productos(producto_id) ON DELETE CASCADE,
    cantidad_disponible INT NOT NULL CHECK (cantidad_disponible >= 0),
    pasillo_ubicacion VARCHAR(50)
);