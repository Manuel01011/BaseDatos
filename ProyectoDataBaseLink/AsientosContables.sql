CREATE TABLE tabla_asientos(
    numero INT,
    cuenta VARCHAR(20),
    centaAfecta VARCHAR(20),
    debe FLOAT,
    haber FLOAT
);

CREATE TABLE catalogo_contable(
    cuenta VARCHAR(20),
    acepta_movimiento CHAR(1),
    debe FLOAT,
    haber FLOAT
);

CREATE TABLE errores (
    cuenta VARCHAR(20),
    mensaje VARCHAR(255)
);


--                            Creacion de directorio
CREATE OR REPLACE DIRECTORY USER_DIR AS 'C:\app\az885\product\21c\admin\XE\adump';


--                         VERIFICAR EXISTENCIA CUENTA
CREATE OR REPLACE PROCEDURE verificarExistenciaCuenta(p_cuenta IN VARCHAR2, p_resultado OUT NUMBER)
IS
    v_file UTL_FILE.FILE_TYPE;
    vCount NUMBER;
BEGIN
    v_file := UTL_FILE.FOPEN('USER_DIR', 'ERRORES.TXT', 'W');
    SELECT COUNT(*) INTO vCount FROM catalogo_contable WHERE cuenta = p_cuenta;
    IF vCount = 0 THEN
        p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'La cuenta no existe en el catálogo contable');
              UTL_FILE.PUT_LINE(v_file,'La cuenta no existe en el catálogo contable: '|| p_cuenta);
              UTL_FILE.FCLOSE(v_file);
    ELSE
        p_resultado := 0;
        UTL_FILE.FCLOSE(v_file);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'Error genérico: ' );
        UTL_FILE.PUT_LINE(v_file,'Error generico en la cuenta: '|| p_cuenta);
        UTL_FILE.FCLOSE(v_file);
END;
/



--                               VERIFICAR MOVIMIENTO 
CREATE OR REPLACE PROCEDURE verificarMovimiento(p_cuenta IN VARCHAR2, p_resultado OUT NUMBER)
IS
    vAcepta CHAR(1);
     v_file UTL_FILE.FILE_TYPE;
BEGIN
    v_file := UTL_FILE.FOPEN('USER_DIR', 'ERRORES.TXT', 'W');
    SELECT acepta_movimiento INTO vAcepta FROM catalogo_contable WHERE cuenta = p_cuenta AND ROWNUM = 1;
    IF vAcepta = 'N' THEN
       p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje)
        VALUES (p_cuenta, 'Movimiento no permitido para esta cuenta');
        UTL_FILE.PUT_LINE(v_file,'Movimiento no permitido para esta cuenta: '|| p_cuenta);
        UTL_FILE.FCLOSE(v_file);
    ELSE
       p_resultado := 0;
       UTL_FILE.FCLOSE(v_file);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'No se encontró la cuenta en el catálogo contable');
         UTL_FILE.PUT_LINE(v_file,'No se encontró la cuenta en el catálogo contable: '|| p_cuenta);
         UTL_FILE.FCLOSE(v_file);
    WHEN TOO_MANY_ROWS THEN
        p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'Múltiples cuentas encontradas en el catálogo contable');
         UTL_FILE.PUT_LINE(v_file,'Múltiples cuentas encontradas en el catálogo contable: '|| p_cuenta);
         UTL_FILE.FCLOSE(v_file);
    WHEN OTHERS THEN
        p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'Error genérico: ' );
         UTL_FILE.PUT_LINE(v_file,'Error generico: '|| p_cuenta);
         UTL_FILE.FCLOSE(v_file);
END;
/


--                               VERIFICAR HABER 
CREATE OR REPLACE PROCEDURE verificarDebeHaber(p_cuenta IN VARCHAR2, p_resultado OUT NUMBER)
IS
    v_file UTL_FILE.FILE_TYPE;
    vDebe NUMBER;
    vHaber NUMBER;
BEGIN
   v_file := UTL_FILE.FOPEN('USER_DIR', 'ERRORES.TXT', 'W');

    SELECT SUM(debe), SUM(haber) INTO vDebe, vHaber FROM tabla_asientos WHERE cuenta = p_cuenta;
    IF (vDebe = 0 AND vHaber = 0) OR (vDebe != 0 AND vHaber != 0) THEN
        p_resultado := 1;
    INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'Incoherencia entre debe y haber');
     UTL_FILE.PUT_LINE(v_file,'Incoherencia entre debe y haber en la cuenta: '|| p_cuenta);
     UTL_FILE.FCLOSE(v_file);
    ELSE
        p_resultado := 0;
        UTL_FILE.FCLOSE(v_file);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 1;
        INSERT INTO errores(cuenta, mensaje) VALUES (p_cuenta, 'Error genérico: ' );
         UTL_FILE.PUT_LINE(v_file,'Error generico en la cuenta: '|| p_cuenta);
         UTL_FILE.FCLOSE(v_file);
END;
/


--                               VERIFICAR ASIENTOS 
CREATE OR REPLACE PROCEDURE verificar_asientos
IS
-- Declaración de un identificador de archivo para el registro de errores
    v_file UTL_FILE.FILE_TYPE;
    CURSOR c_asientos IS
        SELECT DISTINCT numero FROM tabla_asientos;
    
    v_numero_asiento tabla_asientos.numero%TYPE;
    v_error NUMBER := 0;
    primer_digito_cuenta1 CHAR(1); -- Declaración de la variable
    primer_digito_cuenta2 CHAR(1); -- Declaración de la variable
    -- Declaración de la variable asiento para obtener los datos de la tabla_asientos
    asiento tabla_asientos%ROWTYPE;
BEGIN
    -- Intenta abrir el archivo para escritura
   v_file := UTL_FILE.FOPEN('USER_DIR', 'ERRORES.TXT', 'W');
    -- Iniciar la transacción
    BEGIN
        -- Abrir cursor de asientos
        OPEN c_asientos;
        
        -- Recorrer todos los asientos
        LOOP
            FETCH c_asientos INTO v_numero_asiento;
            EXIT WHEN c_asientos%NOTFOUND;
            
            -- Cursor para recorrer todos los registros con el mismo número de asiento
            FOR asiento IN (SELECT * FROM tabla_asientos WHERE numero = v_numero_asiento) LOOP
                -- Obtener el primer dígito de la cuenta
                primer_digito_cuenta1 := SUBSTR(asiento.cuenta, 1, 1);
                primer_digito_cuenta2 := SUBSTR(asiento.centaAfecta, 1, 1); 
                
                -- Verificar existencia de las cuentas y permisos de movimiento
                verificarExistenciaCuenta(asiento.cuenta, v_error);
                verificarExistenciaCuenta(asiento.centaAfecta, v_error);
                verificarMovimiento(asiento.cuenta, v_error);
                verificarMovimiento(asiento.centaAfecta, v_error);
                verificarDebeHaber(asiento.cuenta, v_error);

                -- Aplicar las reglas de negocio según el primer dígito de las cuentas
                CASE
                    WHEN primer_digito_cuenta1 = '1' AND primer_digito_cuenta2 IN ('2', '4') THEN
                        UPDATE catalogo_contable SET debe = debe + asiento.debe WHERE cuenta = asiento.cuenta;
                        UPDATE catalogo_contable SET haber = haber + asiento.debe WHERE cuenta = asiento.centaAfecta;
                        
                    WHEN primer_digito_cuenta1 = '2' AND primer_digito_cuenta2 IN ('1', '2', '3') THEN
                        UPDATE catalogo_contable SET haber = haber + asiento.haber WHERE cuenta = asiento.cuenta;
                        UPDATE catalogo_contable SET debe = debe + asiento.haber WHERE cuenta = asiento.centaAfecta;
                        
                    WHEN primer_digito_cuenta1 = '3' AND primer_digito_cuenta2 IN ('2', '4') THEN
                        UPDATE catalogo_contable SET debe = debe + asiento.debe WHERE cuenta = asiento.cuenta;
                        UPDATE catalogo_contable SET haber = haber + asiento.debe WHERE cuenta = asiento.centaAfecta;
                        
                    WHEN primer_digito_cuenta1 = '4' AND primer_digito_cuenta2 IN ('1', '3', '5') THEN
                        UPDATE catalogo_contable SET haber = haber + asiento.haber WHERE cuenta = asiento.cuenta;
                        UPDATE catalogo_contable SET debe = debe + asiento.haber WHERE cuenta = asiento.centaAfecta;
                        
                    WHEN primer_digito_cuenta1 = '5' AND primer_digito_cuenta2 IN ('2', '4') THEN
                        UPDATE catalogo_contable SET debe = debe + asiento.debe WHERE cuenta = asiento.cuenta;
                        UPDATE catalogo_contable SET haber = haber + asiento.debe WHERE cuenta = asiento.centaAfecta;
                        
                    ELSE
                        v_error := 1;
                        -- Escribe el error en el archivo de texto
                        UTL_FILE.PUT_LINE(v_file, 'Combinación de cuentas no válida para la transacción: ' || asiento.cuenta || ' afecta ' || asiento.centaAfecta);
                END CASE;
                
                -- Salir del loop si hay un error
                EXIT WHEN v_error <> 0;
            END LOOP;
        END LOOP;
        
        -- Cerrar cursor de asientos
        CLOSE c_asientos;
        
        -- Comprobar si hay errores
        IF v_error = 0 THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- En caso de error, registra el error en el archivo de texto
            UTL_FILE.PUT_LINE(v_file, 'Error durante la actualización de asientos: ');
            ROLLBACK;
    END;

    -- Cerrar el archivo después de su uso
    UTL_FILE.FCLOSE(v_file);
END;
/

--                               MAYORIZACION DE SUBCUENTAS 
CREATE OR REPLACE PROCEDURE mayorizar_subcuentas IS
BEGIN
    UPDATE catalogo_contable c1
    SET 
        c1.debe = (SELECT COALESCE(SUM(c2.debe), 0)
                   FROM catalogo_contable c2
                   WHERE c2.cuenta LIKE c1.cuenta || '-%'), 
        c1.haber = (SELECT COALESCE(SUM(c2.haber), 0)
                    FROM catalogo_contable c2
                    WHERE c2.cuenta LIKE c1.cuenta || '-%')
    WHERE c1.acepta_movimiento = 'N';  
END;
/

--                               MAYORIZACION CONTABILIDAD 
CREATE OR REPLACE PROCEDURE mayorizar_contabilidad IS
BEGIN
    FOR i IN REVERSE 1..3 LOOP 
        EXECUTE IMMEDIATE 'BEGIN mayorizar_subcuentas; END;'; 
    END LOOP;
    UPDATE catalogo_contable c1
    SET 
        c1.debe = (SELECT COALESCE(SUM(c2.debe), 0)
                   FROM catalogo_contable c2
                   WHERE c2.cuenta LIKE SUBSTR(c1.cuenta, 1, 3) || '%'
                   AND c2.cuenta != c1.cuenta),
        c1.haber = (SELECT COALESCE(SUM(c2.haber), 0)
                    FROM catalogo_contable c2
                    WHERE c2.cuenta LIKE SUBSTR(c1.cuenta, 1, 3) || '%'
                    AND c2.cuenta != c1.cuenta)
    WHERE c1.acepta_movimiento = 'N';
END;

-------------------------------------------------------------------------------Prueba

INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('10-00-00', 'N', 0, 0); --activos
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('11-01-00', 'N', 0, 0); --Bancos
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('11-01-01', 'S', 0, 0); --Banco Nacional cxc Empresa

INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('20-00-00', 'N', 0, 0); --pasivos
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('22-02-00', 'N', 0, 0); --pago empleados
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('22-02-02', 'S', 0, 0); --empleados de informatica

INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('30-00-00', 'N', 0, 0); 
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('33-03-00', 'N', 0, 0); 
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('33-03-03', 'S', 0, 0); 

INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('40-00-00', 'N', 0, 0); --Gastos
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('44-04-00', 'N', 0, 0); --gastos planilla
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('44-04-04', 'S', 0, 0); --planilla Manuel

INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('50-00-00', 'N', 0, 0); 
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('55-05-00', 'N', 0, 0); 
INSERT INTO catalogo_contable(cuenta, acepta_movimiento, debe, haber) VALUES ('55-05-05', 'S', 0, 0); 


INSERT INTO tabla_asientos (numero, cuenta, centaAfecta, debe, haber) VALUES (1, '11-01-01', '44-04-04',300, 0);--pago a planilla
INSERT INTO tabla_asientos (numero, cuenta, centaAfecta, debe, haber) VALUES (1, '11-01-01', '22-02-02',300, 300);--pago empleados informatica
INSERT INTO tabla_asientos (numero, cuenta, centaAfecta, debe, haber) VALUES (1, '99-99-99', '44-04-04',300, 0);--pago a planilla

delete from catalogo_contable;
delete from tabla_asientos;
delete from errores;


--ejecutar el procedimiento
EXEC verificar_asientos;
EXEC mayorizar_subcuentas;
EXEC mayorizar_contabilidad;

select * from catalogo_contable;
select * from tabla_asientos;
select * from errores;


--                               CREACION DEL DATABASE LINK 
CREATE PUBLIC DATABASE LINK DBLINK
CONNECT TO usuario1 IDENTIFIED BY Victor
USING '  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.137.207)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orclpdb)
    )
  )';
  