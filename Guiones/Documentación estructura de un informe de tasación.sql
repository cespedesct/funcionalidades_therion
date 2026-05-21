USE [CORITEL]
GO
------------------------------------------------------
--Tipologías

--Tipo de comportamiento de elementos o donde se encuentran sus datos (tipeleme en tabla "taorpael")
--0:Elemento común ( o de entrada de datos )
--1:Elemento literal
--2:
--3:
--4:Elemento espejo
--5:Elemento de encargo (o cabecera)
--6:Elemento de testigo

--Tipos de elementos comunes ( o de entrada de datos )
--00:
--01:Elemento de selección desplegable
--02:Entrada numérica
--03:Entrada alfanumérica
--04:Entrada de fecha
--09:Fórmula numérica
--19:Fórmula alfanumérica
--20:
--21:
--70:
--71:
--72:
------------------------------------------------------
--Flujo común

select * from taoencar where numinfor = '25044787' --Encargo

select * from taorobgu where codguion = '80003' --Tabla donde se define que guion se utiliza a partir del objeto, estado y finalidad del encargo
select * from taoguion where codguion = '80003' --Guion usado en ese encargo

select rga.*, a.desapart, a.cabapart from taorguap rga inner join taoapart a  -- Apartados incluidos en ese guion
on rga.codapart = a.codapart where codguion = '80003' order by posapart

select * from taorappa ap inner join taorguap g on ap.codapart = g.codapart where codguion = '80003' order by g.posapart, g.codapart -- Relacion de los parrafos de cada apartado del guion

select * from taoinfor where numinfor = '25044787' --Tabla usada para imprimir el guion, relacion de cada uno de los parrafos de cada apartado y si se deben mostrar o no

-----------------------
--Parrafo de cabecera--
-----------------------

select * from taoparra where codparra = 34453 -- Un parrafo de cabecera (nivestru = 0)
select * from taoestru where codestru = '800' -- La estructura de dicho parrafo define que sus datos de cabecera estan escritos en las tablas de cabecera: CAB030M (o sus consecutivas)
select * from taorpael where codparra = 34453 -- Como es un parrafo de cabecera sus "elementos comunes" (tipeleme = 0) estan definidos en la tabla taorpael
select * from taorpali where codparra = 34453 -- Los elementos que son literales (tipeleme = 1) estan definidos en la tabla taorpali

--A partir de los elementos no literales que se encuentran en la tabla taorpael se buscan los elementos en taoeleme para saber cual 
--es el elemento, taoeleme_condicion para saber si se muestra y en taorelva para saber sus posibles valores 
select * from taoeleme where codeleme in (select codeleme from taorpael where codparra = 34453 and tipeleme != 1)
select * from taoeleme_condicion where codeleme in (select codeleme from taorpael where codparra = 34453 and tipeleme != 1) and codguion = 80003
select * from taorelva where codeleme in (select codeleme from taorpael where codparra = 34453 and tipeleme != 1)

-- Los datos que toman estos elementos de dichos parrafos de cabecera en los distintos informes se encuentran en las 
--tablas que se especifan en taoestru (CAB03OM0 en este caso), para determinar en cual especificamente se usa la tabla
--taoresel

select * from taoresel where codestru = '800' and codeleme in (select codeleme from taorpael where codparra = 34453 and tipeleme != 1) 

--definidas las tablas especificas de datos donde deben estar los datos de estos elementos vamos a estas y 
--aqui hay columnas para cada elemento por cada componente de cada finca registral de cada informe

select numinfor, ELE01305 from CAB03OM5 where numinfor = 25044787
select numinfor, ELE05840 from  CAB03OM25 where numinfor = 25044787 -- (Elemento que no se muestra)
select numinfor, ELE06032 from  CAB03OM15 where numinfor = 25044787 -- (Elemento que no se muestra)
select numinfor, ELE06148 from  CAB03OM16 where numinfor = 25044787
select numinfor, ELE06448 from  CAB03OM27 where numinfor = 25044787 -- (Elemento que no se muestra)

---------------------------------------------------------------
--Funcionamiento de elemento espejo en un párrafo de cabecera--
---------------------------------------------------------------

select * from taorpael where codparra = 34880 and tipeleme = 4 
select * from taorpali where codparra = 34880 and codlitel = 00018 --Un elemento espejo está representado en la tabla taorpali y alli muestra de que elemento es espejo
select * from taoeleme where codeleme = '06607' -- El elemento del que es espejo en este caso es una formula (que no se utiliza en ningun parrafo)

select * from taorpael where codparra = 27945 and tipeleme = 4 
select * from taorpali where codparra = 27945 and codlitel = 00002 --Un elemento espejo está representado en la tabla taorpali y alli muestra de que elemento es espejo
--Localizamos en el guion actual en que parrafo se utliza el elemento del que se es espejo para revisarlo
select * from taorpael where codparra = '34453' and codeleme = '01305' --Es un elemento de entrada de datos que se usa en el parrafo 34453 del actual guion
select * from taoeleme where codeleme = '01305' --Es un elemento de tipo fecha

select * from taorpael where codeleme = '01305'
select * from taorpali
select * from taoeleme where codeleme = '01305' -- El elemento del que es espejo en este caso es una formula (que no se utiliza en ningun parrafo)

--------------------------------------------------------------------
--Funcionamiento de elemento de encargo (o cabecera) en un párrafo--
--------------------------------------------------------------------
select * from taorpael where codparra = 32141 and tipeleme = 5 --Elementos de tipo encargo
select * from taorpael pe inner join taoeleen ee on pe.codeleme = ee.codeleme where codparra = 32141 and tipeleme = 5 --Los elementos de tipo encargo que 
--existen están reflejados en la tabla "taoeleen", estos elementos toman su valor a partir de datos del encargo y no aparecen en la tabla taoeleme
--Los valores de estos elementos se obtienen desde la tabla "taoencar" y subtablas (taosolic, taoprovi, taoentid, taoofici, taodepar, taoclase, taoestad, 
--taoprovi, taousuar, taotasad, taortapf, taoprofe) a la hora de generar el informe

-----------------------
--Parrafo de detalles--
-----------------------

-- Un Parrafo de detalles (nivestru = 1)
select * from th_rpacu where codparra = 34835 order by colparra -- Como es un parrafo de detalles sus "elementos" estan definidos en la tabla th_rpacu
select * from taoestru where codestru = '800' -- La estructura de dicho parrafo define que sus datos de detalles estan escritos en las tablas de detalles: DET030M (o sus consecutivas)

--A partir de los "elementos" que se encuentran en la tabla th_rpacu se buscan los elementos en taoeleme para saber cual 
--es el elemento y en taorelva para saber sus posibles valores 
select * from taoeleme where codeleme in (select codeleme from th_rpacu where codparra = 34835) 
select * from taorelva where codeleme in ( select codeleme from th_rpacu where codparra = 34835)

-- Los datos que toman estos elementos de dichos parrafos de detalles en los distintos informes se encuentran en las 
--tablas que se especifan en taoestru (DET03OM en este caso), para determinar en cual especificamente se usa la tabla
--taoresel

select * from taoresel where codestru = '800' and codeleme in (select codeleme from th_rpacu where codparra = 34835) order by numcabec

--definidas las tablas especificas de datos donde deben estar los datos de estos elementos vamos a estas y 
--aqui hay columnas para cada elemento por cada componente de cada finca registral de cada informe

select numinfor, uniagrup, elemunid, ELE00648, ELE00838, ELE00970, ELE00971, ELE00972, ELE00986, ELE01522 from DET03OM where numinfor = 25044787
select numinfor, uniagrup, elemunid, ELE06200 from DET03OM1 where numinfor = '25044787'
select numinfor, uniagrup, elemunid, ELE05985, ELE05986, ELE05987, ELE05990, ELE05991, ELE06251,
ELE06252,ELE06316, ELE06689, ELE06694, ELE06695, ELE06697, ELE06710, ELE06714, ELE06778, ELE06779, 
ELE06884, ELE07181, ELE07192, ELE07193, ELE07194, ELE07195, ELE07355, ELE07541 from DET03OM2 where numinfor = '25044787'

--Al ser elementos definidos en párrafos de detalles no tienen registros en taoeleme_condicion/taoeleme_validacion

-------------------------------------------------------------------------------------------------------

---------
--Dudas--
---------

SELECT * FROM taorguap ga inner join taorappa ap on ga.codapart = ap.codapart inner join taorpael pe on pe.codparra = ap.codparra inner join taoapart a on a.codapart = ga.codapart
where codguion = '80003'

select *  from taocondi ORDER BY codcondi --where codcondi = 'CVALID'