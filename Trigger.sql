CREATE TABLE vendedor6(
    codigo INT,
    nombre VARCHAR(30),
    vendido FLOAT DEFAULT 0,  
    CONSTRAINT pkcl PRIMARY KEY(codigo)
);

 
create table zonas6(

    nombre varchar(30),

    codigo int,

    constraint pkz primary key (codigo)
);
 
create table cliente6(

vendedor int,

codigo int,

codigoz int,

nombre varchar(30),

constraint pkve primary key(vendedor),

constraint fve foreign key (codigo) references vendedor6 (codigo),

constraint fzo foreign key (codigoz) references zonas6 (codigo)

);
 
create table factura6(

numero int,

fecha date,

cliente int,

constraint pknum primary key(numero),

constraint fcli foreign key (cliente) references  cliente6 (vendedor)
);

 
create table detalle6(

factura int,

producto int,

cantidad int,

codigoD int,

constraint pkco primary key(codigoD),

constraint ffa foreign key (factura) references  factura6 (numero)

);
 
create table producto6(

codigo int,

nombre varchar(30),

precio float,

cantidad float,

detalle int,

constraint pkcod primary key(codigo),

constraint fde foreign key (detalle) references  detalle6 (codigoD)
);
 
create table bodegas6(

    numeroBodega int,

    codigoZ int,

    constraint pkbo primary key(numeroBodega),

    constraint fic foreign key (codigoz) references zonas6 (codigo)
);
 
create table inventario6(

codigoB int,

codigoP int,

cantidad int,

minimo int,

nombre varchar(30),

constraint fProducto foreign key (codigoP) references producto6 (codigo),

constraint fbodega foreign key (codigoB) references bodegas6 (numeroBodega)

);

SELECT * FROM vendedor6;

-- Seleccionar todos los datos de la tabla zonas6
SELECT * FROM zonas6;

-- Seleccionar todos los datos de la tabla cliente6
SELECT * FROM cliente6;

-- Seleccionar todos los datos de la tabla factura6
SELECT * FROM factura6;

-- Seleccionar todos los datos de la tabla detalle6
SELECT * FROM detalle6;

-- Seleccionar todos los datos de la tabla producto6
SELECT * FROM producto6;

-- Seleccionar todos los datos de la tabla bodegas6
SELECT * FROM bodegas6;

-- Seleccionar todos los datos de la tabla inventario6
SELECT * FROM inventario6;


--inicialisamos la tablas 
-- Datos de ejemplo para la tabla vendedor6
INSERT INTO vendedor6 (codigo, nombre, vendido) VALUES (1, 'Juan Pérez', 0);

-- Datos de ejemplo para la tabla zonas6
INSERT INTO zonas6 (nombre, codigo) VALUES ('Zona Norte', 1);

-- Datos de ejemplo para la tabla cliente6
INSERT INTO cliente6 (vendedor, codigo, codigoz, nombre) VALUES (1, 1, 1, 'Victor');

-- Datos de ejemplo para la tabla factura6
INSERT INTO factura6 (numero, fecha, cliente) VALUES (1, TO_DATE('2024-05-04', 'YYYY-MM-DD'), 1);

-- Datos de ejemplo para la tabla detalle6
INSERT INTO detalle6 (factura, producto, cantidad, codigoD) VALUES (1, 1, 0, 0);

--esta sentencia se hace de ultimo para verificar si esta bien los procedimientos: 
INSERT INTO detalle6 (factura, producto, cantidad, codigoD) VALUES (1, 1, 5, 3);

-- Datos de ejemplo para la tabla producto6
INSERT INTO producto6 (codigo, nombre, precio, cantidad, detalle) VALUES (1, 'Arroz', 10, 100, 1);

-- Datos de ejemplo para la tabla bodegas6
INSERT INTO bodegas6 (numeroBodega, codigoZ) VALUES (1,1);

-- Datos de ejemplo para la tabla inventario6
INSERT INTO inventario6 (codigoB, codigoP, cantidad, minimo, nombre) VALUES (1, 1, 50, 10, 'Inventario 1');


CREATE OR REPLACE TRIGGER actualizar_total_vendedor
AFTER INSERT ON detalle
FOR EACH ROW
DECLARE
    precio_producto FLOAT;
BEGIN
    SELECT precio INTO precio_producto FROM producto6 WHERE codigo = :NEW.producto;
    
    UPDATE vendedor6 SET vendido = vendido + (:NEW.cantidad * precio_producto)
    WHERE codigo = (SELECT vendedor FROM cliente6 WHERE codigo = (SELECT cliente FROM factura6 WHERE numero = :NEW.factura));
END;



CREATE OR REPLACE TRIGGER verificar_inventario_y_reabastecimiento
AFTER INSERT ON detalle6
FOR EACH ROW
DECLARE
    cantidad_actual INT;
    minimo_permitido INT;
    codigo_bodega INT;
BEGIN
    -- Determinar el código de bodega basado en la zona del cliente que hizo la factura
    SELECT b.numeroBodega INTO codigo_bodega FROM bodegas6 b
    JOIN cliente6 c ON b.codigoZ = c.codigoz
    WHERE c.codigo = (SELECT cliente FROM factura6 WHERE numero = :NEW.factura);
    
    -- Actualizar inventario
    UPDATE inventario6 SET cantidad = cantidad - :NEW.cantidad
    WHERE codigoP = :NEW.producto AND codigoB = codigo_bodega;
    
    -- Consultar la cantidad actualizada y el mínimo permitido
    SELECT cantidad, minimo INTO cantidad_actual, minimo_permitido FROM inventario6
    WHERE codigoP = :NEW.producto AND codigoB = codigo_bodega;
    
    -- Alertar si la cantidad actual es igual o inferior al mínimo permitido
    IF (cantidad_actual <= minimo_permitido) THEN
        -- Aquí se podría llamar a un procedimiento almacenado o insertar en una tabla de alertas
        -- Por ejemplo: INSERT INTO alertas_reabastecimiento (producto, bodega, cantidad_requerida) VALUES (:NEW.producto, codigo_bodega, cantidad_requerida);
        NULL; -- Reemplaza NULL por la acción deseada
    END IF;
END;


----------------------------------
-- Verificar el total vendido del vendedor
SELECT nombre, vendido FROM vendedor6 WHERE codigo = 1;

-- Verificar la cantidad de inventario
SELECT nombre, cantidad FROM inventario6 WHERE codigoP = 1;