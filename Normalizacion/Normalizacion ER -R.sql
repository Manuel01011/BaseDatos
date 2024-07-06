create table E1(
 a int,
 b int,
 x int,
 y int,
 z int check (z in (1,2,3)),
 constraint pka primary key(a),
 constraint xu unique (x)
)

create table E2(
 b int,
 c int,
 constraint fb foreign key (b) references E1 (a) 
)

create table E3(
 m int,
 x int,
 n int check (n in (5,6)),
 o int,
  constraint pkm primary key(m),
  constraint fx foreign key (x) references E1 (x) 
)

CREATE TABLE E4 (
    m INT,
    p INT, 
    q INT, 
    CONSTRAINT fm FOREIGN KEY (m) REFERENCES E3 (m),
    CONSTRAINT p_eq_q UNIQUE (p, q), -- Para asegurar que p y q sean únicos juntos
    CONSTRAINT p_eq_q_check CHECK (p = q) -- Para asegurar que p y q sean iguales
);

create table E5(
  i int,
  j int,
 constraint pki primary key(i)
)

create table E6(
  g int,
  h int,
  constraint pkg primary key(g)
)

create table E7(
  i int,
  f int,
  g int,
 constraint fi foreign key (i) references E5 (i),
 constraint fg foreign key (g) references E6 (g)
)

--relacion
create table R3(
  i int,
  m int,
 PRIMARY KEY (i, m)
)