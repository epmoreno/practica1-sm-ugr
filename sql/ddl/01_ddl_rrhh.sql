-- 1. Crear el esquema de forma segura (Nativo en PostgreSQL)
CREATE SCHEMA IF NOT EXISTS oltp_rrhh;

-- 2. Borrar las tablas si existen (El orden es correcto: primero hijas, luego padres)
-- Te recomiendo añadir CASCADE por si en el futuro otras tablas dependen de ellas
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