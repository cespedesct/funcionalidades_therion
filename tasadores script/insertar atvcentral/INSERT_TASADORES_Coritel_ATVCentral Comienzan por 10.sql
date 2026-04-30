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
('007', 'ANDRES', 'LORENTE', '', '', '', '', '', '', '629282069', '', '01234556P'),
('034', 'ALEJANDRO', 'ALMEIDA FIERRO', 'CANARIAS', '35', '00496', 'DR. DAVID RAMIREZ', '60', '35250', '609142385', '', '42848497A'),
('155', 'PEDRO', 'INSENSE PEDRET', 'CATALUÑA', '08', '00028', 'REPUBLICA ARGENTINA, AVINGUDA', '182', '08023', '649298216', 'ins299y@apabcn.cat', '36972299Y'),
('162', 'JORGE JUAN', 'ORELLANA PACHECO', 'ANDALUCIA', '14', '00153', 'LLANOS DEL PRETORIO', '1', '14006', '656986152', 'jorge.orep@gmail.com', '45747513F'),
('163', 'ANA', 'BAREA RODRIGUEZ', 'ANDALUCIA', '29', '00467', 'MALASAÑA', '7', '29009', '686125000', 'tecnicos@grupocmsh.es', '76145556P'),
('164', 'CRISTINA', 'RUS BEATO', 'ANDALUCIA', '18', '00181', 'DE LAS CONEJERAS', '30', '18008', '687959799', 'cristinarusbeato@gmail.com', '24237921S'),
('168', 'JESUS', 'RIVERO VARGAS', 'ANDALUCIA', '23', '00275', 'DE LA CIUDAD DE LINARES', '6', '23400', '605013004', 'jesusriverov@gmail.com', '26494917K'),
('174', 'CARLOS', 'CANSECO CEMBRANOS', 'NAVARRA', '31', '00849', 'LEZKAIRU', '6', '31192', '607596128', 'carlos@tallervertical.es', '71431838W'),
('178', 'FRANCISCO JAVIER', 'DIEZ PASTRANA', 'CASTILLA Y LEON', '47', '00033', 'MAESTRO NICOLAS', '6', '47260', '626432456', 'jdiezpastrana@gmail.com', '09292305Y'),
('179', 'EDUARDO', 'SAINZ DE MURIETA GUINDULAIN', 'ARAGON', '50', '00394', 'CESAREO ALIERTA', '11', '50008', '600063281', 'eduardosainzdemurieta@gmail.com', '29120864N'),
('200', 'ANTONIO', 'PUERTAS CASTAÑOS', 'MADRID', '28', '00544', 'PICO DEL AGUILA', '', '', '655848869', '9844puertas@coam.es', '00809214M'),
('211', 'MIGUEL ANGEL', 'GARCIA REY', 'MADRID', '28', '00544', 'VALCARLOS', '7', '28050', '628124401', 'miguelangelgarciarey@cemad.es', '50096229K'),
('230', 'CARLOTA', 'HUAN WANG', 'MADRID', '28', '31900', 'MERCEDES FORMICA', '3', '28232', '603292062', 'chuan@grupoatvalor.com', 'Y2073021E'),
('236', 'IGNACIO', 'CID ABASOLO', 'MADRID', '28', '00860', 'FUENTE DE SANTA AGUEDA', '10', '28294', '682551868', 'icabasolo@hotmail.com', '50829659G'),
('242', 'ALBERTO', 'BARBERO ORCAJO', 'CASTILLA Y LEON', '09', '00543', 'LOS ROSALES', '6', '09340', '616547642', 'lerma@lmproyectos.es', '13169304X'),
('249', 'JUAN', 'SALINERO CASCANTE', 'LA RIOJA', '26', '00053', 'VALVANERA', '1', '26500', '627904465', 'juansalinero@coaatrioja.org', '17851926Q'),
('255', 'DAVID', 'ALFARO GARRIGA', 'CATALUÑA', '25', '00519', 'MARIOLA', '31', '25003', '673114506', 'dag.arquitectura@gmail.com', '47900645V');


SELECT * FROM #TasadoresTemp;


-- =====================================================
-- 1. INSERTS EN TAOTASAD (Principal)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taotasad] 
(codtasad, dnitasad, nomtasad, ap1tasad, ap2tasad, numasign, modcobta, ctabanca, 
 ndircorr, ndircobr, codcabas, anulado, numbanco, numsucur, fecalta, fecbaja, 
 observaciones, encargoprueba, numinforpruebas, iban)
SELECT 
    '88'+ codigo AS codtasad,
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


-- =====================================================
-- 2. INSERTS EN TAORFOTA (Foto del Tasador)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taorfota] (codtasad, fottasad)
SELECT 
    '88'+ codigo AS codtasad,
    0x80 AS fottasad                    -- Valor por defecto para foto
FROM #TasadoresTemp t




-- =====================================================
-- 3. INSERTS EN TH_HISTAS (Histórico Tasador)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[th_histas] (codtasad, usuario, fec_accion, fecbaja, fecalta)
SELECT 
    '88'+ codigo AS codtasad,
    'THMADRID' AS usuario,              -- Usuario del sistema que realiza alta
    DATEADD(SECOND, ROW_NUMBER() OVER (ORDER BY codigo), GETDATE()) AS fec_accion,
    '1900-01-01 00:00:00.000' AS fecbaja,
    CONVERT(DATETIME, CONVERT(NVARCHAR(10), GETDATE(), 103), 103) AS fecalta
FROM #TasadoresTemp t


-- =====================================================
-- 4. INSERTS EN TH_TASMAIL (Correo y Comentarios)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[th_tasmail] (codtasad, email, actmail, anulado, nuevo, comentario)
SELECT 
    '88'+ codigo AS codtasad,
    LOWER(ISNULL(emailpersonal, '')) AS email,
    '0' AS actmail,
    '0' AS anulado,
    '0' AS nuevo,
    'importado desde ATV' AS comentario
FROM #TasadoresTemp t


-- =====================================================
-- 5. INSERTS EN TH_MOVTA (Teléfono Móvil)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[th_movta] (codtasad, movil, tel_contacto_adm)
SELECT 
    '88'+ codigo AS codtasad,
    ISNULL(telfmovil, '') AS movil,
    ISNULL(telfmovil, '') AS tel_contacto_adm
FROM #TasadoresTemp t


-- =====================================================
-- 6. INSERTS EN TAODITAS (Direcciones Postales)
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taoditas] (codtasad, nudirect, diretasa, codposta, codprovi, codlocal, tel1tasa, tel2tasa, faxtasa, obsditas)
SELECT 
    '88'+ codigo AS codtasad,
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
--     'tas' + '88'+ codigo AS USU_Codigo,
--     '88'+ codigo + ' - ' + CASE 
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
--     '88'+ codigo AS USU_Identificador,
--     NULL AS USU_Defecto1,
--     NULL AS USU_Defecto2,
--     NULL AS USU_Defecto3,
--     GETDATE() AS USU_Fecha
-- FROM #TasadoresTemp t
-- WHERE CAST(t.codigo AS INT) < 10000
--   AND NOT EXISTS (
--       SELECT 1 
--       FROM [CORITEL].[dbo].[iTH_Usuarios] 
--       WHERE USU_Codigo = 'tas' + '88'+ t.codigo
--   );

-- =====================================================
-- 8. INSERTS EN TAORTAPF (Profesiones del Tasador) -- Codigo 30 ATVALOR
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taortapf] (codtasad, codprofe, colegiado)
SELECT 
    '88'+ codigo AS codtasad,
    '30' AS codprofe,                   -- Profesión por defecto
    '' AS colegiado
FROM #TasadoresTemp t


  -- 8. INSERTS EN TAORTAPF (Profesiones del Tasador) -- Codigo 27 VISITADOR
-- =====================================================
INSERT INTO [CORITEL].[dbo].[taortapf] (codtasad, codprofe, colegiado)
SELECT 
    '88'+ codigo AS codtasad,
    '27' AS codprofe,                   -- Profesión por defecto
    '' AS colegiado
FROM #TasadoresTemp t


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
PRINT '  - Filtrado: solo códigos > 10000 (no comienzan con 10)';


SELECT *From [CORITEL].[dbo].[taotasad] where codtasad like '88%' and observaciones like'importado desde ATV'
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[taorfota] where codtasad like '88%';
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[th_histas] where  codtasad like '88%' and usuario='THMADRID' ORDER BY fec_accion DESC
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[taortapf] where codtasad like '88%' and ( codprofe='30' or codprofe='27') 
-- WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[th_tasmail] WHERE codtasad like '88%' and comentario='importado desde ATV'
--  WHERE codtasad='80019';
SELECT *From [CORITEL].[dbo].[th_movta] where codtasad like '88%' 
--  WHERE codtasad='80019'; 
SELECT *From [CORITEL].[dbo].[taoditas] where codtasad like '88%' and obsditas='importado desde ATV'
--  WHERE codtasad='80019';







