-- Para cumplir los siguientes requerimientos, debes recordar tener desactivado el autocommit en tu base de datos.

\echo :AUTOCOMMIT
\set AUTOCOMMIT off
\echo :AUTOCOMMIT


-- 1. Cargar el respaldo de la base de datos unidad2.sql. (2 Puntos)

CREATE DATABASE ventas;

\q

psql -U postgres ventas < unidad2.sql

\dt

-- consultamos que las tablas se hayan copiado sin problemas.
SELECT * FROM cliente;
SELECT * FROM producto;
SELECT * FROM detalle_compra;
SELECT * FROM compra;

-- 2. El cliente usuario01 ha realizado la siguiente compra:
-- ● producto: producto9.
-- ● cantidad: 5.
-- ● fecha: fecha del sistema.
-- Mediante el uso de transacciones, realiza las consultas correspondientes para este
-- requerimiento y luego consulta la tabla producto para validar si fue efectivamente descontado en el stock. (3 Puntos)
BEGIN TRANSACTION;
INSERT INTO compra (id, cliente_id, fecha) VALUES (33, 1, now());
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) VALUES (9, 33, 5);
UPDATE producto SET stock = stock - 5 WHERE id = 9;
ROLLBACK;

SELECT * FROM producto;

-- 3. El cliente usuario02 ha realizado la siguiente compra:
-- ● producto: producto1, producto 2, producto 8.
-- ● cantidad: 3 de cada producto.
-- ● fecha: fecha del sistema.
-- Mediante el uso de transacciones, realiza las consultas correspondientes para este
-- requerimiento y luego consulta la tabla producto para validar que si alguno de ellos
-- se queda sin stock, no se realice la compra. (3 Puntos)

BEGIN TRANSACTION;

INSERT INTO compra (id, cliente_id, fecha) VALUES (33,2,NOW());

--Ingresar compra producto 1 (stock=6)
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) VALUES (1, 33, 3);
UPDATE producto SET stock = stock - 3 WHERE descripcion = 'producto1';
SAVEPOINT checkpoint1;

--Ingresar compra producto 2 (stock=5)
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) VALUES (2, 33, 3);
UPDATE producto SET stock = stock - 3 WHERE descripcion = 'producto2';
SAVEPOINT checkpoint2;

--Ingresar compra producto 8 (stock=0)
INSERT INTO detalle_compra (producto_id, compra_id, cantidad) VALUES (8, 33, 3);
UPDATE producto SET stock = stock - 3 WHERE descripcion = 'producto8';
ROLLBACK TO checkpoint2;

SELECT * FROM compra WHERE id = 33;
SELECT * FROM detalle_compra WHERE compra_id = 33;


-- 4. Realizar las siguientes consultas (2 Puntos):

-- a. Deshabilitar el AUTOCOMMIT .
\echo :AUTOCOMMIT
\set AUTOCOMMIT off
\echo :AUTOCOMMIT
-- b. Insertar un nuevo cliente.
BEGIN TRANSACTION;
INSERT INTO cliente (nombre, email) VALUES ('JUAN PEREZ', 'juanperez@gmail.com');
-- c. Confirmar que fue agregado en la tabla cliente.
SELECT * FROM cliente WHERE nombre = 'JUAN PEREZ';
-- d. Realizar un ROLLBACK.
ROLLBACK
-- e. Confirmar que se restauró la información, sin considerar la inserción del punto b.
SELECT * FROM cliente WHERE nombre = 'JUAN PEREZ';

-- confirmamos que las compras no se perdieron con el rollback de linea 83
SELECT * FROM compra WHERE id = 33;
SELECT * FROM detalle_compra WHERE compra_id = 33;

-- f. Habilitar de nuevo el AUTOCOMMIT.
\set AUTOCOMMIT on
\echo :AUTOCOMMIT

-- PREGUNTAR AL PROFE SOBRE EL ROLLBACK Y SOBRE LA DESCRIPCION DEL DESAFIO.