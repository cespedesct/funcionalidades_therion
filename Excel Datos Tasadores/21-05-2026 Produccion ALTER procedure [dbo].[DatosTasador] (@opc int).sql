SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[DatosTasador] 0

ALTER procedure [dbo].[DatosTasador] (@opc int)
AS

	
	--declare @opc int =0   --0 tasadores con numero incompatibilidades
	--1 tasadores con sus incompatibilidades 
	IF OBJECT_ID('tempdb.dbo.#tablaPruebas', 'U') IS NOT NULL
  DROP TABLE #tablaPruebas; 
	declare @tabla table(Activo varchar(2),EnPrueba varchar(2),Visitador varchar(2),TipoEncargo varchar(20),TasadorATV varchar(20),
	CodigoTasador varchar(20),FechaAlta date,Tasador varchar(400),ComunidadTasador varchar(200),ProvinciaTasador varchar(200),
	DNI varchar(100),Email varchar(200),Comentarios varchar(2000),Telefono varchar(100),DireccionCorreo varchar(300),Direccion_001 varchar(2000),Calle_001 varchar(2000),CodigoPostal_001 varchar(2000),Localidad_001 varchar(2000),
	Direccion_002 varchar(2000),Objetos varchar(max),Profesion varchar(1000),Incompatibilidad varchar(100),numeroIncompatibilidad int,
	Firma_Digital varchar(100),Automatica varchar(100),visitadores varchar(2000))

	begin

	begin try
	
	-----cargamos la primera profesión
	WITH ProfesionUnica AS (
    SELECT codtasad, codprofe,
           ROW_NUMBER() OVER (PARTITION BY codtasad ORDER BY codprofe) AS rn
    FROM CORITEL..taortapf
),
BorsanUnico AS (
    SELECT codtasad, codprofe,
           --ROW_NUMBER() OVER (PARTITION BY codtasad ORDER BY codprofe) AS rn

		   ROW_NUMBER() OVER (
  PARTITION BY codtasad
  ORDER BY 
     CASE 
       WHEN codprofe = '27' THEN 1
       WHEN codprofe = '25' THEN 2
       WHEN codprofe = '26' THEN 3
	   WHEN codprofe = '28' THEN 4
       ELSE 5
     END
) AS rn


    FROM CORITEL..taortapf
)

	select distinct
      CASE 
   --     --    WHEN ISNULL(objet.objetos, '') in ('Gestión (80011),','')           THEN 'No'

		 WHEN isnull(borsan.codprofe,'') in ('25','27','28') then 'Sí'
		 WHEN  not exists ( select  * from   CORITEL..taortaobj obje  where a.codtasad =obje.codtasad ) then 'No'			
		 WHEN  (exists ( select  * from   CORITEL..taortaobj obje  where a.codtasad =obje.codtasad and obje.codobjet in ('80011','85011')  ) and   not exists ( select  * from   CORITEL..taortaobj obje  where a.codtasad =obje.codtasad  and obje.codobjet not IN( '80011','85011')))  then 'No'			
		 ----WHEN ISNULL(objet.objetos, '') in ('Rústica con Guion (80018),')           THEN 'Sí'
       
		   ELSE 'Sí'
             END                                                                                                      as     Activo,
	CASE
	--	WHEN isnull(borsan.codprofe,'') in ('25','27','28') then ''
		WHEN exists (select * from CORITEL..taoencar r 
		
				left join  CORITEL..taoencar_clasificacion c on c.numinfor = r.numinfor 

				where a.codtasad = r.codtasad and r.codentid <> 'TH' and r.estinfor ='4' and codclasif not in ('0036' )) THEN 'No'
		ELSE 'Sí'
		END
		as EnPrueba,
		case
			 when isnull (borsan.codprofe,'') = '25' then 'SOLO TH BORSAN'	----requiere datos bde 
			 when isnull (borsan.codprofe,'') = '26' then 'TH + TH BORSAN'	----requiere datos bde 
			 when isnull (borsan.codprofe,'') = '27' then 'VISITADOR TH'	----requiere datos bde 
			 when isnull (borsan.codprofe,'') = '28' then 'CONSULTORIA'		----requiere datos bde 
			 when isnull (borsan.codprofe,'') = '18' then 'VISITADOR EXTERNO'
			 when isnull (borsan.codprofe,'') = '19' then 'VISITADOR EXTERNO'
			 when isnull (borsan.codprofe,'') = '29' then 'TH'
			 when isnull (borsan.codprofe,'') = '30' then 'ATVALOR'
			 when isnull (borsan.codprofe,'') = '' then ''
			 else 'TH'
			 													----requiere datos bde 
		end as TipoEncargo,
			
		CASE 
    WHEN EXISTS (
        SELECT 1
        FROM CORITEL..taortapf p
        WHERE p.codtasad = a.codtasad
          AND p.codprofe = '30'
    ) THEN 'Sí'
    ELSE 'No'
END AS TasadorATV,


		--case
		--	 when isnull (borsan2.codprofe,'') = '25' and isnull (borsan2.codprofe,'') = '30'  then 'SOLO TH BORSAN + ATVALOR'	----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '26' and isnull (borsan2.codprofe,'') = '30' then 'TH + TH BORSAN + ATVALOR'	----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '27' and isnull (borsan2.codprofe,'') = '30' then 'VISITADOR TH + ATVALOR'	----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '28' and isnull (borsan2.codprofe,'') = '30' then 'CONSULTORIA + ATVALOR'		----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '18' and isnull (borsan2.codprofe,'') = '30' then 'VISITADOR EXTERNO + ATVALOR'
		--	 when isnull (borsan2.codprofe,'') = '19' and isnull (borsan2.codprofe,'') = '30' then 'VISITADOR EXTERNO + ATVALOR'
		--	 when isnull (borsan2.codprofe,'') = '25' then 'SOLO TH BORSAN'	----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '26' then 'TH + TH BORSAN'	----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '27' then 'VISITADOR TH'	----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '28' then 'CONSULTORIA'		----requiere datos bde 
		--	 when isnull (borsan2.codprofe,'') = '18' then 'VISITADOR EXTERNO'
		--	 when isnull (borsan2.codprofe,'') = '19' then 'VISITADOR EXTERNO'
		--	 when isnull (borsan2.codprofe,'') = '29' then 'TH'
		--	 when isnull (borsan2.codprofe,'') = '30' then 'ATVALOR'
		--	 when isnull (borsan2.codprofe,'') = '' then ''
		--	 													----requiere datos bde 
		--end as TipoEncargo,


	   /*
	   CASE
			WHEN isnull (profe.codprofe,'') in ('19','20','21','22')            THEN 'Sí'     
			ELSE 'No'
			END
		*/ 'No'	as Visitador,
	   a.codtasad                                                                                         as     CodigoTasador,
       convert (date,fecalta)                                                                             as     FechaAlta,
       rtrim(nomtasad) + ' ' +  rtrim(ap1tasad) + ' ' + rtrim(ap2tasad)   as       Tasador,
      --rtrim(auton.desauton)                                                                              as     ComunidadTasador,
	  CASE
		WHEN 
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('04','11','14','18','21','23','29','41')	THEN 'ANDALUCIA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('22','44','50')								THEN 'ARAGON'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('33')										THEN 'PRINCIPADO DE ASTURIAS'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('07')										THEN 'BALEARES'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('35','38')									THEN 'CANARIAS'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('39')										THEN 'CANTABRIA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('05','09','24','34','37','40','42','47','49')THEN 'CASTILLA Y LEON'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('02','13','16','19','45')					THEN 'CASTILLA LA MANCHA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('08','17','25','43')						THEN 'CATALUÑA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('03','12','46')								THEN 'COMUNIDAD VALENCIANA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('06','10')									THEN 'EXTREMADURA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('15','27','32','36')						THEN 'GALICIA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('28')										THEN 'MADRID'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('30')										THEN 'MURCIA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('31')										THEN 'NAVARRA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('01','48','20')								THEN 'PAIS VASCO'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('26')										THEN 'LA RIOJA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('51')										THEN 'CEUTA'
		WHEN
		(select codprovi from CORITEL..taoditas b where t.codtasad = b.codtasad and b.nudirect = '001') in ('52')										THEN 'MELILLA'
		ELSE ''
		END		  
	  
																										 as     ComunidadTasador,
	  --rtrim(geol.Provincia)                                                                              as     ProvinciaTasador,
	   (select top 1 v.desprovi 
			from CORITEL..taoditas b
			inner join CORITEL..taoprovi v on v.codprovi = b.codprovi
			where t.codtasad = b.codtasad and b.nudirect = '001') 
																										as		ProvinciaTasador,

	   dnitasad                                                                                           as    DNI,
       tasmail.email                                                                                      as    Email,  
	   tasmail.comentario                                                                                      as    Comentarios, 
       tasmov.movil                                                                                       as    Telefono,
       ndircorr                                                                                           as    DireccionCorreo,
       (select top 1 rtrim(diretasa) + ' | ' + rtrim(codposta) + ' | ' + z.deslocal
														from CORITEL..taoditas X 
														inner join CORITEL..taolocal z on z.codlocal = X.codlocal and z.codprovi = X.codprovi
														where t.codtasad = X.codtasad and X.nudirect = '001')
                                                                                                                      as     Direccion_001,
	    (select top 1 rtrim(diretasa) 
														from CORITEL..taoditas X 
														inner join CORITEL..taolocal z on z.codlocal = X.codlocal and z.codprovi = X.codprovi
														where t.codtasad = X.codtasad and X.nudirect = '001')
                                                                                                                      as     Calle_001,
		(select top 1 rtrim(codposta)
														from CORITEL..taoditas X 
														inner join CORITEL..taolocal z on z.codlocal = X.codlocal and z.codprovi = X.codprovi
														where t.codtasad = X.codtasad and X.nudirect = '001')
                                                                                                                      as     CodigoPostal_001,
		(select top 1 z.deslocal
														from CORITEL..taoditas X 
														inner join CORITEL..taolocal z on z.codlocal = X.codlocal and z.codprovi = X.codprovi
														where t.codtasad = X.codtasad and X.nudirect = '001')
                                                                                                                      as     Localidad_001,


       isnull((select top 1 rtrim(diretasa) + ' | ' + rtrim(codposta) + ' | ' + z.deslocal
														from CORITEL..taoditas X
														inner join CORITEL..taolocal z on z.codlocal = X.codlocal and z.codprovi = X.codprovi
														where t.codtasad = X.codtasad and X.nudirect = '002'),'')
                                                                                                                      as     Direccion_002,
		--SELECT STRING_AGG (CONVERT(NVARCHAR(max),FirstName), CHAR(13)) AS csv 																											 
	   	   
	   CASE 
	--	when  isnull (profe.codprofe,'') in ('18','19','20','21','22','25','26','27','28') THEN 'VISITADOR'
		when  isnull (profe.codprofe,'') in ('24') THEN 'COMERCIAL'
		ELSE   isnull((select  STRING_AGG (CONVERT(NVARCHAR(max),objet.codobjet + '-' + ltrim(rtrim(taobj.desobjet))), ',') from CORITEL..taortaobj objet  INNER JOIN CORITEL.dbo.taoobjet taobj  on objet.codobjet =taobj.codobjet   where objet.codtasad = a.codtasad ),'')      
		END																									as     Objetos,

       CASE
			 WHEN isnull (profe.codprofe,'') in ('02','19')                                      THEN 'ARQUITECTO TECNICO'
			 --WHEN isnull (profe.codprofe,'') in ('19')										THEN 'ARQUITECTO TECNICO Visitador'
             WHEN isnull (profe.codprofe,'') in ('01','18')									THEN 'ARQUITECTO'
             --WHEN isnull (profe.codprofe,'') in ('01')                                      THEN 'ARQUITECTO'
             --WHEN isnull (profe.codprofe,'') in ('18')                                      THEN 'ARQUITECTO Visitador'
             WHEN isnull (profe.codprofe,'') in ('03','20')									THEN 'INGENIERO AGRONOMO'
             --WHEN isnull (profe.codprofe,'') in ('03')                                      THEN 'INGENIERO AGRONOMO'
             --WHEN isnull (profe.codprofe,'') in ('20')                                      THEN 'INGENIERO AGRONOMO Visitador'
             WHEN isnull (profe.codprofe,'') in ('04','21')									THEN 'INGENIERO TEC. AGRONOMO'
             --WHEN isnull (profe.codprofe,'') in ('04')                                      THEN 'INGENIERO TEC. AGRONOMO'
             --WHEN isnull (profe.codprofe,'') in ('21')                                      THEN 'INGENIERO TEC. AGRONOMO Visitador'
             WHEN isnull (profe.codprofe,'') in ('15')                                      THEN 'ECONOMISTA'
             WHEN isnull (profe.codprofe,'') in ('06')                                      THEN 'INGENIERO TEC. INDUSTRIAL'
			 WHEN isnull (profe.codprofe,'') in ('09')                                      THEN 'INGENIERO DE MINAS'
             ELSE   ''
       END                                                                                                             as     Profesion,
	   case 
			when pin_signatur is null then 'N'
			else 'S'
			end as Firma_Digital,
	 case 
			when firmar_automaticamente_siempre = 1 then 'S'
			else 'N'
			end as Automatica,
       CASE
             WHEN i.[Codigo Tasador] is null                                                       THEN 'N'
             ELSE 'S'
             END
                                                                                                                      as     Incompatibilidad
         ,0 as numeroIncompatibilidad
		 ,isnull((select STRING_AGG( replace(ltrim(rtrim(tasad.nomtasad)) + ' ' + ltrim(rtrim(tasad.ap1tasad)) + ' '  + ltrim(rtrim(tasad.ap2tasad)),'  ',' '), ',')  as  Visitador 
		 

from CORITEL.dbo.taortavi  tavi  inner join  CORITEL.dbo.taortapf tapf on tavi.codtasad_visitador =tapf.codtasad
inner join CORITEL.dbo.taoprofe  profes on profes.codprofe =tapf.codprofe 
inner join CORITEL.dbo.taotasad tasad on tasad.codtasad =tavi.codtasad_visitador
where tavi.codtasad = a.codtasad
and profes.visitador =1             

),'') as visitadores


/*
select replace(ltrim(rtrim(tasad.nomtasad)) + ' ' + ltrim(rtrim(tasad.ap1tasad)) + ' '  + ltrim(rtrim(tasad.ap2tasad)),'  ',' '),*  
from CORITEL.dbo.taortavi  tavi  inner join  CORITEL.dbo.taortapf tapf on tavi.codtasad_visitador =tapf.codtasad
inner join CORITEL.dbo.taoprofe  profes on profes.codprofe =tapf.codprofe 
inner join CORITEL.dbo.taotasad tasad on tasad.codtasad =tavi.codtasad_visitador
where tavi.codtasad ='02013'
and profes.visitador =1
*/
         into #tablaPruebas
       from [CORITEL].[dbo].[taotasad] a

             left join CORITEL..th_tasmail tasmail   on tasmail.codtasad = a.codtasad
             left join CORITEL..th_movta tasmov    on tasmov.codtasad = a.codtasad
			  --  inner join [EXPLOTACION].[dbo].[tasadgeoloc] geol on geol.Cod = a.codtasad
           --  left join CORITEL..taoprovi prov on geol.Provincia = prov.desprovi
           --  left join CORITEL..taoauton auton on prov.codauton = auton.codauton
             inner join CORITEL..taoditas t ON t.codtasad = a.codtasad
         --    left join EXPLOTACION..tasadobjet objet on objet.codtasad = a.codtasad
		     
			 LEFT JOIN ETHER..TH_Tasadores b on a.codtasad = b.codtasad
			
             --left join CORITEL..taortapf borsan2 on a.codtasad = borsan2.codtasad
			 left join BorsanUnico borsan on a.codtasad = borsan.codtasad and borsan.rn = 1
				-----cargamos la primera profesión
			 left join ProfesionUnica profe on a.codtasad = profe.codtasad and profe.rn = 1
             left join CORITEL..taoprofe desprof on profe.codprofe = desprof.codprofe  
             left join CORITEL.dbo.vIncompatibilidades i on i.[Codigo Tasador] = a.codtasad
			 left join CORITEL.dbo.taolocal l on l.codprovi = t.codprovi and l.codlocal = t.codlocal 
			 
             
  where a.anulado = '0' and a.codtasad not in ('28900','28500','44100','44101')
  and a.codtasad not in ('00001','00002','00003','00004','00005','00006','00007','00008','00009','00010','00011','00012','00013','00014','00015','00016','00017','00026') and 
   isnull(profe.codprofe,'') not in ('23')	
   
 order by a.codtasad

 


 update a
  set a.numeroIncompatibilidad =(select count(*) from CORITEL.dbo.vIncompatibilidades i where i.[Codigo Tasador] = a.CodigoTasador
  --and Convert(date,[Fecha Inicio Incompatibilidad],120)<= GETDATE() and
 and Convert(date,[Fecha Inicio Incompatibilidad],103)<= GETDATE()  
 and convert(date,replace(convert(varchar,Convert(date,[Fecha Final Incompatibilidad],103)),'1900','9999'),120)>=GETDATE()  
  )
  
 from #tablaPruebas  a

 
 update a  
 set Visitador =  case when exists  (select * from CORITEL..taortapf  profe where profe.codtasad = a.CodigoTasador  

 and isnull (profe.codprofe,'') in ('18','19','20','21','22'))  then  'Sí' else 'No' end
 
 from #tablaPruebas  a




 --begin try
 insert @tabla (Activo,EnPrueba , Visitador ,TipoEncargo, TasadorATV, CodigoTasador ,FechaAlta ,Tasador ,ComunidadTasador ,ProvinciaTasador, DNI ,Email , Comentarios,Telefono,DireccionCorreo ,Direccion_001 ,Calle_001,CodigoPostal_001,Localidad_001,Direccion_002 ,Objetos ,Profesion ,Incompatibilidad,numeroIncompatibilidad,Firma_Digital,Automatica,visitadores)
   select Activo,EnPrueba,Visitador , TipoEncargo, TasadorATV, CodigoTasador ,FechaAlta ,Tasador ,ComunidadTasador ,ProvinciaTasador, DNI ,Email, Comentarios ,Telefono,DireccionCorreo ,Direccion_001 ,Calle_001,CodigoPostal_001,Localidad_001,Direccion_002 ,Objetos ,Profesion ,Incompatibilidad,numeroIncompatibilidad,Firma_Digital,Automatica,visitadores from #tablaPruebas


--end try
--begin catch
--print 'entra error'
--select ERROR_MESSAGE() 
--end catch


if @opc =0
Begin
select * from @tabla
end

if @opc =1
Begin
delete  @tabla where numeroIncompatibilidad=0

select i.* from @tabla a  inner join  CORITEL.dbo.vIncompatibilidades i on a.CodigoTasador = i.[Codigo Tasador]
and Convert(date,[Fecha Inicio Incompatibilidad],103)<= GETDATE()  
 and convert(date,replace(convert(varchar,Convert(date,[Fecha Final Incompatibilidad],103)),'1900','9999'),120)>=GETDATE()  
end

 end try
 begin catch
  declare @errornumber varchar(max)
  declare @ErrorSeverity varchar(max)
  declare @Errorstate varchar(max)
  declare @ErrorProcedure varchar(max)
  declare @ErrorLine varchar(max)
  declare @ErrorMesage varchar(max)
   SELECT @errornumber =ERROR_NUMBER() 
         ,@ErrorSeverity =ERROR_SEVERITY() 
         ,@Errorstate =ERROR_STATE() ,@ErrorProcedure =ERROR_PROCEDURE(),@ErrorLine =ERROR_LINE() ,@ErrorMesage =ERROR_MESSAGE() 
        set @ErrorMesage = @ErrorMesage + ' ' +  @ErrorProcedure
		select @ErrorMesage
 IF OBJECT_ID('tempdb.dbo.#tablaPruebas', 'U') IS NOT NULL
  DROP TABLE #tablaPruebas; 
         RAISERROR (@ErrorMesage, -- Message text.
           16, -- Severity,
           @Errorstate -- State,
           )
 end catch
	
end


GO
