SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[TH_Informes_HTML_Ver_Informe] 
       (@numinfor varchar(8)
      , @retorno  varchar(max)=null output
      , @debug    bit         =0
      )

as

begin 

-- select * from CORITEL.dbo.taorpael_formato where codparra='29214'
-- set @numinfor='15008058'   -- Es un terreno

--select * from CORITEL.dbo.taorelva

set nocount on
set dateformat dmy
set transaction isolation level read uncommitted

declare @paso   char(50)
      , @mess   varchar(max)
      , @prbbdd varchar(300)=object_name(@@procid)


begin try

  declare @fecha_inicial datetime=getdate()
         ,@fecha_inicio  datetime=getdate()

  set @paso='Inicio del Proceso' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
    
  declare @codguion varchar(5)     
  select @codguion=codguion 
  from CORITEL.dbo.taoencar (nolock) 
  where numinfor=@numinfor

  declare @l                      decimal(19,0)
  declare @crlf                   varchar(2)=char(13)+char(10)
  declare @pix                    varchar( 1)='45vw'
  declare @pix_dat                varchar( 5)='45vw'
  declare @color_fonfo_no_imprime varchar(25)='#EEE9BF'
  declare @color_fonfo_normal     varchar(25)='#FFFFFF' -- '#ECF1EF'
  declare @color_fonfo_insertado  varchar(25)='#9400D3'

  declare @codestru varchar(3)
  declare @fca      varchar(25)
  declare @fde      varchar(25)

  select @codestru=ltrim(rtrim(s.codestru)) 
        ,@fca     =ltrim(rtrim(s.fcaestru)) 
        ,@fde     =ltrim(rtrim(s.fdeestru))
  from CORITEL.dbo.taoestru (nolock) s
  where s.codestru=(select codestru from CORITEL.dbo.taoguion (nolock) where codguion=@codguion)
  set @paso='Carga de Variables' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------
    
  select r.codeleme                [codeleme]
        ,r.nivestru                [nivestru] 
        ,ltrim(rtrim(r.numcabec))  [numcabec]
  into #taoresel
  from CORITEL.dbo.taoresel r (nolock) 
  where r.codestru=@codestru
  create index IDX_taoresel   on #taoresel (codeleme, nivestru)  
  create index IDX_taoresel_1 on #taoresel (nivestru)  
  set @paso='into #taoresel' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  ------------------------------------
  -- Montaje del Join de los detalles
  ------------------------------------

  declare @leftd nvarchar(max)='', @leftc nvarchar(max)=''
  select @leftd+=[a]+char(10) 
  from (select distinct ' left outer join CORITEL.dbo.'+@fde+r.numcabec+' d'+r.numcabec+' (nolock) on d'+r.numcabec+'.numinfor=e.numinfor and d'+r.numcabec+'.uniagrup=e.uniagrup and d'+r.numcabec+'.elemunid=e.elemunid' [a]
        from #taoresel r 
        where r.nivestru='1' 
        ) t
  set @paso='JOIN DETALLES' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------
  -- Crear la tabla de detalle
  -----------------------------
  
  create table #detalle (numinfor varchar(10), uniagrup varchar(15), elemunid varchar(5) )
  declare @comando_detalle varchar(max)
  select top 1 @comando_detalle='select d.numinfor, d.uniagrup, d.elemunid from CORITEL.dbo.'+@fde+r.numcabec+' d (nolock) where d.numinfor='''+@numinfor+''' ' from #taoresel r where r.nivestru='1'
  insert into #detalle exec (@comando_detalle) 
  set @paso='into #detalle' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  ------------------------------------
  -- Montaje del Join de las Cabeceras
  ------------------------------------
      
  select @leftc+=[a]+char(10) 
   from (select distinct 
           ' left outer join CORITEL.dbo.'+@fca+r.numcabec+' d'+r.numcabec+' (nolock) on d'+r.numcabec+'.numinfor=e.numinfor' [a] 
         from #taoresel r (nolock) 
         where r.nivestru='0') t
  set @paso='JOIN CABECERAS' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  ----------------------
  -- Taoinfor Temporal
  ----------------------

  select i.numinfor
        ,i.posapart
        ,i.codapart
        ,i.posparra
        ,i.codparra
        ,i.modparra
        ,i.numtabul
        ,p.nivestru
        ,p.formato 
        ,p.cabparra
        ,a.supresio
  into #taoinfor
  from CORITEL.dbo.taoinfor i with (nolock index(IX_taoinfor_2) ) 
  left outer join CORITEL.dbo.taoparra p (nolock) on p.codparra=i.codparra
  left outer join CORITEL.dbo.taorappa a (nolock) on a.codapart=i.codapart and a.codparra=i.codparra
  where i.numinfor=@numinfor

  create index IDX_taoinfor_1 on #taoinfor (posapart, posparra)     
  create index IDX_taoinfor_2 on #taoinfor (codapart, codparra)     
  create index IDX_taoinfor_3 on #taoinfor (modparra)
  create index IDX_taoinfor_4 on #taoinfor (nivestru, formato)
  create index IDX_taoinfor_5 on #taoinfor (codparra)

  set @paso='into #taoinfor' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait


  select p.codparra
        ,p.codlitel
        ,p.deslitel
  into #taorpali
  from #taoinfor i with (index (IDX_taoinfor_5))
  inner join CORITEL.dbo.taorpali p (nolock) on p.codparra=i.codparra
  create index IDX_taorpali_1 on #taorpali (codparra, codlitel)     
  set @paso='into #taorpali' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
  
  ----------------------
  -- th_rapcu 
  ----------------------
  
  select r.codparra
        ,r.colparra
        ,r.codeleme
        ,r.litecabe
        ,r.impriele
        ,r.subtoele
        ,r.totalele
        ,r.tipcolum
        ,r.foreleme
        ,r.tamcolum
        ,r.cdivi
        ,r.condedi
        ,r.condmos
  into #th_rpacu
  from #taoinfor i with (index(IDX_taoinfor_5))
  inner join CORITEL.dbo.th_rpacu r (nolock) on r.codparra=i.codparra
  create index IDX_th_rpacu_1 on #th_rpacu (codeleme)     
  create index IDX_th_rpacu_2 on #th_rpacu (codparra, codeleme)     
  set @paso='into #th_rpacu' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  ------------------------------------------------
  -- Extraccion de los campos de cabecera activos
  ------------------------------------------------

  -- select distinct t.tamano_imp from CORITEL.dbo.taorpael_formato t 

  select distinct
         p.codparra
        ,p.codeleme
        ,p.tipeleme
        ,p.fileleme
        ,p.coleleme
        ,p.leteleme
        ,i.posapart
        ,i.posparra
        ,tf.imprimible
        ,tf.fuente_imp
        ,convert(decimal(19,2),isnull(tf.tamano_imp,8.0)/8.0*0.60) [tamano_imp]
  into #taorpael_general
  from #taoinfor i with (index(IDX_taoinfor_5))
  inner      join CORITEL.dbo.taorpael          p (nolock)  on p.codparra=i.codparra
  left outer join CORITEL.dbo.taorpael_formato tf with (nolock index(IX_taorpael_formato_codparra_codeleme_tipoElemento))
                                               on  tf.codparra=i.codparra 
                                               and tf.codeleme    =p.codeleme 
                                               and tf.tipoElemento=p.tipeleme 
  create index IDX_taorpael_general_codparra ON #taorpael_general (codparra, fileleme, coleleme, codeleme)     
  create index IDX_taorpael_general_codeleme ON #taorpael_general (codeleme)     
  set @paso='into #taorpael_general' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
  
  -----------------------------------------------------------------

  select tf.codparra
        ,tf.codeleme
        ,tf.tipoElemento
        ,tf.imprimible
  into #taorpael_formato
  from #taorpael_general p
  inner join CORITEL.dbo.taorpael_formato tf with (nolock index(IX_taorpael_formato_codparra_codeleme_tipoElemento))
                                               on  tf.codparra    =p.codparra 
                                               and tf.codeleme    =p.codeleme 
                                               and tf.tipoElemento=p.tipeleme 
  set @paso='into #taorpael_formato' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------------------------

  select e.codeleme 
        ,e.deseleme
        ,e.tipeleme  
        ,e.plantill
  into #taoeleme 
  from CORITEL.dbo.taoeleme e with (nolock index(taoeleme_codeleme_tipeleme) ) 
  set @paso='into #taoeleme ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
  
  -----------------------------------------------------------------

  select ea.codeleme 
  into #taoinfor_elementos_activos 
  from CORITEL.dbo.taoinfor_elementos_activos ea with (nolock index(IX_taoinfor_elementos_activos) ) 
  where ea.numinfor=@numinfor
  set @paso='into #taoinfor_elementos_activos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------------------------

  select ea.codeleme 
  into #taoinfor_elementos_no_imprimibles
  from CORITEL.dbo.taoinfor_elementos_no_imprimibles ea (nolock) 
  where ea.numinfor=@numinfor
  set @paso='into #taoinfor_elementos_no_imprimibles' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------------------------

  select ea.codeleme               [codeleme]
        ,ltrim(rtrim(ea.nuevalor)) [nuevalor]
  into #taorinmo
  from CORITEL.dbo.taorinmo ea (nolock) 
  where ea.numinfor=@numinfor
  set @paso='into #taorinmo' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------------------------

  select @numinfor                                                  [numinfor] 
        ,ea.codeleme                                                [codeleme]
        ,(select top 1    right('00000'+tr.posapart,5)
                     +'-'+right('00000'+tr.posparra,5)
                     +'-'+right('00000'+isnull(convert(varchar(10),tr.fileleme),''),5)
                     +'-'+right('00000'+isnull(convert(varchar(10),tr.coleleme),''),5)
         from #taorpael_general tr with (index (IDX_taorpael_general_codeleme))
         where tr.codeleme=ea.codeleme
         order by tr.posapart, tr.posparra, tr.fileleme, tr.coleleme) [orden]
        ,@codestru                                                  [codestru] 
        ,l.tipeleme                                                 [tipeleme]
        ,ltrim(rtrim(r.numcabec))                                   [numcabec]
  into #activos
  from #taoinfor_elementos_activos ea
  inner join #taoeleme l on l.codeleme=ea.codeleme and l.tipeleme not in ('20') -- Campos Fotos NO
  inner join #taoresel r on r.codeleme=ea.codeleme and r.nivestru='0'
  set @paso='into #activos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------------------------

  select r.codeleme               [codeleme] 
        ,r.codvalor               [codvalor] 
        ,ltrim(rtrim(r.desvalor)) [desvalor]
  into #taorelva
  from #taoinfor_elementos_activos a
  inner join CORITEL.dbo.taorelva r (nolock) on r.codeleme=a.codeleme
  set @paso='into #taorelva' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -----------------------------------------------------------------
  --select '#activos' [#activos], * from #activos

  -----------------------------------------
  -- Creación #taotesti
  -----------------------------------------


    select 
        t.ordtesti                                                                                                                                                      [ordtesti]
       ,t.numtesti                                                                                                                                                      [numtesti]
       ,convert(varchar,t.fectesti,103)                                                                                                                                 [TES101]
       ,case t.fuentein when '01' then 'Particular' when '02' then 'Promotor' when '03' then 'API' when'04' then 'Compra/Venta' when '05' then 'Otros' else null end    [TES102]
       ,CORITEL.dbo.fFormato_Money(t.tiempoof)                                                                                                                          [TES103]
       ,case t.sitentor when '01' then 'Buena' when '02' then 'Regular' when '03' then 'Mala' else null end                                                             [TES104]
       ,ltrim(rtrim(i.literal))                                                                                                                                         [TES105]
       ,case t.sitedifi when '01' then 'Buena'  when '02' then 'Mala' when '03' then 'Normal' when '04' then 'Regular' else null end                                    [TES106]
       ,CORITEL.dbo.fFormato_Money_Unitario(antigued)                                                                                                                   [TES107]
       ,ltrim(rtrim(substring(t.dirtesti,01,35)))+', '+ltrim(rtrim(substring(t.dirtesti,36,15)))+' '+ltrim(rtrim(substring(t.dirtesti,51,100)))                         [TES108]
       ,ltrim(rtrim(t.cpotesti))                                                                                                                                        [TES109]
       ,CORITEL.dbo.fFormato_Money(t.suptesti)                                                                                                                          [TES110]
       ,ltrim(rtrim(t.distsupe))                                                                                                                                        [TES111]
       ,ltrim(rtrim(t.usosuper))                                                                                                                                        [TES112]
       ,CORITEL.dbo.fFormato_Money(t.poferven)                                                                                                                          [TES113]
       ,CORITEL.dbo.fFormato_Money(t.pofermes)                                                                                                                          [TES114]
       ,CORITEL.dbo.fFormato_Money(t.poferren)                                                                                                                          [TES115]
       ,ltrim(rtrim(t.obsertes))                                                                                                                                        [TES116]
       ,ltrim(rtrim(c.desclase))                                                                                                                                        [TES117]
       ,ltrim(rtrim(o.desobjet))                                                                                                                                        [TES118]
       ,ltrim(rtrim(t.loctesti))                                                                                                                                        [TES119]
       ,'Comp. '+case when substring(t.ordtesti,2,1) ='A' then '10'                                                                                                            
                      when substring(t.ordtesti,2,1) ='B' then '11'                                                                                                             
                      when substring(t.ordtesti,2,1) ='C' then '12'                                                                                                             
                      else substring(t.ordtesti,2,1)                                                                                                                            
                 end                                                                                                                                                    [TES130]
       ,convert(varchar,month(convert(smalldatetime,t.fectesti,103)))+'/'+convert(varchar,(year(convert(smalldatetime,t.fectesti,103))))                                [TES131]
       ,ltrim(rtrim(t.idtrasac))                                                                                                                                        [TES132]
       ,ltrim(rtrim(t.idfuente))                                                                                                                                        [TES133]
       ,ltrim(rtrim(t.localzon))                                                                                                                                        [TES134]
       ,ltrim(rtrim(t.loubizon))                                                                                                                                        [TES135]
       ,case rtrim(t.antigued) when '0' then 'Nuevo' else rtrim(t.antigued) end                                                                                         [TES136]
       ,rtrim(t.edcalida)                                                                                                                                               [TES137]
       ,case when lower(rtrim(t.edascens))!='no' then 'Sí' else 'No' end                                                                                                [TES138]
       , case when lower(rtrim(t.eqpiscin))!='no' then 'Sí/' else 'No/' end                                                                                                      
        +case when lower(rtrim(t.eqdeport))!='no' then 'Sí/' else 'No/' end                                                                                                     
        +case when lower(rtrim(t.eqjardin))!='no' then 'Sí' else 'No' end		                                                                                             [TES139]
       ,ltrim(rtrim(t.acinteri))                                                                                                                                        [TES140]
       ,ltrim(rtrim(t.acconser))                                                                                                                                        [TES141]
       ,ltrim(rtrim(t.funnivel))				                                                                                                                                    [TES142]
       ,ltrim(rtrim(t.fundormi))+'D-'+ltrim(rtrim(t.nc04))+'B-'+ltrim(rtrim(t.funaseos))+'A'                                                                            [TES143]
       ,ltrim(rtrim(t.fuvistas))                                                                                                                                        [TES144]
       ,case when rtrim(t.idtrasac)='Alquiler (Oper. Real)' then CORITEL.dbo.fFormato_Money(t.nc63) + '€'                       
             when rtrim(t.idtrasac)='Oferta Renta'          then	CORITEL.dbo.fFormato_Money(t.nc63) + '€'                               
             when rtrim(t.idtrasac)='Alquiler (Real)'       then CORITEL.dbo.fFormato_Money(t.nc63) + '€'                               
             else						                                          CORITEL.dbo.fFormato_Money(t.vaimport) + '€'                                                                     
        end                                                                                                                                                             [TES145]
       ,case when CORITEL.dbo.f_TECNICOS_existeComparableRenta(t.numinfor,t.ordtesti)='S' and rtrim(t.idtrasac) not in ('Oferta Renta','Alquiler (Real)') then '--'                       
             else rtrim(t.vadescue) + '%'                                                                                                                                       
        end                                                                                                                                                             [TES146]
       ,case isnull(t.vangaraj,'F') when 'F' then '' else t.vangaraj + 'G-' end                                                                                                 
        +case isnull(t.vatraster,'F') when 'F' then '' else t.vatraster + 'T' end                                                                                       [TES147]
       ,ltrim(rtrim(t.vaterraza))+'m²'                                                                                                                                  [TES148]
       ,case when isnumeric(t.vaimpdes)=1 then CORITEL.dbo.fFormato_Money(t.vaimpdes)else null end                                                                      [TES149]
       ,case when isnumeric(t.tasuputil)=1 then CORITEL.dbo.fFormato_Money_Unitario(convert(float,rtrim(t.tasuputil)))+' m²' else null end                              [TES150]
       ,CORITEL.dbo.fFormato_Money_Unitario(convert(float,rtrim(t.nc05))) + ' m²'                                                                                       [TES151]
       ,isnull(ltrim(rtrim(t.dirtesti1)),'')+', '+isnull(ltrim(rtrim(t.dirtesti2)),'')                                                                                                                  
        +case when rtrim(isnull(t.dirtesti3,'')) <>'' then ', Pl.' + rtrim(isnull(t.dirtesti3,'')) else '' end                                                                  
        +', ' + ltrim(rtrim(isnull(t.loctesti,'')))+'('+ltrim(rtrim(isnull(t.idprovin,'')))+')'+ltrim(rtrim(isnull(t.cpotesti,'')))                                     [TES152]
       ,CORITEL.dbo.fFormato_Money(t.vaimpdes)+' €/m²'                                                                                                                  [TES153]
       ,ltrim(rtrim(t.nc09))+' m²'                                                                                                                                      [TES154]
       ,''                                                                                                                                                              [TES155]
       ,''                                                                                                                                                              [TES156]
       ,''                                                                                                                                                              [TES157]
       ,''                                                                                                                                                              [TES158]
       ,''                                                                                                                                                              [TES159]
       ,''                                                                                                                                                              [TES160]
       ,''                                                                                                                                                              [TES161]
       ,''                                                                                                                                                              [TES162]
       ,''                                                                                                                                                              [TES163]
       ,''                                                                                                                                                              [TES164]
       ,''                                                                                                                                                              [TES165]
       ,''                                                                                                                                                              [TES166]
       , CORITEL.dbo.fFormato_Money(isnull(case when isnumeric(isnull(t.vaimpdes,0))=1                                                                                             
                                                then isnull(t.vaimpdes,0) *                                                                                                        
                                               (select top 1 
                                                     case when isnull(c.ELE05504,0)=0 then 0 else isnull(c.ELE05504,0) end
                                                from CORITEL.dbo.CAB9009 c (nolock)                                                                                                   
                                                where c.numinfor=t.numinfor)                                                                                              
                                        else 0                                                                                                                       
                                      end,0))                                                                                                                           [TES167]
       ,''                                                                                                                                                              [TES168]
       ,''                                                                                                                                                              [TES169]
       ,''                                                                                                                                                              [TES170]
       ,ltrim(rtrim(t.locarzon))                                                                                                                                        [TES171]
       ,ltrim(rtrim(t.nc42))                                                                                                                                            [TES172]
       ,ltrim(rtrim(t.nc43))                                                                                                                                            [TES173]
       ,ltrim(rtrim(t.nc44))                                                                                                                                            [TES174]
       ,ltrim(rtrim(t.nc47))+' %'                                                                                                                                       [TES175]
       ,ltrim(rtrim(t.nc48))+' %'                                                                                                                                       [TES176]
       ,ltrim(rtrim(t.nc49))                                                                                                                                            [TES177]
       ,ltrim(rtrim(t.nc50))                                                                                                                                            [TES178]
       ,ltrim(rtrim(t.nc51))                                                                                                                                            [TES179]
       ,ltrim(rtrim(t.nc52))                                                                                                                                            [TES180]
       ,ltrim(rtrim(t.nc53))                                                                                                                                            [TES181]
       ,ltrim(rtrim(t.nc54))                                                                                                                                            [TES182]
       ,ltrim(rtrim(t.nc19))                                                                                                                                            [TES183]
       ,ltrim(rtrim(t.nc56))                                                                                                                                            [TES184]
       ,ltrim(rtrim(t.nc57))                                                                                                                                            [TES185]
       ,ltrim(rtrim(t.nc55))                                                                                                                                            [TES186]
       ,ltrim(rtrim(t.nc41))                                                                                                                                            [TES187]
       ,ltrim(rtrim(t.edtipoin))                                                                                                                                        [TES188]
       ,ltrim(rtrim(t.nc10))                                                                                                                                            [TES189]
       ,ltrim(rtrim(t.ubplanta))                                                                                                                                        [TES190]
       ,ltrim(rtrim(t.ubacceso))                                                                                                                                        [TES191]
       ,case when isnumeric(isnull(t.fulonfac,0))=1 and isnumeric(isnull(t.fulonfon,0))=1 and convert(decimal(19,2),isnull(t.fulonfon,0))>0                                                 
             then convert(varchar,t.fulonfac)+'/'+convert(varchar,t.fulonfon)                                                                                                    
             else '0'                                                                                                                                                           
        end                                                                                                                                                             [TES192]
       ,ltrim(rtrim(t.nc13))                                                                                                                                            [TES193]
       ,ltrim(rtrim(t.nc14))                                                                                                                                            [TES194]
       ,ltrim(rtrim(t.fumaniob))                                                                                                                                        [TES195]
       ,case when left(t.fuplagar,8)='Múltiple' then 'Múltiple' else rtrim(t.fuplagar) end                                                                              [TES196]
       ,ltrim(rtrim(t.nc20))                                                                                                                                            [TES197]
       ,ltrim(rtrim(t.fuctfpla))                                                                                                                                        [TES198]
       ,CORITEL.dbo.fFormato_Money_Unitario(convert(float,rtrim(t.fusuppar)))+' m²'                                                                                     [TES199]
       ,ltrim(rtrim(nc26))+' €'                                                                                                                                         [TES200]
       ,case when convert(decimal(19,2),case when t.vadesgar='' then 0 else  isnull(t.vadesgar,0) end)                                                                                    
                 +convert(decimal(19,2),case when replace(t.vadestra,'`','') ='' then 0  else isnull(replace(t.vadestra,'`',''),0) end)
                 +convert(decimal(19,2),case when t.vadester ='' then 0 else isnull(t.vadester,0) end)                                                                                       
                 +convert(decimal(19,2),case when t.vadesotr ='' then 0 else isnull(t.vadesotr,0) end)>0                                                                                     
             then CORITEL.dbo.fFormato_Money(	
                  convert(decimal(19,2),case when vadesgar='' then 0 else  isnull(vadesgar,0) end)                                                              
                 +convert(decimal(19,2),case when replace(vadestra,'`','') ='' then 0 else isnull(replace(vadestra,'`',''),0) end)                                                      
                 +convert(decimal(19,2),case when vadester =''then 0 else isnull(vadester,0) end)                                                                                        
                 +convert(decimal(19,2),case when vadesotr =''then 0 else isnull(vadesotr,0) end)	                                                                                       
                  )+' €'                                                                                                                                            
          else	''                                                                                                                                                               
        end                                                                                                                                                             [TES201]
       ,ltrim(rtrim(idtipo))                                                                                                                                            [TES202]
       ,''                                                                                                                                                              [TES402]
       ,'1'                                                                                                                                                             [TES210]
       ,ltrim(rtrim(Latitud))                                                                                                                                           [TES211]
       ,ltrim(rtrim(Longitud))                                                                                                                                          [TES212]
       ,case ltrim(rtrim(idtipo))                                                                                                                                                      
    	        when 'VIV - Unif. Promoción'     then rtrim(nc01)                                                                                                                  
             when 'VIV - Unif. Autopromoción' then rtrim(nc02)                                                                                                                  
             when 'IND - Nave Autopromoción'  then rtrim(nc02)                                                                                                                  
             when 'IND - Nave Promoción'      then rtrim(nc01)                                                                                                                  
             else                                  substring(idtipo,7,50)                                                                                                       
       end 			                                                                                                                                                          [TES213]
       ,CORITEL.dbo.fFormato_Money_Unitario(convert(float,rtrim(replace(fusulipa,'p',''))))+' m²'                                                                       [TES214]
       ,ltrim(rtrim(ubidensi))                                                                                                                                          [TES215]
       ,ltrim(rtrim(condivis))                                                                                                                                          [TES216]
       ,ltrim(rtrim(caacveh))                                                                                                                                           [TES217]
       ,case isnull(fualtlib,'')	when '' then	rtrim(isnull(fuluzlib,'0'))	else	rtrim(fualtlib) + '/' + rtrim(isnull(fuluzlib,'0'))	end                                  [TES218]
       ,ltrim(rtrim(isnull(idw1,'')))                                                                                                                                   [TES219]
       ,ltrim(rtrim(isnull(totcrufa,'')))                                                                                                                               [TES220]
       ,case when rtrim(nc05)='' then	nc06	else	nc05 + '/' + nc06	end                                                                                                   [TES221]
       ,rtrim(isnull(ubnplant,''))                                                                                                                                      [TES222]
       ,rtrim(isnull(lousoedi,''))                                                                                                                                      [TES223]
       ,case rtrim(idtipo)	when 'IND - Nave Promoción' then	'Urbano'	else	rtrim(isnull(lotiposu,'')) End 			                                                            [TES224]
       ,rtrim(isnull(tasupinf,'')) + '/' + rtrim(isnull(tasupsup,''))                                                                                                   [TES225]
       ,rtrim(isnull(tasuppla,''))                                                                                                                                      [TES226]
       ,case when upper(left(ubplanta,4))='BAJA' then	'Baja'	                                                                                                                 
             when upper(ubplanta)='INTERMEDIA'   then	case t.ubnplant	when '0' then	'Baja'	else	t.ubnplant	end                                                                
             when upper(ubplanta)='ÚLTIMA'       then	t.ubnplant			                                                                                                         
             else ubplanta                                                                                                                                                      
         end			                                                                                                                                                         [TES227]
       ,case when upper(fuplagar)<>'PZAS. INDEPTS' then '1'	else	funvehic	end                                                                                           [TES228]
       ,CORITEL.dbo.fFormato_Money_Unitario(convert(float,rtrim(nc86)))                                                                                                 [TES229] --GAR. Precio Neto
       ,''                                                                                                                                                              [TES230] --GAR. Valor Homogeneizado (sin m2) PROPUESTA
       ,case when upper(fuplagar)='PZAS. INDEPTS' then	'1'	else	'0'	end                                                                                                 [TES231]
       ,case when isnumeric(t.vaimpdes)=1 then CORITEL.dbo.fFormato_Money(t.vaimpdes)else null end                                                                      [TES232]
       ,''                                                                                                                                                              [TES233]
       ,case when CORITEL.dbo.f_TECNICOS_existeComparableRenta(t.numinfor,t.ordtesti)='S' AND rtrim(t.idtrasac) NOT IN('Oferta Renta','Alquiler (Real)')  then '--'                      
             when isnumeric(t.nc61)=1 then CORITEL.dbo.fFormato_Money(t.nc61) + '%' 				                                                                                             
             else ''                                                                                                                                                            
        end  	                                                                                                                                                          [TES234]
       ,isnull(t.telefono,'')                                                                                                                                           [TES236]
       ,''                                                                                                                                                              [TES300]
       ,''                                                                                                                                                              [TES301]
       ,''                                                                                                                                                              [TES302]
       ,''                                                                                                                                                              [TES303]
       ,''                                                                                                                                                              [TES304]
       
       ,''                                                                                                                                                              [TES500] -- pendiente de saber qué es
       ,CORITEL.dbo.fFormato_Money(t.renm2mes)                                                                                                                          [TES501]
       ,CORITEL.dbo.fFormato_Money(t.rencrufa)                                                                                                                          [TES502]
       ,''                                                                                                                                                              [TES503] -- pendiente de saber qué es
       ,''                                                                                                                                                              [TES504] -- pendiente de saber qué es

       ,isnull(t.dirtesti1,'')                                                                                                                                          [TES900] --SIVASA	NOMBREVIA
       ,isnull(t.dirtesti2,'')                                                                                                                                          [TES901] --SIVASA	NUMERO
       ,isnull(t.dirtesti3,'')                                                                                                                                          [TES902] --SIVASA	PLANTA
       ,case when isnumeric(isnull(fulonfac,0))=1  then convert(varchar,fulonfac) else '0' end                                                                          [TES903]
       ,case when isnumeric(isnull(fulonfon,0))=1 and convert(decimal(19,2),isnull(fulonfon,0))>0 then convert(varchar(30),fulonfon)	else '0' end                			    [TES904]
       ,rtrim(isnull(t.cpotesti,''))                                                                                                                                    [TES905] --SIVASA	CODIGO  POSTAL
       ,case rtrim(idtipo)                                                                                                                                                      
             When 'VIV - Piso'                then 'P'                                                                                                                                          
             When 'IND - Local Ind.'          then 'P'                                                                                                                                     
             When 'COM - Local en edif.'      then 'P'                                                                                                                                 
             When 'OFI - Oficina'             then 'P'                                                                                                                                       
             When 'GAR - Local calle'         then 'P'                                                                                                                                   
             When 'GAR - Mecanizada'          then 'P'                                                                                                                                    
             When 'GAR - Plaza abierta'       then 'P'					                                                                                                                       
             When 'GAR - Plaza cerrada'       then 'P'	                                                                                                                               
             When 'GAR - Plaza exterior'      then 'P'	                                                                                                                               
             When 'TRA - Almac.calle'         then 'P'	                                                                                                                                 
             When 'TRA - Trastero'            then 'P'	                                                                                                                                     
             When 'TRA - Almacén int.'        then 'P'	                                                                                                                                 
             when 'VIV - Unif. Promoción'     then 'E'                                                                                                                               
             when 'VIV - Unif. Autopromoción' then 'E'                                                                                                                           
             when 'IND - Nave Autopromoción'  then 'E'                                                                                                                            
             when 'IND - Nave Promoción'      then 'E'                                                                                                                                
             when 'COM - Nave comercial'      then 'E'                                                                                                                                
             when 'COM - Edif. comercial'     then 'E'                                                                                                                               
             when 'OFI - Edificio'            then 'E'                                                                                                                                      
             when 'Suelo residencial'         then 'S'                                                                                                                                   
             when 'Suelo industrial'          then 'S'                                                                                                                                    
		           when 'Suelo'                     then case rtrim(lotiposu) when 'No urbaniz.' then 'R' else 'S' end
             else  ''                                                                                                                                                            
        end 	                                                                                                                                                           [TES906] --SIVASA	ANTIGUEDAD
       ,convert(varchar,YEAR(DATEADD(YEAR, CORITEL.dbo.fFormato_Money_Unitario(t.antigued)*-1 ,t.fectesti)))                                                            [TES907]
  into #taotesti
  from CORITEL.dbo.taotesti t (nolock)
       left outer join CORITEL.dbo.taoobjet o (nolock) on o.codobjet=t.codobjet
       left outer join CORITEL.dbo.taoclase c (nolock) on c.codclase=t.codclase
       left outer join CORITEL.dbo.taorctes s (nolock) on s.codclase=t.codclase  
       left outer join CORITEL.dbo.taotesli l (nolock) on l.codplant=s.codplant
       left outer join CORITEL.dbo.taorolit i (nolock) on i.codplant=l.codplant and i.codlitel=t.calidade
  where t.numinfor=@numinfor
  set @paso='into #taotesti' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  -- select top 100 * from CORITEL.dbo.taotesti t (nolock)

  -----------------------------------------
  -- Creación de Tablas Técnicas del Guion
  -----------------------------------------

  create table #tablas_tecnicas (cabecera varchar(100) PRIMARY KEY)
  insert into #tablas_tecnicas
  select distinct @fca+rtrim(a.numcabec) [cabecera] 
  from #activos a
  insert into #tablas_tecnicas select @fde
  set @paso='into #tablas_tecnicas' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  drop table #activos

  -----------------------------------------------

--  create table #campos_tecnicos (campo varchar(25) PRIMARY KEY, desplazamiento int)
--  insert into #campos_tecnicos
--  select distinct 
--         rtrim(sc.name)                                                                            [campo]
--        ,case when st.xprec>0 then case when st.name='datetime' then 0 else @despla end else 0 end [desplazamiento]
--  from #tablas_tecnicas tt     
--  inner join CORITEL.dbo.sysobjects so (nolock) on so.name=tt.cabecera
--  inner join CORITEL.dbo.syscolumns sc (nolock) on sc.id  =so.id
--  inner join CORITEL.dbo.systypes   st (nolock) on st.xtype=sc.xtype
--  set @paso='Carga de Tabla Temporal Campos Técnicos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
  
  ------------------------------
  ------------------------------
  -- Datos Técnicos del Informe
  ------------------------------
  ------------------------------
    
   create table #val
         (codeleme    varchar(5)
         ,deseleme    varchar(500) 
         ,tipoparrafo varchar(10)
         ,tipelemepar varchar(10)
         ,tipeleme    varchar(10)
         ,modparra    varchar(10)
         ,codvalor    varchar(500)
         ,valor       varchar(5000)
         ,tabla       varchar(300)
         ,chk_cargado bit
         )
    
   create index IDX_val   on #val (codeleme   , tipelemepar)  
   create index IDX_val_2 on #val (tipoparrafo, tipeleme)  
   create index IDX_val_3 on #val (tabla      , tipeleme)  
   create index IDX_val_4 on #val (modparra   , tipoparrafo)  
   create index IDX_val_5 on #val (tipelemepar, tipeleme)  
   create index IDX_val_6 on #val (tipeleme   , modparra, tipoparrafo)  

   ----------------------------------
   -- Elementos con entrada en guion   
   ----------------------------------
       
   insert into #val
   select distinct 
          e.codeleme                                        [codeleme]
         ,e.deseleme                                        [deseleme]
         ,'C'                                               [tipoparrafo]
         ,'0'                                               [tipelemepar] 
         ,e.tipeleme                                        [tipeleme] 
         ,'0'                                               [modparra]
         ,''                                                [codvalor]
         ,''                                                [valor]
         ,@fca+r.numcabec                                   [tabla]
         ,null                                              [chk_cargado]
   from #taoinfor i with (index(IDX_taoinfor_3))
   inner join #taorpael_general p with (index (IDX_taorpael_general_codparra)) on p.codparra=i.codparra and p.tipeleme='0' -- Elementos
   inner join #taoeleme         e on e.codeleme=p.codeleme and e.codeleme between '00006' and '99998'
   inner join #taoresel         r on r.codeleme=e.codeleme
   where i.modparra='0'
   order by e.codeleme 
   set @paso='into #val (I) - Elementos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
   
   -----------------------------------------------
   -- Elementos espejos sin entrada en guion 
   -----------------------------------------------

   insert into #val      
   select distinct 
          e.codeleme                                        [codeleme]
         ,e.deseleme                                        [deseleme]
         ,'C'                                               [tipoparrafo]
         ,'0'                                               [tipelemepar] 
         ,e.tipeleme                                        [tipeleme] 
         ,'0'                                               [modparra]
         ,''                                                [codvalor]
         ,''                                                [valor]
         ,@fca+r.numcabec                                   [tabla]
         ,null                                              [chk_cargado]
   from #taoinfor i with (index(IDX_taoinfor_3))
   inner join #taorpael_general p with (index (IDX_taorpael_general_codparra)) on p.codparra=i.codparra and p.tipeleme='4'  -- Espejos
   inner join #taorpali         l with (index (IDX_taorpali_1)) on l.codparra=p.codparra and l.codlitel=p.codeleme
   inner join #taoeleme         e on e.codeleme=substring(l.deslitel,2,5) and e.codeleme between '00006' and '99998'
   inner join #taoresel         r on r.codeleme=e.codeleme
   where i.modparra='0'
     and not exists (select * from #val with(index(IDX_val)) where codeleme=substring(l.deslitel,2,5)) 
   order by e.codeleme 
   set @paso='into #val (II) - Espejos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   -----------------------------------------------
   -- Elementos testigos sin entrada en guion 
   -----------------------------------------------

   insert into #val
   select distinct 
          p.codeleme                                        [codeleme]
         ,'Dato Testigo'                                    [deseleme]
         ,'C'                                               [tipoparrafo]
         ,'0'                                               [tipelemepar] 
         ,p.tipeleme                                        [tipeleme] 
         ,'0'                                               [modparra]
         ,''                                                [codvalor]
         ,''                                                [valor]
         ,'taotesti'                                        [tabla]
         ,null                                              [chk_cargado]
   from #taoinfor i with (index(IDX_taoinfor_3))
   inner join #taorpael_general p with (index (IDX_taorpael_general_codparra)) on p.codparra=i.codparra and p.tipeleme='6' -- Elementos de Testigos que se encuentran en el guion
   where i.modparra='0'
   order by p.codeleme 
   set @paso='into #val (III) - Testigos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   -- select * from CORITEL.dbo.taorpael p where p.tipeleme='6' and right(p.codeleme,3)='500'

   ------------------------------------
   -- Incorporar los datos de detalles
   ------------------------------------

   insert into #val
   select distinct 
          e.codeleme                                        [codeleme]
         ,e.deseleme                                        [deseleme]
         ,'D'                                               [tipoparrafo]
         ,'0'                                               [tipelemepar] 
         ,e.tipeleme                                        [tipeleme] 
         ,'0'                                               [modparra]
         ,''                                                [codvalor]
         ,''                                                [valor]
         ,@fde+r.numcabec                                   [tabla]
         ,null                                              [chk_cargado]
   from #taoinfor i with (index(IDX_taoinfor_3))
   inner join #th_rpacu p on p.codparra=i.codparra -- Detalle
   inner join #taoeleme e on e.codeleme=p.codeleme and e.codeleme between '00006' and '99998'
   inner join #taoresel r on r.codeleme=e.codeleme
   where i.modparra='0'
   order by e.codeleme 
   set @paso='into #val (IV) - Detalles' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   -------------------------------

   -- select * from #taorpael_general v 
   -- select * from #val v where v.tipeleme='6'

   declare @comando   varchar(max)=''
          ,@cxml      varchar(max)=''
          ,@codeleinf varchar(10)
          ,@tipeleinf varchar(10)
          ,@ficcabele varchar(10)  

   -----------------------------------------

   declare @update_gral varchar(max)=''

   declare @cabecera varchar(300)
   declare c cursor for
   select distinct v.tabla 
   from #val v with(index (IDX_val_2))
   where v.tipoparrafo='C' 
     and v.tipeleme not in ('6')
   order by 1
   open c
   fetch next from c into @cabecera
   while @@fetch_status=0
         begin
            set @cxml='update v set v.codvalor=case '
            select @cxml+=
                case when v.tipeleme in ('00','02','09') then ' when v.codeleme='''+v.codeleme+''' then convert(varchar(5000),isnull(c.ELE'+v.codeleme+',0))' 
                     when v.tipeleme in ('01','03','19') then ' when v.codeleme='''+v.codeleme+''' then convert(varchar(5000),isnull(c.ELE'+v.codeleme+',''''))'
                     when v.tipeleme in ('04')           then ' when v.codeleme='''+v.codeleme+''' then convert(varchar(  30),isnull(c.ELE'+v.codeleme+',''''),103)'
                     else ''            
                end
            from #val v with(index (IDX_val_3))
            where v.tabla      =@cabecera
              and v.tipeleme   in ('02','09','00','03','04','01','19') 
              and v.modparra   ='0' 
              and v.tipoparrafo='C'
              and v.tipeleme   not in ('6')
            set @cxml+=' else v.codvalor end from #val v inner join CORITEL.dbo.'+@cabecera+' c (nolock) on c.numinfor='''+@numinfor+''''
            set @update_gral+=@cxml+char(10)
            fetch next from c into @cabecera
         end
   close c
   deallocate c
   set @paso='montaje @update_gral' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   exec (@update_gral)
   set @paso='exec @update_gral'; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   -- select * from #val v where v.tipeleme='06'

   --------------------------------------------------------------------------------------------------------
     
   update v set v.valor   =v.codvalor from #val v with(index (IDX_val_2)) where v.tipoparrafo='C' and v.tipeleme not in ('6')
   update v set v.codvalor='#'        from #val v with(index (IDX_val_4)) where v.modparra='2' and v.tipoparrafo='C' and v.tipeleme not in ('6')
   update v set v.codvalor='@'        from #val v with(index (IDX_val_4)) where v.modparra='3' and v.tipoparrafo='C' and v.tipeleme not in ('6')
   
   update v  
      set v.valor=r.desvalor 
   from #val v with(index (IDX_val_5))
   inner join #taorelva r on r.codeleme=v.codeleme and r.codvalor=v.valor 
   where v.tipelemepar='0' 
     and v.tipeleme   ='01' 
     and v.valor between '01' and '97' 
     and v.tipoparrafo='C'
     and v.tipeleme not in ('6')

   update v 
      set v.valor='<font style="color:#ddd;">Vacío</font>' 
   from #val v with(index (IDX_val_5))
   inner join #taorelva r on r.codeleme=v.codeleme and r.codvalor=v.valor 
   where v.tipelemepar='0' 
     and v.tipeleme   ='01' 
     and v.valor in ('00', '98') 
     and v.tipoparrafo='C'
     and v.tipeleme not in ('6')

   update v 
      set v.valor='<a class="e01t">'+rtrim(i.nuevalor)+'</a>' 
   from #val v with(index (IDX_val_5))
   inner join #taorinmo i on i.codeleme=v.codeleme 
   where v.tipelemepar='0' 
     and v.tipeleme   ='01' 
     and v.valor      ='99' 
     and v.tipoparrafo='C'
     and v.tipeleme not in ('6')

   update v 
      set v.valor=dbo.f_FMHD(codvalor,2) 
   from #val v with(index (IDX_val_2))
   where v.tipoparrafo='C'
     and v.tipeleme in ('00', '02', '09') 
     and v.tipeleme not in ('6')

   update v 
      set v.valor=replace(valor,',00', '')          
   from #val v with(index (IDX_val_2))
   inner join #taoeleme e (nolock) on e.codeleme=v.codeleme and not e.plantill like '%,%' 
   where v.tipoparrafo='C'
     and v.tipeleme   in ('00', '02', '09') 
     and v.tipeleme   not in ('6')

   update v 
   set v.valor='<font style="color:#ddd;">Vacío</font>' 
   from #val v with(index (IDX_val_5))
   where v.tipelemepar='0' 
     and v.tipeleme   ='04' 
     and v.valor      ='01/01/1900' 
     and v.tipoparrafo='C'
     and v.tipeleme   not in ('6')

   update v 
      set v.valor='<font style="color:#ddd;">Vacío</font>' 
   from #val v with(index (IDX_val_5))
   where v.tipelemepar='0' 
     and v.tipeleme   ='03' 
     and v.valor      =''
     and v.tipoparrafo='C'
     and v.tipeleme not in ('6')

   -----------------------------------  
   -- Vaciar los elementos no activos  
   -----------------------------------

   update v set v.valor='' from #val v where not exists (select * from #taoinfor_elementos_activos ea where ea.codeleme=v.codeleme) and v.tipeleme not in ('6')

   ----------------------------------------  
   -- Vaciar los elementos no imprimibles
   ----------------------------------------
     
   update v set v.valor='' from #val v where exists (select * from #taoinfor_elementos_no_imprimibles ea where ea.codeleme=v.codeleme) and v.tipelemepar='0' and v.tipeleme not in ('6')

   -----------------------------------------

   set @paso='update #val' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   ----------------------------------------  
   -- cargar datos de testigos
   ----------------------------------------

   set @cxml=replace(replace(replace(replace(replace(
   convert(varchar(max),
   (select 'update #val set valor=(select top 1 t.TES'+right(v.codeleme,3)+' from #taotesti t where t.ordtesti=left('''+v.codeleme+''',2) ) where codeleme='''+v.codeleme+''' and tipeleme=''6''' 
    from #val v 
    where v.tipeleme='6'
      and exists (select * from #taotesti t where t.ordtesti=left(v.codeleme,2))
   for xml raw('') , elements)),'</a><a>',char(10)),'</a>',''),'<a>',''),'&lt;','<'),'&gt;','>')
   set @paso='montaje @cxml - testigos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   exec (@cxml)
   set @paso='exec @cxml - testigos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   -- select v.* from #val v where v.tipeleme='6'
 
   -- ----------------------------------------------------
   -- Tratamiento de los datos del cuadro de detalle
   -- ----------------------------------------------------

   
   set @cxml=replace(replace(replace(replace(replace(
   convert(varchar(max),
   (select case when v.tipeleme in ('00','02','09')       then 'update #val set codvalor=''S'' where exists (select * from CORITEL.dbo.'+@fde+r.numcabec+' (nolock) where numinfor='''+@numinfor+''' and isnull(ELE'+v.codeleme+',   0)!=  0 ) and codeleme='''+v.codeleme+''' '
                when v.tipeleme in ('01','03','19', '04') then 'update #val set codvalor=''S'' where exists (select * from CORITEL.dbo.'+@fde+r.numcabec+' (nolock) where numinfor='''+@numinfor+''' and isnull(ELE'+v.codeleme+','''')!='''') and codeleme='''+v.codeleme+''' '
                else ''
           end [a]         
   from #val v with(index(IDX_val_6))
   inner join #taoresel r on r.codeleme=v.codeleme
   where v.tipeleme in ('02', '09', '00', '03', '04', '01', '19') 
     and v.modparra   ='0' 
     and v.tipoparrafo='D'
     and isnull(v.tipeleme,'0') not in ('6')
   for xml raw('') , elements)),'</a><a>',char(10)),'</a>',''),'<a>',''),'&lt;','<'),'&gt;','>')
   set @paso='montaje @cxml - detalles' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait


/*

   set @cxml=replace(replace(replace(replace(replace(
   convert(varchar(max),
   (select case when v.tipeleme in ('00','02','09')       then 'update v set v.codvalor=''S'' from #val v inner join CORITEL.dbo.'+@fde+r.numcabec+' (nolock) c on c.numinfor='''+@numinfor+''' and isnull(c.ELE'+v.codeleme+',   0)!=  0  where v.codeleme='''+v.codeleme+''' '
                when v.tipeleme in ('01','03','19', '04') then 'update v set v.codvalor=''S'' from #val v inner join CORITEL.dbo.'+@fde+r.numcabec+' (nolock) c on c.numinfor='''+@numinfor+''' and isnull(c.ELE'+v.codeleme+','''')!='''' where v.codeleme='''+v.codeleme+''' '
                else ''
           end [a]         
   from #val v
   inner join #taoresel r on r.codeleme=v.codeleme
   where v.tipeleme in ('02', '09', '00', '03', '04', '01', '19') 
     and v.modparra   ='0' 
     and v.tipoparrafo='D'
     and v.tipeleme not in ('6')
   for xml raw('') , elements)),'</a><a>',char(10)),'</a>',''),'<a>',''),'&lt;','<'),'&gt;','>')
   set @paso='montaje @cxml' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

*/

   exec (@cxml)
   set @paso='exec @cxml - detalle' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
   
   -- select * from #val

  -- ------------------------------------
  -- Extracción de Datos Enlace Taoencar
  -- ------------------------------------

   select  e.numinfor                       [numinfor] 
          ,rtrim(s.nifsolic)                [E00101]
          ,rtrim(s.nomsolic)                [E00102]
          ,rtrim(s.apel1sol)                [E00103]
          ,rtrim(s.apel2sol)                [E00104]
          ,rtrim(s.diresoli)                [E00105]
          ,rtrim(s.cpossoli)                [E00106]
          ,rtrim(s.deslocal)                [E00107]
          ,rtrim(v.desprovi)                [E00108]
          ,rtrim(d.desentid)                [E00201]
          ,rtrim(o.desofici)                [E00202]
          ,rtrim(p.desdepar)                [E00203]
          ,rtrim(c.desclase)                [E00301]
          ,rtrim(es.desestad)               [E00303]
          ,rtrim(e.calleobj)                [E00304]
          ,rtrim(e.numeobje)                [E00305]
          ,rtrim(e.pisoobje)                [E00306]
          ,rtrim(e.restdire)                [E00307]
          ,rtrim(e.cposobje)                [E00308]
          ,rtrim(e.deslocal)                [E00309]
          ,rtrim(e.regiprop)                [E00310]
          ,convert(char(10),e.feccalif,103) [E00311]
          ,convert(char(10),e.fecsubas,103) [E00312]
          ,rtrim(e.referenc)                [E00313]
          ,rtrim(v1.desprovi)               [E00314]
          ,convert(char(10),e.fecdeven,103) [E00315]
          ,ltrim(rtrim(t.nomtasad))
           +' '+ltrim(rtrim(t.ap1tasad))
           +' '+ltrim(rtrim(t.ap2tasad))
           +', '+ltrim(pr.desprofe)         [E00316]
          ,rtrim(u.desusuar)                [E00317]
          ,convert(char(10),e.feccalif,103) [E00318]
     into #encargos
     from CORITEL.dbo.taoencar e (nolock)
          left outer join CORITEL.dbo.taosolic  s (nolock) on  s.codsolic=e.codsolic
          left outer join CORITEL.dbo.taoprovi  v (nolock) on  v.codprovi=s.codprovi 
          left outer join CORITEL.dbo.taoentid  d (nolock) on  d.codentid=e.codentid 
          left outer join CORITEL.dbo.taoofici  o (nolock) on  o.codentid=e.codentid and o.codofici=e.codofici
          left outer join CORITEL.dbo.taodepar  p (nolock) on  p.codentid=e.codentid and p.codofici=e.codofici and p.coddepar=e.coddepar 
          left outer join CORITEL.dbo.taoclase  c (nolock) on  c.codclase=e.codclase 
          left outer join CORITEL.dbo.taoestad es (nolock) on es.codestad=e.codestad 
          left outer join CORITEL.dbo.taoprovi v1 (nolock) on v1.codprovi=e.codprovi 
          left outer join CORITEL.dbo.taousuar  u (nolock) on  u.codusuar=e.usfirma  
          left outer join CORITEL.dbo.taotasad  t (nolock) on  t.codtasad=e.codtasad 
          left outer join CORITEL.dbo.taortapf tp (nolock) on tp.codtasad=t.codtasad
          left outer join CORITEL.dbo.taoprofe pr (nolock) on pr.codprofe=tp.codprofe
     where e.numinfor=@numinfor

     insert into #val select '00101', '', 'C', '5', '03', '0', E00101, E00101, null, null from #encargos
     insert into #val select '00102', '', 'C', '5', '03', '0', E00102, E00102, null, null from #encargos
     insert into #val select '00103', '', 'C', '5', '03', '0', E00103, E00103, null, null from #encargos
     insert into #val select '00104', '', 'C', '5', '03', '0', E00104, E00104, null, null from #encargos
     insert into #val select '00105', '', 'C', '5', '03', '0', E00105, E00105, null, null from #encargos
     insert into #val select '00106', '', 'C', '5', '03', '0', E00106, E00106, null, null from #encargos
     insert into #val select '00107', '', 'C', '5', '03', '0', E00107, E00107, null, null from #encargos
     insert into #val select '00108', '', 'C', '5', '03', '0', E00108, E00108, null, null from #encargos
     insert into #val select '00201', '', 'C', '5', '03', '0', E00201, E00201, null, null from #encargos
     insert into #val select '00202', '', 'C', '5', '03', '0', E00202, E00202, null, null from #encargos
     insert into #val select '00203', '', 'C', '5', '03', '0', E00203, E00203, null, null from #encargos
     insert into #val select '00301', '', 'C', '5', '03', '0', E00301, E00301, null, null from #encargos
     insert into #val select '00303', '', 'C', '5', '03', '0', E00303, E00303, null, null from #encargos
     insert into #val select '00304', '', 'C', '5', '03', '0', E00304, E00304, null, null from #encargos
     insert into #val select '00305', '', 'C', '5', '03', '0', E00305, E00305, null, null from #encargos
     insert into #val select '00306', '', 'C', '5', '03', '0', E00306, E00306, null, null from #encargos
     insert into #val select '00307', '', 'C', '5', '03', '0', E00307, E00307, null, null from #encargos
     insert into #val select '00308', '', 'C', '5', '03', '0', E00308, E00308, null, null from #encargos
     insert into #val select '00309', '', 'C', '5', '03', '0', E00309, E00309, null, null from #encargos
     insert into #val select '00310', '', 'C', '5', '03', '0', E00310, E00310, null, null from #encargos
     insert into #val select '00311', '', 'C', '5', '03', '0', E00311, E00311, null, null from #encargos
     insert into #val select '00312', '', 'C', '5', '03', '0', E00312, E00312, null, null from #encargos
     insert into #val select '00313', '', 'C', '5', '03', '0', E00313, E00313, null, null from #encargos
     insert into #val select '00314', '', 'C', '5', '03', '0', E00314, E00314, null, null from #encargos
     insert into #val select '00315', '', 'C', '5', '03', '0', E00315, E00315, null, null from #encargos
     insert into #val select '00316', '', 'C', '5', '03', '0', E00316, E00316, null, null from #encargos
     insert into #val select '00317', '', 'C', '5', '03', '0', E00317, E00317, null, null from #encargos
     insert into #val select '00318', '', 'C', '5', '03', '0', E00318, E00318, null, null from #encargos
   set @paso='into #encargos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   -----------------------------------
   -- Cargar los Datos de Validaciones
   -----------------------------------

   declare @numorden int
   select top 1 @numorden=vv.numorden 
   from CORITEL.dbo.taoencar_validaciones_version vv (nolock) 
   where numinfor=@numinfor 
   order by vv.fecha desc
   
   create table #validaciones
    ([id]          int identity(1,1) primary key
    ,[codeleme]    varchar(5)
    ,[validacion]  varchar(max)
    )
    
   insert into #validaciones
   select vt.codeleme
         ,  isnull(vt.[textosalida],'')
           +', Gravedad('+convert(varchar(10),vt.[gravedad])+')'
           +case when vt.gravedad=0 then ', Gravedad 0' else '' end
           +case when vt.gravedad=1 then ', Gravedad 1' else '' end
           +case when vt.gravedad=2 then ', Justificación: '+isnull(vt.justificado,'') else ''  end
           +case when vt.gravedad=3 then ', Gravedad 3' else '' end
           +case when vt.gravedad=4 then ', Chequeado: '+case when isnull(vt.chequeado,0)=1 then 'SI' else 'NO'  end else '' end
           +case when vt.gravedad=5 then ', Chequeado: '+case when isnull(vt.chequeado,0)=1 then 'SI' else 'NO'  end else '' end [a]
    from CORITEL.dbo.taoencar_validaciones_tecnicas vt (nolock)
    left outer join CORITEL.dbo.taovalidacion_condiciones va (nolock) on va.codvalid=convert(bigint,replace(vt.codigovalidacion,'V_',''))
    where vt.numorden=@numorden
    set @paso='into #validaciones' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   ----------------------------------------

   create table #taorpael
    ([id]          int identity(1,1) primary key
    ,[codparra]    varchar(5)
    ,[formato]     varchar(5)
    ,[fileleme]    int
    ,[coleleme]    decimal(19,2)
    ,[bi]          varchar(10)
    ,[ii]          varchar(10)
    ,[si]          varchar(10)
    ,[bf]          varchar(10)
    ,[if]          varchar(10)
    ,[sf]          varchar(10)
    ,[fila_precedente]          int
    ,[filas_precedentes_vacias] int
    ,[tipo_dato_precedente] varchar(10)
    ,[tipo_dato]            varchar(10)
    ,[tipo_dato_posterior]  varchar(10)
    ,[es_primero]     int 
    ,[es_ultimo]      int
    ,[ancho]          decimal(19,2)
    ,[porcen]         decimal(19,2)    
    ,[tipeleme]       varchar(10)
    ,[tipeleme_elemento]  varchar(10)
    ,[codeleme]       varchar(10)
    ,[dato]           varchar(max)
    ,[dato_posterior] varchar(max)   
    ,[html]           varchar(max)
    ,[validacion]     varchar(max)
    ,[display]        varchar(100)
    )

   create index IDX_taorpael_1 on #taorpael (id)     
   create index IDX_taorpael_2 on #taorpael (codparra, fileleme, coleleme, codeleme)     
   create index IDX_taorpael_3 on #taorpael (tipo_dato)     
   set @paso='create table #taorpael' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   insert into #taorpael
   select 
         i.codparra                                                    [codparra]
        ,i.formato                                                     [formato] 
        ,t.fileleme                                                    [fileleme]
        ,convert(decimal(19,2),t.coleleme)                             [coleleme]
        ,case when substring(t.leteleme,1,1)='1' then '<b>'  else '' end [bi]
        ,case when substring(t.leteleme,2,1)='1' then '<i>'  else '' end [ii]
        ,case when substring(t.leteleme,3,1)='1' then '<u>'  else '' end [si]
        ,case when substring(t.leteleme,1,1)='1' then '</b>' else '' end [bf]
        ,case when substring(t.leteleme,2,1)='1' then '</i>' else '' end [if]
        ,case when substring(t.leteleme,3,1)='1' then '</u>' else '' end [sf]
        ,isnull((select max(px.fileleme) 
                 from #taorpael_general px with (index (IDX_taorpael_general_codparra))
                 where px.codparra=i.codparra 
                   and px.fileleme<t.fileleme),0)                      [fila_precedente]
        ,convert(int,null)                                             [filas_precedentes_vacias]  
        ----------------------------------------------------------------------- 
        ,convert(varchar(1),null)          [tipo_dato_precedente]   
        ,case when t.tipeleme='0' then case when e.tipeleme in ('00','02','09') then 'N' else 'T' end
              when t.tipeleme='4' then  -- Espejo
                   case when exists (select ex.tipeleme 
                                     from #taoeleme ex
                                     where ex.codeleme=(select top 1 substring(rtrim(px.deslitel),2,5) from #taorpali px with (index (IDX_taorpali_1)) where px.codparra=t.codparra and px.codlitel=t.codeleme) 
                                       and ex.tipeleme in ('00', '02', '09') -- Elemento Numerico
                                    )   
                        then 'N'
                        else 'T'
                 end
           when t.tipeleme='6' then   -- Testigo
                case when right(t.codeleme,3) in ('107','110','113','114','115') then 'N' else 'T' end
           else 'T'
        end                                 [tipo_dato]
       ,convert(varchar(1),null)            [tipo_dato_posterior]    
       ----------------------------------------------------------------------- 
       ,case when (select max(px.coleleme) from #taorpael_general px with (index (IDX_taorpael_general_codparra)) where px.codparra=i.codparra and px.fileleme=t.fileleme and right('00000'+convert(varchar(10),px.coleleme),5)+px.codeleme<right('00000'+convert(varchar(10),t.coleleme),5)+t.codeleme) is null then 1 else null end  [es_primero]
       ,case when (select min(px.coleleme) from #taorpael_general px with (index (IDX_taorpael_general_codparra)) where px.codparra=i.codparra and px.fileleme=t.fileleme and right('00000'+convert(varchar(10),px.coleleme),5)+px.codeleme>right('00000'+convert(varchar(10),t.coleleme),5)+t.codeleme) is null then 1 else null end  [es_ultimo]
       ,convert(decimal(19,2),null)         [ancho]
       ,convert(decimal(19,2),null)         [porcen]    
       ,t.tipeleme                          [tipeleme]
       ,e.tipeleme                          [tipeleme_elemento]
       ,t.codeleme                          [codeleme]
       ,convert(varchar(max),
                case when t.tipeleme='0' then        (select top 1 v.valor     from #val v with(index(IDX_val)) where v.codeleme=t.codeleme and v.tipelemepar='0')
                     when t.tipeleme='1' then isnull((select top 1 px.deslitel from #taorpali px with (index (IDX_taorpali_1)) where px.codparra=i.codparra and px.codlitel=t.codeleme),'')
                     when t.tipeleme='4' then        (select top 1 v.valor     from #val v with(index(IDX_val)) where v.codeleme=(select substring(rtrim(px.deslitel),2,5) from #taorpali px with (index (IDX_taorpali_1)) where px.codparra=i.codparra and px.codlitel=t.codeleme) and v.tipelemepar='0')
                     when t.tipeleme='5' then isnull((select top 1 v.valor     from #val v with(index(IDX_val)) where v.codeleme=t.codeleme and v.tipelemepar='5'),'')
                     when t.tipeleme='6' then isnull((select top 1 v.valor     from #val v with(index(IDX_val)) where v.codeleme=t.codeleme and v.tipeleme   ='6'),'')
                     else ''
                end
         )                                  [dato]
       ,convert(varchar(max),null)          [dato_posterior]    
       ,convert(varchar(max),null)          [html]
       ,replace(replace(replace(convert(varchar(max), (select vt.validacion [a] from #validaciones vt where vt.codeleme=t.codeleme for xml raw(''), elements)),'</a><a>','<br/>'),'</a>',''),'<a>','') [validacion] 
       ,case when t.imprimible=0 then ';background:#fff;color:#fff;' else '' end
        +isnull(';font-family:'+isnull(t.fuente_imp,'Arial')+';','')
        +isnull(';font-size:'+convert(varchar(10),t.tamano_imp)+'vw;','')  
                                            [display]
    from #taoinfor i with( index(IDX_taoinfor_4) )
     inner      join #taorpael_general t with (index (IDX_taorpael_general_codparra)) on t.codparra=i.codparra
     left outer join #taoeleme         e                                              on e.codeleme=t.codeleme and t.tipeleme='0'
    where i.nivestru='0'   -- párrafo normal
      and i.formato ='1'   -- parrafo en rejilla (por posicionamiento)
    order by i.posapart, i.posparra, t.fileleme, t.coleleme, t.codeleme
    set @paso='insert #taorpael nivestru=0 y formato=1 (posicionado) ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

    --select '#taorpael' [#taorpael], * from #taorpael t where t.tipeleme='6'

    /* ------------------------------------------------
       Zona de Control
    */ ------------------------------------------------

    if 1=2  -- OJO CERRADO
       begin
          select @numorden
          select vt.codeleme
                ,vt.tipoeleme
                ,
                  isnull(vt.[textosalida],'')
                     +', Gravedad('+convert(varchar(10),vt.[gravedad])+')'
                     +case when vt.gravedad=0 then ', Gravedad 0' else '' end
                     +case when vt.gravedad=1 then ', Gravedad 1' else '' end
                     +case when vt.gravedad=2 then ', Justificación: '+isnull(vt.justificado,'') else ''  end
                     +case when vt.gravedad=3 then ', Gravedad 3' else '' end
                     +case when vt.gravedad=4 then ', Chequeado: '+case when isnull(vt.chequeado,0)=1 then 'SI' else 'NO'  end else '' end
                     +case when vt.gravedad=5 then ', Chequeado: '+case when isnull(vt.chequeado,0)=1 then 'SI' else 'NO'  end else '' end [a]
              from [CORITEL].[dbo].[taoencar_validaciones_tecnicas] vt with(nolock)
              left outer join [CORITEL].[dbo].[taovalidacion_condiciones] va with(nolock) on va.codvalid=convert(bigint,replace(vt.codigovalidacion,'V_',''))
              where vt.numorden=@numorden
                --and vt.tipoeleme='C'
              order by orden

          select * from #taorpael p where p.tipeleme='0' and p.codeleme='02389'
       end

    --------------------------------

    update t set t.dato= t.bi+t.ii+t.si 
                        +t.dato
                        +t.bf+t.[if]+t.sf 
    from #taorpael t
                
    update t 
      set t.tipo_dato_posterior =isnull((select tx.tipo_dato from #taorpael tx where tx.id=t.id+1),'T')
         ,t.dato_posterior      =isnull((select tx.dato      from #taorpael tx where tx.id=t.id+1),'')
    from #taorpael t

    update t 
      set t.tipo_dato_precedente=isnull((select tx.tipo_dato+tx.tipo_dato_posterior from #taorpael tx where tx.id=t.id-1),'TT')
    from #taorpael t

    --------------------------------

    if @debug=1
       begin
          select * 
          from #taorpael t 
          where t.formato='1' 
            and t.codparra in ('29214')
            and t.fileleme=1
          order by t.id

          select * 
          from CORITEL.dbo.taorpael t 
          where t.codparra in ('29214')
            and t.fileleme=1
          order by t.fileleme, t.coleleme, t.codeleme
      end

    -------------------------

    update t 
       set t.ancho=(select top 1 tx.coleleme from #taorpael tx with(index(IDX_taorpael_1)) where tx.id=t.id+1 order by tx.id)-t.coleleme 
    from #taorpael t with(index(IDX_taorpael_3))
    where t.tipo_dato='T'

    update t 
       set t.ancho=t.coleleme-(select top 1 tx.coleleme from #taorpael tx with(index(IDX_taorpael_1)) where tx.id=t.id-1 order by tx.id)
    from #taorpael t with(index(IDX_taorpael_3))
    where t.tipo_dato='N'
   
    --------------------------------

    update t 
       set t.porcen=(t.ancho/10000.00)*100.00 
    from #taorpael t 

    update t set t.filas_precedentes_vacias=t.fileleme-t.fila_precedente-1 from #taorpael t 
    update t set t.filas_precedentes_vacias=0                              from #taorpael t where t.filas_precedentes_vacias<0
    update t set t.es_primero=0                                            from #taorpael t where t.es_primero is null
    update t set t.es_ultimo =0                                            from #taorpael t where t.es_ultimo  is null

    set @paso='update #taorpael ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

    
    declare @porce_numero decimal(19,2)=1
    
    -----------------------------------------------
    -- Montaje del HTML para los parrafos tabulados
    -----------------------------------------------
    
    update t 
       set t.html=''
       +case when t.es_primero=1 then '<table style=";border-collapse:collapse;border:solid 0px #d00;width:100%;margin:auto"><tr>'
                                     +'<td class="inipt" style="border:solid 0px #d00;color:#fff;width:'+isnull(dbo.f_FMHDI((t.coleleme/10000.00)*100.00,2),'0')+'%">..</td>' 
             else '' 
        end                  -- apertura tabla + primera posicion 
       +case t.tipo_dato+t.tipo_dato_posterior
             when 'TN' then   
                       case when t.porcen=0  then ''
                            else '<td style="border:solid 0px #d00;width:'+isnull(dbo.f_FMHDI(t.porcen,2),'0')+'%;text-align:left;">'
                                    +'<table style=";width:100%;border-collapse:collapse;"><tr>'    -- Lo Monto en Tabla sobre una celda
                                    +'<td '
                                         +case when t.tipeleme='0' then ' class="e'+isnull(t.tipeleme_elemento,'')+'"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Párr.: '+isnull(t.codparra,'')+', El.Cab(TN). '+isnull(t.codeleme,'')+'['+isnull(t.tipeleme_elemento,'')+']" ' 
                                               when t.tipeleme='1' then ' class="litnormal"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', El.Taorpali '+isnull(t.codeleme,'')+'" '
                                               when t.tipeleme='4' then ' class="espejo"   '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Espejo '+isnull((select top 1 substring(rtrim(deslitel),2,5) from #taorpali with (index (IDX_taorpali_1)) where codparra=t.codparra and codlitel=t.codeleme),'')+'" ' 
                                               when t.tipeleme='5' then ' class="cabecera" '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Dato Inf. '+isnull(t.codeleme,'')+'" ' 
                                               when t.tipeleme='6' then ' class="testigo"  '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Dato Test. '+isnull(t.codeleme,'')+'" ' 
                                               else ''
                                          end     
                                         +' style="border:solid 0px #d00;width:auto;text-align:left;'+case when t.validacion is not null then ';background:#a00' else '' end+t.display+'">'+isnull(t.dato,'')+'</td>'
                                     +'<td '
                                         +case when ts.tipeleme is null then ''
                                               when ts.tipeleme='0' then ' class="e'+isnull(ts.tipeleme_elemento,'')+'"'+' title="FilEle:'+convert(varchar(10),ts.fileleme)+',ColEle:'+convert(varchar(10),ts.coleleme)+',Párr.: '+isnull(ts.codparra,'')+', El.Cab(TNS). '+isnull(ts.codeleme,'')+'['+isnull(ts.tipeleme_elemento,'')+']" ' 
                                               when ts.tipeleme='1' then ' class="litnormal"'+' title="FilEle:'+convert(varchar(10),ts.fileleme)+',ColEle:'+convert(varchar(10),ts.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', El.Taorpali '+isnull(ts.codeleme,'')+'" '
                                               when ts.tipeleme='4' then ' class="espejo"   '+' title="FilEle:'+convert(varchar(10),ts.fileleme)+',ColEle:'+convert(varchar(10),ts.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', Espejo '+isnull((select top 1 substring(rtrim(deslitel),2,5) from #taorpali with (index (IDX_taorpali_1)) where codparra=ts.codparra and codlitel=ts.codeleme),'')+'" ' 
                                               when ts.tipeleme='5' then ' class="cabecera" '+' title="FilEle:'+convert(varchar(10),ts.fileleme)+',ColEle:'+convert(varchar(10),ts.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', Dato Inf. '+isnull(ts.codeleme,'')+'" ' 
                                               when ts.tipeleme='6' then ' class="testigo"  '+' title="FilEle:'+convert(varchar(10),ts.fileleme)+',ColEle:'+convert(varchar(10),ts.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', Dato Test. '+isnull(ts.codeleme,'')+'" ' 
                                               else ''
                                          end     
                                       +' style="border:solid 0px #d0d;width:auto;text-align:right;'+case when ts.validacion is not null then ';background:#a00' else '' end+ts.display+'">'+isnull(t.dato_posterior,'')+'</td>' 
                                     +'</td>'
                                     +'</tr>'
                                     +'</table>'
                                 +'</td>'
                       end
             when 'NN' then 
                            case when t.tipo_dato_precedente='TN' then '' -- Ya lo ha pintado cuando es un TN
                                 when t.porcen=0                  then ''
                                 else '<td '
                                          +case when ts.tipeleme is null then ''
                                                when ts.tipeleme='0' then ' class="e'+isnull(ts.tipeleme_elemento,'')+'"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Párr.: '+isnull(ts.codparra,'')+', El.Cab(NN). '+isnull(ts.codeleme,'')+'['+isnull(ts.tipeleme_elemento,'')+']" ' 
                                                when ts.tipeleme='1' then ' class="litnormal"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', El.Taorpali '+isnull(ts.codeleme,'')+'" '
                                                when ts.tipeleme='4' then ' class="espejo"   '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', Espejo '+isnull((select top 1 substring(rtrim(deslitel),2,5) from #taorpali with (index (IDX_taorpali_1)) where codparra=ts.codparra and codlitel=ts.codeleme),'')+'" ' 
                                                when ts.tipeleme='5' then ' class="cabecera" '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', Dato Inf. '+isnull(ts.codeleme,'')+'" ' 
                                                when ts.tipeleme='6' then ' class="testigo"  '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(ts.codparra,'')+', Dato Test. '+isnull(ts.codeleme,'')+'" ' 
                                                else ''
                                           end     
                                         +' style="border:solid 0px #d00;width:'+isnull(dbo.f_FMHDI(t.porcen,2),'0')+'%;text-align:right;'+case when ts.validacion is not null then ';background:#a00' else '' end+ts.display+'">'
                                           +isnull(t.dato,'')
                                      +'</td>'
                            end
             when 'NT' then 
                            case when t.tipo_dato_precedente='TN' then '' -- Ya lo ha pintado cuando es un TN
                                 when t.porcen=0                  then ''
                                 else '<td '
                                    +case when t.tipeleme='0' then ' class="e'+isnull(t.tipeleme_elemento,'')+'"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Párr.: '+isnull(t.codparra,'')+', El.Cab(TT). '+isnull(t.codeleme,'')+'['+isnull(t.tipeleme_elemento,'')+']" ' 
                                          when t.tipeleme='1' then ' class="litnormal"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', El.Taorpali '+isnull(t.codeleme,'')+'" '
                                          when t.tipeleme='4' then ' class="espejo"   '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Espejo '+isnull((select top 1 substring(rtrim(deslitel),2,5) from #taorpali with (index (IDX_taorpali_1)) where codparra=t.codparra and codlitel=t.codeleme),'')+'" ' 
                                          when t.tipeleme='5' then ' class="cabecera" '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Dato Inf. '+isnull(t.codeleme,'')+'" ' 
                                          when t.tipeleme='6' then ' class="testigo"  '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Dato Test. '+isnull(t.codeleme,'')+'" ' 
                                          else ''
                                     end     
                                  +' style="border:solid 0px #d00;width:'+isnull(dbo.f_FMHDI(t.porcen,2),'0')+'%;text-align:right;'+case when t.validacion is not null then ';background:#a00' else '' end+t.display+'">'
                                  +isnull(t.dato,'')
                                +'</td>'
                            end
             when 'TT' then 
                            case when t.porcen=0 then ''
                                 else '<td '
                                           +case when t.tipeleme='0' then ' class="e'+isnull(t.tipeleme_elemento,'')+'"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Párr.: '+isnull(t.codparra,'')+', El.Cab(TT). '+isnull(t.codeleme,'')+'['+isnull(t.tipeleme_elemento,'')+']" ' 
                                                 when t.tipeleme='1' then ' class="litnormal"'+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', El.Taorpali '+isnull(t.codeleme,'')+'" '
                                                 when t.tipeleme='4' then ' class="espejo"   '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Espejo '+isnull((select top 1 substring(rtrim(deslitel),2,5) from #taorpali with (index (IDX_taorpali_1)) where codparra=t.codparra and codlitel=t.codeleme),'')+'" ' 
                                                 when t.tipeleme='5' then ' class="cabecera" '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Dato Inf. '+isnull(t.codeleme,'')+'" ' 
                                                 when t.tipeleme='6' then ' class="testigo"  '+' title="FilEle:'+convert(varchar(10),t.fileleme)+',ColEle:'+convert(varchar(10),t.coleleme)+',Pár.: '+isnull(t.codparra,'')+', Dato Test. '+isnull(t.codeleme,'')+'" ' 
                                                 else ''
                                            end     
                                         +' style="border:solid 0px #d00;width:'+isnull(dbo.f_FMHDI(t.porcen,2),'0')+'%;text-align:left;'+case when t.validacion is not null then ';background:#a00' else '' end+t.display+'">'
                                         +isnull(t.dato,'')
                                       +'</td>'
                            end

             else '<td style="border:solid 5px #d00;width:'+isnull(dbo.f_FMHDI(t.porcen,2),'0')+'%;text-align:right;"></td>'
        end      
       +case when t.es_ultimo=1 then 
              '<td style="border:solid 0px #0f0;width:auto;"></td>'
             +'</tr></table>' 
            else '' 
       end -- cierre de tabla
    from #taorpael t with(index(IDX_taorpael_1))
    left outer join #taoeleme  e on e.codeleme=t.codeleme and t.tipeleme='0'
    left outer join #taorpael ts with(index(IDX_taorpael_1)) on ts.id=t.id+1
    set @paso='Adecuar campo HTML por párrafo' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait


    if @debug=1
       begin
          select * 
          from #taorpael t 
          where t.formato='1' 
            and t.codparra in ('29214')
            and t.fileleme=1
          order by t.id
      end

    --------------------------------
    -- select t.fileleme, t.coleleme, t.ancho, t.ancho_agregado,  t.tipo_dato+t.tipo_dato_posterior [combi], t.porcen, t.dato, t.html from #taorpael t where t.codparra in ('32109','29189')
    ------------------------------------

  ---------
  -- HTML
  ---------

  declare @html varchar(max)=''

  declare @Clave_Html varchar(60)
      set @Clave_Html=convert(varchar(60), newid())

  declare @font_familiy varchar(100)='Arial'
  declare @font_size    varchar(100)='0.70vw'  
  declare @font         varchar(100)='font-family:'+@font_familiy+'; font-size:'+@font_size+';'
  declare @bgc          varchar(100)='' -- ';background-color: #EEEEEE'
  declare @fc           varchar(100)='color:#05F;'
  
  /*
   Estructura de variables @html
    
      @html_head_inicial
      @html_text_css
      @html_text_javascript
      @html_head_final
      @html_body_inicial
        @html_tabla_inicial
           @html_celda_informe_inicial
             @html_div_cabecera
             @html_div_informe_inicial
               @html_informe
             @html_div_informe_final
           @html_celda_graficos
        @html_tabla_final
      @html_body_final

  */

  declare @html_head_inicial varchar(max)=''
      --+'<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
      --+'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">'
      --+'<head>'
      --+'<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'
      --+'<title>Informe TH</title>'


  declare @html_text_css varchar(max)=''
      +' <style type="text/css">'
      +' <!--'
  --  +' div.postit {border: 0px solid #fff;background-color:#fff;color:#fff;text-align:left;padding:0px;z-index:1;filter:alpha(opacity=65);float:left;}'
  --  +' textarea.nota {background-color:#555;color:#fff;border:none;font-family:'+@font_familiy+';font-size:10pt; font-weight:normal; text-decoration:normal;}'

  set @html_text_css+=
   ' hr '
  +'{ border: 0;'
  +'  height: 1px;'
  +'  background: #333;'
  +'  background-image: -webkit-linear-gradient(left, #ccc, #333, #ccc);'
  +'  background-image:    -moz-linear-gradient(left, #ccc, #333, #ccc);'
  +'  background-image:     -ms-linear-gradient(left, #ccc, #333, #ccc);'
  +'  background-image:      -o-linear-gradient(left, #ccc, #333, #ccc);'
  +'}'

  set @html_text_css+=
   ' div.ca      {border:1px solid #aaa;display:;background-color:#fff;text-align:left}'
  +' div.pv      {border:0px solid #fff;display:;background-color:#fff;}'
  +' div.ph      {border:0px solid #fff;display:;background-color:#fee;}'
  +' div.gr      {border:0px solid #fff;display:;background-color:#fff;text-align:center}'

  +' a.br        {color:#000;font-family:'+@font_familiy+';font-size:0.4vw;}'
  +' a.titulo    {color:#000;font-family:'+@font_familiy+';font-size:1.5vw;font-weight:bold;text-decoration:normal;    padding:15px;}'
  +' a.apartado  {color:#000;font-family:'+@font_familiy+';font-size:1.1vw;font-weight:bold;text-decoration:underline; padding:15px;}'
  +' a.cabparra  {color:#000;font-family:'+@font_familiy+';font-size:0.8vw;font-weight:bold;text-decoration:underline; padding:15px;}'
  
  +' a.insertado {color:#90D;font-family:'+@font_familiy+';font-size:0.7vw;}'
  
  +' a.litnormal {color:#000;'+@font+';padding-right:3px;}'
  +' a.e00       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.e01       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.e02       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.e03       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.e04       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.e09       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.e19       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;color:#d00;}'
  +' a.e20       {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;color:#0aa;}'
  +' a.espejo    {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;}'
  +' a.cabecera  {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;color:#0a0;font-weight:bold;}'
  +' a.testigo   {'+ @fc+@bgc+@font+';padding-left:0px;padding-right:3px;color:#a00;}'
  +' a.e01t      {color:#800;font-family:'+@font_familiy+';font-size:0.8vw;font-weight:bold;}'
  +' a.e01v      {color:#080;font-family:'+@font_familiy+';font-size:0.8vw;font-weight:bold;}'

  +' td.litnormal {color:#000;'+@font+';padding-top:3px;}'
  +' td.e00       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e01       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e02       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e03       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e04       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e09       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e19       {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.e20       {'+ @fc+@bgc+@font+';color:#0aa;padding-top:3px;}'
  +' td.espejo    {'+ @fc+@bgc+@font+';padding-top:3px;}'
  +' td.cabecera  {'+ @fc+@bgc+@font+';color:#0a0;font-weight:bold;padding-top:3px;}'
  +' td.testigo   {'+ @fc+@bgc+@font+';color:#a00;padding-top:3px;}'
  +' td.e01t      {color:#800;font-weight:bold;padding-top:3px;}'
  +' td.e01v      {color:#080;font-weight:bold;padding-top:3px;}'
  +' td.inipt     {font-size:0.5vw;font-family:Times New Roman;color:#0aa;}'
  +' th.titucv    {font-size:0.6vw;text-align:center;}'
    
  +' table.par   {border-collapse:collapse;font-family:'+@font_familiy+';font-size:'+@font_size+'; padding:0px; text-align:justify; width:'+@pix+'}'
  +' table.tit   {border-collapse:collapse;font-family:'+@font_familiy+';font-size:'+@font_size+'; padding:0px; text-align:justify; width:'+@pix+'}'
  +' td.jus      {font-family:'+@font_familiy+';font-size:'+@font_size+';text-align:justify;padding-top:6px;}'

  +' tr.divc th  {color:#00a;border:solid 1px #aaa; padding:2px;font-family:'+@font_familiy+'; font-size:0.7vw;text-align:center;background:#eee;}'
  +' tr.divs td  {color:#0a0;border:solid 1px #aaa; padding:2px;font-family:'+@font_familiy+'; font-size:0.7vw;font-weight:normal}'
  +' tr.divt td  {color:#a00;border:solid 1px #aaa; padding:2px;font-family:'+@font_familiy+'; font-size:0.7vw;font-weight:normal}'
  +' tr.divd td  {color:#000;border:solid 1px #aaa; padding:2px;font-family:'+@font_familiy+'; font-size:0.7vw;font-weight:normal}'

  +' a.siguelinea {'+@font+'}'
  +' H1.SaltoDePagina {PAGE-break-AFTER: always}'
  +'-->'
  +'</style>'


  declare @html_text_javascript varchar(max)=''
  +'<script type="text/JavaScript">'
  +'<!--                           '
  +'//-->'
  +'</script>'


  set @paso='Montar Cabecera de HTML' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  --------------------------------------------
  
  declare @html_head_final            varchar(1000)=''--'</head>'
  declare @html_body_inicial          varchar(1000)=''--'<body style="display:inline-block;font-family:'+@font_familiy+';text-align:center;border:solid 0px;">'
  declare @html_tabla_inicial         varchar(1000)=''--'<table style="width:100%;height:98%;"><tr>'
  declare @html_celda_informe_inicial varchar(1000)=''--'<td style="width:920px;">'
                
  -------------
  -- Cabecera
  -------------

  declare @html_div_cabecera varchar(max)=''
       +'<div id="cabecera" class="ca" style="width:100%;height:5%;overflow:auto;border:solid 0px #a00;" >' 
        +'<table style=";border:solid 0px #eee;border-collapse:collapse;width:100%;text-align:left;">'
        +'<tr>'
           +'<td style="width:auto;border:solid 0px #eee;text-align:center;font-family:'+@font_familiy+';font-size:5vw;font-weight:bold;">'
              +'<a class="titulo">Informe Nº '+@numinfor+' datos al '+dbo.fFecha_Hora(getdate())+'</a>' 
           +'</td>'               
           +'<td style="width:10%;">'
           +' <a id="aNI"'
                +' style="cursor:pointer;" '
                +' title="Ver Imprimibles o no" '
                +' onclick="'+
                    +' var d=document.getElementsByClassName(''ph'');'
                    +' var t=this;'
                    +' for (var i=0; i<d.length; i++) {if (d[i].style.display==''none'') {d[i].style.display=''''} else {d[i].style.display=''none''} }'
                    +' if (t.innerHTML==''Ocultar NO Imprimibles'') {t.innerHTML=''Ver NO Imprimibles''} else {t.innerHTML=''Ocultar NO Imprimibles''}'
                +'"'
           +'>Ver NO Imprimibles</a>'
           +'</td>'               
           +'<td style="width:10%;">'
           +' <img alt="X" '
                +' style="cursor:pointer;" '
                +' src="data:image/png;base64,'+dbo.f_Parametro_SISTEMA ('ico_pdf')+'" '
                +' title="Generación PDF" '
                +' onclick="WPDF_General_Procedimiento('''+@prbbdd+''',''PDF_GENERAL_'+@prbbdd+''');"'
           +' /><br/><a id="PDF_GENERAL_'+@prbbdd+'"></a>'
           +'</td>'               
        +'</tr>'
        +'</table>'
       +'</div>'

  set @paso='set @html_div_cabecera' set @mess=@paso raiserror(@mess,10,1,0) with nowait

  declare @html_div_informe_inicial varchar(max)='<div style="float:left;border:solid 0px #aaa;padding:5px;width:50vw;height:90%;overflow:auto;">'
  declare @html_informe varchar(max)=''
    
  -------------------------------------------------------------
  -- Trabajar con los distintos Parrafos a través de un cursor
  -------------------------------------------------------------

  declare @cabparra    varchar(150)
         ,@cabapart    varchar(150)
         ,@oldposapart varchar(4)
         ,@posapart    varchar(10)
         ,@codapart    varchar(10)
         ,@posparra    varchar(10)
         ,@codparra    varchar(10)
         ,@modparra    varchar(4)
         ,@titulo      varchar(100)
         ,@tp          varchar(1)
         ,@fp          varchar(1)
         ,@su          varchar(1)
         ,@condicion   varchar(1000)
         ,@fondo       varchar(10)

  declare @titulo_largo varchar(max)
  declare @apartado_visible bit

  ----------------------------------------------------------------

  set @paso='Inicio cursor_Parrafos ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  create table #cuadro (orden varchar(100), dato varchar(7880))

  declare @numapartado int=0  
  declare @numparrafo  int=0  

  set @oldposapart='XXX'

  declare cursor_Parrafos cursor for
  select 
      i.posapart                                                             [@posapart]
     ,i.codapart                                                             [@codapart]
     ,i.posparra                                                             [@posparra]
     ,i.codparra                                                             [@codparra]
     ,i.modparra                                                             [@modparra]
     ,case when isnull(i.cabparra,'') ='' then '' else rtrim(i.cabparra) end [@titulo]
     ,case when i.nivestru='0' then 'C' else 'D' end                         [@tp]
     ,case when i.formato ='0' then 'N' else 'T' end                         [@fp]
     ,isnull(i.supresio,'1')                                                 [@su]
  from #taoinfor i with (index(IDX_taoinfor_3))
  where i.modparra in ('2','0','9')
  order by i.posapart, i.posparra
  open cursor_Parrafos

  fetch next from cursor_Parrafos into @posapart,@codapart,@posparra,@codparra,@modparra,@titulo,@tp,@fp,@su

  while @@fetch_status=0

        begin

            set @paso='Inicio Párrafo '+@codparra+'' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

            -----------------------------------------------
            -- Titulo Largo Incrustado en Título de Párrafo
            -----------------------------------------------
           
            set @titulo_largo=null
            if charindex('&&TITULO_LARGO&&',@titulo)>0       -- Hay que añadir el titulo Largo al final del Parrafo
               begin
                 set @titulo_largo=(select titulo from CORITEL.dbo.taoinfor_tit_apartados (nolock) where numinfor=@numinfor and codapart='TITLA')
               end

            ------------------------------------------
            -- Cambio de Apartado -> Titular Apartado
            ------------------------------------------

            if @oldposapart!=@posapart
               begin

                 -------------------------------------------------------------
                 -- Verificar si dentro del apartado existen parrafos visibles
                 -------------------------------------------------------------
                
                 set @apartado_visible=0
                 if exists(select *
                           from #taoinfor i  with (index(IDX_taoinfor_2))
                           inner join CORITEL.dbo.taorappa a (nolock) on a.codapart=i.codapart and a.codparra=i.codparra
                           where  i.codapart=@codapart
                              and i.modparra in ('0','9')
                              and isnull(a.supresio,'1')!='3'
                           )      -- No aparecen los no imprimibles
                    begin
                       set @apartado_visible=1
                    end

                 set @numapartado+=case when @apartado_visible=1 then 1 else 0 end
                 set @numparrafo=0

                 -----------------------------------------------
                 -- Quitar las marcas del parrafo por si existen
                 -----------------------------------------------

                 select @cabapart=rtrim(isnull(cabapart,'')) from CORITEL.dbo.taoapart (nolock) where codapart=@codapart
                 while charindex('&&',@cabapart)>0 set @cabapart=substring(@cabapart, 1, charindex('&&',@cabapart)-1)+substring(@cabapart, charindex('&&',@cabapart, charindex('&&',@cabapart)+2)+ 2, 1500)
                 set @cabapart=ltrim(rtrim(@cabapart))

                 if @cabapart!='' 
                    begin               
                       set @html_informe+=
                           '<div id="apartado_'+@codapart+'"'
                              +' class="'+case when @apartado_visible=1 then 'pv' else 'ph' end+'" '
                              +' style="'+case when @apartado_visible=1 then '' else 'display:none;' end+'" '
                              +'>'
                              +'<table class="tit" style="border:solid 0px #000;width:100%;margin:auto">'
                                +'<tr>'
                                 +'<td class="jus" style="padding:10px;width:100%">'
                                    +'<a class="apartado">'+case when @apartado_visible=1 then convert(varchar(10),@numapartado)+'. ' else '' end+@cabapart+'</a>'
                                 +'</td>'
                                +'</tr>'     
                              +'</table>' 
                          +'</div>'
                    end
                 set @oldposapart=@posapart
               end

            -------------------------------------------------------------------
            -------------------------------------------------------------------

            set @html_informe+=
                  '<!--- Inicio Parrafo ----->'           
                 +'<div id="parrafo_'+@codparra+'"'
                    +' class="'+case when @su='3' or @modparra='2' then 'ph' else 'pv' end+'"'
                    +' style="'+case when @modparra='2' then 'color:#aaa;text-decoration:line-through;' else '' end+''
                               +case when @su='3' or @modparra='2' then ';display:none;' else '' end
                               +';border:solid 0px #000;'
                 +'">'

            -------------------------------------------------------------------

            -----------------------
            -- Título del parrafo
            -----------------------

            set @cabparra= 
                case when @modparra='9'   -- Párrafo Insertado
                     then (select top 1 rtrim(isnull(cabinser,'')) from CORITEL.dbo.taorinin (nolock) where numinfor=@numinfor and codinser=@codparra and rtrim(isnull(cabinser,''))!='')
                     else @titulo
                end
            while charindex('&&',@cabparra)>0 set @cabparra=substring(@cabparra, 1, charindex('&&',@cabparra)-1)+substring(@cabparra, charindex('&&',@cabparra, charindex('&&',@cabparra)+2)+ 2, 500)
            set @cabparra=ltrim(rtrim(@cabparra))

            if @cabparra!='' 
                begin           
                 set @numparrafo+=1
                 set @html_informe+=
                     '<table class="tit" style="border:solid 0px #000;width:100%;margin:auto">'
                      +'<tr>'
                       +'<td class="jus" valign="middle" style="padding:10px;width:100%">'
                          +'<a class="cabparra" title="Cód.Párr.: '+@codparra+'">'+convert(varchar(10),@numapartado)+'.'+convert(varchar(10),@numparrafo)+'. '+@cabparra+'</a>'
                       +'</td>'
                      +'</tr>'   
                    +'</table>'
                end

            if @titulo_largo is not null
               begin
                 set @html_informe+=
                    '<table class="par" style="border:solid 0px #000;width:100%;margin:auto" >'
                    +'<tr>' 
                     +'<td class="jus" valign="middle" style="padding:10px;width:100%">'
                      +'<a class="cabecera" title="Pár: '+@codparra+', Titulo Largo">'+isnull(@titulo_largo,'')+'</a>'
                     +'</td>'                                
                    +'</tr>'
                   +'</table>'
               end

            ------------------------------------------------------------
            ------------------------------------------------------------
            ------------------------------------------------------------

            if @modparra='9'   -- Párrafo Insertado
               begin
                      --set @paso='....Inicio Parrafo Insertado '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    
                      -----------------------------------
                      -- Cuerpo del párrafo Insertado
                      -----------------------------------
                      set @html_informe+=
                                +'<table><tr style="height:10px;"><td></td></tr></table>'
                                +'<table class="par" style="border:solid 0px #d0d;width:100%;margin:auto" >'
                                    +'<tr>'
                                     +'<td class="jus" valign="middle" style="width:100%;" >'
                                      +'<a class="insertado">' 
                      select @html_informe+=isnull(replace(rtrim(CORITEL.dbo.fValor_Desinser_taorinin(i.desinser)),char(13)+char(10),'<br>'),'')
                      from CORITEL.dbo.taorinin i (nolock)
                      where i.numinfor=@numinfor 
                        and i.codinser=@codparra 
                      order by i.ordinser
                      set @html_informe+=       '</a>'
                                    +'</td>'
                                  +'</tr>'
                               +'</table>'                                
                               +'<table><tr style="height:10px;"><td></td></tr></table>'
                      --set @paso='....Fin Parrafo Insertado '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    
               end

            ------------------------------------------------------------
            ------------------------------------------------------------
            ------------------------------------------------------------

            else if @tp='D' and @modparra in ('0','2')  -- Párrafo de Detalle
               begin

                  set @paso='....Inicio párrafo Detalle '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                  declare @comando_subto varchar(max) 
                  declare @comando_total varchar(max) 

                  ------------
                  -- Cabeceras
                  ------------
                  set @html_informe+=
                          +'<table><tr style="height:10px;"><td></td></tr></table>'
                          +'<table style="border-collapse:collapse;border:solid 0px #a00;width:100%;margin:auto;" >'
                             +'<tr class="divc" style="background:#ddd;">'
                               +'<th style="width:2vw;" title="Pár:'+@codparra+'" >Finca</td>'
                               +'<th style="width:2.5vw;">Unidad</td>'
                  
                  select @html_informe+=
                          '<th title="Cód.Ele. '+r.codeleme+'">'
                            +rtrim(replace(replace(replace(replace(replace(litecabe,'"','&#34;'),'>','&gt;'),'<','&lt:'),'_',' '),' ',' '))
                          +'</th>'
                  from #th_rpacu r (nolock)
                  where r.codparra=@codparra 
                    and exists (select * from #val with(index(IDX_val)) where codeleme=r.codeleme and tipoparrafo='D' and codvalor='S' )
                    and case when r.codeleme='03869' then 'S' else r.cdivi end!='N'
                  order by r.colparra
                  set @html_informe+='</tr>'
                  set @paso='........Línea de Títulos ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                  ----------
                  -- Datos
                  ----------
          
                  delete #cuadro                
                  
                  declare @comando_gener AS varchar(8000) 
                  
                  set @comando_gener='insert into #cuadro '+@crlf
                                   +' select [o], [c]'+@crlf
                                   +' from ('+@crlf

                  declare @codeleme_div varchar(25)
                         ,@subtoele_div varchar(25)
                         ,@totalele_div varchar(25)
                         ,@totalizar    varchar(1)='N'

                  if exists(select * from #th_rpacu r where r.codparra=@codparra and r.totalele='1')
                     begin
                        set @totalizar='S'
                     end

                  declare @comando_datos varchar(max) 
                  set @comando_datos='select rtrim(d.uniagrup)+''0''+d.elemunid [o]'
                                          +',''<tr class="divd" align="left">'''
                                             +'+case when exists(select * from #detalle x where x.uniagrup=d.uniagrup and x.elemunid<d.elemunid) '
                                                  +' then ''<td> </td><td> </td>'''
                                                  +' else ''<td><b>''+rtrim(d.uniagrup)+''</td><td>''+rtrim(d.elemunid)+''</b></td>'''
                                             +' end +'+@crlf

                  
                  set @comando_subto=''
                  if @totalizar='S' 
                     begin
                        set @comando_subto='UNION select rtrim(d.uniagrup)+''1'' [o], ''<tr class="divs" align="left"><td> </td><td>Subtotal</td>''+'+@crlf 
                     end

                  set @comando_total=''
                  if @totalizar='S' 
                     begin
                        set @comando_total='UNION select char(255) o, ''<tr class="divt" align="left"><td>Total</td><td> </td>''+'+@crlf 
                     end

                  set @paso='........Inicio elementos '; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    
                  declare tcursor_th_rpacu cursor for        -- Recorrido del thrpacu por cursor
                  select r.codeleme
                        ,r.subtoele
                        ,r.totalele 
                  from #th_rpacu r
                  where r.codparra=@codparra 
                    and exists (select * from #val with(index(IDX_val)) where codeleme=r.codeleme and tipoparrafo='D' and codvalor='S' )
                    and case when r.codeleme='03869' then 'S' else r.cdivi end not in ('N')
                  order by colparra
                  open tcursor_th_rpacu
                  fetch next from tcursor_th_rpacu into @codeleme_div, @subtoele_div, @totalele_div
                  
                  declare @tipo_elemento varchar(10)

                  while @@fetch_status=0      	
                        begin
                         
                           set @paso='...........elemento '+@codeleme_div set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                           set @tipo_elemento=null
                           select @tipo_elemento=tipeleme from #taoeleme where codeleme=@codeleme_div

                           if @tipo_elemento in ('01')
                               begin
                                  set @comando_datos+='''<td>''+isnull((select top 1 rv.desvalor from #taorelva rv where rv.codeleme='''+@codeleme_div+''' and rv.codvalor=ELE'+@codeleme_div+'),'''')+''</td>''+'+@crlf
                                  if @totalizar='S'  set @comando_subto+='''<td>&nbsp;</td>''+'+@crlf
                                  if @totalizar='S'  set @comando_total+='''<td>&nbsp;</td>''+'+@crlf
                               end
                           else if @tipo_elemento in ('00', '02', '09')
                               begin 
                                 set @comando_datos+='''<td align="right">''+ETHER.dbo.fFormato_Money_HTML_Decimales(isnull(ELE'+@codeleme_div+',0),2)+''</td>''+'+@crlf
                                 if @subtoele_div='1'
                                    set @comando_subto+='''<td align="right">''+ETHER.dbo.fFormato_Money_HTML_Decimales(sum(isnull(ELE'+@codeleme_div+',0)),2)+''</td>''+'+@crlf
                                  else
                                    if @totalizar='S' set @comando_subto+='''<td>&nbsp;</td>''+'+@crlf
 
                                 if @totalele_div='1'
                                    set @comando_total+='''<td align="right">&nbsp;''+ETHER.dbo.fFormato_Money_HTML_Decimales(sum(isnull(ELE'+@codeleme_div+',0)),2)+''</td>''+'+@crlf
                                  else
                                    if @totalizar='S' set @comando_total+='''<td>&nbsp;</td>''+'+@crlf
                               end 
                           else if @tipo_elemento in ('04')
                               begin
                                  set @comando_datos=@comando_datos+'''<td>''+convert(varchar(10),isnull(ELE'+@codeleme_div+',''''), 103)+''</td>''+'+@crlf
                                  if @totalizar='S' set @comando_subto+='''<td> </td>''+'+@crlf
                                  if @totalizar='S' set @comando_total+='''<td> </td>''+'+@crlf
                               end
                           else if @tipo_elemento in ('03')
                               begin 
                                  set @comando_datos+='''<td>''+rtrim(isnull(ELE'+@codeleme_div+',''''))+''&nbsp;</td>''+'+@crlf
                                  if @totalizar='S' set @comando_subto+='''<td>&nbsp;</td>''+'+@crlf
                                  if @totalizar='S' set @comando_total+='''<td>&nbsp;</td>''+'+@crlf
                               end 
                          ---------------------------------------------------------------------------------
                          fetch next from tcursor_th_rpacu into @codeleme_div, @subtoele_div, @totalele_div

                        end

                  close      tcursor_th_rpacu
                  deallocate tcursor_th_rpacu
                  set @paso='........Fin elementos '; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                  ------------------------------

                  set @comando_datos+='''   </tr>'' [c] '+char(10)+'from #detalle e '+@leftd+' '+@crlf
                  if @totalizar='S' 
                     begin
                        set @comando_subto+='''   </tr>'' [c]'+char(10)+' from #detalle e '+@leftd+' where (select count(*) from #detalle x where x.uniagrup=d.uniagrup)>1 group by d.uniagrup'+@crlf
                     end

                  if @totalizar='S' 
                     begin
                        set @comando_total+='''   </tr>'' [c]'+char(10)+' from #detalle e'+@leftd+' '+@crlf
                     end

                  set @comando_gener+=@comando_datos
                                     +@comando_subto
                                     +@comando_total
                                     +') A order by [o]'+@crlf
                  set @paso='........montaje @comando_datos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    
                  --print @comando_gener
                  exec (@comando_gener)
                  set @paso='........exec @comando_datos' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                  select @html_informe+=replace(dato,char(255),'') from #cuadro order by orden
                  
                  set @html_informe+='</td>'
                            +'</tr>'
                            +'</table>'
                            +'<table><tr style="height:10px;"><td></td></tr></table>'
                 --------------------------------------------------------------- 

                 set @paso='....Fin Parrafo Detalle '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

               end

            -- -------------------------------------------------------------------------
            -- -------------------------------------------------------------------------

            else if @tp='C' and @fp='T' and @modparra in ('0','2') -- Párrafo de Cabecera y Tabulado (va posicionado el Elemento)

               begin
                 -------------

                 --set @paso='....Inicio Parrafo Cabecera Tabulado '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                 select @html_informe+=isnull(t.html,'') 
                 from #taorpael t with(index(IDX_taorpael_2))
                 where codparra=@codparra 
                 order by t.fileleme, t.coleleme

                 /*
                 declare @html_informe_sub varchar(max)
                 declare c cursor for 
                 select isnull(t.html,'') 
                 from #taorpael t 
                 where codparra=@codparra 
                 order by t.fileleme, t.coleleme
                 open c
                 fetch next from c into @html_informe_sub
                 while @@fetch_status=0
                    begin
                        set @html_informe+=@html_informe_sub
                        fetch next from c into @html_informe_sub
                    end
                 close c 
                 deallocate c
                 */
                 --set @paso='....Fin Parrafo Cabecera Tabulado '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                 -------------
               end
            -------------------------------------------------------------------
            -------------------------------------------------------------------

            if @tp='C' and @fp='N' and @modparra in ('0','2') -- Párrafo de Cabecera y no tabulado
               begin
                 
                 --set @paso='....Inicio Parrafo Cabecera NO Tabulado '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

                 ----------------------------------------------------------------
                 -- Verificar si el párrafo sólo tiene elementos de tipeleme='0'
                 ----------------------------------------------------------------
                 
                 set @html_informe+=
                    '<table class="par" style="border:solid 0px #0d0;width:100%;margin:auto" >'
                    +'<tr>' 
                     +'<td class="jus" valign="middle" style="width:100%">'
                    
                 ---------------------------- 
                 -- Introduccion de los Datos
                 ----------------------------
                    
                 declare @lInsertar varchar (1)
                 declare @ce   varchar (5)
                 declare @te   varchar (1)
                 declare @fi   decimal (19,0)
                 declare @co   decimal (19,0)
                 declare @bold varchar (10)
                 declare @ital varchar (10)
                 declare @subr varchar (10)

                 declare @cbold varchar (10)
                 declare @cital varchar (10)
                 declare @csubr varchar (10)

                 declare @fi_ant      decimal (19,0)     -- Fila Anterior
                 declare @texto_fila  varchar(max)       -- Texto de la Fila
                 declare @lSigueLinea varchar (1)        -- Para saber si existe sigue Línea
                 declare @display     varchar(100)

                 declare cursor_Taorpael cursor for      -- Recorrido del Taorpael por cursor
                 select codeleme     ce
                       ,tipeleme     te
                       ,fileleme     fi
                       ,coleleme-375 co
                       ,case when substring(leteleme,1,1)='1' then '<b>' else '' end bold
                       ,case when substring(leteleme,2,1)='1' then '<i>' else '' end ital
                       ,case when substring(leteleme,3,1)='1' then '<u>' else '' end subr
                 from #taorpael_general p with (index (IDX_taorpael_general_codparra))
                 where p.codparra=@codparra
                   and case when exists (select * 
                                         from #taorpael_general px with (index (IDX_taorpael_general_codparra))
                                         where px.codparra=p.codparra 
                                           and px.fileleme=p.fileleme 
                                           and px.tipeleme not in ('0'))  -- tiene elementos distintos '0'
                            then 1  
                            else case when exists (select * from #val v with(index(IDX_val)) 
                                                   where v.codeleme in (select codeleme 
                                                                        from #taorpael_general px with (index (IDX_taorpael_general_codparra))
                                                                        where px.codparra=p.codparra 
                                                                          and px.fileleme=p.fileleme
                                                                          and px.tipeleme in ('0')
                                                                        )
                                                      and ltrim(rtrim(isnull(v.valor,'')))!='') 
                                      then 1
                                      else 0
                                 end
                       end=1
                 order by codparra, fileleme, coleleme
                 open cursor_Taorpael
                 fetch next from cursor_Taorpael into @ce,@te,@fi,@co,@bold,@ital,@subr

                 set @fi_ant=@fi      -- Iniciar en la misma fila
                 set @texto_fila=''   -- Vaciar el Texto de la Fila

                 while @@fetch_status=0      	
                       begin

                         set @lInsertar='S'  -- Iniciar como insercion
                         set @display  =''   -- Iniciar el display
                         set @display=case when exists(select * 
                                                       from #taorpael_formato tf with(nolock) 
                                                       where tf.codparra    =@codparra
                                                         and tf.codeleme    =@ce 
                                                         and tf.tipoElemento=@te 
                                                         and tf.imprimible  =0) 
                                           then ';background:#aa0;' 
                                           else '' 
                                      end

                         -- -----------------------------------
                         -- Establecer el formato del texto
                         -- -----------------------------------

                         set @cbold=replace(@bold, '<b>', '</b>')
                         set @cital=replace(@ital, '<i>', '</i>')
                         set @csubr=replace(@subr, '<u>', '</u>')

                         ----------------------------
                         -- Meter los Saltos de Carro
                         ----------------------------

                         if @lSigueLinea='S'
                            begin
                                set @lInsertar='N'
                                set @lSigueLinea='N'
                                set @fi_ant=@fi
                            end
                         -- -----------------------------------

                         if @te<>'3'  -- SI NO ES sigue Linea realizar los saltos de linea necesarios
                            begin
                              if @fi_ant=@fi           -- Son Elementos que están en la misma línea -> se concatenan
                                 begin
                                    set @lInsertar='N'
                                 end
                                 
                              while @fi_ant<@fi
                                    begin
                                      set @html_informe+='<br>'
                                      set @fi_ant+=1
                                    end
                            end

                         -- -----------------------------------

                         if @te='0'  -- Es un Codigo de Elemento
                            begin
                              declare @tip_ele varchar(2)
                              select @tip_ele=e.tipeleme from #taoeleme e where e.codeleme=@ce
                              set @html_informe+=
                                  '<a class="e'+@tip_ele+'" '
                                    +'style="'+case when exists (select vt.validacion [a] from #validaciones vt where vt.codeleme=@ce) then ';background:#a00;' else '' end
                                    +@display+'"'
                                    +' title="Pár: '+@codparra+', El.Cab. '+@ce+'['+@tip_ele+']"'
                                  +'>'
                                   +@bold+@ital+@subr
                                   +isnull((select top 1 valor from #val with(index(IDX_val)) where codeleme=@ce and tipelemepar='0'),'')
                                   +@cbold+@cital+@csubr
                                 +'</a>'
                            end

                         -- -----------------------------------

                         if @te='1'  -- Es un Literal -> buscar en taorpali
                            set @html_informe+=
                                '<a class="litnormal" '
                                 +' style="'+@display+'"'
                                 +' title="Pár: '+@codparra+', El.Taorpali '+@ce+'"'
                                +'>'
                                 +@bold+@ital+@subr
                                 +isnull((select top 1 rtrim(deslitel) from #taorpali with (index (IDX_taorpali_1)) where codparra=@codparra and codlitel=@ce),'')
                                 +@cbold+@cital+@csubr
                               +'</a>'
                            
                         -- -----------------------------------

                         if @te='3'  -- Es un sigue Linea
                            begin
                              set @lSigueLinea='S'
                              set @html_informe+='<a class="siguelinea"></a>'
                            end

                         -- -----------------------------------

                         if @te='4'  -- Es un Espejo
                            begin
                               declare @cod_espejado varchar(10)
                               set @cod_espejado=(select top 1 substring(rtrim(deslitel),2,5) from #taorpali with (index (IDX_taorpali_1)) where codparra=@codparra and codlitel=@ce)
                               set @html_informe+=
                                   '<a class="espejo"'
                                    +' style="'+case when exists (select vt.validacion [a] from #validaciones vt where vt.codeleme=@cod_espejado) then ';background:#a00;' else '' end
                                              +@display+'"'
                                    +' title="Párrafo : '+@codparra+', Espejo de '+@cod_espejado+'"'
                                    +'>'
                                  +@bold+@ital+@subr+''
                                  +isnull((select top 1 valor from #val with(index(IDX_val)) where codeleme=@cod_espejado and tipelemepar='0'),'')
                                  +@cbold+@cital+@csubr
                                  +'</a>'
                            end
                         -- -----------------------------------
                         
                         if @te='5'  -- Es un dato de la Definición del Informe
                            set @html_informe+=
                                '<a class="cabecera"'
                                 +' style="'+@display+'"'
                                 +' title="Párrafo : '+@codparra+', Dato Inf. '+@ce+'"'
                               +'>'
                               +@bold+@ital+@subr
                               +isnull((select top 1 valor from #val with(index(IDX_val)) where codeleme=@ce and tipelemepar='5'),'')
                               +@cbold+@cital+@csubr
                               +'</a>'

                         -- -----------------------------------

                         if @te='6'  -- Es un dato de Testigos
                            set @html_informe+=
                               '<a class="testigo"'
                                +' style="'+@display+'"'
                                +' title="Párrafo : '+@codparra+', Test. Cód.Ele.: '+@ce+'"'
                              +'>'
                              +@bold+@ital+@subr
                              +isnull((select top 1 v.valor from #val v with(index(IDX_val)) where v.codeleme=@ce and v.tipeleme='6'),'nulo')
                            --+isnull(CORITEL.dbo.f_Valor_Testigo_Informe (@numinfor, @ce+'N'),'nulo')
                              +@cbold+@cital+@csubr
                              +'</a>'

                         --------------------------------------

                         fetch next from cursor_Taorpael into @ce,@te,@fi,@co,@bold,@ital,@subr

                       end

                 close      cursor_Taorpael
                 deallocate cursor_Taorpael

                 -------------------------------
                 -- Finalizacíon de la Tabla
                 -------------------------------

                 set @html_informe+=
                            '</td>'
                          +'</tr>'
                         +'</table>'

                 --set @paso='....Final Parrafo Cabecera NO Tabulado '+@codparra set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait                                    

               end

            -------------------------------------------------------------------

            set @html_informe+='</div>'
                              +'<!--- Final del Parrafo ----->'           

            -------------------------------------------------------------------

            set @paso='Fin Párrafo '+@codparra+'' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait
            
            -------------------------------------------------------------------

            fetch next from cursor_Parrafos into @posapart,@codapart,@posparra,@codparra,@modparra,@titulo,@tp,@fp,@su

        end

   close      cursor_Parrafos
   deallocate cursor_Parrafos
   
   drop table #cuadro

   set @paso='Fin Cursor Párrafos ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

   declare @html_celda_informe_final varchar(1000)=''--'</td>'
   declare @html_div_informe_final   varchar(1000)='</div>'
   declare @html_tabla_final         varchar(1000)=''--'</tr></table>'
   
   declare @html_celda_graficos varchar(max)=''
			--+'<td style="width:auto;height:100%;">'
				+'<div style="float:right;overflow:auto;width:50%;height:90%;border:solid 1px #aaa;margin-right:5px;">'
		--	+'<iframe style="overflow:auto;width:100%;height:98%;border:solid 0px #000" src="http://tasacionesh.es/intraTH/galeriaAnexos.asp?numinf='+@numinfor+'&imprimir=n&mostrarnoinc=1" ></iframe>'
		-- +'<iframe style="overflow:auto;width:100%;height:98%;border:solid 0px #000" src="http://app.tasacioneshipotecarias.com/intraTH/galeriaAnexos.asp?numinf='+@numinfor+'&imprimir=1" ></iframe>'
				+'</div>'
			--+'</td>'

  ---------------------------------------------

-- select * from CORITEL.dbo.HTML_Ficheros with(nolock)
-- select @ruta+'\'+@numinfor+'.html'

  -------------------------------------------
  
  declare @html_body_final varchar(max)=''--'</body></html>'

  ------------------
  -- Final del HTML
  ------------------

  declare @html_tiempo_proceso  varchar(1000)='<div style="width:100%;height:2%;overflow:auto;"><a style="padding-left:5px;font-size:0.5vw">Tiempo Base de Datos: '+convert(varchar,datediff(ms,@fecha_inicial,getdate()))+' ms</a></div>' 

  set @html=''
     --- +@html_body_inicial
     --- +@html_head_inicial
      +@html_text_css
      +@html_text_javascript
     ---- +@html_head_final
        +@html_tabla_inicial
           +@html_celda_informe_inicial
             +@html_div_cabecera
             +@html_div_informe_inicial
               +isnull(@html_informe,'')
             +@html_div_informe_final
           +@html_celda_informe_final
     --      +@html_celda_graficos
        +@html_tabla_final
        +@html_tiempo_proceso
     ---- +@html_body_final

  ------------------------------------------------------------------------
  -- Introduccion del HTML exclusivo del Informe en TextArea de Impresion
  ------------------------------------------------------------------------
  
  set @html+='<textarea id="htmlpdf_'+@prbbdd+'" type="text" style="display:none;width:100%;height:50%;">'
             +@html_body_inicial
             +@html_head_inicial
             +@html_text_css
             +@html_text_javascript
             +@html_head_final
               --+@html_tabla_inicial
                  --+@html_celda_informe_inicial
                    +@html_div_cabecera
                    +@html_div_informe_inicial
                      +@html_informe
                    +@html_div_informe_final
                --+@html_celda_informe_final
                --+@html_celda_graficos
               --+@html_tabla_final
             +@html_body_final
           +'</textarea>'
   
  -------------------------------------

  drop table #detalle
  drop table #taotesti
  drop table #taorelva
  drop table #taoeleme
  drop table #taoinfor_elementos_activos    
  drop table #validaciones
  drop table #taorpael
  drop table #taorpael_general
  drop table #val
  drop table #encargos
  drop table #taoinfor
  drop table #taoresel
  drop table #tablas_tecnicas
--  drop table #campos_tecnicos
  set @paso='drop temporales ' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait

  select
       '<resultado>OK</resultado>'
      +'<error></error>'
      +'<salida>'+isnull(isnull(@html,'Nulo'),'No existen datos')+'</salida>'
      
  set @paso='FINAL de MONTAJE' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror(@mess,10,1,0) with nowait      
 
       
  return

end try

begin catch
    print error_message()+' -> '+convert(varchar(10),error_line())
    select
       '<resultado>KO</resultado>'
      +'<error>'+error_message()+' -> '+convert(varchar(10),error_line())+'</error>'
      +'<salida></salida>'
end catch

end

/*
go
exec TH_Informes_HTML_Ver_Informe @numinfor='22003161', @debug=1
*/


GO
