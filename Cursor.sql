CREATE TABLE clientes_tarea1 (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    apellido VARCHAR2(100),
    puesto VARCHAR2(100),
    salario NUMBER
);

INSERT INTO clientes_tarea1 (id, nombre, apellido, puesto, salario) VALUES (1, 'Juan', 'Pérez', 'Gerente', 5000);
INSERT INTO clientes_tarea1 (id, nombre, apellido, puesto, salario) VALUES (2, 'María', 'González', 'Analista', 4000);
INSERT INTO clientes_tarea1 (id, nombre, apellido, puesto, salario) VALUES (3, 'Pedro', 'Sánchez', 'Desarrollador', 4500);

select * from clientes_tarea1;


CREATE OR REPLACE FUNCTION obtener_datos RETURN SYS_REFCURSOR AS
    resultado_cursor SYS_REFCURSOR;
BEGIN
    OPEN resultado_cursor FOR
    SELECT id, nombre, apellido, puesto, salario
    FROM clientes_tarea1;
    
    RETURN resultado_cursor;
EXCEPTION
    WHEN OTHERS THEN
        IF resultado_cursor%ISOPEN THEN
            CLOSE resultado_cursor;
        END IF;
        RAISE;
END obtener_datos;
/


