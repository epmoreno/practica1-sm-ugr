CREATE SCHEMA IF NOT EXISTS oltp_logistica;

DROP TABLE IF EXISTS oltp_logistica.tracking CASCADE;
DROP TABLE IF EXISTS oltp_logistica.envios CASCADE;
DROP TABLE IF EXISTS oltp_logistica.tarifas CASCADE;
DROP TABLE IF EXISTS oltp_logistica.operadores CASCADE;

CREATE TABLE oltp_logistica.operadores (
    operador_id SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(150) NOT NULL UNIQUE,
    telefono_contacto VARCHAR(20)
);

CREATE TABLE oltp_logistica.tarifas (
    tarifa_id SERIAL PRIMARY KEY,
    operador_id INT NOT NULL REFERENCES oltp_logistica.operadores(operador_id) ON DELETE CASCADE,
    zona_destino VARCHAR(100) NOT NULL,
    coste_base NUMERIC(10,2) NOT NULL CHECK (coste_base >= 0)
);

CREATE TABLE oltp_logistica.envios (
    envio_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES oltp_ventas.pedidos(pedido_id) ON DELETE CASCADE,
    operador_id INT REFERENCES oltp_logistica.operadores(operador_id) ON DELETE SET NULL,
    fecha_salida DATE,
    estado VARCHAR(50) DEFAULT 'Preparando'
);
CREATE INDEX idx_envios_pedido ON oltp_logistica.envios(pedido_id);

CREATE TABLE oltp_logistica.tracking (
    tracking_id SERIAL PRIMARY KEY,
    envio_id INT NOT NULL REFERENCES oltp_logistica.envios(envio_id) ON DELETE CASCADE,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ubicacion VARCHAR(200),
    descripcion VARCHAR(250)
);