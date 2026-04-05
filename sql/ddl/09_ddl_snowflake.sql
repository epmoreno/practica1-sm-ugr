-- 1. Crear sub-dimensión (Snowflake)
CREATE TABLE olap.dim_categoria (
    categoria_sk SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) UNIQUE
);

-- 2. Poblar sub-dimensión
INSERT INTO olap.dim_categoria (nombre_categoria)
SELECT DISTINCT categoria_nombre FROM olap.dim_producto;

-- 3. Modificar la dimensión original para enlazar la FK
CREATE TABLE olap.dim_producto_snowflake (
    producto_sk SERIAL PRIMARY KEY,
    producto_id INT,
    sku VARCHAR(50),
    nombre_producto VARCHAR(150),
    categoria_sk INT REFERENCES olap.dim_categoria(categoria_sk), -- Enlace Copo Nieve
    proveedor_nombre VARCHAR(150),
    precio_base NUMERIC(10,2)
);