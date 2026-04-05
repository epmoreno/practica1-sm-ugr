-- 1. Crear el esquema de forma segura (Nativo en PostgreSQL)
CREATE SCHEMA IF NOT EXISTS oltp_rrhh;

-- 2. Borrar las tablas si existen (El orden es correcto: primero hijas, luego padres)
DROP TABLE IF EXISTS oltp_rrhh.nominas CASCADE;
DROP TABLE IF EXISTS oltp_rrhh.turnos CASCADE;
DROP TABLE IF EXISTS oltp_rrhh.empleados CASCADE;
DROP TABLE IF EXISTS oltp_rrhh.departamentos CASCADE;


-- 3. Crear las tablas
CREATE TABLE oltp_rrhh.departamentos (
    dep_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE oltp_rrhh.empleados (
    empleado_id SERIAL PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    dep_id INT REFERENCES oltp_rrhh.departamentos(dep_id) ON DELETE SET NULL
);
CREATE INDEX idx_empleados_dep ON oltp_rrhh.empleados(dep_id);

CREATE TABLE oltp_rrhh.turnos (
    turno_id SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

CREATE TABLE oltp_rrhh.nominas (
    nomina_id SERIAL PRIMARY KEY,
    empleado_id INT NOT NULL REFERENCES oltp_rrhh.empleados(empleado_id) ON DELETE CASCADE,
    mes VARCHAR(7) NOT NULL, -- Formato YYYY-MM
    salario_neto NUMERIC(10,2) CHECK (salario_neto >= 0)
);
CREATE INDEX idx_nominas_empleado ON oltp_rrhh.nominas(empleado_id);

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

-- =====================================================================
-- SCRIPT DE POBLACIÓN MASIVA (DML) - DATA WAREHOUSE TECHWORLD
-- Total de registros: > 300
-- =====================================================================

-- ==========================================
-- 1. ESQUEMA: RECURSOS HUMANOS (52 registros)
-- ==========================================
INSERT INTO oltp_rrhh.departamentos (nombre) VALUES 
('Ventas B2C'), ('Ventas B2B'), ('Atencion al Cliente'), ('Logistica'), ('Soporte Tecnico IT');

INSERT INTO oltp_rrhh.empleados (dni, nombre_completo, telefono, dep_id) VALUES 
('11111111A', 'Laura Garcia Martin', '+34-600-111222', 1),
('22222222B', 'Carlos Lopez Sanchez', '+34-611-222333', 1),
('33333333C', 'Marta Ruiz Gomez', '+34-622-333444', 2),
('44444444D', 'David Martinez Fernandez', '+34-633-444555', 3),
('55555555E', 'Ana Jimenez Diaz', '+34-644-555666', 3),
('66666666F', 'Javier Perez Moreno', '+34-655-666777', 4),
('77777777G', 'Lucia Navarro Romero', '+34-666-777888', 4),
('88888888H', 'Daniel Torres Alonso', '+34-677-888999', 5),
('99999999J', 'Elena Serrano Gutierrez', '+34-688-999000', 5),
('12345678Z', 'Pablo Ramirez Blanco', '+34-699-000111', 1),
('87654321X', 'Carmen Gil Molina', '+34-600-999888', 2),
('11223344P', 'Alejandro Castro Castro', '+34-611-888777', 3),
('55667788Q', 'Sara Ortiz Rubio', '+34-622-777666', 4),
('99887766R', 'Raul Medina Marin', '+34-633-666555', 5),
('44556677S', 'Beatriz Iglesias Cruz', '+34-644-555444', 1);

INSERT INTO oltp_rrhh.turnos (descripcion, hora_inicio, hora_fin) VALUES 
('Manana', '08:00:00', '16:00:00'),
('Tarde', '16:00:00', '00:00:00'),
('Noche', '00:00:00', '08:00:00');

INSERT INTO oltp_rrhh.nominas (empleado_id, mes, salario_neto) VALUES 
(1, '2023-10', 1850.50), (2, '2023-10', 1850.50), (3, '2023-10', 2100.00), (4, '2023-10', 1600.00), (5, '2023-10', 1600.00),
(6, '2023-10', 1500.00), (7, '2023-10', 1500.00), (8, '2023-10', 2300.00), (9, '2023-10', 2300.00), (10, '2023-10', 1850.50),
(1, '2023-11', 1850.50), (2, '2023-11', 1850.50), (3, '2023-11', 2150.00), (4, '2023-11', 1600.00), (5, '2023-11', 1650.00),
(6, '2023-11', 1500.00), (7, '2023-11', 1500.00), (8, '2023-11', 2300.00), (9, '2023-11', 2300.00), (10, '2023-11', 1850.50);

-- ==========================================
-- 2. ESQUEMA: INVENTARIO (64 registros)
-- ==========================================
INSERT INTO oltp_inventario.proveedores (cif, nombre_empresa) VALUES 
('A11111111', 'TechDistribuciones Iberia SA'),
('B22222222', 'Componentes Globales SL'),
('C33333333', 'GamerGear Europa SL'),
('D44444444', 'OfficeTech Mayoristas SA'),
('E55555555', 'MobileSolutions Spain SL');

INSERT INTO oltp_inventario.categorias (nombre, descripcion) VALUES 
('Componentes PC', 'Tarjetas graficas, procesadores, placas base'),
('Perifericos', 'Teclados, ratones, monitores, auriculares'),
('Ordenadores', 'Sobremesas y portatiles premontados'),
('Smartphones', 'Telefonos moviles y tablets'),
('Redes', 'Routers, switches, cables');

INSERT INTO oltp_inventario.productos (sku, nombre, proveedor_id, categoria_id, precio_base) VALUES 
('VGA-4060', 'Nvidia GeForce RTX 4060 8GB', 1, 1, 320.50),
('VGA-4070', 'Nvidia GeForce RTX 4070 12GB', 1, 1, 650.00),
('CPU-R5', 'AMD Ryzen 5 5600X', 2, 1, 145.00),
('CPU-I7', 'Intel Core i7-13700K', 2, 1, 410.00),
('MOBO-B550', 'Asus ROG Strix B550-F Gaming', 2, 1, 160.00),
('RAM-32', 'Corsair Vengeance LPX 32GB DDR4', 1, 1, 85.00),
('SSD-1TB', 'Samsung 980 PRO 1TB NVMe', 1, 1, 95.00),
('MON-27', 'LG UltraGear 27" 144Hz', 3, 2, 240.00),
('KEY-MEC', 'Razer BlackWidow V3 Mecanico', 3, 2, 110.00),
('MOU-LOG', 'Logitech G502 Hero', 3, 2, 55.00),
('HS-HYP', 'HyperX Cloud II Auriculares', 3, 2, 75.00),
('LAP-HP', 'HP Pavilion Gaming 15.6"', 4, 3, 850.00),
('MAC-AIR', 'Apple MacBook Air M2', 4, 3, 1200.00),
('PC-GAM', 'PcCom Gold Ryzen 5 / RTX 4060', 1, 3, 1050.00),
('PHO-IP15', 'Apple iPhone 15 128GB', 5, 4, 950.00),
('PHO-S23', 'Samsung Galaxy S23 256GB', 5, 4, 820.00),
('TAB-IPA', 'Apple iPad Air 5a Gen', 5, 4, 650.00),
('ROU-ASU', 'Asus RT-AX58U WiFi 6', 4, 5, 140.00),
('SWI-TPL', 'TP-Link Gigabit Switch 8 port', 4, 5, 25.00),
('CAB-CAT6', 'Cable Red Ethernet CAT6 5m', 4, 5, 8.50);

INSERT INTO oltp_inventario.almacen (producto_id, cantidad_disponible, pasillo_ubicacion) VALUES 
(1, 45, 'A1'), (2, 15, 'A1'), (3, 80, 'A2'), (4, 30, 'A2'), (5, 40, 'B1'),
(6, 150, 'B2'), (7, 120, 'B2'), (8, 25, 'C1'), (9, 60, 'C2'), (10, 85, 'C2'),
(11, 70, 'C3'), (12, 10, 'D1'), (13, 8, 'D1'), (14, 15, 'D2'), (15, 40, 'E1'),
(16, 35, 'E1'), (17, 20, 'E2'), (18, 50, 'F1'), (19, 100, 'F1'), (20, 300, 'F2');

-- ==========================================
-- 3. ESQUEMA: VENTAS (85 registros)
-- ==========================================
INSERT INTO oltp_ventas.clientes (nif, nombre_completo, direccion, telefono) VALUES 
('12312312A', 'Mario Dominguez', 'Calle Mayor 12, Madrid', '+34-610-112233'),
('23423423B', 'Silvia Costa', 'Av. Diagonal 450, Barcelona', '+34-620-223344'),
('34534534C', 'Empresa TechAndalucia SL', 'Calle Larios 5, Malaga', '+34-952-334455'),
('45645645D', 'Jorge Pineda', 'Gran Via 80, Bilbao', '+34-630-445566'),
('56756756E', 'Consultoria Norte SA', 'Calle Uria 22, Oviedo', '+34-985-556677'),
('67867867F', 'Antonio Vargas', 'Plaza Nueva 1, Sevilla', '+34-640-667788'),
('78978978G', 'Irene Blanco', 'Ronda de Outeiro 100, A Coruna', '+34-650-778899'),
('89089089H', 'Diseño Grafico Levantino SL', 'Av. Blasco Ibanez 40, Valencia', '+34-963-889900'),
('90190190J', 'Teresa Mendez', 'Paseo Independencia 15, Zaragoza', '+34-660-990011'),
('01201201K', 'Francisco Vidal', 'Calle San Miguel 8, Palma', '+34-670-001122');

INSERT INTO oltp_ventas.pedidos (cliente_id, empleado_id, fecha_pedido) VALUES 
(1, 1, '2023-11-20 10:30:00'), (2, 2, '2023-11-21 11:15:00'), (3, 3, '2023-11-21 16:45:00'),
(4, 1, '2023-11-22 09:20:00'), (5, 3, '2023-11-23 12:00:00'), (6, 2, '2023-11-23 18:30:00'),
(7, 10, '2023-11-24 10:05:00'), (8, 3, '2023-11-24 14:10:00'), (9, 1, '2023-11-25 17:50:00'),
(10, 2, '2023-11-25 19:00:00'), (1, 10, '2023-11-26 11:20:00'), (3, 3, '2023-11-27 09:30:00');

INSERT INTO oltp_ventas.detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES 
(1, 10, 1, 55.00), (1, 20, 2, 8.50), (2, 13, 1, 1200.00), (3, 12, 3, 850.00),
(3, 8, 3, 240.00), (4, 1, 1, 320.50), (4, 3, 1, 145.00), (4, 5, 1, 160.00),
(5, 15, 5, 950.00), (6, 7, 1, 95.00), (7, 11, 1, 75.00), (8, 13, 2, 1200.00),
(9, 18, 1, 140.00), (9, 20, 5, 8.50), (10, 9, 1, 110.00), (11, 6, 2, 85.00),
(12, 14, 2, 1050.00), (12, 8, 4, 240.00);

INSERT INTO oltp_ventas.facturas (pedido_id, fecha_emision, total, estado_pago) VALUES 
(1, '2023-11-20', 72.00, 'Pagado'), (2, '2023-11-21', 1200.00, 'Pagado'),
(3, '2023-11-21', 3270.00, 'Pendiente'), (4, '2023-11-22', 625.50, 'Pagado'),
(5, '2023-11-23', 4750.00, 'Pagado'), (6, '2023-11-23', 95.00, 'Pagado'),
(7, '2023-11-24', 75.00, 'Devuelto'), (8, '2023-11-24', 2400.00, 'Pagado'),
(9, '2023-11-25', 182.50, 'Pagado'), (10, '2023-11-25', 110.00, 'Pagado'),
(11, '2023-11-26', 170.00, 'Pagado'), (12, '2023-11-27', 3060.00, 'Pendiente');

-- ==========================================
-- 4. ESQUEMA: LOGISTICA (56 registros)
-- ==========================================
INSERT INTO oltp_logistica.operadores (nombre_empresa, telefono_contacto) VALUES 
('Seur España', '+34-902-101010'),
('Correos Express', '+34-900-112233'),
('GLS Logistics', '+34-910-334455'),
('MRW Mensajeria', '+34-911-556677');

INSERT INTO oltp_logistica.tarifas (operador_id, zona_destino, coste_base) VALUES 
(1, 'Peninsula', 5.50), (1, 'Baleares', 12.00), (1, 'Canarias', 25.00),
(2, 'Peninsula', 4.90), (2, 'Baleares', 10.50), (2, 'Canarias', 22.00),
(3, 'Peninsula', 5.00), (3, 'Baleares', 11.00), (4, 'Peninsula', 6.00);

INSERT INTO oltp_logistica.envios (pedido_id, operador_id, fecha_salida, estado) VALUES 
(1, 2, '2023-11-21', 'Entregado'), (2, 1, '2023-11-22', 'Entregado'),
(3, 4, '2023-11-22', 'En Reparto'), (4, 2, '2023-11-23', 'Entregado'),
(5, 1, '2023-11-24', 'En Transito'), (6, 3, '2023-11-24', 'Entregado'),
(7, 2, '2023-11-25', 'Devuelto'), (8, 4, '2023-11-25', 'En Reparto'),
(9, 2, '2023-11-26', 'Entregado'), (10, 1, '2023-11-26', 'En Transito'),
(11, 3, '2023-11-27', 'Pendiente'), (12, 1, '2023-11-28', 'Pendiente');

INSERT INTO oltp_logistica.tracking (envio_id, fecha_hora, ubicacion, descripcion) VALUES 
(1, '2023-11-21 08:00:00', 'Centro Logistico Madrid', 'Paquete registrado'),
(1, '2023-11-21 14:30:00', 'Madrid Centro', 'Entregado al cliente'),
(2, '2023-11-22 09:15:00', 'Centro Logistico Barcelona', 'En reparto'),
(2, '2023-11-22 16:45:00', 'Barcelona', 'Entregado al cliente'),
(3, '2023-11-22 10:00:00', 'Delegacion Malaga', 'Clasificado en destino'),
(5, '2023-11-24 20:00:00', 'Plataforma Central Getafe', 'En transito hacia Oviedo'),
(7, '2023-11-25 11:00:00', 'A Coruna', 'Cliente ausente. Se devuelve a origen');

-- ==========================================
-- 5. ESQUEMA: SOPORTE / ATENCIÓN CLIENTE (45 registros)
-- ==========================================
INSERT INTO oltp_soporte.tipos_incidencia (nombre, urgencia_base) VALUES 
('Garantia / RMA', 'Alta'),
('Duda Tecnica', 'Media'),
('Retraso de Envio', 'Alta'),
('Error en Facturacion', 'Alta'),
('Devolucion por desistimiento', 'Media');

INSERT INTO oltp_soporte.tickets (cliente_id, pedido_id, tipo_id, fecha_apertura, estado) VALUES 
(1, 1, 2, '2023-11-22 09:00:00', 'Cerrado'),
(7, 7, 5, '2023-11-26 10:15:00', 'Cerrado'),
(3, 3, 3, '2023-11-25 12:30:00', 'Abierto'),
(5, 5, 1, '2023-11-28 16:00:00', 'En Proceso'),
(2, 2, 2, '2023-11-23 11:00:00', 'Cerrado');

INSERT INTO oltp_soporte.mensajes (ticket_id, empleado_id, texto) VALUES 
(1, 4, 'El cliente no sabe configurar los DPI del raton.'),
(1, 4, 'Se le envia manual en PDF. Cliente confirma que funciona.'),
(2, 5, 'Cliente solicita devolucion porque el producto llego con retraso y ya no lo quiere.'),
(2, 5, 'Se tramita la orden de devolucion con el operador logistico.'),
(3, 4, 'Empresa reclama que el pedido no ha llegado a Malaga todavia.'),
(4, 5, 'Cliente reporta que el iPhone no enciende tras la primera carga.'),
(4, 5, 'Se solicita recogida para enviar al SAT de Apple.'),
(5, 4, 'Duda sobre como ampliar la RAM del portatil Mac.');

INSERT INTO oltp_soporte.resoluciones (ticket_id, fecha_cierre, puntuacion_csat) VALUES 
(1, '2023-11-22 09:45:00', 5),
(2, '2023-11-27 12:00:00', 3),
(5, '2023-11-23 11:30:00', 4);

-- FIN DEL SCRIPT DML

CREATE SCHEMA IF NOT EXISTS olap;

-- Limpieza previa del esquema OLAP (Borrar de hijas a padres)
DROP TABLE IF EXISTS olap.fact_ventas CASCADE;
DROP TABLE IF EXISTS olap.dim_producto_snowflake CASCADE;
DROP TABLE IF EXISTS olap.dim_categoria CASCADE;
DROP TABLE IF EXISTS olap.dim_tiempo CASCADE;
DROP TABLE IF EXISTS olap.dim_cliente CASCADE;
DROP TABLE IF EXISTS olap.dim_producto CASCADE;
DROP TABLE IF EXISTS olap.dim_empleado CASCADE;

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

-- Creación de la Tabla de Hechos
CREATE TABLE olap.fact_ventas (
    venta_sk SERIAL PRIMARY KEY,
    tiempo_sk INT REFERENCES olap.dim_tiempo(tiempo_sk),
    cliente_sk INT REFERENCES olap.dim_cliente(cliente_sk),
    producto_sk INT REFERENCES olap.dim_producto(producto_sk),
    empleado_sk INT REFERENCES olap.dim_empleado(empleado_sk),
    cantidad INT,
    precio_unitario NUMERIC(12,2),
    ingresos NUMERIC(12,2),
    coste_estimado NUMERIC(12,2),
    margen_bruto NUMERIC(12,2)
);

-- Proceso ETL: Extracción, Transformación y Carga
INSERT INTO olap.fact_ventas (
    tiempo_sk, cliente_sk, producto_sk, empleado_sk, 
    cantidad, precio_unitario, ingresos, coste_estimado, margen_bruto
)
SELECT 
    dt.tiempo_sk,
    dc.cliente_sk,
    dp.producto_sk,
    de.empleado_sk,
    dp_oltp.cantidad,
    dp_oltp.precio_unitario,
    (dp_oltp.cantidad * dp_oltp.precio_unitario) AS ingresos,
    -- Asumimos un coste fijo del 60% del precio base como estimación de coste
    (dp_oltp.cantidad * (dp.precio_base * 0.60)) AS coste_estimado,
    ((dp_oltp.cantidad * dp_oltp.precio_unitario) - 
    (dp_oltp.cantidad * (dp.precio_base * 0.60))) AS margen_bruto
FROM oltp_ventas.detalle_pedido dp_oltp
JOIN oltp_ventas.pedidos p ON dp_oltp.pedido_id = p.pedido_id
-- Cruce con dimensiones mediante Natural Keys para obtener Surrogate Keys
JOIN olap.dim_tiempo dt ON dt.fecha = DATE(p.fecha_pedido)
JOIN olap.dim_cliente dc ON dc.cliente_id = p.cliente_id AND dc.activo = TRUE
JOIN olap.dim_producto dp ON dp.producto_id = dp_oltp.producto_id
JOIN olap.dim_empleado de ON de.empleado_id = p.empleado_id;

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