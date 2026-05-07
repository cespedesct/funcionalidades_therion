SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
exec IDEALISTA_Solicitar_Anuncios 
     @numinfor='26000840'
   , @js='OKNORELOAD[INIEVAL]refrescar.onclick()[FINEVAL]'
   , @parametros='<root><p><c>typologyUNI</c><v>2</v></p><p><c>isinmiddlefloor</c><v>1</v></p><p><c>hasparkingspace</c><v>1</v></p><p><c>hasgarden</c><v>1</v></p><p><c>haslift</c><v>1</v></p><p><c>hasswimmingpool</c><v>1</v></p><p><c>agesince</c><v></v></p><p><c>ageuntil</c><v></v></p><p><c>roomnumberfrom</c><v></v></p><p><c>roomnumberto</c><v></v></p><p><c>bathnumberfrom</c><v></v></p><p><c>bathnumberto</c><v></v></p><p><c>radiocercanos</c><v>2000</v></p></root>'
*/

ALTER procedure [dbo].[IDEALISTA_Solicitar_Anuncios] 
      ( @codigo     int         =null
       ,@numinfor   varchar(10) =null
       ,@js         varchar(max)=null
       ,@parametros varchar(max)=null
       ,@debug      bit=0
      )

as

begin

 /*
 
 declare @url varchar(200)='https://www.idealista.com/data/ws/appraisers/witnesses/details.json'
 declare @headers varchar(200)='Content-Type:application/json|x-api-key:zHuV8jzxo2fMSeUCiPPVBldRpQobBlz877BuEmsB|x-api-version:2'
 declare @body varchar(max)='{"ad_id": 109116202}'
 
 print [CLR_HTTP].dbo.PostText(@url, @headers, @body,'UTF-8')

 */

------------------------------------------
set nocount on
set dateformat dmy                                                                          
set transaction isolation level read uncommitted
-----------------------------------------

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

set @agesince        =case when @agesince      =0 then null else @agesince       end
set @ageuntil        =case when @ageuntil      =0 then null else @ageuntil       end
set @roomnumberfrom  =case when @roomnumberfrom=0 then null else @roomnumberfrom end
set @roomnumberto    =case when @roomnumberto  =0 then null else @roomnumberto   end
set @bathnumberfrom  =case when @bathnumberfrom=0 then null else @bathnumberfrom end
set @bathnumberto    =case when @bathnumberto  =0 then null else @bathnumberto   end
set @areato          =case when @areato        =0 then 1000000 else @areato end

----------------------------------------------------

declare @lat varchar(50)=null
       ,@lng varchar(50)=null
     
select @lat=replace(g.latitud ,',','.')
     , @lng=replace(g.longitud,',','.')
from CORITEL.dbo.taoencar_gps g (nolock) 
where g.numinfor=@numinfor

if @debug=1
   begin
       select
           [@areafrom       ]=@areafrom       
          ,[@areato         ]=@areato         
          ,[@typologyVIV    ]=@typologyVIV    
          ,[@typologyUNI    ]=@typologyUNI    
          ,[@typologyAPA    ]=@typologyAPA    
          ,[@typologyTRA    ]=@typologyTRA    
          ,[@typologyEDF    ]=@typologyEDF    
          ,[@typologyIND    ]=@typologyIND    
          ,[@typologyLOC    ]=@typologyLOC    
          ,[@typologyOFI    ]=@typologyOFI    
          ,[@typologyTER    ]=@typologyTER    
          ,[@isingroundfloor]=@isingroundfloor
          ,[@isinmiddlefloor]=@isinmiddlefloor
          ,[@isintopfloor   ]=@isintopfloor   
          ,[@hasboxroom     ]=@hasboxroom     
          ,[@hasparkingspace]=@hasparkingspace
          ,[@hasgarden      ]=@hasgarden      
          ,[@hasterrace     ]=@hasterrace     
          ,[@haslift        ]=@haslift        
          ,[@hasswimmingpool]=@hasswimmingpool
          ,[@agesince       ]=@agesince       
          ,[@ageuntil       ]=@ageuntil       
          ,[@roomnumberfrom ]=@roomnumberfrom 
          ,[@roomnumberto   ]=@roomnumberto   
          ,[@bathnumberfrom ]=@bathnumberfrom 
          ,[@bathnumberto   ]=@bathnumberto   
          ,[@distance       ]=@distance       
   end

----------------------------------------------------

declare @json_idealista varchar(max)=
'{'
 +'"areafrom":'+case when @areafrom is not null then convert(varchar,@areafrom) else '0'       end
+',"areato":'  +case when @areato   is not null then convert(varchar,@areato  ) else '1000000' end
+',"latitude" :'+@lat+''
+',"longitude":'+@lng+''
------------------------------------
set @json_idealista+=
    case when @operationVTA is not null then ',"operation":'+convert(varchar,@operationVTA) 
         when @operationALQ is not null then ',"operation":'+convert(varchar,@operationALQ) 
         when @operationOPC is not null then ',"operation":'+convert(varchar,@operationOPC) 
         else ',"operation":1'
    end+''
------------------------------------
set @json_idealista+=
+',"removeduplicates":1'
------------------------------------
set @json_idealista+=
    case when @typologyVIV  is not null then ',"typology":'+convert(varchar,@typologyVIV) 
         when @typologyUNI  is not null then ',"typology":'+convert(varchar,@typologyUNI) 
         when @typologyAPA  is not null then ',"typology":'+convert(varchar,@typologyAPA) 
         when @typologyTRA  is not null then ',"typology":'+convert(varchar,@typologyTRA) 
         when @typologyEDF  is not null then ',"typology":'+convert(varchar,@typologyEDF) 
         when @typologyIND  is not null then ',"typology":'+convert(varchar,@typologyIND) 
         when @typologyLOC  is not null then ',"typology":'+convert(varchar,@typologyLOC) 
         when @typologyOFI  is not null then ',"typology":'+convert(varchar,@typologyOFI) 
         when @typologyTER  is not null then ',"typology":'+convert(varchar,@typologyTER) 
         else ',"typology":1'
    end+''
-------------------------------------
set @json_idealista+=
     case when @withcadastralreferenceonly is not null then ',"withcadastralreferenceonly":'+convert(varchar,@withcadastralreferenceonly) else '' end
-------------------------------------
set @json_idealista+=
     case when @isingroundfloor is not null then ',"isingroundfloor":'+convert(varchar,@isingroundfloor) else '' end
    +case when @isinmiddlefloor is not null then ',"isinmiddlefloor":'+convert(varchar,@isinmiddlefloor) else '' end
    +case when @isintopfloor    is not null then ',"isintopfloor":'   +convert(varchar,@isintopfloor   ) else '' end
    +case when @hasboxroom      is not null then ',"hasboxroom":'     +convert(varchar,@hasboxroom     ) else '' end
    +case when @hasparkingspace is not null then ',"hasparkingspace":'+convert(varchar,@hasparkingspace) else '' end
    +case when @hasgarden       is not null then ',"hasgarden":'      +convert(varchar,@hasgarden      ) else '' end
    +case when @hasterrace      is not null then ',"hasterrace":'     +convert(varchar,@hasterrace     ) else '' end
    +case when @haslift         is not null then ',"haslift":'        +convert(varchar,@haslift        ) else '' end
    +case when @hasswimmingpool is not null then ',"hasswimmingpool":'+convert(varchar,@hasswimmingpool) else '' end
-------------------------------------
set @json_idealista+=
    +case when @agesince        is not null then ',"agesince":'       +convert(varchar,@agesince       ) else '' end
    +case when @ageuntil        is not null then ',"ageuntil":'       +convert(varchar,@ageuntil       ) else '' end
    +case when @roomnumberfrom  is not null then ',"roomnumberfrom":' +convert(varchar,@roomnumberfrom ) else '' end
    +case when @roomnumberto    is not null then ',"roomnumberto":'   +convert(varchar,@roomnumberto   ) else '' end
    +case when @bathnumberfrom  is not null then ',"bathnumberfrom":' +convert(varchar,@bathnumberfrom ) else '' end
    +case when @bathnumberto    is not null then ',"bathnumberto":'   +convert(varchar,@bathnumberto   ) else '' end
-------------------------------------
set @json_idealista+=
    +case when @distance        is not null then ',"distance":'       +convert(varchar,@distance       ) else '' end
-------------------------------------
set @json_idealista+=
    +'}'

----------------------------------------------------

/*

area                         => integer  => Si se establece 'areamargin', el tamaño del área de la propiedad
areamargin                   => float    => Si se establece 'área', la relación superior e inferior se aplicará al campo de tamaño del área entre 0 y 1
areafrom                     => integer  => Si no se establece 'área', límite inferior para el tamaño del área de la propiedad.
areato                       => integer  => Si no se establece 'área', límite superior para el tamaño del área de la propiedad
latitude                     => float    => Latitud para la solicitud con un punto para separar decimales
longitude                    => float    => Longitud para la solicitud con un punto para separar decimales
operation                    =>          => '#/components/schemas/Operation'
         1 => Venta
         2 => Alquiler
         3 => Alquiler con opción a compra   
typology                     =>          => '#/components/schemas/Typology' => '#/components/schemas/Subtypology'
         1 => Home           
         2 => Chalet         
              0 => Unknown           
              1 => Villa             
              2 => Adosado
              3 => SemiAdosado
              4 => Independiente       
              5 => Andar de moradia  
         3 => Casa de campo
               0 => Desconocido
               1 => Country house   
               2 => Castillo
               3 => Palacio        
               4 => Masía           
               5 => Cortijo         
               6 => Casale          
               7 => Casa de pueblo  
               8 => Casa terrera    
               9 => Casa mata       
              10 => Torre           
              11 => Caserón         
              12 => Pazo            
              13 => Villa           
              14 => Palacete        
              15 => Masseria        
              16 => Fattoria        
              17 => Trullo          
              18 => Casali/Cascine  
              19 => Baita           
              20 => Quinta          
              21 => Moinho          
              22 => Monte alentejano
              23 => Solar           
         4 => Garage         
               0 => Desconocido
               1 => Aparcamiento propio         
               2 => Plaza de aparcamiento
         5 => Office         
         6 => Almacén
              0 => Desconocido
              1 => Local comercial
              2 => Local industrial
         7 => Habitación           
              0 => Desconocido
              1 => En Piso compartido
              2 => En Chalet compartido
         8 => Terreno            
              0 => Desconocido
              1 => Urbano
              2 => Terreno rústico disponible para construir
              3 => Terreno rústico
        10 => Nuevo desarrollo
        11 => Anuncio personalizado
        12 => Trastero   
        13 => Edificio       

distance                     => float    => Distancia de los testigos al punto construido con latitud y longitud en metros.
builttype                    =>          => '#/components/schemas/BuiltType'
agesince                     => string   => Límite inferior para el año de construcción de la propiedad. ('1950')
ageuntil                     => string   => Límite superior para el año de construcción de la propiedad. ('1990')
propertytype                 =>          => '#/components/schemas/PropertyType'
roomnumber                   => integer  => Número de habitaciones incluidas en la propiedad.
roomnumberfrom               => integer  => Límite inferior para el número de habitaciones incluidas en la propiedad
roomnumberto                 => integer  => Límite superior para el número de habitaciones incluidas en la propiedad
bathnumber                   => integer  => Número de baños incluidos en la propiedad
bathnumberfrom               => integer  => Límite Inferior de Número de baños incluidos en la propiedad
bathnumberto                 => integer  => Límite Superior de Número de baños incluidos en la propiedad

withcadastralreferenceonly   => boolean  => Valor que define si la respuesta solo contiene testigos coincidentes con el catastro (false/true)
applyunitpricebounds         => boolean  => Valor que define si la respuesta evita valores extremos de precios unitarios (false/true)
removeduplicates             => boolean  => Valor que define si se eliminan los testigos que consideramos como duplicados (false/true)
isingroundfloor              => boolean  => Valor que define si esta en planta baja (false/true)
isinmiddlefloor              => boolean  => Valor que define si está en piso medio (false/true)
isintopfloor                 => boolean  => Valor que define si está en el piso superior (false/true)
hasboxroom                   => boolean  => Valor que define si tiene trastero (false/true)
hasgarden                    => boolean  => Valor que define si tiene jardin (false/true)
haslift                      => boolean  => Valor booleano que define si tiene elevación (false/true) 
hasparkingspace              => boolean  => Valor que define si tiene espacio de estacionamiento (false/true) 
hasswimmingpool              => boolean  => Valor que define si tiene piscina (false/true) 
hasterrace                   => boolean  => Value that defines if has terrace (false/true) 
pagefrom                     => integer  => Número de página de respuesta

*/



declare @url     nvarchar(200)='https://www.idealista.com/data/ws/appraisers/witnesses/list.json'
declare @headers nvarchar(200)='Content-Type:application/json|x-api-key:zHuV8jzxo2fMSeUCiPPVBldRpQobBlz877BuEmsB|x-api-version:2'
declare @body    nvarchar(max)=@json_idealista --'{"areafrom":20,"areato":250,"latitude":'+@lat+',"longitude":'+@lng+',"operation":1,"typology":1,"distance":10000, "responses":10}'
declare @res     varchar(max)

--print @headers
--print @body

--set @js='alert("'+isnull(@json_idealista,'null')+'");'
select @url as URL, @headers as HEADERS, @body as BODY

end

GO
