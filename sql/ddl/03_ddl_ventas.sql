CREATE SCHEMA IF NOT EXISTS oltp_ventas;

DROP TABLE IF EXISTS oltp_ventas.facturas CASCADE;
DROP TABLE IF EXISTS oltp_ventas.detalle_pedido CASCADE;
DROP TABLE IF EXISTS oltp_ventas.pedidos CASCADE;
DROP TABLE IF EXISTS oltp_ventas.clientes CASCADE;

CREATE TABLE oltp_ventas.clientes (
    cliente_id SERIAL PRIMARY KEY,
    nif VARCHAR(9) UNIQUE NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    direccion VARCHAR(250),
    telefono VARCHAR(20)
);

CREATE TABLE oltp_ventas.pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES oltp_ventas.clientes(cliente_id) ON DELETE CASCADE,
    empleado_id INT REFERENCES oltp_rrhh.empleados(empleado_id) ON DELETE SET NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_pedidos_cliente ON oltp_ventas.pedidos(cliente_id);
CREATE INDEX idx_pedidos_fecha ON oltp_ventas.pedidos(fecha_pedido);

CREATE TABLE oltp_ventas.detalle_pedido (
    detalle_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES oltp_ventas.pedidos(pedido_id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES oltp_inventario.productos(producto_id) ON DELETE RESTRICT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0)
);

CREATE TABLE oltp_ventas.facturas (
    factura_id SERIAL PRIMARY KEY,
    pedido_id INT UNIQUE NOT NULL REFERENCES oltp_ventas.pedidos(pedido_id) ON DELETE CASCADE,
    fecha_emision DATE NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    estado_pago VARCHAR(50) DEFAULT 'Pendiente'
);