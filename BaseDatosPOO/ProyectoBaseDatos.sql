-------------------Objeto persona----------------
CREATE OR REPLACE TYPE persona AS OBJECT (
    identificacion INT,
    nombre VARCHAR2(30),
    edad NUMBER,
    MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION persona RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION persona (p_id INT, p_nombre VARCHAR2, p_edad NUMBER) RETURN SELF AS RESULT
) NOT FINAL;
/

-------------------Cuerpo de persona----------------
CREATE OR REPLACE TYPE BODY persona AS
    MEMBER PROCEDURE mostrar_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion);
    END mostrar_info;

    CONSTRUCTOR FUNCTION persona RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := 0;
        SELF.nombre := 'Desconocido';
        SELF.edad := 0;
        return;
    END persona;

    CONSTRUCTOR FUNCTION persona(p_id INT, p_nombre VARCHAR2, p_edad NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := p_id;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        RETURN;
    END persona;
END;
/
-------------------fin de persona-------------------


-------------------Objeto estudiante----------------
CREATE OR REPLACE TYPE estudiante UNDER persona (
    escuela VARCHAR2(30),
    OVERRIDING MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION estudiante RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION estudiante(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_escuela VARCHAR2) RETURN SELF AS RESULT
) NOT FINAL;
/
-------------------Cuerpo de estudiante----------------
CREATE OR REPLACE TYPE BODY estudiante AS
    OVERRIDING MEMBER PROCEDURE mostrar_info IS
    BEGIN
        -- Llamar al método mostrar_info de la clase base
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion||' escuela: ' || escuela);
    END mostrar_info;

    CONSTRUCTOR FUNCTION estudiante RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := 0;
        SELF.nombre := 'Desconocido';
        SELF.edad := 0;
        SELF.escuela := 'Desconocido'; -- Asignar un valor por defecto para escuela
        RETURN;
    END estudiante;

    CONSTRUCTOR FUNCTION estudiante(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_escuela VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        -- Inicializar los atributos de la clase base
        SELF.identificacion := p_id;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        SELF.escuela := p_escuela; -- Asignar el valor de p_escuela al atributo escuela
        RETURN;
    END estudiante;
END;
/
-------------------fin de estudiante----------------

-------------------Objeto curso----------------
CREATE OR REPLACE TYPE curso AS OBJECT (
    nombre VARCHAR2(30),
    nota NUMBER,
    CONSTRUCTOR FUNCTION curso RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION curso(p_nombre VARCHAR2, p_nota NUMBER) RETURN SELF AS RESULT
);
/
-------------------Cuerpo de curso----------------
CREATE OR REPLACE TYPE BODY curso AS
    CONSTRUCTOR FUNCTION curso RETURN SELF AS RESULT IS
    BEGIN
        SELF.nombre := 'Desconocido'; -- Valor por defecto
        SELF.nota := 0; -- Valor por defecto
        RETURN;
    END curso;

    CONSTRUCTOR FUNCTION curso(p_nombre VARCHAR2, p_nota NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.nombre := p_nombre;
        SELF.nota := p_nota;
        RETURN;
    END curso;
END;
/
-------------------fin de curso----------------



-------------------array de cursos----------------
CREATE TYPE cursos AS VARRAY(4) OF curso;
/

-------------------Objeto Alumno----------------
CREATE OR REPLACE TYPE alumno UNDER estudiante (
    misCursos cursos,
    OVERRIDING MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION alumno RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION alumno (p_identificacion INT, p_nombre VARCHAR2, p_edad NUMBER, p_escuela VARCHAR2, p_cursos cursos) RETURN SELF AS RESULT
);
/

-------------------Cuerpo de Alumno----------------
CREATE OR REPLACE TYPE BODY alumno AS
    OVERRIDING MEMBER PROCEDURE mostrar_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion||' escuela: ' || escuela);
        FOR i IN 1..misCursos.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Curso: ' || misCursos(i).nombre || ', Nota: ' || misCursos(i).nota);
        END LOOP;
    END mostrar_info;

    CONSTRUCTOR FUNCTION alumno RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := NULL; -- Valor por defecto
        SELF.nombre := 'Desconocido'; -- Valor por defecto
        SELF.edad := 0; -- Valor por defecto
        SELF.escuela := 'Desconocido'; -- Valor por defecto
        SELF.misCursos := cursos(); -- Inicialización con una lista de cursos vacía
        RETURN;
    END alumno;

    CONSTRUCTOR FUNCTION alumno(p_identificacion INT, p_nombre VARCHAR2, p_edad NUMBER, p_escuela VARCHAR2, p_cursos cursos) RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := p_identificacion;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        SELF.escuela := p_escuela;
        SELF.misCursos := p_cursos;
        RETURN;
    END alumno;
END;
/
-------------------fin de alumno----------------


---------------------Objeto Asistente----------------
CREATE OR REPLACE TYPE asistente UNDER estudiante (
    horas INT,
    OVERRIDING MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION asistente RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION asistente(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2, p_horas INT) RETURN SELF AS RESULT
);
/
-------------------Cuerpo de Asistente----------------
CREATE OR REPLACE TYPE BODY asistente AS
    OVERRIDING MEMBER PROCEDURE mostrar_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion||' escuela: ' || escuela ||' horas: ' || horas);
    END mostrar_info;

    CONSTRUCTOR FUNCTION asistente RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := 0; -- Valor por defecto
        SELF.nombre := 'Desconocido'; -- Valor por defecto
        SELF.edad := 0; -- Valor por defecto
        SELF.escuela := 'Desconocido'; -- Valor por defecto
        SELF.horas := 0; -- Valor por defecto
        RETURN;
    END asistente;

    CONSTRUCTOR FUNCTION asistente(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2, p_horas INT) RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := p_id;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        SELF.escuela := p_unidad;
        SELF.horas := p_horas;
        RETURN;
    END asistente;
END;
/
-------------------fin de asistente----------------


-------------------objeto funcionario----------------
CREATE OR REPLACE TYPE funcionario UNDER persona (
    unidad_academica VARCHAR2(30),
    OVERRIDING MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION funcionario RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION funcionario(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2) RETURN SELF AS RESULT
) NOT FINAL;
/
-------------------Cuerpo de funcionario----------------
CREATE OR REPLACE TYPE BODY funcionario AS
    OVERRIDING MEMBER PROCEDURE mostrar_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion||' unidad Académica: ' || unidad_academica);
    END mostrar_info;

    CONSTRUCTOR FUNCTION funcionario RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := NULL; -- Valor por defecto
        SELF.nombre := 'Desconocido'; -- Valor por defecto
        SELF.edad := 0; -- Valor por defecto
        SELF.unidad_academica := 'Desconocido'; -- Valor por defecto
        RETURN;
    END funcionario;

    CONSTRUCTOR FUNCTION funcionario(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := p_id;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        SELF.unidad_academica := p_unidad;
        RETURN;
    END funcionario;
END;
/
-------------------fin de funcionario----------------


-------------------Objeto docente----------------
CREATE OR REPLACE TYPE docente UNDER funcionario (
    categoria NUMBER,
    OVERRIDING MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION docente RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION docente(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2, p_categoria NUMBER) RETURN SELF AS RESULT
);
/
-------------------Cuerpo de docente----------------
CREATE OR REPLACE TYPE BODY docente AS
    OVERRIDING MEMBER PROCEDURE mostrar_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion||' unidad Académica: ' || unidad_academica||' categoría: ' || categoria);
    END mostrar_info;

    CONSTRUCTOR FUNCTION docente RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := NULL; -- Valor por defecto
        SELF.nombre := 'Desconocido'; -- Valor por defecto
        SELF.edad := 0; -- Valor por defecto
        SELF.unidad_academica := 'Desconocido'; -- Valor por defecto
        SELF.categoria := 0; -- Valor por defecto
        RETURN;
    END docente;

    CONSTRUCTOR FUNCTION docente(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2, p_categoria NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := p_id;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        SELF.unidad_academica := p_unidad;
        SELF.categoria := p_categoria;
        RETURN;
    END docente;
END;
/
-------------------fin de docente----------------


-------------------Objeto administrativo----------------
CREATE OR REPLACE TYPE administrativo UNDER funcionario (
    puesto VARCHAR2(30),
    OVERRIDING MEMBER PROCEDURE mostrar_info,
    CONSTRUCTOR FUNCTION administrativo RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION administrativo(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2, p_puesto VARCHAR2) RETURN SELF AS RESULT
);
/
-------------------Cuerpo de administrativo----------------
CREATE OR REPLACE TYPE BODY administrativo AS
    OVERRIDING MEMBER PROCEDURE mostrar_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || nombre || ' Edad: ' || edad || ' Identificacion: ' || identificacion||' unidad Académica: ' || unidad_academica||' puesto: ' || puesto);
    END mostrar_info;

    CONSTRUCTOR FUNCTION administrativo RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := NULL; -- Valor por defecto
        SELF.nombre := 'Desconocido'; -- Valor por defecto
        SELF.edad := 0; -- Valor por defecto
        SELF.unidad_academica := 'Desconocido'; -- Valor por defecto
        SELF.puesto := 'Desconocido'; -- Valor por defecto
        RETURN;
    END administrativo;

    CONSTRUCTOR FUNCTION administrativo(p_id INT, p_nombre VARCHAR2, p_edad NUMBER, p_unidad VARCHAR2, p_puesto VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.identificacion := p_id;
        SELF.nombre := p_nombre;
        SELF.edad := p_edad;
        SELF.unidad_academica := p_unidad;
        SELF.puesto := p_puesto;
        RETURN;
    END administrativo;
END;
/
-------------------fin de administrativo----------------


-------------------Pruebas de constructores con y sin parametros----------------
----------persona------------
set serveroutput on
DECLARE
    p persona;
    p_param persona;
BEGIN
    -- Constructor sin parámetros
    p := persona();
    p.mostrar_info;

    -- Constructor con parámetros
    p_param := persona(1, 'Juan', 25);
    p_param.mostrar_info;
END;
/

---------estudiante----------
set serveroutput on
DECLARE
    e estudiante;
    e_param estudiante;
BEGIN
    -- Constructor sin parámetros
    e := estudiante();
    e.mostrar_info;

    -- Constructor con parámetros
    e_param := estudiante(2, 'Ana', 22, 'Ingeniería');
    e_param.mostrar_info;
END;
/

-------curso---------------
DECLARE
    c curso;
    c_param curso;
BEGIN
    -- Constructor sin parámetros
    c := curso();
    DBMS_OUTPUT.PUT_LINE('Curso: ' || c.nombre || ', Nota: ' || c.nota);

    -- Constructor con parámetros
    c_param := curso('Matemáticas', 95);
    DBMS_OUTPUT.PUT_LINE('Curso: ' || c_param.nombre || ', Nota: ' || c_param.nota);
END;
/

---------Alumno----------
DECLARE
    a alumno;
    a_param alumno;
    cursos_var cursos := cursos(curso('Matemáticas', 95), curso('Historia', 88));
BEGIN
    -- Constructor sin parámetros
    a := alumno();
    a.mostrar_info;

    -- Constructor con parámetros
    a_param := alumno(3, 'Carlos', 20, 'Ciencias', cursos_var);
    a_param.mostrar_info;
END;
/

-------------Asistente-------
DECLARE
    asist asistente;
    asist_param asistente;
BEGIN
    -- Constructor sin parámetros
    asist := asistente();
    asist.mostrar_info;

    -- Constructor con parámetros
    asist_param := asistente(4, 'Marta', 24, 'Humanidades', 20);
    asist_param.mostrar_info;
END;
/

----------funcionario----------
DECLARE
    func funcionario;
    func_param funcionario;
BEGIN
    -- Constructor sin parámetros
    func := funcionario();
    func.mostrar_info;

    -- Constructor con parámetros
    func_param := funcionario(5, 'Pedro', 35, 'Administración');
    func_param.mostrar_info;
END;
/


----------Docente-------------
DECLARE
    doc docente;
    doc_param docente;
BEGIN
    -- Constructor sin parámetros
    doc := docente();
    doc.mostrar_info;

    -- Constructor con parámetros
    doc_param := docente(6, 'Luis', 45, 'Matemáticas', 3);
    doc_param.mostrar_info;
END;
/


--------administrativo-------------
DECLARE
    admin administrativo;
    admin_param administrativo;
BEGIN
    -- Constructor sin parámetros
    admin := administrativo();
    admin.mostrar_info;

    -- Constructor con parámetros
    admin_param := administrativo(7, 'Sofía', 30, 'Recursos Humanos', 'Coordinador');
    admin_param.mostrar_info;
END;
/