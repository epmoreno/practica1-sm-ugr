import psycopg2
import os
from dotenv import load_dotenv
load_dotenv()  # Carga las variables de entorno desde el archivo .env
import time
import statistics

# ==========================================
# 1. CONEXIÓN A LA BASE DE DATOS
# ==========================================
conn = psycopg2.connect(
    host=os.getenv("DBHOST"),
    port=os.getenv("DBPORT"),
    database=os.getenv("DBNAME"),
    user=os.getenv("DBUSER"),
    password=os.getenv("DBPASSWORD")
)
cur = conn.cursor()

# ==========================================
# 2. DEFINICIÓN DE CONSULTAS (Misma pregunta de negocio)
# Pregunta: Ingresos totales por categoría de producto.
# ==========================================

# Consulta OLTP: Múltiples JOINs entre esquemas
query_oltp = """
SELECT c.nombre, SUM(dp.cantidad * dp.precio_unitario) AS total_ingresos
FROM oltp_ventas.pedidos p
JOIN oltp_ventas.detalle_pedido dp ON p.pedido_id = dp.pedido_id
JOIN oltp_inventario.productos pr ON dp.producto_id = pr.producto_id
JOIN oltp_inventario.categorias c ON pr.categoria_id = c.categoria_id
GROUP BY c.nombre;
"""

# Consulta STAR: Solo 1 JOIN desde la tabla de hechos
query_star = """
SELECT dp.categoria_nombre, SUM(fv.ingresos) AS total_ingresos
FROM olap.fact_ventas fv
JOIN olap.dim_producto dp ON fv.producto_sk = dp.producto_sk
GROUP BY dp.categoria_nombre;
"""

# Consulta SNOW: 2 JOINs desde la tabla de hechos
query_snow = """
SELECT c.nombre_categoria, SUM(fv.ingresos) AS total_ingresos
FROM olap.fact_ventas fv
JOIN olap.dim_producto_snowflake dp ON fv.producto_sk = dp.producto_sk
JOIN olap.dim_categoria c ON dp.categoria_sk = c.categoria_sk
GROUP BY c.nombre_categoria;
"""

# ==========================================
# 3. FUNCIÓN DE MEDICIÓN
# ==========================================
def medir(query, repeticiones=20):
    tiempos = []
    cur.execute(query)
    cur.fetchall()
    
    # Comenzamos las mediciones reales
    for _ in range(repeticiones):
        inicio = time.time()
        cur.execute(query)
        cur.fetchall()
        fin = time.time()
        
        # Guardamos el tiempo en milisegundos
        tiempos.append((fin - inicio) * 1000)
    
    return tiempos

# ==========================================
# 4. EJECUCIÓN DEL BENCHMARK
# ==========================================
print("Iniciando Benchmarking (20 iteraciones por arquitectura)...\n")

print("Ejecutando OLTP (Sistema Transaccional)...")
oltp_times = medir(query_oltp)

print("Ejecutando Esquema en Estrella...")
star_times = medir(query_star)

print("Ejecutando Esquema en Copo de Nieve...")
snow_times = medir(query_snow)

# ==========================================
# 5. RESULTADOS
# ==========================================
def mostrar(nombre, tiempos):
    promedio = round(statistics.mean(tiempos), 4)
    desv_std = round(statistics.stdev(tiempos), 4)
    print(f"--- {nombre} ---")
    print(f"Promedio: {promedio} ms")
    print(f"Desv Std: ±{desv_std} ms\n")

print("\n" + "="*30)
print("     RESULTADOS FINALES")
print("="*30)
mostrar("OLTP (Múltiples schemas)", oltp_times)
mostrar("Esquema en Copo de Nieve", snow_times)
mostrar("Esquema en Estrella", star_times)

cur.close()
conn.close()