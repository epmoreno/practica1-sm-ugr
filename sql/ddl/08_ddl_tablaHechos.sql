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