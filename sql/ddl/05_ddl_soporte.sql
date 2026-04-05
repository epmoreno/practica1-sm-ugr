CREATE SCHEMA IF NOT EXISTS oltp_soporte;

DROP TABLE IF EXISTS oltp_soporte.resoluciones CASCADE;
DROP TABLE IF EXISTS oltp_soporte.mensajes CASCADE;
DROP TABLE IF EXISTS oltp_soporte.tickets CASCADE;
DROP TABLE IF EXISTS oltp_soporte.tipos_incidencia CASCADE;

CREATE TABLE oltp_soporte.tipos_incidencia (
    tipo_id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    urgencia_base VARCHAR(50) NOT NULL
);

CREATE TABLE oltp_soporte.tickets (
    ticket_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES oltp_ventas.clientes(cliente_id) ON DELETE CASCADE,
    pedido_id INT REFERENCES oltp_ventas.pedidos(pedido_id) ON DELETE SET NULL,
    tipo_id INT REFERENCES oltp_soporte.tipos_incidencia(tipo_id) ON DELETE RESTRICT,
    fecha_apertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(50) DEFAULT 'Abierto'
);
CREATE INDEX idx_tickets_cliente ON oltp_soporte.tickets(cliente_id);

CREATE TABLE oltp_soporte.mensajes (
    mensaje_id SERIAL PRIMARY KEY,
    ticket_id INT NOT NULL REFERENCES oltp_soporte.tickets(ticket_id) ON DELETE CASCADE,
    empleado_id INT REFERENCES oltp_rrhh.empleados(empleado_id) ON DELETE SET NULL,
    texto TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE oltp_soporte.resoluciones (
    resolucion_id SERIAL PRIMARY KEY,
    ticket_id INT UNIQUE NOT NULL REFERENCES oltp_soporte.tickets(ticket_id) ON DELETE CASCADE,
    fecha_cierre TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    puntuacion_csat INT CHECK (puntuacion_csat BETWEEN 1 AND 5)
);