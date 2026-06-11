SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[IDEALISTA_Mapa] (
       @numinfor    varchar( 10)
      ,@distancia   int=2000
      ,@zoom        int=13
      ,@usuario     int null
      ,@imprimir    bit=0
      ,@debug       bit=0
      ,@parametros  varchar(max)=null
     )

as

begin

------------------------------------------
set nocount on
set dateformat dmy                                                                          
set transaction isolation level read uncommitted
------------------------------------------

declare @paso          char(200)
      , @mess          varchar(max)
      , @prbbdd        varchar(300)=object_name(@@procid)
      , @fecha_inicial datetime=getdate()
      , @fim           datetime=getdate()
      , @resultado     varchar(500)

begin try

    if @debug=1 begin set @paso='============================================================' set @mess=@paso; raiserror(@mess,10,1,0) with nowait end
    if @debug=1 begin set @paso='Inicio Proceso '+@prbbdd set @mess=@paso; raiserror(@mess,10,1,0) with nowait end

    declare @id_mapa varchar(50)=format(sysdatetime(),'yyyyMMddmmsshhfffffff')

    if @numinfor is null
       begin
          raiserror('No existe informe',16,1,0)
       end

    declare @lat varchar(50)=null
           ,@lng varchar(50)=null
         
    select @lat=replace(g.latitud ,',','.')
         , @lng=replace(g.longitud,',','.')
    from CORITEL.dbo.taoencar_gps g (nolock) 
    where g.numinfor=@numinfor

    if @lat is null or @lng is null
       begin
          raiserror('Sin Coordenadas',16,1,0)
       end

    declare @dLat  decimal(19,14)=replace(convert(varchar(20),@lat ),',','.')
    declare @dLng  decimal(19,14)=replace(convert(varchar(20),@lng),',','.') 
    declare @radio decimal(19,14)=@distancia

    declare @dDisLatMetro decimal(19,14)=0.00000908013661  -- 1 metro en Latitud
    declare @dDisLngMetro decimal(19,14)=0.00000904175255  -- 1 metro en Longitud

    declare @dLatIni decimal(19,14)=@dLat-(@dDisLatMetro*@radio)
    declare @dLatFin decimal(19,14)=@dLat+(@dDisLatMetro*@radio)

    declare @dLngIni decimal(19,14)=@dLng-(@dDisLngMetro*@radio)
    declare @dLngFin decimal(19,14)=@dLng+(@dDisLngMetro*@radio)

    -------------------------------------------------
    -- Actualización de Geolocalización de Tasadores
    -------------------------------------------------

    update n 
       set n.Punto=geography::STPointFromText('POINT('+replace(convert(varchar(20),n.Longitud),',','.')+' '+replace(convert(varchar(20),n.Latitud),',','.')+')',4326)
    from EXPLOTACION.dbo.tasadgeoloc n
    where n.Punto is null
      and isnumeric(n.Latitud )=1 
      and isnumeric(n.Longitud)=1
      and left(n.Longitud,1) in ('+','-','1','2','3','4','5','6','7','8','9','0')
      and left(n.Latitud ,1) in ('+','-','1','2','3','4','5','6','7','8','9','0')
      and left(Cod,1)='4'

    --------------------------------
    -- Captacion de los parámetros
    --------------------------------

    set @parametros=replace(@parametros,'''','´')
    declare @x1 xml=convert(xml,@parametros)
    
    declare @areafrom        int
           ,@areato          int
           ,@operationVTA    int
           ,@operationALQ    int
           ,@operationOPC    int
           ,@typologyVIV     int
           ,@typologyUNI     int
           ,@typologyAPA     int
           ,@typologyTRA     int
           ,@typologyEDF     int
           ,@typologyIND     int
           ,@typologyLOC     int
           ,@typologyOFI     int
           ,@typologyTER     int
    
    declare @withcadastralreferenceonly bit
    
    declare @isingroundfloor bit
           ,@isinmiddlefloor bit
           ,@isintopfloor    bit
           ,@hasboxroom      bit
           ,@hasparkingspace bit
           ,@hasgarden       bit
           ,@hasterrace      bit
           ,@haslift         bit
           ,@hasswimmingpool bit
           ,@agesince        int
           ,@ageuntil        int
           ,@roomnumberfrom  int
           ,@roomnumberto    int
           ,@bathnumberfrom  int
           ,@bathnumberto    int
           ,@distance        int
    
    ----------------------------------------------------
    set @areafrom        =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='areafrom')
    set @areato          =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='areato')
    ----------------------------------------------------
    set @operationVTA    =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='operationVTA')
    set @operationALQ    =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='operationALQ')
    set @operationOPC    =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='operationOPC')
    ----------------------------------------------------
    set @typologyVIV     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyVIV')
    set @typologyUNI     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyUNI')
    set @typologyAPA     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyAPA')
    set @typologyTRA     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyTRA')
    set @typologyEDF     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyEDF')
    set @typologyIND     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyIND')
    set @typologyLOC     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyLOC')
    set @typologyOFI     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyOFI')
    set @typologyTER     =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='typologyTER')
    ----------------------------------------------------
    set @withcadastralreferenceonly=(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='withcadastralreferenceonly')
    ----------------------------------------------------
    set @isingroundfloor =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='isingroundfloor')
    set @isinmiddlefloor =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='isinmiddlefloor')
    set @isintopfloor    =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='isintopfloor')
    set @hasboxroom      =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='hasboxroom')
    set @hasparkingspace =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='hasparkingspace')
    set @hasgarden       =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='hasgarden')
    set @hasterrace      =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='hasterrace')
    set @haslift         =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='haslift')
    set @hasswimmingpool =(select top 1 xc.value('v[1]','bit') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='hasswimmingpool')
    ----------------------------------------------------
    set @agesince        =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='agesince')
    set @ageuntil        =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='ageuntil')
    ----------------------------------------------------
    set @roomnumberfrom  =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='roomnumberfrom')
    set @roomnumberto    =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='roomnumberto')
    set @bathnumberfrom  =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='bathnumberfrom')
    set @bathnumberto    =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='bathnumberto')
    ----------------------------------------------------
    set @distance        =(select top 1 xc.value('v[1]','int') from @x1.nodes('/root/p') as xt(xc) where xc.value('c[1]','varchar(50)')='radiocercanos')
    ----------------------------------------------------

    set @areafrom        =case when @areafrom      =0 then null    else @areafrom       end
    set @areato          =case when @areato        =0 then null    else @areato         end
    set @agesince        =case when @agesince      =0 then null    else @agesince       end
    set @ageuntil        =case when @ageuntil      =0 then null    else @ageuntil       end
    set @roomnumberfrom  =case when @roomnumberfrom=0 then null    else @roomnumberfrom end
    set @roomnumberto    =case when @roomnumberto  =0 then null    else @roomnumberto   end
    set @bathnumberfrom  =case when @bathnumberfrom=0 then null    else @bathnumberfrom end
    set @bathnumberto    =case when @bathnumberto  =0 then null    else @bathnumberto   end

    -------------------------
    -- Inicio de montaje HTML
    -------------------------

    declare @logo               varchar(max)='<img style="width:100%;" src="https://app.tasacioneshipotecarias.com/intraTH/images/00_Jll_logo_header.png" >'
           ,@fuente_supereti    varchar(100)='Arial'
           ,@color_supereti     varchar(100)='#000'
           ,@fuente_eti         varchar(100)='Arial'
           ,@color_eti          varchar(100)='#BC141A'
           ,@fuente_dat         varchar(100)='Arial'
           ,@color_dat          varchar(100)='black'
           ,@ancho_diagrama     int         =1600
           ,@alto_diagrama      int         =800
           ,@ancho_imagen       int         =1800
           ,@alto_imagen        int         =800
           ,@grafico            varchar(max)
           ,@json_diagrama      varchar(max)
           ,@caso               varchar(500)
           ,@secuencias         varchar(max)
           ,@option_casos       varchar(max)

    declare @estinfor   varchar(10)
           ,@codtasad   varchar(10)
           ,@nomtasad   varchar(500)
           ,@tasador    varchar(500)
           ,@direccion  varchar(500)=null
           ,@piso       varchar(100)=null
           ,@finca      varchar( 50)=null
           ,@obj_tec    varchar(10)
           ,@objeto     varchar(100)
           ,@compatible varchar(1000)

    select @estinfor =e.estinfor
          ,@codtasad =isnull(e.codtasad,'')
          ,@nomtasad =isnull(t.nomtasad,'')+isnull(' '+t.ap1tasad,'')+isnull(' '+t.ap2tasad,'')
          ,@tasador  =isnull(t.nomtasad,'')+isnull(' '+t.ap1tasad,'')+isnull(' '+t.ap2tasad,'') + isnull(' ('+e.codtasad+')','')
          ,@direccion=ltrim(rtrim(e.calleobj))+', '+ltrim(rtrim(e.numeobje))+' '+ltrim(rtrim(e.pisoobje))+' '+ltrim(rtrim(e.deslocal))+' ('+ltrim(rtrim(e.cposobje))+')'
          ,@obj_tec  =case when e.codobjet='80004' 
                           then CORITEL.dbo.f_TECNICOS_Objeto_Tecnico_ConParametroCodObjet_Minutas (e.numinfor,e.codobjet,null) 
                           else CORITEL.dbo.f_TECNICOS_Objeto_Tecnico_ConParametroCodObjet         (e.numinfor,e.codobjet,null) 
                      end
    from CORITEL.dbo.taoencar e (nolock) 
    inner join CORITEL.dbo.taotasad t (nolock) on t.codtasad=e.codtasad
    where e.numinfor=@numinfor

    ----------------------------------------
    -- Lista de Objetos Técnicos disponibles
    ----------------------------------------

    drop table if exists #objtec
    select [id]        =row_number() over (order by ltrim(rtrim(isnull(f.desobjet,''))))                  
          ,[codobjet]  =isnull(f.codobjet,'')                                    
          ,[objeto]    =ltrim(rtrim(isnull(f.desobjet,'')))
          ,[compatible]=convert(varchar(500),null)
          ,[idealista] =convert(varchar(500),null)
    into #objtec
    from CORITEL.dbo.taoobjet f (nolock)
    where f.anuobjet=0
      and f.codclase in ('800','900')
      and f.codobjet in (select distinct codobjet 
                         from CORITEL.dbo.taoencar e (nolock) 
                         where year(e.fecalta)>=2016 
                           and e.codobjet is not null
                        )
    --select * from #objtec
    
    /*
    
    80015	Conjunto Edif.            UNI,VIV,EDF
    80010	Edificio                  EDF
    80011	Gestión                   UNI,VIV,APA,ED1,HOT,IND,LOC,OFI
    80017	ILAE - con Guión          UNI,VIV,APA,ED1,HOT,IND,LOC,OFI
    80014	Industrial                IND
    80009	Local Comercial           LOC
    80013	Oficina                   OFI
    80016	Parte Edificio            VIV,LOC,OFI
    80006	Plaza de Garaje           APA
    90002	Rústica (Terrenos)        TER
    80018	Rústica con Guion         TER
    80019	Terreno                   TER
    90001	Terrenos                  TER
    80007	Trastero                  TRA
    80004	Valoración Int. Obra      VIV,APA,EDF,HOT,IND,LOC,OFI
    80008	Vivienda-Piso             VIV
    80012	Vivienda-Unif             UNI

typology                     =>          => '#/components/schemas/Typology' => '#/components/schemas/Subtypology'
         1 => Home           
         2 => Chalet         
         3 => Casa de campo
         4 => Garage         
         5 => Office         
         6 => Almacén
         7 => Habitación           
         8 => Terreno            
        10 => Nuevo desarrollo
        11 => Anuncio personalizado
        12 => Trastero   
        13 => Edificio       
    */

    update t set t.compatible='EDF,VIV,UNI                ' from #objtec t where t.codobjet='80015'  -- Conjunto Edif.        
    update t set t.compatible='EDF,UNI                    ' from #objtec t where t.codobjet='80010'  -- Edificio              
    update t set t.compatible='VIV,APA,ED1,IND,LOC,OFI,UNI' from #objtec t where t.codobjet='80011'  -- Gestión               
    update t set t.compatible='VIV,APA,ED1,IND,LOC,OFI,UNI' from #objtec t where t.codobjet='80017'  -- ILAE - con Guión      
    update t set t.compatible='IND                        ' from #objtec t where t.codobjet='80014'  -- Industrial            
    update t set t.compatible='LOC                        ' from #objtec t where t.codobjet='80009'  -- Local Comercial       
    update t set t.compatible='OFI                        ' from #objtec t where t.codobjet='80013'  -- Oficina               
    update t set t.compatible='VIV,UNI,LOC,OF             ' from #objtec t where t.codobjet='80016'  -- Parte Edificio
    update t set t.compatible='APA                        ' from #objtec t where t.codobjet='80006'  -- Plaza de Garaje       
    update t set t.compatible='TER                        ' from #objtec t where t.codobjet='90002'  -- Rústica (Terrenos)    
    update t set t.compatible='TER                        ' from #objtec t where t.codobjet='80018'  -- Rústica con Guion     
    update t set t.compatible='TER                        ' from #objtec t where t.codobjet='80019'  -- Terreno               
    update t set t.compatible='TER                        ' from #objtec t where t.codobjet='90001'  -- Terrenos              
    update t set t.compatible='TRA                        ' from #objtec t where t.codobjet='80007'  -- Trastero              
    update t set t.compatible='EDF,UNI,VIV,APA,IND,LOC,OFI' from #objtec t where t.codobjet='80004'  -- Valoración Int. Obra
    update t set t.compatible='VIV,UNI                    ' from #objtec t where t.codobjet='80008'  -- Vivienda-Piso         
    update t set t.compatible='UNI,VIV                    ' from #objtec t where t.codobjet='80012'  -- Vivienda-Unif         

    select @objeto    =o.objeto
          ,@compatible=o.compatible 
    from #objtec o 
    where o.codobjet=@obj_tec

    ----------------------------------

    --if @debug=1
    --   begin
    --      select 'Paso 2'
    --   end

    --------------------------------------------     
    declare @js_cargar_parametros varchar(max)=''
    +'var xmli='''';'
    -------------------------------------------------------------------------------------------------
    +' xmli+=''<p><c>areafrom</c><v>''+areafrom.value+''</v></p>'';'
    +' xmli+=''<p><c>areato</c><v>''+areato.value+''</v></p>'';'
    set @js_cargar_parametros+=
    ---------------------------------------------------------------------------------------------------
    +' if (opeVTA.checked) {xmli+=''<p><c>operationVAT</c><v>''+opeVTA.dataset.idealista+''</v></p>''};'
    +' if (opeALQ.checked) {xmli+=''<p><c>operationALQ</c><v>''+opeALQ.dataset.idealista+''</v></p>''};'
    +' if (opeOPC.checked) {xmli+=''<p><c>operationOPC</c><v>''+opeOPC.dataset.idealista+''</v></p>''};'
    set @js_cargar_parametros+=
    -------------------------------------------------------------------------------------------------
    +' if (VIV.checked) {xmli+=''<p><c>typologyVIV</c><v>''+VIV.dataset.idealista+''</v></p>''};'
    +' if (UNI.checked) {xmli+=''<p><c>typologyUNI</c><v>''+UNI.dataset.idealista+''</v></p>''};'
    +' if (APA.checked) {xmli+=''<p><c>typologyAPA</c><v>''+APA.dataset.idealista+''</v></p>''};'
    +' if (TRA.checked) {xmli+=''<p><c>typologyTRA</c><v>''+TRA.dataset.idealista+''</v></p>''};'
    +' if (EDF.checked) {xmli+=''<p><c>typologyEDF</c><v>''+EDF.dataset.idealista+''</v></p>''};'
    +' if (IND.checked) {xmli+=''<p><c>typologyIND</c><v>''+IND.dataset.idealista+''</v></p>''};'
    +' if (LOC.checked) {xmli+=''<p><c>typologyLOC</c><v>''+LOC.dataset.idealista+''</v></p>''};'
    +' if (OFI.checked) {xmli+=''<p><c>typologyOFI</c><v>''+OFI.dataset.idealista+''</v></p>''};'
    +' if (TER.checked) {xmli+=''<p><c>typologyTER</c><v>''+TER.dataset.idealista+''</v></p>''};'
    set @js_cargar_parametros+=
    -------------------------------------------------------------------------------------------------
    +' if (withcadastralreferenceonly.checked) {xmli+=''<p><c>withcadastralreferenceonly</c><v>1</v></p>''};'
    +' if (isingroundfloor.checked) {xmli+=''<p><c>isingroundfloor</c><v>1</v></p>''};'
    +' if (isinmiddlefloor.checked) {xmli+=''<p><c>isinmiddlefloor</c><v>1</v></p>''};'
    +' if (isintopfloor.checked)    {xmli+=''<p><c>isintopfloor</c><v>1</v></p>''};'
    +' if (hasboxroom.checked)      {xmli+=''<p><c>hasboxroom</c><v>1</v></p>''};'
    +' if (hasparkingspace.checked) {xmli+=''<p><c>hasparkingspace</c><v>1</v></p>''};'
    +' if (hasgarden.checked)       {xmli+=''<p><c>hasgarden</c><v>1</v></p>''};'
    +' if (hasterrace.checked)      {xmli+=''<p><c>hasterrace</c><v>1</v></p>''};'
    +' if (haslift.checked)         {xmli+=''<p><c>haslift</c><v>1</v></p>''};'
    +' if (hasswimmingpool.checked) {xmli+=''<p><c>hasswimmingpool</c><v>1</v></p>''};'
    set @js_cargar_parametros+=
    -------------------------------------------------------------------------------------------------
    +' xmli+=''<p><c>agesince</c><v>''+agesince.value+''</v></p>'';'
    +' xmli+=''<p><c>ageuntil</c><v>''+ageuntil.value+''</v></p>'';'
    +' xmli+=''<p><c>roomnumberfrom</c><v>''+roomnumberfrom.value+''</v></p>'';'
    +' xmli+=''<p><c>roomnumberto</c><v>''+roomnumberto.value+''</v></p>'';'
    +' xmli+=''<p><c>bathnumberfrom</c><v>''+bathnumberfrom.value+''</v></p>'';'
    +' xmli+=''<p><c>bathnumberto</c><v>''+bathnumberto.value+''</v></p>'';'
    set @js_cargar_parametros+=
    -------------------------------------------------------------------------------------------------
    +' xmli+=''<p><c>radiocercanos</c><v>''+radiocercanos_'+@id_mapa+'.value+''</v></p>'';'
    -------------------------------------------------------------------------------------------------
    set @js_cargar_parametros+=
    +' xmli=xmli.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
    +' xmli=xmli.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
    +' xmli=xmli.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
    +' xmli=xmli.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
    +' xmli=xmli.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'                -- Es el &
    set @js_cargar_parametros+=
    --  -------------------------------------------------------------------------------------------------
    +' xmli=''<root>''+xmli+''</root>'';'


    declare @html varchar(max)=''

    if @imprimir=1
       begin
           set @html+='<!DOCTYPE html><html><head>'+char(10)
                    +' <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.2/dist/leaflet.css" />'+char(10)
                    +' <link rel="stylesheet" href="https://unpkg.com/esri-leaflet-geocoder@2.2.3/dist/esri-leaflet-geocoder.css" />'+char(10)
                    +' <script src="https://unpkg.com/leaflet@1.0.2/dist/leaflet-src.js" type="text/javascript"></script>'+char(10)
                    +' <script src="https://unpkg.com/esri-leaflet@2.0.7"                type="text/javascript"></script>'+char(10)
                    +' <script src="https://unpkg.com/esri-leaflet-geocoder@2.2.3"       type="text/javascript"></script>'+char(10)
                    +'</head>'+char(10)
                    +'<body>'+char(10)
       end

    set @html+=''
     +'<style type="text/css">'
     +' .controls             {border: 1px solid transparent;border-radius: 2px 0 0 2px;box-sizing: border-box;-moz-box-sizing: border-box;height: 28px;outline: none;box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);}'
     +'  #type-selector       {color: #ffg; background-color: #4d90fe; padding: 5px 5px 5px 5px;}'
     +'  #type-selector label {font-family: Roboto; font-size: 13px;}'
     +'  td.popup             {border:solid 1px #aaa}'
     +'  td.seleccionado      {border:solid 1px #aaa; background:PapayaWhip}'
     +'  span.seleccionar     {cursor:pointer;color:blue;display:inline-block;width:100%;text-align:center;font-weight:bold;}'
     +'  img.borratestigo     {cursor:pointer;vertical-align:middle}'
     +'  tr.popup             {height:0px;}'
     +'  table.popup          {border-collapse:collapse;table-layout:fixed;font-size:0.50vw;width:15vw;text-align:left}'
     set @html+='
         
         input[type="radio"] {vertical-align:middle;
           height: 2vh;                 /* or whatever */
           width:  1.5vw;               /* or whatever */
           border: 0.1vw solid #999;    /* or whatever */
           border-radius: 50%;          /* make it round */
           transition: 0.2s all linear; /* just to make it change smoothly */
         }
         input[type="radio"]:checked {border:0.2vw solid blue; /* make it change visually when checked */ }

         input[type="checkbox"]  {vertical-align:middle;
           content: "\2714";
           height: 1.5vh;
           width:  1vw;
           border: 0.1vw solid #999;
           transition: 0.2s all linear;
         }
         input[type="checkbox"]:checked {border:0.7vw solid blue; /* make it change visually when checked */ }
      '
     +'</style>'+char(10)
   

    declare @ico_bor varchar(max)='https://app.tasacioneshipotecarias.com/ether/img/ico_0025.png'

    declare @ico_inm varchar(max)='https://app.tasacioneshipotecarias.com/ether/img/gps_negro.png'
    declare @ico_tas varchar(max)='https://app.tasacioneshipotecarias.com/ether/img/gps_azul.png'
    declare @ico_ide varchar(max)='https://app.tasacioneshipotecarias.com/ether/img/gps_idealista.png'
    declare @ico_atv varchar(max)='https://app.tasacioneshipotecarias.com/ether/img/gps_gold.png'
    
    --if @debug=1
    --   begin
    --      select 'Paso 3'
    --   end

    declare @origen geography
    set @origen=geography::STPointFromText('POINT('+@lng+' '+@lat+')',4326)

    --if @debug=1
    --   begin
    --      select 'Paso 4'
    --   end

    ---------------------------------------------------------
    -- Sacar lo anuncios de IDEALISTA que tenemos guardados
    ---------------------------------------------------------

    drop table if exists #anuncios
    select g.*
          ,[Distancia]       =posicion.STDistance(@origen) 
          ,[latitud_decimal] =convert(decimal(19,15),replace(convert(varchar(20),g.latitude ),',','.')) 
          ,[longitud_decimal]=convert(decimal(19,15),replace(convert(varchar(20),g.longitude),',','.'))
    into #anuncios
    from IDEALISTA_API_Anuncios g (nolock)
    where ltrim(isnull(g.latitude ,''))!='' 
      and ltrim(isnull(g.longitude,''))!=''
      and case when isnumeric(replace(convert(varchar(20),g.latitude  ),',','.'))=1 then case when abs(convert(float,replace(convert(varchar(20),g.latitude ),',','.')))>100 then 0 else 1 end else 0 end=1
      and case when isnumeric(replace(convert(varchar(20),g.longitude ),',','.'))=1 then case when abs(convert(float,replace(convert(varchar(20),g.longitude),',','.')))>100 then 0 else 1 end else 0 end=1
      and g.posicion is not null

    ------------------------------------------------------------------------------------

    set @html+=''
    +'<a id="selth" data-codigo="" style="display:none;" 
         onclick="
          var tipos=document.getElementsByClassName(''itemsanuncio'');
          for (var i=0; i<tipos.length; i++) {tipos[i].style.background=''transparent''}
          var id=''testith_''+this.dataset.codigo;
          ele=document.getElementById(id);
          ele.scrollIntoView();
          ele.style.background=''Gold'';
          var testisel=document.getElementsByClassName(''testisel'');
          for (var i=0; i<testisel.length; i++) 
              {if (testisel[i].innerHTML=='''') 
                  {testisel[i].innerHTML=this.dataset.codigo;
                   if (i==0)  {borra01.style.display=''''};
                   if (i==1)  {borra02.style.display=''''};
                   if (i==2)  {borra03.style.display=''''};
                   if (i==3)  {borra04.style.display=''''};
                   if (i==4)  {borra05.style.display=''''};
                   if (i==5)  {borra06.style.display=''''};
                   if (i==6)  {borra07.style.display=''''};
                   if (i==7)  {borra08.style.display=''''};
                   if (i==8)  {borra09.style.display=''''};
                   if (i==9)  {borra10.style.display=''''};
                   if (i==10) {borra11.style.display=''''};
                   if (i==11) {borra12.style.display=''''};
                   break
                  }
              }
         "'
    +'</a>'

    ------------------------------------
    set @html+=''
    +'<a id="selidea" data-codigo="" style="display:none;" 
         onclick="
          var tipos=document.getElementsByClassName(''itemsanuncio'');
          for (var i=0; i<tipos.length; i++) {tipos[i].style.background=''transparent''}
          var id=''testiide_''+this.dataset.codigo;
          ele=document.getElementById(id);
          ele.scrollIntoView();
          ele.style.background=''Gold'';
          for (var i=0; i<testisel.length; i++) 
              {if (testisel[i].innerHTML=='''') 
                  {testisel[i].innerHTML=this.dataset.codigo;
                   if (i==0)  {borra01.style.display=''''};
                   if (i==1)  {borra02.style.display=''''};
                   if (i==2)  {borra03.style.display=''''};
                   if (i==3)  {borra04.style.display=''''};
                   if (i==4)  {borra05.style.display=''''};
                   if (i==5)  {borra06.style.display=''''};
                   if (i==6)  {borra07.style.display=''''};
                   if (i==7)  {borra08.style.display=''''};
                   if (i==8)  {borra09.style.display=''''};
                   if (i==9)  {borra10.style.display=''''};
                   if (i==10) {borra11.style.display=''''};
                   if (i==11) {borra12.style.display=''''};
                   break
                  }
              }
         "'
    +'</a>'

    set @html+=''
    +'<a id="delth" data-codigo="" style="display:none;" 
         onclick="
         if (this.dataset.codigo== 1) {borra01.style.display=''none'';testi01.innerHTML='''';};
         if (this.dataset.codigo== 2) {borra02.style.display=''none'';testi02.innerHTML='''';};
         if (this.dataset.codigo== 3) {borra03.style.display=''none'';testi03.innerHTML='''';};
         if (this.dataset.codigo== 4) {borra04.style.display=''none'';testi04.innerHTML='''';};
         if (this.dataset.codigo== 5) {borra05.style.display=''none'';testi05.innerHTML='''';};
         if (this.dataset.codigo== 6) {borra06.style.display=''none'';testi06.innerHTML='''';};
         if (this.dataset.codigo== 7) {borra07.style.display=''none'';testi07.innerHTML='''';};
         if (this.dataset.codigo== 8) {borra08.style.display=''none'';testi08.innerHTML='''';};
         if (this.dataset.codigo== 9) {borra09.style.display=''none'';testi09.innerHTML='''';};
         if (this.dataset.codigo==10) {borra10.style.display=''none'';testi10.innerHTML='''';};
         if (this.dataset.codigo==11) {borra11.style.display=''none'';testi11.innerHTML='''';};
         if (this.dataset.codigo==12) {borra12.style.display=''none'';testi12.innerHTML='''';};
         "'
    +'</a>'

    declare @proveedor varchar(1000)='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    

           -- var Punto_Inm=L.icon({iconUrl:'''+@ico_inm+''',iconSize:[110,110],shadowAnchor:[22,94]});
           -- var Punto_Tas=L.icon({iconUrl:'''+@ico_tas+''',iconSize:[ 80, 80],shadowAnchor:[22,94]});
           -- var Punto_Ide=L.icon({iconUrl:'''+@ico_ide+''',iconSize:[ 80, 80],shadowAnchor:[22,94]});
           -- var Punto_Atv=L.icon({iconUrl:'''+@ico_atv+''',iconSize:[ 80, 80],shadowAnchor:[22,94]});


    set @html+=''
      +'<a id="carga_mapa_'+@id_mapa+'" style="display:none;"'
        +' onclick="'+char(10)
        +' //-------------------------------------
           // Mapa LeatFlet y Posicion de Inicio
           //-------------------------------------
           var Punto_Inm=L.icon({iconUrl:'''+@ico_inm+''',iconSize:[32,88],shadowAnchor:[22,94]});
           var Punto_Tas=L.icon({iconUrl:'''+@ico_tas+''',iconSize:[22,60],shadowAnchor:[22,94]});
           var Punto_Ide=L.icon({iconUrl:'''+@ico_ide+''',iconSize:[22,60],shadowAnchor:[22,94]});
           var Punto_Atv=L.icon({iconUrl:'''+@ico_atv+''',iconSize:[22,60],shadowAnchor:[22,94]});
           var defaultZoom='+format(@zoom,'0')+';
           var mapOrigin=['+@lat+','+@lng+'];
           var GeoMapa=document.getElementById(''mapaLeatFlet_'+@id_mapa+''');
           mapLF=L.map(''mapaLeatFlet_'+@id_mapa+''').setView(mapOrigin, defaultZoom);
           L.tileLayer('''+@proveedor+''', {maxZoom: 19}).addTo(mapLF);
           GEODatosDiv=document.getElementById(''datosLeatFlet_'+@id_mapa+''');
           var Tex=''<a>'+ltrim(rtrim(@direccion))+'</a>'+isnull('<br>Piso:'+@piso,'')+'''; Tex+=''<br>''; Tex+=''GPS (''+'''+@lat+'''; Tex+='',''+'''+@lng+'''; Tex+='')'';
           var Tit='''+ltrim(rtrim(@direccion))+''+isnull('Piso:'+@piso,'')+''';
           markerLeatFlet=L.marker(['+@lat+', '+@lng+'], {icon:Punto_Inm, draggable:false, title:'''+ltrim(rtrim(@direccion))+''+isnull('Piso:'+@piso,'')+'''}).addTo(mapLF).bindPopup(Tex);
         //markerLeatFlet=L.marker(['+@lat+', '+@lng+'], {icon:Punto_Inm, draggable:false, title:'''+ltrim(rtrim(@direccion))+''+isnull('Piso:'+@piso,'')+'''}).addTo(mapLF).bindPopup(Tex).openPopup();
       '

    --------------------------------------
    --------------------------------------

    declare @puntos varchar(max)

    ---------------------------------------
    -- Puntos de los anuncios de Idealista
    ---------------------------------------

    if @debug=1
       begin
          select [#anuncios]='#anuncios', * 
          from #anuncios g
          where g.latitud_decimal  between @dLatIni and @dLatFin
            and g.longitud_decimal between @dLngIni and @dLngFin
            and posicion.STDistance(@origen)<=@radio
          order by g.Distancia
       end

    declare c cursor fast_forward local for
    select top 60
           [@puntos]=
             'L.marker(['+replace(convert(varchar(20),g.latitude ),',','.')+', '+replace(convert(varchar(20),g.longitude),',','.')+']'
            +',{icon:Punto_Ide' 
             +',draggable:false'
             +',customId:'+format(g.codigo,'0')
             +',title:''Testigo => Dist. '+format(posicion.STDistance(@origen),'#.0,00','de-DE')+' metros)'''
             +'})'
            +'.addTo(mapLF)'
            +'.bindPopup(''<u>Inmueble ORIGEN Idealista</u>'
                 +'<table class=\''popup\''>'
                   +'<tr class=\''popup\''><td style=\''width:25%\''></td><td style=\''width:auto\''></td></tr>'
                   +'<tr><td class=\''popup\''>Fecha:</td>          <td class=\''popup\''><b>'+isnull(g.modificationdate,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Dirección:</td>      <td class=\''popup\''><b>'+replace(isnull(ltrim(rtrim(g.streettype))+'&nbsp;','')+isnull(g.streetname,'')+isnull(', '+g.streetnumber,''),char(39),'´')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Precio:</td>         <td class=\''popup\''><b>'+isnull(g.price      ,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Precio Unitario:</td><td class=\''popup\''><b>'+isnull(g.unitprice  ,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Superficie:</td>     <td class=\''popup\''><b>'+isnull(g.area       ,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Distancia:</td>      <td class=\''popup\''><b>'+isnull(g.distance   ,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Habitaciones:</td>   <td class=\''popup\''><b>'+isnull(g.roomnumber ,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\''>Baños:</td>          <td class=\''popup\''><b>'+isnull(g.bathnumber ,'')+'</b></td></tr>'
                   +'<tr><td class=\''popup\'' colspan=\''2\''><span class=\''seleccionar\'' onclick=\''selidea.dataset.codigo='+g.id+';selidea.click();\'' >SELECCIONAR</span></td></tr>'
                 +'</table>' 
                +''',{maxWidth:1000})'
             +'.on(''click'', 
                     function(e)
                     {var l=new google.maps.LatLng('+replace(convert(varchar(20),g.latitude),',','.')+', '+replace(convert(varchar(20),g.longitude),',','.')+');'
                      +'if (markergoogle) {markergoogle.setMap(null)};'
                      +'markergoogle=new google.maps.Marker({map: mapgoogle, draggable:false});'
                      +'markergoogle.setPosition(l);'
                      +'mapgoogle.setCenter(l);'
                      +'var fenway = {lat: '+replace(convert(varchar(20),g.latitude),',','.')+', lng: '+replace(convert(varchar(20),g.longitude),',','.')+'};'
                      +'var panorama = new google.maps.StreetViewPanorama(document.getElementById(''mapstrevi_'+@id_mapa+'''), {position:fenway, pov:{heading:34, pitch:10} });'
                      +'mapgoogle.setStreetView(panorama)'
                     +'})'
           +';'+char(10)   
    from #anuncios g
    where g.latitud_decimal  between @dLatIni and @dLatFin
      and g.longitud_decimal between @dLngIni and @dLngFin
      and posicion.STDistance(@origen)<=@radio
    order by g.Distancia
    open c
    fetch next from c into @puntos
    while @@fetch_status=0
          begin
             set @html+=isnull(@puntos,'')+char(10)
             fetch next from c into @puntos
          end
    close c
    deallocate c

    --------------------------------------------------
    -- Puntos de los anuncios de TESTIGOS de TASACION
    --------------------------------------------------

    ---------------------------------------------------------
    -- Sacar los Testigos de las TASACIONES que tenemos guardados
    ---------------------------------------------------------

    drop table if exists #taotesti_completo
    select [orden]           =identity(int,1,1)
          ,[origen]          ='TASACION' 
          ,[fechatestigo]    =t.fectesti
          ,[codtasad]        =t.codtasad  
          ,[tasador]         =isnull(rtrim(ts.nomtasad),'')+isnull(' '+rtrim(ts.ap1tasad),'')+isnull(' '+rtrim(ts.ap2tasad),'')
          ,[tipo]            =t.idtipo
          ,[fuente]          =t.nc03 
          ,[latitud]         =t.Latitud
          ,[longitud]        =t.Longitud
          ,[latitud_decimal] =case when ltrim(isnull(t.Latitud ,''))!='' and case when isnumeric(replace(convert(varchar(20),t.Latitud ),',','.'))=1 then case when abs(convert(float,replace(convert(varchar(20),t.Latitud ),',','.')))>100 then 0 else 1 end else 0 end=1 then convert(decimal(19,15),replace(convert(varchar(20),t.Latitud ),',','.')) else convert(decimal(19,15),null) end
          ,[longitud_decimal]=case when ltrim(isnull(t.Longitud,''))!='' and case when isnumeric(replace(convert(varchar(20),t.Longitud),',','.'))=1 then case when abs(convert(float,replace(convert(varchar(20),t.Longitud),',','.')))>100 then 0 else 1 end else 0 end=1 then convert(decimal(19,15),replace(convert(varchar(20),t.Longitud),',','.')) else convert(decimal(19,15),null) end
          ,[posicion]        =convert(geography,null)
          ,[distancia]       =convert(decimal(19,4),null)
          ,[direccion]       =isnull(t.dirtesti1,'')+isnull(', '+t.dirtesti2,'')+isnull(' '+t.dirtesti3,'')
          ,[municipio]       =+isnull(      ltrim(rtrim(t.loctesti)),'')+isnull(' (' +ltrim(rtrim(t.cpotesti))+')','')+isnull(' - '+ltrim(rtrim(t.idprovin)),'')
          ,[superficie]      =case when left(t.idtipo,5) in ('Suelo')                             and t.fusuppar  is not null and isnumeric(t.fusuppar )=1 then convert(decimal(19,2),isnull(t.fusuppar ,0))
                                   when left(t.idtipo,3) in ('COM','GAR','IND','OFI','TRA','VIV') and t.tasuputil is not null and isnumeric(t.tasuputil)=1 then convert(decimal(19,2),isnull(t.tasuputil,0))
                                   else 0.00
                              end                                                                                                  
          ,[valor]           =case when t.nc63 is not null and isnumeric(t.nc63)=1 then convert(decimal(19,2), t.nc63) else 0 end
          ,[valor_descontado]=case when t.nc63 is not null and isnumeric(t.nc86)=1 then convert(decimal(19,2), t.nc86) else 0 end  
          ,[dormitorios]     =t.fundormi
          ,[baños]           =t.funaseos
          ,[antigued]        =t.antigued
          ,[comentario]      =convert(varchar(max),'Usado en la tasación '+t.numinfor)
    into #taotesti_completo
    from CORITEL.dbo.taotesti t (nolock)
    left outer join CORITEL.dbo.taotasad ts (nolock) on ts.codtasad=t.codtasad
    where t.fectesti>getdate()-180
      and t.Latitud  is not null
      and t.Longitud is not null
      and t.idtipo='VIV - Piso'
    order by t.numinfor desc, t.ordtesti

    -- @objeto

    --------------------------
    -- Actualizar la Posicion
    --------------------------
    
    update g 
       set g.posicion=geography::STPointFromText('POINT('+replace(convert(varchar(20),longitud),',','.')+' '+replace(convert(varchar(20),latitud),',','.')+')',4326)
    from #taotesti_completo g
    where g.posicion is null
      and g.latitud_decimal  between @dLatIni and @dLatFin
      and g.longitud_decimal between @dLngIni and @dLngFin
    
    update g 
       set g.distancia=posicion.STDistance(@origen)
    from #taotesti_completo g
    where g.posicion is not null

    -----------------------
    -- Descartar los repes
    -----------------------

    drop table if exists #taotesti
    select [id]              =t.orden
          ,[origen]          =t.[origen]          
          ,[fechatestigo]    =t.[fechatestigo]    
          ,[codtasad]        =t.[codtasad]        
          ,[tasador]         =t.[tasador]         
          ,[tipo]            =t.[tipo]            
          ,[fuente]          =t.[fuente]          
          ,[latitud]         =t.[latitud]         
          ,[longitud]        =t.[longitud]        
          ,[latitud_decimal] =t.[latitud_decimal] 
          ,[longitud_decimal]=t.[longitud_decimal]
          ,[distancia]       =t.[distancia]       
          ,[direccion]       =t.[direccion]       
          ,[municipio]       =t.[municipio]       
          ,[superficie]      =t.[superficie]      
          ,[valor]           =t.[valor]           
          ,[valor_descontado]=t.[valor_descontado]
          ,[dormitorios]     =t.[dormitorios]     
          ,[baños]           =t.[baños]           
          ,[antigued]        =t.[antigued]        
          ,[comentario]      =t.[comentario]      
    into #taotesti
    from #taotesti_completo t 
    outer apply (select x.orden 
                 from #taotesti_completo x 
                 where exists (select  t.[origen]          
                                      ,t.[fechatestigo]    
                                      ,t.[codtasad]
                                      ,t.[tasador]         
                                      ,t.[tipo]            
                                      ,t.[fuente]          
                                      ,t.[latitud]         
                                      ,t.[longitud]        
                                      ,t.[latitud_decimal] 
                                      ,t.[longitud_decimal]
                                      ,t.[distancia]       
                                      ,t.[direccion]       
                                      ,t.[municipio]       
                                      ,t.[superficie]      
                                      ,t.[valor]           
                                      ,t.[valor_descontado]
                                      ,t.[dormitorios]     
                                      ,t.[baños]           
                                      ,t.[antigued]        
                               intersect
                               select  x.[origen]          
                                      ,x.[fechatestigo]    
                                      ,x.[codtasad]
                                      ,x.[tasador]         
                                      ,x.[tipo]            
                                      ,x.[fuente]          
                                      ,x.[latitud]         
                                      ,x.[longitud]        
                                      ,x.[latitud_decimal] 
                                      ,x.[longitud_decimal]
                                      ,x.[distancia]       
                                      ,x.[direccion]       
                                      ,x.[municipio]       
                                      ,x.[superficie]      
                                      ,x.[valor]           
                                      ,x.[valor_descontado]
                                      ,x.[dormitorios]     
                                      ,x.[baños]           
                                      ,x.[antigued]        
                                 ) 
                 and x.orden>t.orden
                ) [repes]
    where [repes].orden is null

    if @debug=1
       begin
          select [#taotesti]='#taotesti', * 
          from #taotesti t 
          where t.distancia is not null 
            and t.distancia<=@radio
          order by t.distancia
       end
      
    ------------------------------------

    declare c cursor fast_forward local for
    select top 60
           [@puntos]=
             'L.marker(['+replace(convert(varchar(20),t.latitud ),',','.')+', '+replace(convert(varchar(20),t.longitud),',','.')+'],{icon:'+case when t.codtasad=@codtasad then 'Punto_Tas' else 'Punto_Atv' end +'' 
            +',draggable:false'
            +',title:''Testigo '
                      +'=> Dist. '+format(t.distancia,'#.0,00','de-DE')+' metros) '
                     +''''
            +'})'
            +'.addTo(mapLF)'
            +'.bindPopup(''<u>Inmueble ORIGEN TASACION TH</u>'
                            +'<table class=\''popup\''>'
                               +'<tr class=\''popup\''><td style=\''width:25%\''></td><td style=\''width:auto\''></td></tr>'
                               +'<tr><td class=\''popup\''>Fecha:</td>          <td class=\''popup\''><b>'+isnull(format(t.fechatestigo,'dd/MM/yyyy'),'')+'</b></td></tr>'
                               +'<tr><td class=\''popup\''>Dirección:</td>      <td class=\''popup\''><b>'+replace(isnull(t.direccion,''),char(39),'´')+'</b></td></tr>'
                               +'<tr><td class=\''popup\''>Precio:</td>         <td class=\''popup\''><b>'+isnull(format(t.valor      ,'#,0.00','de_DE'),'')+'</b></td></tr>'
                               +'<tr><td class=\''popup\''>Superficie:</td>     <td class=\''popup\''><b>'+isnull(format(t.superficie ,'#,0.00','de_DE'),'')+'</b></td></tr>'
                               +'<tr><td class=\''popup\''>Distancia:</td>      <td class=\''popup\''><b>'+isnull(format(t.distancia  ,'#,0.00','de_DE'),'')+'</b></td></tr>'
                               +'<tr><td class=\''popup\''>Habitaciones:</td>   <td class=\''popup\''><b>'+isnull(t.dormitorios                         ,'')+'</b></td></tr>'
                               +'<tr><td class=\''popup\''>Baños:</td>          <td class=\''popup\''><b>'+isnull(t.baños                               ,'')+'</b></td></tr>'
                               +'<tr><td class=\''popup\'' colspan=\''2\''><span class=\''seleccionar\'' onclick=\''selth.dataset.codigo='+format(t.id,'0')+';selth.click();\'' >SELECCIONAR</span></td></tr>'
                            +'</table>' 
                        +''',{maxWidth:1000})'
             +'.on(''click'', function(e) {var l=new google.maps.LatLng('+replace(convert(varchar(20),t.latitud),',','.')+', '+replace(convert(varchar(20),t.longitud),',','.')+');'
                                         +'if (markergoogle) {markergoogle.setMap(null)};'
                                         +'markergoogle=new google.maps.Marker({map: mapgoogle, draggable:false});'
                                         +'markergoogle.setPosition(l);'
                                         +'mapgoogle.setCenter(l);'
                                         +' var fenway = {lat: '+replace(convert(varchar(20),t.latitud),',','.')+', lng: '+replace(convert(varchar(20),t.longitud),',','.')+'};'
                                         +' var panorama = new google.maps.StreetViewPanorama(document.getElementById(''mapstrevi_'+@id_mapa+'''), {position: fenway, pov: {heading: 34, pitch: 10} });'
                                         +' mapgoogle.setStreetView(panorama)'
                                        +'})'
           +';'+char(10)   
    from #taotesti t 
    where t.distancia is not null 
      and t.distancia<=@radio
    order by t.distancia
    open c
    fetch next from c into @puntos
    while @@fetch_status=0
          begin
             set @html+=isnull(@puntos,'')+char(10)
             fetch next from c into @puntos
          end
    close c
    deallocate c

    --------------------------

    set @html+='
     //-----------------
     // Mapa de Google
     //-----------------
     var mapOptions = {zoom: 13, mapTypeId:google.maps.MapTypeId.ROADMAP, center: new google.maps.LatLng('+@lat+','+@lng+')};
     mapgoogle      = new google.maps.Map(document.getElementById(''mapgoogle_'+@id_mapa+'''),mapOptions);
     if (markergoogle) {markergoogle.setMap(null)}
     markergoogle=new google.maps.Marker({map: mapgoogle, draggable:false});
     var location=new google.maps.LatLng('+@lat+', '+@lng+');
     markergoogle.setPosition(location);
     mapgoogle.setCenter(location);
     //-------------------
     // Mapa de streeView
     //-------------------
     var fenway = {lat:'+@lat+',lng:'+@lng+'};
     var panorama = new google.maps.StreetViewPanorama(document.getElementById(''mapstrevi_'+@id_mapa+'''), {position: fenway, pov: {heading:34, pitch:10} });
     mapgoogle.setStreetView(panorama);
     $get(''geocercanos'').click();
     '
     +'" >Carga Mapa</a>'
              
    set @html+=
    '<table style="border:solid 0px #000;width:99%;margin:auto;">'

    set @html+=
    '<tr>'
     +'<td style="width:1%;text-align:center;border:solid 1px transparent">'
        +'<span style="cursor:pointer;font-weight:bold;" title="Refrescar" onclick="refrescar.click()">R</span> '
     +'</td>'
     ---------------------
     -- Datos del Informe
     ---------------------
     +'<td style="width:27%;text-align:left;padding-left:5px;border:solid 1px transparent">'
          --------------------------------------------
          +'<span style="color:red;font-size:1.3vw;color:black;font-weight:bold;vertical-align:middle;">'+isnull(@numinfor,'')+'</span>'
          +'<span style="display:inline-block;vertical-align:middle;color:blue;font-size:0.85vw;font-weight:bold  ;width:auto;border:solid 1px transparent;padding-left:5px;">'+isnull(@objeto,'')+'</span>'
          +'<span style="display:inline-block;vertical-align:middle;color:blue;font-size:0.85vw;font-weight:normal;width:auto;border:solid 1px transparent;padding-left:5px;">'+isnull(@tasador,'')+'</span>'
          +'<br><span style="display:inline-block;vertical-align:middle;color:black;font-size:0.85vw;font-weight:normal;width:auto;border:solid 1px transparent">'+isnull(@direccion,'')+'</span>'
          +'<br><span style="padding-left:2px;display:inline-block;width:auto;vertical-align:middle;border:solid 1px transparente">('+@lat+','+@lng+')</span>'
          --------------------------------------------
     +'</td>' 
    -----------------------
    -- Filtros de Testigos
    -----------------------
    set @html+=
     +'<td style="width:auto;text-align:left;border:solid 1px transparent">'
     set @html+=
          +'<input style="vertical-align:middle" type="radio" name="operacion" data-idealista="1" id="opeVTA" checked ><span style="display:inline-block;width:auto;font-size:0.85vw;vertical-align:middle;border:solid 0px #000;;">Venta</span>'
          +'<input style="vertical-align:middle" type="radio" name="operacion" data-idealista="2" id="opeALQ" ><span style="display:inline-block;width:auto;font-size:0.85vw;vertical-align:middle;border:solid 0px #000;;">Alqu.</span>'
          +'<input style="vertical-align:middle" type="radio" name="operacion" data-idealista="3" id="opeOPC" ><span style="display:inline-block;width:auto;font-size:0.85vw;vertical-align:middle;border:solid 0px #000;;">Alqu./Compra</span>'
     set @html+=
     --------------------------------------------
          +'<span style="display:inline-block;width:4vw;vertical-align:middle"></span>'
          +'<input style="vertical-align:middle" id="withcadastralreferenceonly" type="checkbox"><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.85vw;vertical-align:middle;">Sólo con Catastro Informado</span>'
      --------------------------------------------
      set @html+=     
          +'<hr style="border:solid 0px transparent">'
          --------------------------------------------
          +'<span style="display:inline-block;width:4vw;vertical-align:middle;color:black;font-size:0.75vw;font-weight:normal;width:auto;border:solid 1px transparent;padding-left:5px;;padding-right:5px;">Rango Superf.</span>'
          +'<input id="areafrom" type="number" value="'+format(isnull(@areafrom,0),'#')+'" maxlength="6" style="display:inline-block;text-align:right;width:3vw;font-size:0.80vw;color:blue" min="1" max="10000" step="1"/>'
          +'<span style="display:inline-block;width:5px;vertical-align:middle">-</span>'
          +'<input id="areato"   type="number" value="'+format(isnull(@areato  ,0),'#')+'" maxlength="6" style="display:inline-block;text-align:right;width:3vw;font-size:0.80vw;color:blue" min="1" max="10000" step="1"/>'
          --------------------------------------------
          +'<span style="display:inline-block;width:4vw;vertical-align:middle;color:black;font-size:0.75vw;font-weight:normal;width:auto;border:solid 1px transparent;padding-left:5px;padding-right:5px;">Rango Hab.</span>'
          +'<input id="roomnumberfrom" type="number" value="'+format(isnull(@roomnumberfrom,0),'#')+'" maxlength="3" style="display:inline-block;text-align:right;width:2vw;font-size:0.80vw;color:blue" min="1" max="100" step="1"/>'
          +'<span style="display:inline-block;width:5px;vertical-align:middle">-</span>'
          +'<input id="roomnumberto"   type="number" value="'+format(isnull(@roomnumberto,0),'#')+'" maxlength="3" style="display:inline-block;text-align:right;width:2vw;font-size:0.80vw;color:blue" min="1" max="100" step="1"/>'
          --------------------------------------------
          +'<span style="display:inline-block;width:4vw;vertical-align:middle;color:black;font-size:0.75vw;font-weight:normal;width:auto;border:solid 1px transparent;padding-left:5px;;padding-right:5px;">Rango Baños.</span>'
          +'<input id="bathnumberfrom" type="number" value="'+format(isnull(@bathnumberfrom,0),'#')+'" maxlength="3" style="display:inline-block;text-align:right;width:2vw;font-size:0.80vw;color:blue" min="1" max="100" step="1"/>'
          +'<span style="display:inline-block;width:5px;vertical-align:middle">-</span>'
          +'<input id="bathnumberto"   type="number" value="'+format(isnull(@bathnumberto,0),'#')+'" maxlength="3" style="display:inline-block;text-align:right;width:2vw;font-size:0.80vw;color:blue" min="1" max="100" step="1"/>'
          --------------------------------------------
          +'<span style="display:inline-block;width:4vw;vertical-align:middle;color:black;font-size:0.75vw;font-weight:normal;width:auto;border:solid 1px transparent;padding-left:5px;;padding-right:5px;">Rango Año Const.</span>'
          +'<input id="agesince" type="number" value="'+format(isnull(@agesince,0),'#')+'" maxlength="4" style="display:inline-block;text-align:right;width:3vw;font-size:0.80vw;color:blue" min="1900" max="2500" step="1"/>'
          +'<span style="display:inline-block;width:5px;vertical-align:middle">-</span>'
          +'<input id="ageuntil" type="number" value="'+format(isnull(@ageuntil,0),'#')+'" maxlength="4" style="display:inline-block;text-align:right;width:3vw;font-size:0.80vw;color:blue" min="1900" max="2500" step="1"/>'
          --------------------------------------------
     set @html+=
          --------------------------------------------
          +'<hr style="border:solid 0px transparent">'
          +'<input style="vertical-align:middle" id="isingroundfloor" type="checkbox" '+case when isnull(@isingroundfloor ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Bajo</span>'
          +'<input style="vertical-align:middle" id="isinmiddlefloor" type="checkbox" '+case when isnull(@isinmiddlefloor ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Pl.Inter.</span>'
          +'<input style="vertical-align:middle" id="isintopfloor"    type="checkbox" '+case when isnull(@isintopfloor    ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Ático</span>'
          +'<input style="vertical-align:middle" id="hasboxroom"      type="checkbox" '+case when isnull(@hasboxroom      ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Trastero</span>'
          +'<input style="vertical-align:middle" id="hasparkingspace" type="checkbox" '+case when isnull(@hasparkingspace ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Parking</span>'
          +'<input style="vertical-align:middle" id="hasgarden"       type="checkbox" '+case when isnull(@hasgarden       ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Jardín</span>'
          +'<input style="vertical-align:middle" id="hasterrace"      type="checkbox" '+case when isnull(@hasterrace      ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Terraza</span>'
          +'<input style="vertical-align:middle" id="haslift"         type="checkbox" '+case when isnull(@haslift         ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Ascensor</span>'
          +'<input style="vertical-align:middle" id="hasswimmingpool" type="checkbox" '+case when isnull(@hasswimmingpool ,0)=1 then 'checked' else '' end+'><span style="display:inline-block;width:auto;padding-right:0px;font-size:0.75vw;vertical-align:middle;">Piscina</span>'
     +'</td>' 
     --------------------------------------------
     set @html+=
     +'<td rowspan="4" style="width:25%;text-align:left;border:solid 1px transparent;padding-left:6px">'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="1"  id="VIV" '+case when left(@compatible,3)='VIV' then ' checked ' else '' end+case when charindex('VIV',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('VIV',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000">Pisos</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="2"  id="UNI" '+case when left(@compatible,3)='UNI' then ' checked ' else '' end+case when charindex('UNI',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('UNI',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000">Unifam.</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="4"  id="APA" '+case when left(@compatible,3)='APA' then ' checked ' else '' end+case when charindex('APA',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('APA',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000">Garaj.</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="12" id="TRA" '+case when left(@compatible,3)='TRA' then ' checked ' else '' end+case when charindex('TRA',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('TRA',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000">Trast.</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="13" id="EDF" '+case when left(@compatible,3)='EDF' then ' checked ' else '' end+case when charindex('EDF',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('EDF',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000">Edif.</a>'
          +'<hr style="border:solid 0px transparent">'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="6"  id="IND" '+case when left(@compatible,3)='IND' then ' checked ' else '' end+case when charindex('IND',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('IND',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000;">Nav.Ind.</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="6"  id="LOC" '+case when left(@compatible,3)='LOC' then ' checked ' else '' end+case when charindex('LOC',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('LOC',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000;">L.Com.</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="5"  id="OFI" '+case when left(@compatible,3)='OFI' then ' checked ' else '' end+case when charindex('OFI',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('OFI',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000;">Ofic.</a>'
          +'<input style="vertical-align:middle" class="filtrotipo" type="radio" name="tipologia" data-idealista="8"  id="TER" '+case when left(@compatible,3)='TER' then ' checked ' else '' end+case when charindex('TER',@compatible)>0 then '' else ' disabled' end+'><a style="display:inline-block;width:2.2vw;'+case when charindex('TER',@compatible)>0 then '' else 'color:gray;' end+'font-size:0.75vw;vertical-align:middle;border:solid 0px #000;">Terr.</a>'
     set @html+=    
          -----------------------------------------------
          +'<hr style="border:solid 0px transparent">'
          +'<span>Radio(met.):</span>'
          +'<input id="radiocercanos_'+@id_mapa+'" type="range" value="'+format(@distancia,'0')+'" min="20" max="10000" style="width:65%;vertical-align:middle" onchange="refrescar.click();">'
          +'<span style="display:inline-block;width:3vw;;vertical-align:middle;text-align:center;">'+format(@distancia,'0,0','de-DE')+' m.</span>'
          +'<br>'

     set @html+=
          ---------------------
          -- Mostrar los Puntos
          ---------------------
          +'<span style="cursor:pointer;font-weight:bold;font-size:150%;vertical-align:middle;display:none" '
               +' id="geocercanos" '
               +' title="Busca en la base de datos y dibuja los testigos cercanos en el radio informado"'
               +' onclick="var lat='+@lat+'; 
                           var lng='+@lng+';
                           var tipologias=''#listatipos#'';
                           var tipos=document.getElementsByClassName(''filtrotipo'');
                           for (var i=0; i<tipos.length; i++) {if (tipos[i].checked==true) {tipologias+=tipos[i].id+'',''}}
                           tipologias+=''/#listatipos# '';
                           var rad=document.getElementById(''radiocercanos_'+@id_mapa+''').value;
                           var opc='''';
                           opc+=tipologias;
                           if (geopuntos[10000]) {mapLF.removeLayer(geopuntos[10000]); geopuntos[10000]=null;}
                           for (var x = 0; x < 10000; x++) {if (geopuntos[x]) {mapLF.removeLayer(geopuntos[x]); geopuntos[x]=null;}}              // Borrar los geopuntos
                           geopuntos[10000]=L.circle([lat,lng], {radius:rad, color:''blue'',	fillColor:''red'', fillOpacity:0.1	}).addTo(mapLF);  // Radio en Metros
                         ">Mostrar Testigos</span>'
          ---------------------
          -- Vaciar los Puntos
          ---------------------
          +'<span style="display:inline-block;width:5vw;cursor:pointer;font-weight:bold;font-size:0.70vw;display:none"'
               +' id="geovaciar" '
               +' title="Borrar los datos de testigos"'
               +' onclick="var divdatos=document.getElementById(''datos_'+@id_mapa+''');
                           if (divdatos) {divdatos.innerHTML='''';}
                           if (geopuntos[10000]) {mapLF.removeLayer(geopuntos[10000]); geopuntos[10000]=null;}
                           for (var x = 0; x < 10000; x++) {if (geopuntos[x]) {mapLF.removeLayer(geopuntos[x]); geopuntos[x]=null;}}
                           ">Vaciar Testigos</span>'
          --------------
          -- Refrescar
          --------------
          +'<span style="display:inline-block;width:5vw;cursor:pointer;font-weight:bold;font-size:0.70vw;display:none" '
                +'id="refrescar" '
                +'title="refrescar" '
                +'onclick="'+@js_cargar_parametros+'; 
                           var p=''IDEALISTA_Mapa @numinfor ='+isnull('·'+@numinfor+'·','null')+',@usuario ='+format(@usuario,'0')+', @parametros=·''+xmli+''·, @distancia=''+radiocercanos_'+@id_mapa+'.value;
                           WHTML_General(p,0)
                          ">Refrescar</span>'
          -----------------------------------------------
      set @html+=
      +'</td>'
      --------------------------------------------
      set @html+=
      +'<td style="width:3%;text-align:center;border:solid 1px #000;background:#D9F563">'
           +'<span style="cursor:pointer;padding:3px;display:inline-block;width:auto;vertical-align:middle;color:black" title="Solicitar a Idealista Testigos con las condiciones establecidas"'
           +' onclick="'
                       +@js_cargar_parametros+
                     --+' prompt(''datos-xmli'',xmli);'
                      +'var p=''IDEALISTA_Solicitar_Anuncios @numinfor=·'+@numinfor+'·, @js=·OKNORELOAD[INIEVAL]refrescar.onclick()[FINEVAL]·, @parametros=·''+xmli+''·'';'
                     -- +'alert(p);'
                      +'WSQL(p);'
                      +'" '
           +'>Solicitar<br>Idealista</span>'
      +'</td>' 
    +'</tr>'
    set @html+=
    +'</table>'

    ---------------------
    -- Opciones de Capa
    ---------------------

    declare @check_mapa varchar(max)=''
    set @check_mapa+=
    '<div style="border:solid 3px transparent;width:100%;margin:auto;text-align:center">'+char(10)
      +'<input type="checkbox" name="capa1" value="0" onchange="if (this.checked) {layermap[0]=L.esri.basemapLayer(''Streets''      ).addTo(mapLF)} else {if (layermap[0]) {mapLF.removeLayer(layermap[0])}}"><span style="display:inline-block;width:7vw;padding-left:6px;text-align:left;color:blue;">Callejero</span>'
      +'<input type="checkbox" name="capa1" value="1" onchange="if (this.checked) {layermap[1]=L.esri.basemapLayer(''Imagery''      ).addTo(mapLF)} else {if (layermap[1]) {mapLF.removeLayer(layermap[1])}}"><span style="display:inline-block;width:7vw;padding-left:6px;text-align:left;color:blue;">Satelite</span>'
      +'<input type="checkbox" name="capa1" value="2" onchange="if (this.checked) {layermap[2]=L.esri.basemapLayer(''ImageryLabels'').addTo(mapLF)} else {if (layermap[2]) {mapLF.removeLayer(layermap[2])}}"><span style="display:inline-block;width:7vw;padding-left:6px;text-align:left;color:blue;">Etiq. Satélite</span>'
    +'</div>'

    ------------------------
    -- Listado de los Datos
    ------------------------

    declare @htmldatos varchar(max)=''
    set @htmldatos+=
    '<div style="display:inline-block;width:99%;margin:auto;overflow-y:scroll;height:3vh;">'
     +'<table style="border-collapse:collapse;width:99%;margin:auto;font-size:0.65vw;">'
         +'<tr style="color:white;background:black;text-align:center">'
            +'<td style="border:solid 1px #fff;width:  4%;">Origen</td>'
            +'<td style="border:solid 1px #fff;width:auto;">Dirección</td>'
            +'<td style="border:solid 1px #fff;width:  6%;">Fecha</td>'
            +'<td style="border:solid 1px #fff;width:  3%;">Dist.(m.)</td>'
            +'<td style="border:solid 1px #fff;width:  5%;">Precio (€)</td>'
            +'<td style="border:solid 1px #fff;width: 60%;">Comentario</td>'
         +'</tr>'
     +'</table>'
    +'</div>'

    set @htmldatos+=
    '<div style="display:inline-block;width:99%;margin:auto;overflow-y:scroll;height:30vh;">'
     +'<table style="border-collapse:collapse;width:99%;margin:auto;font-size:0.50vw;">'
         +'<tr style="color:white;background:black;text-align:center;font-size:0px">'
            +'<td style="border:solid 0px #fff;width:  4%;"></td>'
            +'<td style="border:solid 0px #fff;width:auto;"></td>'
            +'<td style="border:solid 0px #fff;width:  6%;"></td>'
            +'<td style="border:solid 0px #fff;width:  3%;"></td>'
            +'<td style="border:solid 0px #fff;width:  5%;"></td>'
            +'<td style="border:solid 0px #fff;width: 60%;"></td>'
         +'</tr>'

    select top 60 @htmldatos+=
          '<tr id="testiide_'+s.id+'" class="itemsanuncio" style="color:black;background:transparent;text-align:left">'
             +'<td style="border:solid 1px #aaa;">IDEALISTA</td>'
             +'<td style="border:solid 1px #aaa;">'+isnull(s.streettype+' ','')+isnull(s.streetname+' ','')+isnull(', '+s.streetnumber,'') 
                                                   +'<br>'+isnull(s.town,'')+isnull(s.postalcode,'')+'</td>'
             +'</td>'
             +'<td style="border:solid 1px #aaa;">'+isnull(s.modificationdate,'')+'</td>'
             +'<td style="border:solid 1px #aaa;text-align:center;">'+isnull(format(convert(decimal(19,2),s.distance),'#,#.00','de-DE'),'')+'</td>'
             +'<td style="border:solid 1px #aaa;text-align:right;padding-right:0.2vw;">'+isnull(format(convert(decimal(19,2),s.price),'#,#.00','de-DE'),'')+'</td>'
             +'<td style="border:solid 1px #aaa;padding-left:0.2vw;"><div style="display:inline-block;width:99%;margin:auto;margin-top:4px;margin-bottom:4px;;overflow:auto;max-height:5vh;font-size:0.55vw" >'+isnull(s.comment,'')+'</div></td>'
         +'</tr>'
    from #anuncios s
    where s.latitud_decimal  between @dLatIni and @dLatFin
      and s.longitud_decimal between @dLngIni and @dLngFin
      and posicion.STDistance(@origen)<=@radio
    order by s.Distancia
    
    select top 60 @htmldatos+=
          '<tr id="testith_'+format(s.id,'0')+'" class="itemsanuncio" style="color:black;background:transparent;text-align:left">'
             +'<td style="border:solid 1px #aaa;">TASACION</td>'
             +'<td style="border:solid 1px #aaa;">'+isnull(s.direccion+' ','')+'<br>'+isnull(s.municipio,'')+'</td>'
             +'<td style="border:solid 1px #aaa;">'+isnull(format(s.fechatestigo,'dd/MM/yyyy'),'')+'</td>'
             +'<td style="border:solid 1px #aaa;text-align:center;">'+isnull(format(s.distancia,'#,#.00','de-DE'),'')+'</td>'
             +'<td style="border:solid 1px #aaa;text-align:right;padding-right:0.2vw;">'+isnull(format(s.valor,'#,#.00','de-DE'),'')+'</td>'
             +'<td style="border:solid 1px #aaa;padding-left:0.2vw;">'+isnull(s.comentario,'')+'</td>'
         +'</tr>'
    from #taotesti s 
    where s.distancia is not null 
      and s.distancia<=@radio
    order by s.distancia

    set @htmldatos+=
    +'</table>'
    +'</div>'
    -----------------------
    -- Mapa OpenStreet Map
    -----------------------
    set @html+=
    '<div style="border:solid 1px transparent;width:99%;height:88%;margin:auto;">'
     +'<table style="table-layout:fixed;height:100%;width:100%;margin:auto;border:solid 0px transparent;">'
       +'<tr>'
        +'<td style="width:70%;vertical-align:top">'
           --------------------------------------------------
           +'<div id="seleccionados_:'+@id_mapa+'" style="display:inline-block;border:solid 1px #eee;width:30%;height:45vh;">'
               +'<table style="table-layout:fixed;height:100%;width:100%;margin:auto;border:solid 0px transparent;">'
               +'<tr style="height:0px"><td style="width:5%"></td><td style="width:auto"></td><td style="width:5%"></td></tr>'
               +'<tr><td colspan="2">Testigos Seleccionados</td></tr>'
               +'<tr><td style="text-align:center">Nº</td><td style="text-align:center">Datos</td><td></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 1</td><td id="testi01" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra01" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=1 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 2</td><td id="testi02" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra02" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=2 ;delth.click();" src="'+@ico_bor+'" /></td></tr>' 
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 3</td><td id="testi03" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra03" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=3 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 4</td><td id="testi04" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra04" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=4 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 5</td><td id="testi05" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra05" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=5 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 6</td><td id="testi06" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra06" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=6 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 7</td><td id="testi07" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra07" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=7 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 8</td><td id="testi08" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra08" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=8 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center"> 9</td><td id="testi09" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra09" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=9 ;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center">10</td><td id="testi10" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra10" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=10;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center">11</td><td id="testi11" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra11" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=11;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'<tr id="sel"><td class="seleccionado" style="text-align:center">12</td><td id="testi12" class="seleccionado testisel"></td><td class="seleccionado"><img class="borratestigo" id="borra12" style="display:none;text-align:center;" title="Eliminar Testigo" onclick="delth.dataset.codigo=12;delth.click();" src="'+@ico_bor+'" /></td></tr>'
               +'</table>'
           +'</div>'
           --------------------------------------------------
           +'<div id="mapaLeatFlet_'  +@id_mapa+'" style="display:inline-block;border: solid 1px #eee; width:68%;height:45vh;"></div>'
           --------------------------------------------------
           +@check_mapa
           --+'<hr style="border:solid 3px transparent">'
           --------------------------------------------------
           +'<div id="datosLeatFlet_' +@id_mapa+'" style="display:inline-block;border: solid 1px #eee; width:100%;height:35vh;">'
              +isnull(@htmldatos,'')
           +'</div>'
           --------------------------------------------------
        +'</td>'
        ----------------------
        -- Mapa de Google Map
        ----------------------
        +'<td style="width:auto;">'
          +'<div id="mapgoogle_'+@id_mapa+'" style="border:solid 3px transparent;width:100%;height:25vh;margin:auto"></div>'
          +'<div id="mapstrevi_'+@id_mapa+'" style="border:solid 3px transparent;width:100%;height:55vh;margin:auto"></div>'
        +'</td>'
       +'</tr>'
     +'</table>'
    +'</div>'+char(10)

    -------------------------------
    -- Img para que cargue el mapa
    -------------------------------
        
    set @html+='<img id="cargamapa" src="img\ico_geolocalizar.png" onload="carga_mapa_'+@id_mapa+'.click();cargamapa.style.display=''none'';">'

    -------------------------------------------
    if @imprimir=1 set @html+='</body></html>'
    -------------------------------------------
   
    select  '<resultado>OK</resultado><error></error><salida>'+isnull(@html,'No existen datos')+'</salida>'

    if @debug=1 begin set @paso='Fin' set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicial,getdate())) set @fim=getdate() raiserror(@mess,10,1,0) with nowait end
    if @debug=1 begin set @paso='============================================================' set @mess=@paso; raiserror(@mess,10,1,0) with nowait end

   
end try begin catch

    select  '<resultado>OK</resultado><error></error><salida>'+isnull(ltrim(str(error_line()))+') '+error_message(),'No existen datos')+'</salida>'
        
		  if @debug=1 begin set @paso='ERROR (*) '+@resultado; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicial,getdate())) set @fim=getdate() raiserror(@mess,10,1,0) with nowait end
		  if @debug=1 begin set @paso='============================================================' set @mess=@paso; raiserror(@mess,10,1,0) with nowait end

end catch    

end 
GO
