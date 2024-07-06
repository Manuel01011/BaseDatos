create table Vendedor(
codigo int,
nombre varchar(30),
 constraint pkc primary key(codigo)
);

create table Cliente(
vendedor int,
codigo int,
nombre varchar(30),
 constraint pkv primary key(vendedor),
 constraint fv foreign key (codigo) references vendedor (codigo)
);

create table Factura(
numero int,
fecha date,
vendedor int,
 constraint pkn primary key(numero),
 constraint fc foreign key (vendedor) references  cliente (vendedor)
);


create table Producto(
codigo int,
nombre varchar(30),
precio float,
cantidad float,
 constraint pkc1 primary key(codigo)
);

create table Detalle(
factura int,
producto int,
cantidad int,
 constraint ff foreign key (factura) references  Factura (numero),
 constraint fp foreign key (producto) references  Producto (codigo)
);

--------------------------------
create table tipoMovimiento(
codigo int,
nombre varchar(30),
accion int,
 constraint pkt primary key(codigo)
);

create table Movimiento(
fecha Date,
tipoMovimiento int,
cantidad int,
revisado int,
producto int,
 constraint fti foreign key (tipoMovimiento) references  tipoMovimiento (codigo),
 constraint fp1 foreign key (producto) references  Producto (codigo)
);


INSERT INTO tipoMovimiento (codigo, nombre, accion) VALUES (1, 'Devulucion', 1);
INSERT INTO tipoMovimiento (codigo, nombre, accion) VALUES (2, 'Venta', 2);

INSERT INTO Producto (codigo, nombre, precio, cantidad) VALUES (1, 'Arroz', 10.99, 100);
INSERT INTO Producto (codigo, nombre, precio, cantidad) VALUES (2, 'Leche', 9.05, 50);

INSERT INTO Movimiento (fecha, tipoMovimiento, cantidad, revisado, producto) 
VALUES (TO_DATE('2024-01-15', 'YYYY-MM-DD'), 1, 50, 0, 1);
INSERT INTO Movimiento (fecha, tipoMovimiento, cantidad, revisado, producto) 
VALUES (TO_DATE('2024-01-17', 'YYYY-MM-DD'), 2, 25, 0, 2);

--prueba
-- Insertar datos de prueba en la tabla Producto
CREATE OR REPLACE FUNCTION procesarMovimientos(fechaInicio IN DATE, fechaFin IN DATE) RETURN INT AS
    tipoMovimientoAccion tipoMovimiento.accion%TYPE;
    productoId Movimiento.producto%TYPE;
    cantidadMovimiento Movimiento.cantidad%TYPE;
BEGIN
    FOR movimiento IN (SELECT m.producto, m.cantidad, tm.accion
                       FROM Movimiento m
                       INNER JOIN tipoMovimiento tm ON m.tipoMovimiento = tm.codigo
                       WHERE m.fecha BETWEEN fechaInicio AND fechaFin AND m.revisado = 0)
    LOOP
        productoId := movimiento.producto;
        tipoMovimientoAccion := movimiento.accion;
        cantidadMovimiento := movimiento.cantidad;
        
        -- Actualizar la cantidad del producto según la acción del tipo de movimiento
        IF tipoMovimientoAccion = 1 THEN
            UPDATE Producto SET cantidad = cantidad + cantidadMovimiento WHERE codigo = productoId;
        ELSE
            UPDATE Producto SET cantidad = cantidad - cantidadMovimiento WHERE codigo = productoId;
        END IF;
        
        -- Marcar el movimiento como revisado
        UPDATE Movimiento SET revisado = 1 WHERE producto = productoId;
    END LOOP;

    RETURN 1; -- Indicar que la función ha sido ejecutada correctamente
END procesarMovimientos;
/


DECLARE
    resultado INT;
BEGIN
    resultado := procesarMovimientos(TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-12-31', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Procesamiento completado');
END;
/



-- Verificar los cambios en la tabla Producto
SELECT * FROM Producto;

-- Verificar si los movimientos han sido marcados como revisados
SELECT * FROM Movimiento;



