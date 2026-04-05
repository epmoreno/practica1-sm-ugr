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