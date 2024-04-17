/* Nivel 1. Ejercicio 1: "La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
 La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
 Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar 
una breu descripció d'aquest." */

CREATE TABLE credit_card (
	id VARCHAR(10) UNIQUE,
    iban VARCHAR(255),
    pan VARCHAR(255),
    pin INT,
    cvv INT,
    expiring_date DATE,
    PRIMARY KEY (id),
    FOREIGN KEY (id) REFERENCES transaction(credit_card_id)
);

# Se ha creado un índice en la tabla transaction porque devolvía el error 1822 y requería que estuviera indexado el campo "credit_card_id".

CREATE INDEX idx_credcard
ON transaction (credit_card_id);

ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(10);


# Se cargan los archivos 

LOAD DATA LOCAL INFILE "C:\Users\menes\Documents\HAILE\FORMACION\ITACADEMY\CURS_DATAANALYSIS\SPRINT3\datos_introducir_credit.sql"
INTO TABLE credit_card
FIELDS TERMINATED BY  ","
ENCLOSED BY "'"
LINES TERMINATED BY ";"
IGNORE 1 ROWS;

/* Nivel 1. Ejercicio 2: "El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de
# mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar. */

UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

/* Nivel 1. Ejercicio 3: En la taula "transaction" ingressa un nou usuari amb la següent informació:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined */

INSERT INTO transaction
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", CURRENT_DATE(), "111.11", "0") ; 
/* Error al existir una restricción por la FK, El usuario no existe CcU-9999 y no permite ingresar los datos en la tabla "transaction", 
se ingresa un nuevo id en la tabla "credit_card"*/

SET FOREIGN_KEY_CHECKS=1;

INSERT INTO credit_card (id)
VALUES ("CcU-9999");

/* Nivel 1. Ejercicio 4: Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.*/

ALTER TABLE credit_card
DROP pan;

SELECT * 
FROM credit_card; # EN LA CONSULTA NO APARECE LA COLUMNA ELIMINADA.

/* Nivel 2. Ejercicio 1: "Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades."*/

DELETE 
from transaction
where id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

select *
from transaction
where id = "02C6201E-D90A-1859-B4EE-88D2986D3B02"; # RESULTADOS CON NULL AL NO EXISTIR EL REGISTRO INDICADO.

/* NIVEL 2. EJERCICIO 2: "La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
 S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
 Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
 Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
 
 Presenta la vista creada, ordenant les dades de major a menor mitjana de compra."*/


CREATE VIEW VistaMarketing AS
SELECT company_name AS Nombre_Compañia, phone AS Telefono_Contacto, country AS Pais_Residencia, ROUND(AVG(amount), 2) AS Mediana_Compra_Compañia
FROM company
JOIN transaction ON company.id = transaction.company_id
GROUP BY Nombre_Compañia, Telefono_Contacto, Pais_Residencia
ORDER BY Mediana_Compra_Compañia DESC;

SELECT *
FROM VistaMarketing;

/* NIVEL 2. EJERCICIO 3: "Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"*/


	SELECT *
    FROM VistaMarketing
    WHERE Pais_Residencia = "Germany";

/* NIVEL 3. EJERCICIO 1: "La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip 
va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els 
comandos executats per a obtenir el següent diagrama: (Ver PDF)"*/

/* Tabla user: Renombrar la columna email a personal_email*/

ALTER TABLE user
RENAME COLUMN email to personal_email;

/* Tabla credit_card: 1. modificar el tipo de datos en el campo pin. Se establece como varchar(4)*/

ALTER TABLE credit_card
MODIFY pin varchar(4);

/* Tabla credit_card: 2. Agregar la columna fecha_actual a la tabla como tipo DATE, espeficicando al crearla que se indica la fecha actual al momento alter
de crear el campo mediante DATE DEFAULT(CURRENT_DATE)*/

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE DEFAULT(CURRENT_DATE);

/* Tabla credit_card: 3: Modificar el tipo de datos en el campo iban. Se establece como varchar(50)*/

ALTER TABLE credit_card
MODIFY iban varchar(50);

/* Tabla company: Eliminar el campo/columna "website"*/


/*L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction. */

#CREATE VIEW InformeTecnico AS
SELECT
transaction.id AS ID_Transaccion,
CONCAT(user.name, " ", surname) AS Nombre_Usuario_a,
credit_card.iban AS IBAN_Tarjeta,
transaction.amount AS Importe_Transaccion,
transaction.timestamp AS Fecha_Operacion,
transaction.declined AS Aprobacion,
company.company_name AS Nombre_Compañia,
company.country AS Pais_Compañia
FROM transaction
LEFT JOIN user ON transaction.user_id = user.id
RIGHT JOIN credit_card ON transaction.credit_card_id = credit_card.id
LEFT JOIN company ON transaction.company_id = company.id
ORDER BY ID_Transaccion DESC;

# Para comprobar el resultado
SELECT *
FROM informetecnico;
