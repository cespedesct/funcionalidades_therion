-- =====================================================
-- SCRIPT: Inserción de Tasadores desde CSV
-- Fecha: 2026-04-29
-- Descripción: Inserta tasadores con código < 10000 
--              que no existan en taotasad, genera nuevo 
--              código "8" + codigo original, e inserta 
--              en taortapf con codfprof = 30
-- =====================================================
DROP TABLE IF EXISTS #TasadoresTemp;
-- Crear tabla temporal para importar datos del CSV
CREATE TABLE #TasadoresTemp (
    codigo VARCHAR(10),
    nombre VARCHAR(100),
    apellidos VARCHAR(100),
    comunidad VARCHAR(50),
    provincia VARCHAR(50),
    municipio VARCHAR(100),
    calle VARCHAR(100),
    numero VARCHAR(20),
    codpostal VARCHAR(10),
    telfmovil VARCHAR(20),       -- Teléfono móvil
    emailpersonal VARCHAR(100),
    dni VARCHAR(20)               -- DNI del tasador
);



-- Insertar datos del CSV filtrado con DNI
INSERT INTO #TasadoresTemp VALUES 
('0019', 'AGUSTIN', 'COBOS RUEDA', 'ANDALUCIA', '41', '00321', 'VERACRUZ', '17', '41710', '667052572', 'agustincobos@telefonica.net', '28914697V'),
('0026', 'JUAN MIGUEL', 'MARTOS DIAZ', 'MURCIA', '30', '00012', 'ISIDORO DE LA CIERVA', '1', '30880', '687715072', 'arquitecto@estudiomartos.com', '23258386G'),
('0058', 'CESAR', 'GARCIA VILLAR', 'EXTREMADURA', '10', '00067', 'OSA MAYOR', '39', '10001', '646330382', 'cesar.garciavillar@gmail.com', '76116100S'),
('0059', 'EDUARDO', 'MURIEDAS GARCIA', 'MADRID', '28', '00544', 'VILLA DE MARIN', '30', '28029', '677444404', 'emuriedas@arquired.es', '25120863X'),
('0062', 'MARCELO', 'TALENS ARMAND', 'NAVARRA', '31', '00849', 'PAMPLONA', '35', '31009', '698931488', 'mtalensa@gmail.com', '15832749D'),
('0075', 'JOAQUIN', 'BUSTAMANTE CABRERO', 'CANTABRIA', '39', '00891', 'DE PEREDA', '7', '39004', '617491092', 'estudiojb@coacan.es', '13724633G'),
('0085', 'RICARDO', 'COLLANTES DE TERAN RODRIGUEZ', 'ANDALUCIA', '41', '00302', 'RUIZ GIJON', '57', '41001', '692645421', 'collantesdeteranricardo@gmail.com', '28615674V'),
('0090', 'SALVADOR IGNACIO', 'CANTO LOAIZA', 'ANDALUCIA', '29', '00467', 'PEÑA', '19', '29012', '680135981', 'ignaciocanto2970@gmail.com', '48895378T'),
('0127', 'TOMAS', 'FEO DE CELIS', 'CASTILLA Y LEON', '24', '00563', 'LUIS CARMONA', '1', '24002', '639393214', 'tomasfeo@hotmail.es', '09771429V'),
('0132', 'MARCOS', 'MOLINA GARCIA', 'CASTILLA Y LEON', '34', '00281', 'EUROPA', '4', '34003', '636478378', 'aparejador.mmg@gmail.com', '12774026X'),
('0148', 'MARIA DEL MAR', 'BORREGO MAIZ', 'ANDALUCIA', '14', '00403', 'FELIX RODRIGUEZ DE LA FUENTE', '19', '14500', '675822107', 'tasadorvalor@gmail.com', '52486629P'),
('0149', 'JOSE MARIA', 'SANTIAGO BARRIO', 'CASTILLA Y LEON', '47', '00016', 'SAN QUINCE', '4', '47195', '661801467', 'jm.santiago@coaatva.es', '45685069P'),
('0160', 'RAFAEL', 'DE UNAMUNO VERA', 'MADRID', '28', '00544', 'SAN MARCOS', '3', '28004', '639358425', 'runamuno@telefonica.net', '11944635E'),
('0163', 'ANGEL MANUEL', 'PEDRERO FERNANDEZ', 'CANARIAS', '35', '01088', 'CEBRIAN', '34', '35003', '678480318', 'mpedrero@hotmail.com', '43264783N'),
('0169', 'RAUL', 'NAVARRO HERNANDEZ', 'CATALUÑA', '17', '00088', 'SAUGUER', '40B', '17300', '685960852', 'info@ramonhpartners.com', '45547006Z'),
('0170', 'ANTONIO', 'MOLINA BARRIENTOS', 'ANDALUCIA', '04', '00063', 'ENEIDA', '8', '04130', '649593509', 'antonio@trabajotecnico.es', '75097127B'),
('0171', 'JORGE', 'SERRANO EDO', 'VALENCIA', '46', '42725', 'LA PLANA', '76', '46137', '657874606', 'jorgeserrano.arquitecto@gmail.com', '33456097K'),
('0179', 'LUIS MIGUEL', 'DIAZ DE LA FUENTE', 'BALEARES', '07', '00365', 'MAQUINARIA', '4', '07011', '626302043', 'balearesatvalor@gmail.com', '53104692S'),
('0195', 'MARIA JOSE', 'CEQUIER MUZAS', 'NAVARRA', '31', '00524', 'MIGUEL ZABALZA', '10', '31471', '617456069', 'info@arkival.es', '73201184G'),
('0203', 'JOSE MARÍA', 'CANO AYLLÓN', 'ANDALUCIA', '23', '00147', 'PESO DE LA HARINA', '5', '23001', '617984594', 'ca219@coajaen.org', '26009101B'),
('0214', 'BRUNO', 'FERNANDEZ ZAPICO', 'ASTURIAS', '33', '03195', 'COLEGIO DE LA ENCARNACIÓN', '4', '33500', '661902574', 'uno618.bruno@gmail.com', '71636695K'),
('0216', 'JOSE ANTONIO', 'RIVAS DOMINGUEZ', 'ANDALUCIA', '21', '00076', 'JESUS DEL CALVARIO', '1', '21003', '687919800', 'joseantonio.rivas@hotmail.com', '28490860R'),
('0218', 'JUAN', 'CABAÑAS MARTINEZ', 'MADRID', '28', '00544', 'ISLA DE ALEGRANZA', '55', '28', '695395323', 'tasaciones@juancabanas.com', '50306432G'),
('0219', 'PEDRO', 'LOPEZ RUIPEREZ', 'GALICIA', '36', '01532', 'MARQUES DE VALLADARES', '33', '36201', '669380375', 'pedrolr@coag.es', '51346284A'),
('0223', 'GONZALO PEDRO', 'PEÑA SANCHO', 'MADRID', '28', '00544', 'DEL GOBERNADOR', '16', '28014', '661583429', 'g.penasancho@gmail.com', '01937600B'),
('0232', 'MARIA DE LOS ANGELES', 'TOSCANO RODRIGUEZ', 'ARAGON', '50', '43593', 'FUENTE', '1', '50692', '609493012', 'onubense67@yahoo.es', '29786402E'),
('0233', 'GONZALO', 'DE SALVADOR ROBERT', 'CATALUÑA', '08', '00380', 'VICTOR CATALA', '16B', '08190', '699754367', 'valores66@gmail.com', '46126900D'),
('0264', 'MARIA DEL MAR', 'MARIN RAMIREZ', 'MADRID', '28', '00544', 'CORAZON DE MARIA', '13', '28002', '670754788', 'mmarin@arquitectosasociados12.com', '19891034J'),
('0283', 'JUAN JOSE', 'GARCIA ROMAN', 'MADRID', '28', '00544', 'PONTONES, PASEO', '19', '28005', '661744826', 'jjgarciaroman@gmail.com', '27389361H'),
('0285', 'TOMAS', 'ESPINOSA ZAFRA', 'MADRID', '28', '00521', 'ARROYO NARANJO', '3', '', '637738065', 'tez.aqum@gmail.com', '02247854H'),
('0302', 'RAUL', 'RICO NETO', 'ANDALUCIA', '21', '00076', 'LA FUENTE', '13-15', '21004', '652191439', 'raulrine@gmail.com', '48921974P'),
('0304', 'BEATRIZ', 'COLILLES CASCALLAR', 'ANDALUCIA', '29', '00467', 'ESMERALDA', '7', '29649', '670745327', 'bcolilles@hotmail.com', '16046080S'),
('0305', 'SERGI', 'HERNANDEZ CORTES', 'CATALUÑA', '08', '00501', 'PRAT DE LA RIBA', '103', '08222', '605672441', 'sergihcortes@gmail.com', '46733749A'),
('0308', 'MARGARITA', 'TOMAS IBAÑEZ', 'VALENCIA', '46', '00537', 'LUIS SANTANGEL', '5', '46005', '606792013', 'margatomas.tecnico@gmail.com', '07558531H'),
('0312', 'MARGARITA', 'SOLER ROMERO', 'MADRID', '28', '00544', 'CARDENAL HERRERA ORIA, AVENIDA', '309', '28034', '666488628', 'margasr63@gmail.com', '18198988P'),
('0315', 'JAVIER', 'GARCIA RODRIGUEZ', 'ANDALUCIA', '23', '00155', 'ANDALUCIA', '2D', '23700', '637858780', 'agroforestramedioambientalslu@gmail.com', '75070637V'),
('0317', 'SANTIAGO', 'VILLALBA JORDAN', 'MADRID', '28', '00045', 'MONASTERIO DE SAN MILLAN', '31', '28300', '673300242', 'santiago@ibervalor.es', '52354850L'),
('0320', 'DAVID', 'TURIEL REVILLA', 'CASTILLA Y LEON', '49', '00038', 'HERREROS', '50', '49600', '980631637', 'davidturiel@expertosenvaloracion.es', '71023828N'),
('0321', 'CARLOS', 'ALCOBE VIVES', 'ARAGON', '22', '00329', 'CABAÑERA REAL', '9', '22520', '670647661', 'perito@alcotax.com', '40883291D'),
('0322', 'PAULA', 'VILLA SANZ', 'MADRID', '28', '00544', 'ISLAS CIES', '34', '28035', '699524041', 'paula.villa@estudiopavisa.com', '47295138P'),
('0325', 'MARZIA', 'MONTELEONE', 'VALENCIA', '46', '00537', 'SALVADOR RODRIGUEZ BRONCHU', '1', '46025', '648760246', 'mmonteleone@ctav.es', 'X3797567Z'),
('0336', 'DAVID', 'DEL BLANCO QUIJANO', 'VALENCIA', '12', '26341', 'PADRE LLUIS MARIA LLOP', '52', '12540', '639502838', 'davidblancoquijano@gmail.com', '12779162V'),
('0350', 'CLAUDIO', 'ANDRADE SIRER', 'BALEARES', '07', '00365', 'CARDENAL ROSELL', '7', '07007', '671512643', 'candradesirer@gmail.com', '45188153F'),
('0352', 'FRANCISCO BORJA', 'GARCIA GARRIDO', 'CASTILLA Y LEON', '24', '00847', 'SAN ANTONIO', '1', '24401', '633572501', 'b.garcia@ingraria.com', '71511692T'),
('0357', 'JAVIER', 'HERMOSILLA GALVE', 'ANDALUCIA', '29', '00348', 'RIO GUADALMINA', '2', '29640', '699880430', 'jhergal.appraisal@gmail.com', '33421580G'),
('0362', 'SERGIO', 'PEREZ LAFUENTE', 'ARAGON', '50', '00394', 'EL ANGEL AZUL', '7', '50019', '616827061', 'sergioperezlafuente@gmail.com', '76919601B'),
('0367', 'PABLO', 'GIMENO DE SANTIAGO', 'MADRID', '28', '00544', 'DE LA CASTELLANA', '173', '28046', '667035791', 'pablo@gdsarquitectos.com', '45328186Q'),
('0369', 'MARIA BLANCA', 'CALDAS MARQUEZ', 'EXTREMADURA', '10', '00067', 'RIO ALAGON', '4', '10001', '696245460', 'c2c.arq@gmail.com', '07017090C'),
('0371', 'ENRIQUE', 'GUTIERREZ BRIONES', 'MADRID', '28', '00544', 'ALONSO CASTRILLO', '18', '', '654521269', 'egutierrez@valtecsa.com', '50806825D'),
('0373', 'ANTONIO', 'GARCIA FERNANDEZ', 'ANDALUCIA', '14', '00153', 'SANTA ANA', '39', '14400', '675143416', 'tecnicarquitec@gmail.com', '80142310Y'),
('0385', 'ELISABETH', 'ORTEGA MORENO', 'ANDALUCIA', '18', '00181', 'PADRE CLARTET', '6', '18013', '680912739', 'elisabetortegamoreno@gmail.com', '75149338N'),
('0395', 'JOSÉ IGNACIO', 'DE VELASCO PÉREZ', 'PAIS VASCO', '48', '00153', 'SAN VICENTE EDIFICIO ALBIA 1', '8', '48001', '629684179', 'ignaciovelasco@telefonica.net', '14956289X'),
('0398', 'NATALIA', 'CAMPOS RODRIGUEZ', 'BALEARES', '07', '00365', 'POBLE ESPANYOL', '45', '07014', '687102279', 'CAMPOS-NATALIA@OUTLOOK.COM', '32074241M'),
('0401', 'PABLO', 'FERNANDEZ DIEZ', 'BALEARES', '07', '00365', 'COSTA DE LES GERMANETES', '6', '07010', '675552400', 'info@gfarquitectos.es', '51406787Q'),
('0407', 'JAVIER', 'MENDOZA DOMINGUEZ', 'MADRID', '28', '00544', 'FINISTERRE', '6', '28029', '655495217', 'jmendoza@atvalor.com', '47026154D');


SELECT * FROM #TasadoresTemp;


-- =====================================================
-- 1. INSERTS EN TAOTASAD (Principal)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taotasad] 
(codtasad, dnitasad, nomtasad, ap1tasad, ap2tasad, numasign, modcobta, ctabanca, 
 ndircorr, ndircobr, codcabas, anulado, numbanco, numsucur, fecalta, fecbaja, 
 observaciones, encargoprueba, numinforpruebas, iban)
SELECT 
    '8' + codigo AS codtasad,
    ISNULL(dni, '') AS dnitasad,
    UPPER(nombre) AS nomtasad,
    CASE 
        WHEN (UPPER(LEFT(apellidos, 4)) = 'DEL ' OR UPPER(LEFT(apellidos, 3)) = 'DE ') AND CHARINDEX(' ', apellidos, CHARINDEX(' ', apellidos) + 1) > 0
        THEN UPPER(LEFT(apellidos, CHARINDEX(' ', apellidos, CHARINDEX(' ', apellidos) + 1) - 1))
        WHEN (UPPER(LEFT(apellidos, 4)) = 'DEL ' OR UPPER(LEFT(apellidos, 3)) = 'DE ')
        THEN UPPER(apellidos)
        WHEN CHARINDEX(' ', apellidos) > 0
        THEN UPPER(LEFT(apellidos, CHARINDEX(' ', apellidos) - 1))
        ELSE UPPER(apellidos)
    END AS ap1tasad,
    CASE 
        WHEN (UPPER(LEFT(apellidos, 4)) = 'DEL ' OR UPPER(LEFT(apellidos, 3)) = 'DE ') AND CHARINDEX(' ', apellidos, CHARINDEX(' ', apellidos) + 1) > 0
        THEN UPPER(SUBSTRING(apellidos, CHARINDEX(' ', apellidos, CHARINDEX(' ', apellidos) + 1) + 1, LEN(apellidos)))
        WHEN CHARINDEX(' ', apellidos) > 0
        THEN UPPER(SUBSTRING(apellidos, CHARINDEX(' ', apellidos) + 1, LEN(apellidos)))
        ELSE ''
    END AS ap2tasad,
    '0' AS numasign,
    '1' AS modcobta,                    -- 0=talón, 1=transferencia bancaria
    '' AS ctabanca,
    '001' AS ndircorr,
    '001' AS ndircobr,
     '000' AS codcabas,
    '0' AS anulado,
    '' AS numbanco,
    '' AS numsucur,
    GETDATE() AS fecalta,
  '1900-01-01 00:00:00.000' AS fecbaja,
    'importado desde ATV' AS observaciones,
    '0' AS encargoprueba,
'' AS numinforpruebas,
    '' AS iban
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[taotasad] 
      WHERE codtasad = '8' + t.codigo
  );





-- =====================================================
-- 2. INSERTS EN TAORFOTA (Foto del Tasador)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taorfota] (codtasad, fottasad)
SELECT 
    '8' + codigo AS codtasad,
    0x80 AS fottasad                    -- Valor por defecto para foto
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[taorfota] 
      WHERE codtasad = '8' + t.codigo
  );



-- =====================================================
-- 3. INSERTS EN TH_HISTAS (Histórico Tasador)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[th_histas] (codtasad, usuario, fec_accion, fecbaja, fecalta)
SELECT 
    '8' + codigo AS codtasad,
    'THMADRID' AS usuario,              -- Usuario del sistema que realiza alta
    DATEADD(SECOND, ROW_NUMBER() OVER (ORDER BY codigo), GETDATE()) AS fec_accion,
    '1900-01-01 00:00:00.000' AS fecbaja,
    CONVERT(DATETIME, CONVERT(NVARCHAR(10), GETDATE(), 103), 103) AS fecalta
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[th_histas] 
      WHERE codtasad = '8' + t.codigo
  );


-- =====================================================
-- 4. INSERTS EN TH_TASMAIL (Correo y Comentarios)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[th_tasmail] (codtasad, email, actmail, anulado, nuevo, comentario)
SELECT 
    '8' + codigo AS codtasad,
    LOWER(ISNULL(emailpersonal, '')) AS email,
    '0' AS actmail,
    '0' AS anulado,
    '0' AS nuevo,
    'importado desde ATV' AS comentario
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[th_tasmail] 
      WHERE codtasad = '8' + t.codigo
  );

-- =====================================================
-- 5. INSERTS EN TH_MOVTA (Teléfono Móvil)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[th_movta] (codtasad, movil, tel_contacto_adm)
SELECT 
    '8' + codigo AS codtasad,
    ISNULL(telfmovil, '') AS movil,
    ISNULL(telfmovil, '') AS tel_contacto_adm
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[th_movta] 
      WHERE codtasad = '8' + t.codigo
  );

-- =====================================================
-- 6. INSERTS EN TAODITAS (Direcciones Postales)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taoditas] (codtasad, nudirect, diretasa, codposta, codprovi, codlocal, tel1tasa, tel2tasa, faxtasa, obsditas)
SELECT 
    '8' + codigo AS codtasad,
    '001' AS nudirect,                    -- Número de dirección por defecto
    ISNULL(calle, '') + ' ' + ISNULL(numero, '') AS diretasa,
    ISNULL(codpostal, '') AS codposta,
    ISNULL(provincia, '') AS codprovi,  -- Nota: Esto probablemente sea código, revisar mapeo
    ISNULL(municipio, '') AS codlocal,   -- Nota: Esto probablemente sea código, revisar mapeo
    ISNULL(telfmovil, '') AS tel1tasa,
    '' AS tel2tasa,
    '' AS faxtasa,
    'importado desde ATV' AS obsditas
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[taoditas] 
      WHERE codtasad = '8' + t.codigo
  );

-- =====================================================
-- 7. INSERTS EN iTH_Usuarios (Usuario Web)
-- =====================================================
-- NOTA: La contraseña debe estar encriptada. Fórmula: "X" + Left(nombre,1) + Left(apellidos,2)
-- Ejemplo: "X" + "A" + "CO" = "XACO"
-- Se requiere función de encriptación del sistema
-- INSERT INTO [CORITEL].[dbo].[iTH_Usuarios] 
-- (USU_Codigo, USU_Descripcion, USU_Password, USU_CambioPassword, USU_Tipo, PER_Codigo, 
--  USU_Identificador, USU_Defecto1, USU_Defecto2, USU_Defecto3, USU_Fecha)
-- SELECT 
--     'tas' + '8' + codigo AS USU_Codigo,
--     '8' + codigo + ' - ' + CASE 
--         WHEN (UPPER(LEFT(apellidos, 4)) = 'DEL ' OR UPPER(LEFT(apellidos, 3)) = 'DE ') AND CHARINDEX(' ', apellidos, CHARINDEX(' ', apellidos) + 1) > 0
--         THEN LEFT(apellidos, CHARINDEX(' ', apellidos, CHARINDEX(' ', apellidos) + 1) - 1)
--         WHEN (UPPER(LEFT(apellidos, 4)) = 'DEL ' OR UPPER(LEFT(apellidos, 3)) = 'DE ')
--         THEN apellidos
--         WHEN CHARINDEX(' ', apellidos) > 0
--         THEN LEFT(apellidos, CHARINDEX(' ', apellidos) - 1)
--         ELSE apellidos
--     END AS USU_Descripcion,
--     'X' + LEFT(nombre, 1) + LEFT(CASE 
--         WHEN CHARINDEX(' ', apellidos) > 0 
--         THEN LEFT(apellidos, CHARINDEX(' ', apellidos) - 1)
--         ELSE apellidos
--     END, 2) AS USU_Password,            -- NOTA: Esto necesita encriptación real
--     '1' AS USU_CambioPassword,
--     'T' AS USU_Tipo,
--     'TASAD' AS PER_Codigo,
--     '8' + codigo AS USU_Identificador,
--     NULL AS USU_Defecto1,
--     NULL AS USU_Defecto2,
--     NULL AS USU_Defecto3,
--     GETDATE() AS USU_Fecha
-- FROM #TasadoresTemp t
-- WHERE CAST(t.codigo AS INT) < 10000
--   AND NOT EXISTS (
--       SELECT 1 
--       FROM [CORITEL].[dbo].[iTH_Usuarios] 
--       WHERE USU_Codigo = 'tas' + '8' + t.codigo
--   );

-- =====================================================
-- 8. INSERTS EN TAORTAPF (Profesiones del Tasador)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taortapf] (codtasad, codprofe, colegiado)
SELECT 
    '8' + codigo AS codtasad,
    '30' AS codprofe,                   -- Profesión por defecto
    '' AS colegiado
FROM #TasadoresTemp t
WHERE CAST(t.codigo AS INT) < 10000
  AND NOT EXISTS (
      SELECT 1 
      FROM [CORITEL].[dbo].[taortapf] 
      WHERE codtasad = '8' + t.codigo
  );

-- =====================================================
-- LIMPIEZA
-- =====================================================
DROP TABLE #TasadoresTemp;

-- =====================================================
-- Mensaje de confirmación
-- =====================================================
PRINT '✓ Proceso de inserción completado';
PRINT '  - Tasadores insertados en taotasad';
PRINT '  - Registros insertados en taortapf (codfprof = 30)';
PRINT '  - Código de tasador: 8 + código original';
PRINT '  - Filtrado: solo códigos < 10000 (no comienzan con 10)';


SELECT *From [CORITEL].[dbo].[taotasad] where codtasad like '80%' and observaciones like'importado desde ATV'
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[taorfota] where codtasad like '80%';
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[th_histas] where usuario='THMADRID' and codtasad like '80%' ORDER BY fec_accion DESC
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[taortapf] where codtasad like '80%' and codprofe='30'
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[th_tasmail] WHERE codtasad like '80%' and comentario='importado desde ATV'
--  WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[th_movta] where codtasad like '80%' 
--  WHERE codtasad='80019'; 
SELECT *From [CORITEL].[dbo].[taoditas] where codtasad like '80%' and obsditas='importado desde ATV'
--  WHERE codtasad='80019';





