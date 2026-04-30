SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- https://app.tasacioneshipotecarias.com/ether/FRTHERION_EXT.aspx?peticion=AgAAAPZBpajgsF9HhQzFoGj/JIbRSae4hWOApSFDlcHidx+mbW2WitsSn4kPe7zMV6NXv4PlUYOiRtALhPan4bc+4KtsXP0y+Eh9Ecvrdjgs0j+hh3xIpPRBdOf/xQsTpI+hEA==
-- print dbo.f_Parametro_SISTEMA('urlexternas')+dbo.THERION_EnCriptar_Cadena_con_Clave  ('TH_Clientes_Acceso_Externo_Solicitar_Presupuesto @fk_usuario=1','19271812')

-- exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto @fk_usuario=1, @debug=1

ALTER procedure  [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto] 
     ( @debug        bit=0
     , @fk_usuario   int=null
     , @tipo_tasador int=null    -- puede ser 1-PIN o 2-PON que corresponde al corto del expediente
     )

 as 

------------------------------------------
set nocount on
set dateformat dmy                                                                          
set transaction isolation level read uncommitted
------------------------------------------

begin

declare @prbbdd        varchar(300)=object_name(@@procid)
declare @paso          char   (80)='Sin Iniciar'
      , @mess          varchar(max)
      , @fis           datetime=getdate()
      , @fip           datetime=getdate()
      , @traza         varchar(200)
declare @trancount     int=@@trancount

begin try

      set @paso=@prbbdd+' ======================================================================='; set @mess=@paso; raiserror(@mess,10,1,0) with nowait
      set @paso=space(len(@prbbdd))+' -> Inicio'; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fis,getdate())) set @fis=getdate() raiserror(@mess,10,1,0) with nowait

      declare @radius     varchar(80)='0vw 0vw vw 0vw'
             ,@sombra     varchar(80)='0px 10px 10px -5px rgba(0,0,0,1)'
             ,@sombra_des varchar(80)='0px 10px 30px -15px rgba(255,255,255,1)'

      declare @semilla_ficheros     varchar(200)='[V'+replace(replace(replace(replace(convert(varchar(100),getdate(),121),':',''),'.',''),'-',''),' ','')+']'
      declare @semilla_verificacion varchar(200)=convert(varchar(200),newid())
      declare @usuario              varchar(200)=''
      declare @corto                varchar(10) ='WEB'

      ---------------------------------------
      -- Establecer el corto para el informe
      ---------------------------------------

      if @tipo_tasador is not null
         begin
           set @corto=case when @tipo_tasador=1 then 'PIN'
                           when @tipo_tasador=2 then 'PON'
                           else 'WEB'
                      end
           select @usuario=u.descripcion from usuarios u (nolock) where u.codigo=@fk_usuario
         end

      -----------------------------------------
      -- Comprobar si es un colaborador externo
      -----------------------------------------

      declare @chk_externo bit=0
      if @fk_usuario is not null and @tipo_tasador is null
         begin
           select @usuario    =u.descripcion 
                 ,@corto      =v.codentid
                 ,@chk_externo=1
           from TH_Presupuestos_API_Vendedores v (nolock) 
           inner join usuarios u (nolock) on u.codigo=v.fk_usuarios
           where v.fk_usuarios=@fk_usuario
         end

      -----------------------------------------
      -- Comprobar si es un usuario interno
      -----------------------------------------

      if @fk_usuario is not null and @tipo_tasador is null and @chk_externo=0
         begin
           select @usuario=u.descripcion from usuarios u (nolock) where u.codigo=@fk_usuario
           set @corto=(select top 1 e.codentid from TH_Entidades e (nolock) where e.fk_usuario_comercial=@fk_usuario)
           if isnull(@corto,'')=''
              begin
                set @corto='PAR'
              end
         end

      -----------------------
      -- Prefijos de móviles
      -----------------------

      declare @lista_prefijos varchar(max)=
       'Estados Unidos/Canada: +1,México: +52 ,Brasil: +55,Argentina: +54 ,Colombia: +57,Chile: +56,Venezuela: +58'
      +',Perú: +51,Ecuador: +593,Cuba: +53 ,Bolivia: +591,Costa Rica: +506,Panamá: +507,Uruguay: +598,España: +34' 
      +',Alemania: +49,Francia: +33,Italia: +39 ,Reino Unido: +44,Rusia: +7,Ucrania: +380,Polonia: +48,Rumania: +40'
      +',Países Bajos: +31  ,Bélgica: +32,Grecia: +30 ,Portugal: +351,Suecia: +46  ,Noruega: +47,China: +86'
      +',India: +91,Japón: +81,Corea del Sur: +82,Indonesia: +62,Turquía: +90 ,Filipinas: +63  ,Tailandia: +66  ,Vietnam: +84'
      +',Israel: +972 ,Malasia: +60,Singapur: +65,Pakistán: +92,Bangladés: +880,Arabia Saudita: +966  ,Egipto: +20 ,Sudáfrica: +27'  
      +',Nigeria: +234,Kenia: +254 ,Marruecos: +212 ,Argelia: +213,Uganda: +256 ,Ghana: +233 ,Camerún: +237,Costa de Marfil: +225' 
      +',Senegal: +221,Tanzania: +255  ,Sudán: +249 ,Libia: +218,Túnez: +216  ,Australia: +61  ,Nueva Zelanda: +64,Fiji: +679'
      +',Papúa Nueva Guinea: +675 ,Tonga: +676 ,Irán: +98 ,Iraq: +964,Jordania: +962 ,Líbano: +961,Kuwait: +965,Emiratos Árabes Unidos: +971'
      +',Omán: +968,Catar: +974 ,Bahrein: +973,Yemen: +967'

      declare @option_prefijos varchar(max)=''

      select @option_prefijos+='<option value="'+ltrim(rtrim(prefijo.items))+'"'+case when ltrim(rtrim(prefijo.items))='+34' then ' selected ' else '' end +'>'+ltrim(rtrim(prefijo.items))+' ('+ltrim(rtrim(pais.items))+')</option>'
      from dbo.f_split(@lista_prefijos,',') a 
      outer apply (select x.items from dbo.f_split(ltrim(rtrim(a.items)),':') x where x.i=1) pais
      outer apply (select x.items from dbo.f_split(ltrim(rtrim(a.items)),':') x where x.i=2) prefijo
      where ltrim(rtrim(a.items))!=''
      order by ltrim(rtrim(pais.items))
            
      declare @html varchar(max)=''

      set @html+=
          +' <!DOCTYPE html>'+char(10)
          +' <html lang="es">'+char(10)
          +' <head>'+char(10)
          +'   <meta charset="utf-8">'+char(10)
          +'   <meta name="viewport" content="width=device-width, initial-scale=1">'+char(10)
          +'   <script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>'+char(10)
          +'   <script src="https://code.jquery.com/ui/1.11.1/jquery-ui.min.js"></script>'+char(10)
          +'   <link rel="stylesheet" href="https://code.jquery.com/ui/1.11.1/themes/smoothness/jquery-ui.css" />'+char(10)
          +' </head>'+char(10)

     declare @favicon varchar(max)='img/faviconth.png'
     set @html+=
          +'<script type="text/javascript">'
      +'   // ---------------------
           // -- Cambiar Favicon
           // ---------------------
           function CambiarFavIcon() { 
           var link = document.querySelector("link[rel~=''icon'']");
           if (!link) {
               link    =document.createElement("link");
               link.rel="icon";
               document.getElementsByTagName("head")[0].appendChild(link);
           }
           link.href="'+@favicon+'";
           document.title = "Presupuesto";
          }'+char(10)
      +'</script>'
      set @html+=  
       +'<script type="text/javascript">'
      +'// --- Normalización de nombres de archivos ---'+char(10)
      +'function normalizeFileName(fileName) {'+char(10)
      +'    return fileName'+char(10)
      +'        .replace(/Ñ/g, "N")'+char(10)
      +'        .replace(/ñ/g, "n")'+char(10)
      +'        .replace(/#/g, "_")'+char(10)
      +'        .normalize("NFD")'+char(10)
      +'        .replace(/[\u0300-\u036f]/g, "")'+char(10)
      +'        .replace(/[^a-zA-Z0-9._-]/g, "_");'+char(10)
      +'}'+char(10)

        +'function Subeficheros_Normalizado(input, panel) {'+char(10)
        +'    if (input.files && input.files.length > 0) {'+char(10)
        +'        var file = input.files[0];'+char(10)
        +'        var normalized = normalizeFileName(file.name);'+char(10)
        +'        if (file.name !== normalized) {'+char(10)
        +'            var dataTransfer = new DataTransfer();'+char(10)
        +'            var newFile = new File([file], normalized, { type: file.type });'+char(10)
        +'            dataTransfer.items.add(newFile);'+char(10)
        +'            input.files = dataTransfer.files;'+char(10)
        +'        }'+char(10)
        +'    }'+char(10)
        +'    Subeficheros(input, panel);'+char(10)
        +'}'+char(10)
      +'</script>'
      
     set @html+=
      +'<script type="text/javascript">'
      +' function RellenaFicheroTransferencia() { alert(PGFiles_transferencia.innerHTML)
          }'+char(10)
      +'</script>'
      -----------------------------------------
      set @html+=
          +'<style type="text/css">'
          +' a.btn           {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;border:solid 2px gray;color:black;padding:4px 4px;cursor:pointer;border-radius:5px;font-size:0.70vw;font-weight:normal}'
          +' a.primary       {background:LightSteelBlue;border:solid 2px gray;} '
          +' a.primary:hover {background:CornflowerBlue;color:white;border:solid 2px black;}'
          +' input, select   {font-size:0.8vw;font-size:font-family:''Open Sans'',''Helvetica Neue'',helvetica,arial,sans-serif;vertical-align:middle;height:2vh}'
          +' p.separatasec   {height:2vh;border:solid 1px transparent;margin:0;background:#fff;width:36.6vw;}'
          +' p.separatacam   {height:3px;border:solid 1px transparent;margin:0}'
          +' div.saltopag    {display:block;page-break-before:always;}'
          +' td.etiqueta, td.datoencargo, td.aportacion, td.datoimporte {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:black;font-size:0.8vw;padding-right:0.5vw;text-align:left;vertical-align:middle;border-bottom:solid 1px transparent;border-right:solid 4px #92575b}'
          +' td.etiqueta     {width:13% ;padding-right:0.5vw;text-align:right;border-bottom:solid 1px transparent;border-right:solid 4px #92575b}'
                +' td.datoencargo  {width:100%;padding-left :0.5vw;border:solid 1px transparent}'
                +' td.datoimporte  {width:100%;padding-left :0.5vw;border:solid 1px transparent; display:flex; flex-direction:row}'
                +' td.aportacion   {width:40% ;font-size:0.75vw;font-weight:bold;padding-left:0.5vwborder:solid 1px transparent;border-left:solid 0px #92575b}'
                +' td.resto        {width:auto;font-size:0.75vw;font-weight:bold;padding-left:0.5vwborder:solid 1px transparent;border-left:solid 0px #92575b}
             #outerContainer #mainContainer div.toolbar {display: none !important;}
             #outerContainer #mainContainer #viewerContainer {top: 0 !important;}                              
           '

     set @html+='input[type="radio"]  {
                    height: 1vh;                 /* or whatever */
                    width:  0.5vw;               /* or whatever */
                    border: 0.1vw solid #999;    /* or whatever */
                    border-radius: 50%;          /* make it round */
                    transition: 0.2s all linear; /* just to make it change smoothly */
                  }
                  input[type="radio"]:checked {border: 0.2vw solid blue; /* make it change visually when checked */ }

                  input[type="checkbox"]  {
                    content: "\2714";
                    height: 2vh;
                    width:  1vw;
                    border: 0.1vw solid #999;
                    transition: 0.2s all linear;
                  }
                  input[type="checkbox"]:checked {border: 0.7vw solid blue; /* make it change visually when checked */ }
               '
      set @html+=
          +'  a.etiqueta     {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:black;font-size:0.8vw;font-weight:normal;text-align:right;padding-left:0.5vw;padding-right:0.2vw;margin:auto;vertical-align:middle;border:solid 1px transparent}'
          +'  a.etipri       {display:inline-block;width:14vw;}'
          +'  a.opensans     {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif}'
          +'  a.etisig       {display:inline-block;width:4vw;}'
          +' td.titulo       {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;width:auto;background:black;opacity:1;vertical-align:middle;font-size:2vw;font-weight:bold;padding-left:2vw;color:white;'
                             +';border-radius:'+@radius+';-ms-border-radius:'+@radius+';-moz-border-radius:'+@radius+';-webkit-border-radius:'+@radius+';-khtml-border-radius:'+@radius
                             +';box-shadow:'+@sombra+';-webkit-box-shadow:'+@sombra+';-moz-box-shadow:'+@sombra+';-ms-box-shadow:'+@sombra+';-o-box-shadow:'+@sombra+'} div.cita:hover {overflow:auto}'
          +' td.eticomp      {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:black;font-size:1vw;font-weight:bold;vertical-align:middle;border-bottom:solid 0px #aaa;padding-top:10px;display:flex; flex-direction:row}'
          +' td.eticomp_2    {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:black;font-size:0.85vw;font-weight:normal;vertical-align:middle;border-bottom:solid 0px #aaa;padding:8px}'
          +' td.etiquetabajo {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:white;font-size:0.8vw;font-weight:normal;padding-left :0.3vw;text-align:left;vertical-align:middle;border-bottom:solid 0px #aaa}'
          +' td.datoabajo    {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:white;font-size:0.8vw;font-weight:bold  ;padding-right:0.3vw;text-align:left;vertical-align:middle;border-bottom:solid 0px #aaa}'
          +' li.itemabajo    {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:white;font-size:0.8vw;font-weight:bold  ;padding-right:0.3vw;text-align:left;vertical-align:middle;border-bottom:solid 0px #aaa}'
          +'  a.itemabajo    {font-family:"Open Sans","Helvetica Neue",helvetica,arial,sans-serif;color:white;font-size:0.8vw;font-weight:normal;padding-right:0.3vw;text-align:left;vertical-align:middle;border-bottom:solid 0px #aaa}'
          +'img.acciones     {cursor:pointer;vertical-align:middle;width:2vw;height:auto;transition:500ms;padding-right:1vw;} img.acciones:hover {transform: scale(1.2);transition:500ms;}'

      set @html+=
          +' div.abajo  {border-radius:'+@radius+';-ms-border-radius:'+@radius+';-moz-border-radius:'+@radius+';-webkit-border-radius:'+@radius+';-khtml-border-radius:'+@radius
                      +';box-shadow:'+@sombra+';-webkit-box-shadow:'+@sombra+';-moz-box-shadow:'+@sombra+';-ms-box-shadow:'+@sombra+';-o-box-shadow:'+@sombra+'}'
      set @html+=
          +'</style> '

       declare @logo_th varchar(max)='<img style="width:9vw;height:auto" src="imgEXT/LOGO_TH.png" class="custom-logo" alt="" decoding="async">'

      --########################
      --------------------------
      -- Icono de Grabar datos
      --------------------------
      --########################

      declare @ico_grabacion    varchar(max)='' 
      declare @ico_verificacion varchar(max)='' 
      declare @ico_validacion varchar(max)='' 

      declare @ico_nueva_verificacion varchar(max)=''

      ---------------------------------------
      
      set @ico_verificacion ='<img alt="X" id="ico_verificacion" class="acciones" src="imgEXT/Enviar_SMS_verificacion.png" title="Solicitar Código de Verificación"'+char(10)
      set @ico_validacion   ='<img alt="X" id="ico_validacion"   class="acciones" src="imgEXT/Verificar_Informe_TH.png" title="Validar Justificante de Transferencia"'+char(10)

      ---------------------------------------
      ---------------------------------------

      set @ico_grabacion    ='<a class="btn primary" style="font-size:1vw;" title="Enviar Solicitud" '+char(10)
      set @ico_grabacion+=
         +' onclick="'
                 +' '
      ---------------------------------------
      ---------------------------------------
      
      ----------------------------------------
      -- Montaje del XML de datos introducidos
      /*

       Relacion de campos

       rpersona
       rempresa
       nombresolicitante
       apellidossolicitante
       dnisolicitante
       empresasolicitante
       cifsolicitante
       emailsolicitante

       calle_sol
       numerocalle_sol
       portal_sol
       escalera_sol
       piso_sol
       letra_sol
       anexo_sol
       codigopostal_sol
       municipio_sol

       rpersona_fac
       rempresa_fac
       nombresolicitante_fac
       apellidossolicitante_fac
       dnisolicitante_fac
       empresasolicitante_fac
       cifsolicitante_fac
       emailsolicitante_fac

       calle_fac
       numerocalle_fac
       portal_fac
       escalera_fac
       piso_fac
       letra_fac
       anexo_fac
       codigopostal_fac
       municipio_fac

       tipoinmueble
       finalidad
       calle
       numerocalle
       portal
       escalera
       piso
       letra
       anexo
       codigopostal
       municipio
       refcatastral
       regpropiedad
       fincaregistral
       idufir
       nombrecontacto
       telefonocontacto
       tramitacionurgente
       mismocontactogestion
       otrocontactogestion
       nombrecontactogestion
       apellidoscontactogestion
       dnicontactogestion
       telefonocontactogestion
       emailcontactogestion
       aceptaciondatos
       telefonoverificacion
       llaveenvio

       +' xmli+=''<p><c>rpersona</c><v>''                +rpersona.value+''</v></p>'';'
       +' xmli+=''<p><c>rempresa</c><v>''                +rempresa.value+''</v></p>'';'
       +' xmli+=''<p><c>nombresolicitante</c><v>''       +nombresolicitante.value+''</v></p>'';'
       +' xmli+=''<p><c>apellidossolicitante</c><v>''    +apellidossolicitante.value+''</v></p>'';'
       +' xmli+=''<p><c>dnisolicitante</c><v>''          +dnisolicitante.value+''</v></p>'';'
       +' xmli+=''<p><c>empresasolicitante</c><v>''      +empresasolicitante.value+''</v></p>'';'
       +' xmli+=''<p><c>cifsolicitante</c><v>''          +cifsolicitante.value+''</v></p>'';'
       +' xmli+=''<p><c>emailsolicitante</c><v>''        +emailsolicitante.value+''</v></p>'';'
       
       +' xmli+=''<p><c>calle_sol</c><v>''               +calle_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>numerocalle_sol</c><v>''         +numerocalle_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>portal_sol</c><v>''              +portal_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>escalera_sol</c><v>''            +escalera_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>piso_sol</c><v>''                +piso_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>letra_sol</c><v>''               +letra_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>anexo_sol</c><v>''               +anexo_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>codigopostal_sol</c><v>''        +codigopostal_sol.value+''</v></p>'';'
       +' xmli+=''<p><c>municipio_sol</c><v>''           +municipio_sol.value+''</v></p>'';'

       +' xmli+=''<p><c>rpersona_fac</c><v>''            +rpersona_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>rempresa_fac</c><v>''            +rempresa_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>nombresolicitante_fac</c><v>''   +nombresolicitante_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>apellidossolicitante_fac</c><v>''+apellidossolicitante_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>dnisolicitante_fac</c><v>''      +dnisolicitante_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>empresasolicitante_fac</c><v>''  +empresasolicitante_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>cifsolicitante_fac</c><v>''      +cifsolicitante_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>emailsolicitante_fac</c><v>''    +emailsolicitante_fac.value+''</v></p>'';'

       +' xmli+=''<p><c>calle_fac><v>''                  +calle_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>numerocalle_fac</c><v>''         +numerocalle_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>portal_fac</c><v>''              +portal_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>escalera_fac</c><v>''            +escalera_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>piso_fac</c><v>''                +piso_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>letra_fac</c><v>''               +letra_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>anexo_fac</c><v>''               +anexo_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>codigopostal_fac</c><v>''        +codigopostal_fac.value+''</v></p>'';'
       +' xmli+=''<p><c>municipio_fac</c><v>''           +municipio_fac.value+''</v></p>'';'

       +' xmli+=''<p><c>tipoinmueble</c><v>''            +tipoinmueble.value+''</v></p>'';'
       +' xmli+=''<p><c>finalidad</c><v>''               +finalidad.value+''</v></p>'';'
       +' xmli+=''<p><c>calle</c><v>''                   +calle.value+''</v></p>'';'
       +' xmli+=''<p><c>numerocalle</c><v>''             +numerocalle.value+''</v></p>'';'
       +' xmli+=''<p><c>portal</c><v>''                  +portal.value+''</v></p>'';'
       +' xmli+=''<p><c>escalera</c><v>''                +escalera.value+''</v></p>'';'
       +' xmli+=''<p><c>piso</c><v>''                    +piso.value+''</v></p>'';'
       +' xmli+=''<p><c>letra</c><v>''                   +letra.value+''</v></p>'';'
       +' xmli+=''<p><c>anexo</c><v>''                   +anexo.value+''</v></p>'';'
       +' xmli+=''<p><c>codigopostal</c><v>''            +codigopostal.value+''</v></p>'';'
       +' xmli+=''<p><c>municipio</c><v>''               +municipio.value+''</v></p>'';'
       +' xmli+=''<p><c>refcatastral</c><v>''            +refcatastral.value+''</v></p>'';'
       +' xmli+=''<p><c>superficie</c><v>''              +superficie.value+''</v></p>'';'
       +' xmli+=''<p><c>regpropiedad</c><v>''            +sch_regpropiedad.value+''</v></p>'';'
       +' xmli+=''<p><c>fincaregistral</c><v>''          +fincaregistral.value+''</v></p>'';'
       +' xmli+=''<p><c>idufir</c><v>''                  +idufir.value+''</v></p>'';'
       +' xmli+=''<p><c>nombrecontacto</c><v>''          +nombrecontacto.value+''</v></p>'';'
       +' xmli+=''<p><c>telefonocontacto</c><v>''        +telefonocontacto.value+''</v></p>'';'
       +' xmli+=''<p><c>tramitacionurgente</c><v>''      +tramitacionurgente.value+''</v></p>'';'
       +' xmli+=''<p><c>mismocontactogestion</c><v>''    +mismocontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>otrocontactogestion</c><v>''     +otrocontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>nombrecontactogestion</c><v>''   +nombrecontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>apellidoscontactogestion</c><v>''+apellidoscontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>dnicontactogestion</c><v>''      +dnicontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>telefonocontactogestion</c><v>'' +telefonocontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>emailcontactogestion</c><v>''    +emailcontactogestion.value+''</v></p>'';'
       +' xmli+=''<p><c>aceptaciondatos</c><v>''         +aceptaciondatos.value+''</v></p>'';'
       +' xmli+=''<p><c>telefonoverificacion</c><v>''    +telefonoverificacion.value+''</v></p>'';'
       +' xmli+=''<p><c>llaveenvio</c><v>''              +llaveenvio.value+''</v></p>'';'
       +' xmli+=''<p><c>importemanual</c><v>''           +importemanual.value+''</v></p>'';'

      */
      ----------------------------------------
      set @ico_grabacion+=
      +' var xmli    ='''';'
      +' var xmli_sol='''';'
      +' var xmli_fac='''';'
      +' var xmli_inm='''';'
      +' var xmli_con='''';'
      +' var xmli_ver='''';'
      -------------------------------------------------------------------------------------------------
      +' xmli+=''<p><c>tabla_asociada</c><v>TH_Presupuestos_WEB_'+@semilla_ficheros+'</v></p>'';'
      +' xmli+=''<p><c>tabla_asociada_justificante</c><v>TH_Presupuestos_WEB_justificante_'+@semilla_ficheros+'</v></p>'';'
      +' xmli+=''<p><c>tabla_asociada_notasimple</c><v>TH_Presupuestos_WEB_notasimple_'+@semilla_ficheros+'</v></p>'';'
      +' xmli+=''<p><c>tabla_asociada_otrosficheros</c><v>TH_Presupuestos_WEB_otrosficheros_'+@semilla_ficheros+'</v></p>'';'
      +' xmli+=''<p><c>tabla_asociada_transferencia</c><v>TH_Presupuestos_WEB_transferencia_'+@semilla_ficheros+'</v></p>'';'
      +' xmli+=''<p><c>semillapresupuesto</c><v>'+@semilla_verificacion+'</v></p>'';'
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' if (tramitacionurgente.checked)   {xmli+=''<p><c>tramitacionurgente</c><v>1</v></p>''  } else {xmli+=''<p><c>tramitacionurgente</c><v>0</v></p>'' };'
      -------------------------------------------------------------------------------------------------
      if @fk_usuario is not null
         begin
            set @ico_grabacion+=
            ' xmli+=''<p><c>fk_usuario</c><v>'+format(@fk_usuario,'0')+'</v></p>'';'
         end
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      ' xmli+=''<p><c>codentid</c><v>'+@corto+'</v></p>'';'
      -------------------------------------------------------------------------------------------------
      if @fk_usuario is null
         begin
            set @ico_grabacion+=
                +' if (aceptaciondatos.checked) {xmli+=''<p><c>aceptaciondatos</c><v>1</v></p>''} else {xmli+=''<p><c>aceptaciondatos</c><v>0</v></p>''};'
         end
      -------------------------------------------------------------------------------------------------
      if @fk_usuario is null
         begin
            set @ico_grabacion+=
                +' xmli_ver+=''<p><c>telefonoverificacion</c><v>''    +telefonoverificacion.value+''</v></p>'';'
                +' xmli_ver+=''<p><c>llaveenvio</c><v>''              +llaveenvio.value+''</v></p>'';'
         end
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' if (rpersona.checked) {xmli_sol+=''<p><c>rpersona</c><v>1</v></p>''} else {xmli_sol+=''<p><c>rpersona</c><v>0</v></p>''};'
      +' if (rempresa.checked) {xmli_sol+=''<p><c>rempresa</c><v>1</v></p>''} else {xmli_sol+=''<p><c>rempresa</c><v>0</v></p>''};'
      +' if (rpersona.checked) {xmli_sol+=''<p><c>nombresolicitante</c><v>''       +nombresolicitante.value+''</v></p>''};'
      +' if (rpersona.checked) {xmli_sol+=''<p><c>apellidossolicitante</c><v>''    +apellidossolicitante.value+''</v></p>''};'
      +' if (rpersona.checked) {xmli_sol+=''<p><c>dnisolicitante</c><v>''          +dnisolicitante.value+''</v></p>''};'
      +' if (rempresa.checked) {xmli_sol+=''<p><c>empresasolicitante</c><v>''      +empresasolicitante.value+''</v></p>''};'
      +' if (rempresa.checked) {xmli_sol+=''<p><c>cifsolicitante</c><v>''          +cifsolicitante.value+''</v></p>''};'
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_sol+=''<p><c>emailsolicitante</c><v>''   +emailsolicitante.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>emaildoc</c><v>''           +emaildoc.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>emailfac</c><v>''           +emailfac.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>telefonosolicitante</c><v>''+telefonosolicitante.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>calle_sol</c><v>''          +calle_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>numerocalle_sol</c><v>''    +numerocalle_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>portal_sol</c><v>''         +portal_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>escalera_sol</c><v>''       +escalera_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>piso_sol</c><v>''           +piso_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>letra_sol</c><v>''          +letra_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>anexo_sol</c><v>''          +anexo_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>codigopostal_sol</c><v>''   +codigopostal_sol.value+''</v></p>'';'
      +' xmli_sol+=''<p><c>municipio_sol</c><v>''      +municipio_sol.value+''</v></p>'';'
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' if (otrosolicitantefacturacion.checked) {'
           +' xmli_fac+=''<p><c>otrosolicitantefacturacion</c><v>1</v></p>''+''<p><c>mismosolicitantefacturacion</c><v>0</v></p>'';'
           +' if (rpersona_fac.checked) {xmli_fac+=''<p><c>rpersona_fac</c><v>1</v></p>''} else {xmli_fac+=''<p><c>rpersona_fac</c><v>0</v></p>''};'
           +' if (rempresa_fac.checked) {xmli_fac+=''<p><c>rempresa_fac</c><v>1</v></p>''} else {xmli_fac+=''<p><c>rempresa_fac</c><v>0</v></p>''};'
           +' if (rpersona_fac.checked) {xmli_fac+=''<p><c>nombresolicitante_fac</c><v>''   +nombresolicitante_fac.value+''</v></p>''};'
           +' if (rpersona_fac.checked) {xmli_fac+=''<p><c>apellidossolicitante_fac</c><v>''+apellidossolicitante_fac.value+''</v></p>''};'
           +' if (rpersona_fac.checked) {xmli_fac+=''<p><c>dnisolicitante_fac</c><v>''      +dnisolicitante_fac.value+''</v></p>''};'
           +' if (rempresa_fac.checked) {xmli_fac+=''<p><c>empresasolicitante_fac</c><v>''  +empresasolicitante_fac.value+''</v></p>''};'
           +' if (rempresa_fac.checked) {xmli_fac+=''<p><c>cifsolicitante_fac</c><v>''      +cifsolicitante_fac.value+''</v></p>''};'
           +' xmli_fac+=''<p><c>emailsolicitante_fac</c><v>''+emailsolicitante_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>telefonosolicitante_fac</c><v>''+telefonosolicitante_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>calle_fac</c><v>''           +calle_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>numerocalle_fac</c><v>''     +numerocalle_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>portal_fac</c><v>''          +portal_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>escalera_fac</c><v>''        +escalera_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>piso_fac</c><v>''            +piso_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>letra_fac</c><v>''           +letra_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>anexo_fac</c><v>''           +anexo_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>codigopostal_fac</c><v>''    +codigopostal_fac.value+''</v></p>'';'
           +' xmli_fac+=''<p><c>municipio_fac</c><v>''       +municipio_fac.value+''</v></p>'';'
      +' } else {xmli_fac+=''<p><c>otrosolicitantefacturacion</c><v>0</v></p>''+''<p><c>mismosolicitantefacturacion</c><v>1</v></p>''
                } '
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_inm+=''<p><c>tipoinmueble</c><v>''                +tipoinmueble.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>finalidad</c><v>''                   +finalidad.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>calle</c><v>''                       +calle.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>numerocalle</c><v>''                 +numerocalle.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>portal</c><v>''                      +portal.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>escalera</c><v>''                    +escalera.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>piso</c><v>''                        +piso.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>letra</c><v>''                       +letra.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>anexo</c><v>''                       +anexo.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>codigopostal</c><v>''                +codigopostal.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>municipio</c><v>''                   +municipio.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>refcatastral</c><v>''                +refcatastral.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>superficie</c><v>''                  +superficie.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>importetransferenciavalidado</c><v>''+importetransferenciavalidado.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>fechatransferenciavalidado</c><v>''  +fechatransferenciavalidado.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>regpropiedad</c><v>''                +sch_regpropiedad.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>fincaregistral</c><v>''              +fincaregistral.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>idufir</c><v>''                      +idufir.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>nombrecontacto</c><v>''              +nombrecontacto.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>telefonocontacto</c><v>''            +telefonocontacto.value+''</v></p>'';'
      +' xmli_inm+=''<p><c>importemanual</c><v>''               +importemanual.value+''</v></p>'';'
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' if (mismocontactogestion.checked) {xmli_con+=''<p><c>mismocontactogestion</c><v>1</v></p>''} else {xmli_con+=''<p><c>mismocontactogestion</c><v>1</v></p>''};'
      +' if (otrocontactogestion.checked)  {xmli_con+=''<p><c>otrocontactogestion</c><v>1</v></p>'' } else {xmli_con+=''<p><c>otrocontactogestion</c><v>0</v></p>'' };'
      +' if (otrocontactogestion.checked)  {xmli_con+=''<p><c>nombrecontactogestion</c><v>''   +nombrecontactogestion.value+''</v></p>''};'
      +' if (otrocontactogestion.checked)  {xmli_con+=''<p><c>apellidoscontactogestion</c><v>''+apellidoscontactogestion.value+''</v></p>''};'
      +' if (otrocontactogestion.checked)  {xmli_con+=''<p><c>dnicontactogestion</c><v>''      +dnicontactogestion.value+''</v></p>''};'
      +' if (otrocontactogestion.checked)  {xmli_con+=''<p><c>telefonocontactogestion</c><v>'' +telefonocontactogestion.value+''</v></p>''};'
      +' if (otrocontactogestion.checked)  {xmli_con+=''<p><c>emailcontactogestion</c><v>''    +emailcontactogestion.value+''</v></p>''};'
      -------------------------------------------------------------------------------------------------
    --  set @ico_grabacion+=
    --  +' prompt(''datos-xmli'',xmli);'
    --  +' prompt(''datos-sol'',xmli_sol);'
    --  +' prompt(''datos-fac'',xmli_fac);'
    --  +' prompt(''datos-inm'',xmli_inm);'
    --  +' prompt(''datos-com'',xmli_con);'
    --  +' prompt(''datos-ver'',xmli_ver);'
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli=xmli.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
      +' xmli=xmli.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
      +' xmli=xmli.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
      +' xmli=xmli.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
      +' xmli=xmli.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'                -- Es el &
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_sol=xmli_sol.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
      +' xmli_sol=xmli_sol.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
      +' xmli_sol=xmli_sol.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
      +' xmli_sol=xmli_sol.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
      +' xmli_sol=xmli_sol.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'        -- Es el &
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_fac=xmli_fac.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
      +' xmli_fac=xmli_fac.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
      +' xmli_fac=xmli_fac.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
      +' xmli_fac=xmli_fac.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
      +' xmli_fac=xmli_fac.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'        -- Es el &
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_inm=xmli_inm.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
      +' xmli_inm=xmli_inm.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
      +' xmli_inm=xmli_inm.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
      +' xmli_inm=xmli_inm.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
      +' xmli_inm=xmli_inm.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'        -- Es el &
   -- +' prompt(''datos xmli_inm'',xmli_inm);'
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_con=xmli_con.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
      +' xmli_con=xmli_con.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
      +' xmli_con=xmli_con.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
      +' xmli_con=xmli_con.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
      +' xmli_con=xmli_con.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'        -- Es el &
      -------------------------------------------------------------------------------------------------
      set @ico_grabacion+=
      +' xmli_ver=xmli_ver.replaceAll(String.fromCharCode(39),String.fromCharCode(180));'
      +' xmli_ver=xmli_ver.replaceAll(String.fromCharCode(9) ,String.fromCharCode(32));'
      +' xmli_ver=xmli_ver.replaceAll(String.fromCharCode(10),String.fromCharCode(32));'
      +' xmli_ver=xmli_ver.replaceAll(String.fromCharCode(13),String.fromCharCode(32));'
      +' xmli_ver=xmli_ver.replaceAll(String.fromCharCode(38),''_AMPERSAN_'');'        -- Es el &
      -------------------------------------------------------------------------------------------------
      +' xmli=''<root>''+xmli+xmli_sol+xmli_fac+xmli_inm+xmli_con+xmli_ver+''</root>'';'
   -- +' prompt(''datos'',xmli);'

      set @ico_grabacion+=
      +' seccionvalidacion.style.display=''none''; '

      set @ico_grabacion+=        
      +' var p='' '+dbo.THERION_EnCriptar_Cadena_con_Clave ('exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Grabar','19271812')+' '';'
      +'     p+='' || @datos=·''+xmli+''·'' ;'
   -- +' prompt(''Exec'',p);'
      +' var w=''WEncriptSQLExt(\''''+p+''\'')'';'
      +' ConfirmDialog(''Confirmar Datos....'', w);'
      +' "'                                
      +'>Enviar Solicitud</a>'  -- final del Icono de Grabar


      -- ##################################################
      set @ico_verificacion+=
         +' onclick="'
                 +' '
      ---------------------------------------
      ---------------------------------------
      set @ico_verificacion+=
      ----------------------------------------
      -- Montaje del XML de datos introducidos
      ----------------------------------------
      +' var xmli=''<root>'';'
      +' xmli+=''<p><c>semillapresupuesto</c><v>'+@semilla_verificacion+'</v></p>'';'
      +' xmli+=''<p><c>prefijo</c><v>''+prefijo.value+''</v></p>'';'
      +' xmli+=''<p><c>telefonoverificacion</c><v>''+telefonoverificacion.value+''</v></p>'';'
      +' if (aceptaciondatos.checked) {xmli+=''<p><c>aceptaciondatos</c><v>1</v></p>''} else {xmli+=''<p><c>aceptaciondatos</c><v>0</v></p>''};'
      +' xmli+=''</root>''; '
      +' var p='' '+dbo.THERION_EnCriptar_Cadena_con_Clave ('exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Enviar_Codigo_Verificacion','19271812')+' '';'
      +'     p+='' || @datos=·''+xmli+''·'' ;'
      +' WEncriptSQLExt(p);'
      +' "'                                
      +' />'  -- final del Icono de Grabar

      declare @peticion varchar(max)=dbo.THERION_EnCriptar_Cadena_con_Clave ('TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Validar_Transferencia @tabla_asociada=''TH_Presupuestos_WEB_transferencia_'+@semilla_ficheros+'''','19271812')
      
      -------------------
      set @ico_validacion+=
         +' onclick="if (PGFiles_transferencia.innerHTML=='''') {alert(''No existe Fichero'');return} else {}
                     var enc='' '+@peticion+' '';
                     var p=enc;
                     WEncriptHTML_General_Ext(p,1);      
                    "'                                
         +' />' -- final del Icono de Validar Transferencia
     
      ---------------------------------------- 
      set @ico_nueva_verificacion='<img alt="X" id="nuevaverificacion" class="acciones" src="imgEXT/Repetir_Verificar_Informe_TH.png" title="Solicitar nuevo Presupuesto" onclick="window.location.reload(true);" />'
      ----------------------------------------
      declare @titulo_formulario varchar(100)='Solicite Presupuesto de Valoración de Inmueble'
      if @fk_usuario is not null
         begin
           set @titulo_formulario='Crear Presupuesto de Valoración de Inmueble '+case when right(@prbbdd,4)='_UTC' then ' (UTC)' else '' end
         end

      ---------------------------------------- 

      declare @calculo_tarifa varchar(max)=''
      set @calculo_tarifa+=        
      +' var xmli=''<root>'';'
      +' xmli+=''<p><c>tipoinmueble</c><v>''+tipoinmueble.value+''</v></p>'';'
      +' xmli+=''<p><c>superficie</c><v>''+superficie.value+''</v></p>'';'
      +' xmli+=''<p><c>codentid</c><v>'+@corto+'</v></p>'';'
      +' xmli+=''<p><c>municipio</c><v>''+municipio.value+''</v></p>'';'
      +' xmli+=''<p><c>importemanual</c><v>''+importemanual.value+''</v></p>'';'
      +' if (tramitacionurgente.checked) {xmli+=''<p><c>tramitacionurgente</c><v>1</v></p>''} else {xmli+=''<p><c>tramitacionurgente</c><v>0</v></p>''};'
      +' xmli+=''</root>''; '
      +' var p='' '+dbo.THERION_EnCriptar_Cadena_con_Clave ('TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Calcular_Tarifa','19271812')+' '';'
          +' p+='' || [NOWAIT]@datos=·''+xmli+''·'';'
      +' WEncriptSQLExt(p);'
      
      ---------------------------------------- 
      set @html+=
       +'<div id="Principal" style="position:absolute;top:0vh;width:99%;overflow-y:hidden;margin:auto;border:solid 0px #transparent">'+char(10)
       +'<a id="comprobardni" 
            data-dni=""
            data-lbinput=""
            style="display:none" 
            onclick="var p='' '+dbo.THERION_EnCriptar_Cadena_con_Clave ('exec TH_Accesos_Externos_Validar_DNI','19271812')+' '';
                     p+='' || @datos=·[''+this.dataset.dni+''][''+this.dataset.lbinput+'']·'' ;
                     WEncriptSQLExt(p);
                    "                                
        ></a>'  
       +'<a id="comprobarcif" 
            data-cif=""
            data-lbinput=""
            style="display:none" 
            onclick="var p='' '+dbo.THERION_EnCriptar_Cadena_con_Clave ('exec TH_Accesos_Externos_Validar_CIF','19271812')+' '';
                     p+='' || @datos=·[''+this.dataset.cif+''][''+this.dataset.lbinput+'']·'' ;
                     WEncriptSQLExt(p);
                    "                                
        ></a>'  
      ------------------------------------
       +'<a id="autoarrancar">'
           +'CambiarFavIcon();'
           +'nombresolicitante.focus();'
           +'fichero_dni.value='''';'
           +'sch_municipio.value='''';'
           +'sch_municipio_sol.value='''';'
           +'municipio_fac.value='''';'
           +'var omunicipio=document.getElementById(''sch_municipio''); omunicipio.addEventListener(''change'', function() {'+@calculo_tarifa+'});'
        -- +'alert(''arrancado'');'
       +'</a>'
       ------------------------------------ 
       +case when @fk_usuario is null then 
              '<table style="width:100%;margin:auto;">'+char(10)
               +'<tr>'+char(10)
                 +'<td style="width:10%;text-align:left;">'+@logo_th+'</td>'+char(10)
               +'</tr>'+char(10)
             +'</table>'+char(10)
            else '' 
        end
       +'<table style="width:100%;margin:auto;">'+char(10)
         +'<tr>'+char(10)
           +'<td class="titulo" style="font-size:1.5vw;text-align:center;">
               <a style="vertical-align:middle;">'+@titulo_formulario+''
           --  +'<font style="font-size:70%;padding-left:2vw;">'+format(getdate(),'dd/MM/yyyy HH:mm:ss')+'</font>'
             +'</a>'
           +'</td>'
         +'</tr>'+char(10)
       +'</table>'+char(10)

       ----------------------------------------

       set @html+='<br>'
       declare @height_div varchar(10)='65'
       if @fk_usuario is not null
          begin
            set @height_div='85'
          end
       set @html+=
       +'<div id="divdatos" style="display:inline-block;height:'+@height_div+'vh;border:solid 1px transparent;overflow-y:scroll;overflow-x:hidden;">'+char(10)
       
       ----------------------------------------
       set @html+=
          ' <table style="border-collapse:collapse;table-layout:fixed;border:solid 3px transparent;width:80%;margin:auto;background-color:transparent;opacity:0.7;margin:auto">'+char(10)

       -----------
       -- Objeto
       -----------

       -- select * from CORITEL.dbo.taoobjet where codclase='800'

       declare @lista_tipo_inmueble varchar(max)=
                     '<option value="0" >--</option>'
                    +'<option value="80008">Vivienda-Piso</option>'
                    +'<option value="80012">Vivienda Unifamiliar</option>'
                    +'<option value="80006">Plaza de Garaje</option>'
                    +'<option value="80007">Trastero</option>'
                    +'<option value="80009">Local Comercial</option>'
              +'<option value="80013">Oficina</option>'
              +'<option value="80014">Nave Industrial</option>'
              +'<option value="80010">Edificio</option>'
              +'<option value="80018">Rústica (Edificaciones)</option>'
              +'<option value="80017">ILAE</option>'
              +'<option value="90001">Terrenos</option>'

       ------------------------------------
       declare @lista_finalidad varchar(max)=
                     '<option value="0" >--</option>'
                    +'<option value="HI">Préstamo Hipotecario</option>'
                    +'<option value="ME">Valor de Mercado</option>'
       
       

--       set @html+=
--               +'<tr><td class="etiqueta"></td><td class="datoencargo"><p class="separatasec"></p></td></tr>'        
          
       
--       set @html+=
--               +'<tr style="height:2vh">
--                  <td class="datoencargo"></td>'
--       /*
--       set @html+=
--                   +'<td class="aportacion" id="documentacionaportar" rowspan="10" style="vertical-align:center;display:none">
--                        <div style=";border-right:solid 2px #aaa;;border-left:solid 2px #aaa;padding-left:0.5vw;">  
--                        <a>Documentación Técnica</a>
--                        <br>
--                        <br>
--                        <ul>
--                        <li><u>IMPRESCINDIBLE</u>
--                            <ul style="font-weight:normal">
--                               <br>
--                               <li>NOTA SIMPLE REGISTRAL COMPLETA EMITIDA EN LOS 3 MESES ANTERIORES A LA FECHA DE VALORACIÓN </li>
--                               <li>CONTRATO DE ARRENDAMIENTO EN CASO DE ESTAR ARRENDADO</li>
--                            </ul>
--                        </li>
--                        <br>
--                        <li><u>RECOMENDABLE</u>
--                            <ul style="font-weight:normal">
--                            <br>
--                            <li>PLANO DEL INMUEBLE</li>
--                            <li>CÉDULA DE CALIFICACIÓN O DOCUMENTO EQUIVALENTE EN CASO DE VPO</li>
--                            <li>CERTIFICACIÓN ENERGÉTICA</li>
--                            <li>EN LA REALIZACIÓN DE LOS TRABAJOS, TH PODRÁ SOLICITAR DOCUMENTACIÓN ADICIONAL, QUE PODRÁ TENER, EN FUNCIÓN DE LAS CARÁCTERISTICAS COMPROBADAS (INMUEBLES EN CONSTRUCCIÓN, EN EXPLOTACIÓN, ETC.), CONSIDERACION DE IMPRESCINDIBLE O RECOMENDABLE.</li>
--                            </ul>
--                        </li>
--                        </ul>
--                        <a>Forma de Pago</a>
--                        <ul style="font-weight:normal">
--                        <li>EL PAGO PODRÁ REALIZARSE MEDIANTE TARJETA BANCARIA CON LA ACEPTACIÓN DE LA OFERTA MEDIANTE UN ENLACE PROPORCIONADO AL EFECTO.</li>
--                        <br>
--                        <li>MEDIANTE TRANSFERECIA BANCARIA AL NÚMERO DE CUENTA DE TASACIONES HIPOTECARIAS S.A.U (A-28806222) INDICADA EN LA OFERTA.</li>
--                        <br>
--                        <li style="font-size:0.6vw">EL IMPORTE ABONADO TENDRÁ CONSIDERACIÓN DE PROVISIÓN DE FONDOS COMO CANTIDAD NECESARIA PARA REALIZAR LOS TRABAJOS DESCRITOS EN LA OFERTA TÉCNICA. UNA VEZ FINALIZADOS, SI LOS TRABAJOS REALIZADOS DIFIEREN DE LOS INCIALMENTE DECLARADOS EN LA OFERTA, LOS HONORARIOS PODRÁN SER REVISADOS PREVIA ENTREGA</li>
--                        </ul>
--                        </div>  
--                  </td>'
--       */
--
--       set @html+=
--            -- +'<td class="resto" rowspan="10" style="">'
--               +'</tr>'     
--
       if @fk_usuario is not null
          begin
             ------------------------------------
             -- Usuario
             ------------------------------------
             set @html+=
               +'<tr style="height:auto">
                     <td class="datoencargo">'
                         +'<a class="etiqueta etipri">'+case when @chk_externo=1        then 'Vendedor Externo ('+@corto+')' 
                                                             when @tipo_tasador is null then 'Comercial ('+@corto+')' 
                                                             else 'Tasador'+case when @tipo_tasador is null then '' else ' ('+@corto+')' end 
                                                        end+':</a>'
                         +'<a id="usuario" style="vertical-align:middle;display:inline-block;width:25vw;">'+isnull(@usuario,'')
                       --  + '<br>('+@semilla_verificacion+')'
                         +'</a>' 
                    +'</td>'
               +'</tr>'        
              -- +'<tr><td style="text-align:left"><div style="text-align:left;border:solid 2px #92575b;width:8%"></div></td></tr>'+char(10)
          end
       -----------------------------------------------
       -- Solicitante (Seleccion Persona/Empresa)
       -----------------------------------------------
       set @html+=
       +'<tr><td class="eticomp">
                 TITULAR DEL INFORME DE TASACION
                 <span style="display:inline-block;width:3vw;"></span>
                 <input type ="radio" id="rpersona" class="datoentrada" name="rsolicitante" style="vertical-align:middle" value="P" checked 
                        onchange="if (rpersona.checked) {sectionpersonafisica.style.display='''';sectionpersonajuridica.style.display=''none'';nombresolicitante.focus()}
                                  if (rempresa.checked) {sectionpersonafisica.style.display=''none'';sectionpersonajuridica.style.display='''';empresasolicitante.focus()}
                                  "
                 />
                 <a style="display:inline-block;width:1vw;"></a>
                 <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Persona Física</a>
                 <a style="display:inline-block;width:2vw;"></a>
                 <input type="radio" id="rempresa" class="datoentrada" name="rsolicitante" style="vertical-align:middle" value="E"
                        onchange="if (rpersona.checked) {sectionpersonafisica.style.display='''';sectionpersonajuridica.style.display=''none'';nombresolicitante.focus()}
                                  if (rempresa.checked) {sectionpersonafisica.style.display=''none'';sectionpersonajuridica.style.display='''';empresasolicitante.focus()}
                                  "
                     />
                 <a style="display:inline-block;width:1vw;">
                 <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Persona Jurídica (Empresa)</a>
                 <a style="display:inline-block;width:2vw;">
             </td>
        </tr>'+char(10)
       --------------------------
       -- Datos del Solicitante
       --------------------------
          set @html+=
       +'<tr style="height:auto">
             <td class="datoencargo">'
                          +'<p class="separatacam"></p>'
              +'<section id="sectionpersonafisica">'
                 +'<a class="etiqueta etipri">Nombre:</a><input id="nombresolicitante"    class="datoentrada" type="text" value="" maxlength="40" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Apellidos:</a><input id="apellidossolicitante" class="datoentrada" type="text" value="" maxlength="60" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri" >Dni:</a><input id="dnisolicitante" onchange="comprobardni.dataset.dni=this.value;comprobardni.dataset.lbinput=''lbdnisolicitante'';comprobardni.click();" class="datoentrada" type="text" value="" maxlength="12" style="display:inline-block;width:10vw;"/>' 
                 +'<a id="lbdnisolicitante" style="vertical-align:middle;display:inline-block;height:2vh;padding-left:1vw;width:15vw;border:solid 1px transparent;font-weight:normal;"></a>'
              +'</section>'

              +'<section id="sectionpersonajuridica" style="display:none">'
                 +'<a class="etiqueta etipri">Empresa:</a><input id="empresasolicitante" class="datoentrada" type="text" value="" maxlength="40" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri" >Cif:</a><input id="cifsolicitante" onchange="comprobarcif.dataset.cif=this.value;comprobarcif.dataset.lbinput=''lbcifsolicitante'';comprobarcif.click();" class="datoentrada" type="text" value="" maxlength="12" style="display:inline-block;width:10vw;"/>' 
                 +'<a id="lbcifsolicitante" style="vertical-align:middle;display:inline-block;height:2vh;padding-left:1vw;width:15vw;border:solid 1px transparent;font-weight:normal;"></a>'
              +'</section>'
              
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Dirección: </a><input id="calle_sol" class="datoentrada" type="text" value="" maxlength="60" style="display:inline-block;width:25vw;"/>' 
       --       +'<p class="separatacam"></p>'
              +'<a class="etiqueta" style="display:inline-block;width:2.5vw;">Núm.:</a><input id="numerocalle_sol" class="datoentrada"  type="text" value="" maxlength="10" style="display:inline-block;width:4vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2.75vw;text-align:right">Portal:</a><input id="portal_sol" class="datoentrada" type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Esc.:  </a><input id="escalera_sol" class="datoentrada" type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Piso:  </a><input id="piso_sol" class="datoentrada"     type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Letra: </a><input id="letra_sol" class="datoentrada"    type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              --+'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri" style="display:none" >Resto dirección: </a><input id="anexo_sol" class="datoentrada" type="text" value="" maxlength="25" style="display:none;width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri" style="padding-right:0px">Población:</a>'
               +dbo.f_ASPX_THERION_AutoCombo('municipio_sol'                                                                                          -- @id_autocombo
                                            ,'INE_CRUDO_MUNICIPIO'                                                                                    -- @tabla_autocombo  
                                            ,'NOMBRE'                                                                                                 -- @campo_busqueda
                                            ,'NOMBRE'                                                                                                 -- @campo_mostrar
                                            ,'1=1'                                                                                                    -- @where
                                            ,'25vw'                                                                                                   -- @width
                                            , null                                                                                                    -- @codigo_seleccionado
                                            ,'Seleccionar Municipio. Empiece a teclear e irán saliendo los registros disponibles'                     -- @title 
                                            , 0                                                                                                       -- @disable 
                                            ,';font-size:0.80vw;vertical-aling:middle;background:transparent
                                              ;font-family:Open Sans;border-radius:0px;-ms-border-radius:0px;-moz-border-radius:0px;-webkit-border-radius:0px;-khtml-border-radius:0px
                                              ;border:solid 1px #000
                                              ;border-bottom-width:2px
                                              ;border-bottom-style:dotted;'                                                    -- @style_adicional  
                                            )
             +'<a class="etiqueta" style="display:inline-block;width:2.5vw;">C.P.:</a><input id="codigopostal_sol" class="datoentrada" type="text" value="" maxlength="8" style="width:4vw;"/>' 
            +'</td>'
       +'</tr>'        
       --------------
       -- Contacto
       --------------
       set @html+=
       +'<tr><td class="eticomp_2" style="padding-left:2vw;"><u>Persona de Contacto para la visita</u></td></tr>'+char(10)
          set @html+=
       +'<tr style="height:auto">
             <td class="datoencargo">'
                          +'<a class="etiqueta etipri">Nombre:  </a><input id="nombrecontacto" class="datoentrada" type="text" value="" maxlength="40" style="width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Teléfono: </a><input id="telefonocontacto" class="datoentrada" type="text" value="" maxlength="12" style="width:10vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri" style="display:none">Email:</a><input id="emailsolicitante" class="datoentrada" type="text" value="" maxlength="300" style="display:none;width:25vw;"/>' 
              +'<a class="etiqueta etipri" style="display:none">Teléfono:</a><input id="telefonosolicitante" class="datoentrada" type="text" value="" maxlength="25" style="display:none;width:10vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Email envío Informe Tasacion:</a><input id="emaildoc" class="datoentrada" type="text" value="" maxlength="300" style="width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Email Titular Factura:</a><input id="emailfac" class="datoentrada" type="text" value="" maxlength="300" style="width:25vw;"/>' 
              +'<a class="etiqueta"><i>(*)La factura se emitirá al titular del Informe de Tasación</i></a>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Finalidad:</a><select id="finalidad" class="datoentrada" style ="display:inline-block;width:25.3vw;height:2.7vh">'+isnull(@lista_finalidad,'')+'</select>' 
            +'</td>'
       +'</tr>'  
       ------------------------
       -- Tramitación urgente
       ------------------------
       +'<tr><td class="eticomp">
                <a style="display:inline-block;width:2vw;"></a>
                <input type ="checkbox" id="tramitacionurgente" class="datoentrada" style="vertical-align:middle"/>
                <a style="display:inline-block;width:0.5vw;"></a>
                <a style="vertical-align:middle;font-size:0.80vw;font-weight:normal;color:black;display:inline-block;width:auto;">
                  <b><u>Tramitación URGENTE (incremento de la tarifa en un 15%)</u></b>. 
                  Entrega en 72 horas desde el momento en el que el técnico disponga de toda la documentación y haya realizado la visita
                </a>
                <hr style="border:solid 1px #000">
             </td>
        </tr>'+char(10)

       ---------------------------------------------
       --###########################################

       ---------------------------------------------
       -- Seleccion del Solicitante de Facturación
       ---------------------------------------------
       set @html+=
       +'<tr><td class="eticomp"  style="height:auto;display:none">  
                 Datos Facturación
                 <a style="display:inline-block;width:2vw;"></a>
                 <input type ="radio" 
                        id   ="mismosolicitantefacturacion" 
                        name ="facturacion" 
                        class="datoentrada" 
                        style="vertical-align:middle" 
                        value="M"
                        checked 
                        onchange="trsolicitante_fac.style.display=''none'';trsolicitante_sel_fac.style.display=''none'';
                                  if (otrosolicitantefacturacion.checked) {trsolicitante_sel_fac.style.display='''';trsolicitante_fac.style.display='''';}
                                  "
                 />
                 <a style="display:inline-block;width:0.5vw;">
                 <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Solicitante de la Tasación</a>
                 <a style="display:inline-block;width:2vw;"></a>
                 <input 
                      type ="radio" 
                      id   ="otrosolicitantefacturacion" 
                      name ="facturacion" 
                      class="datoentrada" 
                      style="vertical-align:middle"
                      value="O"
                        onchange="trsolicitante_fac.style.display=''none'';trsolicitante_sel_fac.style.display=''none'';
                                  if (otrosolicitantefacturacion.checked) {trsolicitante_sel_fac.style.display='''';trsolicitante_fac.style.display='''';}
                                "
                     />
                 <a style="display:inline-block;width:1vw;">
                 <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Distinto al Solicitante de la Tasación</a>
                 <a style="display:inline-block;width:2vw;">
       </td></tr>'+char(10)
    --   +'<tr><td style="text-align:left"><div style="text-align:left;border:solid 2px #92575b;width:8%"></div></td></tr>'+char(10)

       -----------------------------------------------
       -- Solicitante Facturacion (Seleccion Persona/Empresa)
       -----------------------------------------------
       set @html+=
       +'<tr id="trsolicitante_sel_fac" style="height:auto;display:none">
            <td class="eticomp">
                 <a style="display:inline-block;width:20vw;"></a>
                 <input type ="radio" id="rpersona_fac" class="datoentrada" name="rsolicitante_fac" style="vertical-align:middle" value="P" checked 
                        onchange="if (rpersona_fac.checked) {sectionpersonafisica_fac.style.display=''''    ;sectionpersonajuridica_fac.style.display=''none'';nombresolicitante_fac.focus()}
                                  if (rempresa_fac.checked) {sectionpersonafisica_fac.style.display=''none'';sectionpersonajuridica_fac.style.display=''''    ;empresasolicitante_fac.focus()}
                                  "
                 />
                 <a style="display:inline-block;width:1vw;"></a>
                 <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Persona Física</a>
                 <a style="display:inline-block;width:2vw;"></a>
                 <input type="radio" id="rempresa_fac" class="datoentrada" name="rsolicitante_fac" style="vertical-align:middle" value="E"
                        onchange="if (rpersona_fac.checked) {sectionpersonafisica_fac.style.display=''''    ;sectionpersonajuridica_fac.style.display=''none'';nombresolicitante_fac.focus()}
                                  if (rempresa_fac.checked) {sectionpersonafisica_fac.style.display=''none'';sectionpersonajuridica_fac.style.display=''''    ;empresasolicitante_fac.focus()}
                                  "
                     />
                 <a style="display:inline-block;width:1vw;">
                 <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Persona Jurídica (Empresa)</a>
                 <a style="display:inline-block;width:2vw;">
             </td>
        </tr>'+char(10)

       ---------------------------------------------
       -- Datos del Solicitante de Facturación
       ---------------------------------------------

          set @html+=
       +'<tr id="trsolicitante_fac" style="height:auto;display:none">
             <td class="datoencargo">'
                          +'<p class="separatacam"></p>'
              +'<section id="sectionpersonafisica_fac">'
                 +'<a class="etiqueta etipri">Nombre:   </a><input id="nombresolicitante_fac"    class="datoentrada" type="text" value="" maxlength="40" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Apellidos:</a><input id="apellidossolicitante_fac" class="datoentrada" type="text" value="" maxlength="60" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Dni:      </a><input id="dnisolicitante_fac" onchange="comprobardni.dataset.dni=this.value;comprobardni.dataset.lbinput=''lbdnisolicitante_fac'';comprobardni.click();"  class="datoentrada" type="text" value="" maxlength="12" style="display:inline-block;width:10vw;"/>' 
                 +'<a id="lbdnisolicitante_fac" style="vertical-align:middle;display:inline-block;height:2vh;padding-left:1vw;width:15vw;border:solid 1px transparent;font-weight:normal;"></a>'
              +'</section>'

              +'<section id="sectionpersonajuridica_fac" style="display:none">'
                 +'<a class="etiqueta etipri">Empresa:</a><input id="empresasolicitante_fac" class="datoentrada" type="text" value="" maxlength="40" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Cif:</a><input id="cifsolicitante_fac" class="datoentrada" onchange="comprobarcif.dataset.cif=this.value;comprobarcif.dataset.lbinput=''lbcifsolicitante_fac'';comprobarcif.click();" type="text" value="" maxlength="12" style="display:inline-block;width:10vw;"/>' 
                 +'<a id="lbcifsolicitante_fac" style="vertical-align:middle;display:inline-block;height:2vh;padding-left:1vw;width:15vw;border:solid 1px transparent;font-weight:normal;"></a>'
              +'</section>'

              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Email:    </a><input id="emailsolicitante_fac" class="datoentrada" type="text" value="" maxlength="300" style="display:inline-block;width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Teléfono:</a><input id="telefonosolicitante_fac" class="datoentrada" type="text" value="" maxlength="150" style="display:inline-block;width:10vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Calle: </a><input id="calle_fac" class="datoentrada" type="text" value="" maxlength="60" style="display:inline-block;width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Nº:    </a><input id="numerocalle_fac" class="datoentrada"  type="text" value="" maxlength="10" style="display:inline-block;width:4vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2.75vw;text-align:right">Portal:</a><input id="portal_fac" class="datoentrada" type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Esc.:  </a><input id="escalera_fac" class="datoentrada" type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Piso:  </a><input id="piso_fac" class="datoentrada"     type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Letra: </a><input id="letra_fac" class="datoentrada"    type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Resto dirección: </a><input id="anexo_fac" class="datoentrada" type="text" value="" maxlength="25" style="display:inline-block;width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Cód.Postal:     </a><input id="codigopostal_fac" class="datoentrada" type="text" value="" maxlength="8" style="width:6vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri" style="padding-right:0px">Localidad: </a>'
               +dbo.f_ASPX_THERION_AutoCombo('municipio_fac'                                                                                          -- @id_autocombo
                                            ,'INE_CRUDO_MUNICIPIO'                                                                                    -- @tabla_autocombo  
                                            ,'NOMBRE'                                                                                                 -- @campo_busqueda
                                            ,'NOMBRE'                                                                                                 -- @campo_mostrar
                                            ,'1=1'                                                                                                    -- @where
                                            ,'25vw'                                                                                                   -- @width
                                            , null                                                                                                    -- @codigo_seleccionado
                                            ,'Seleccionar Municipio. Empiece a teclear e irán saliendo los registros disponibles'                     -- @title 
                                            , 0                                                                                                       -- @disable  
                                            ,';font-size:0.80vw;vertical-aling:middle;background:transparent
                                              ;font-family:Open Sans;border-radius:0px;-ms-border-radius:0px;-moz-border-radius:0px;-webkit-border-radius:0px;-khtml-border-radius:0px
                                              ;border:solid 1px #000
                                              ;border-bottom-width:2px
                                              ;border-bottom-style:dotted;'                                                    -- @style_adicional  
                                            )
            +'</td>'
       +'</tr>'        

       --###########################################
       ---------------------------------------------
       ------------------------------------
       -- Direccion del Inmueble de Tasación
       ------------------------------------
       set @html+=
       +'<tr><td class="eticomp">SITUACIÓN DEL INMUEBLE</td></tr>'+char(10)
       set @html+=
       +'<tr style="height:2vh">
           <td class="datoencargo">'
                    +'<a class="etiqueta etipri">Tipo de inmueble:</a><select id="tipoinmueble" class="datoentrada" style ="display:inline-block;width:25.3vw;height:2.7vh">'+isnull(@lista_tipo_inmueble,'')+'</select>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Dirección:</a><input id="calle" class="datoentrada" type="text" value="" maxlength="60" style="display:inline-block;width:25vw;"/>' 
              +'<a class="etiqueta " style="display:inline-block;width:2.5vw;" >Núm.:</a><input id="numerocalle" class="datoentrada"  type="text" value="" maxlength="10" style="display:inline-block;width:4vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2.75vw;text-align:right">Portal:</a><input id="portal" class="datoentrada" type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Esc.:  </a><input id="escalera" class="datoentrada" type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Piso:  </a><input id="piso" class="datoentrada"     type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<a class="etiqueta" style="display:inline-block;width:2vw;text-align:right" >Letra: </a><input id="letra" class="datoentrada"    type="text" value="" maxlength="10" style="display:inline-block;width:2vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Resto dirección: </a><input id="anexo" class="datoentrada" type="text" value="" maxlength="25" style="width:25vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri" style="padding-right:0px">Población:</a>'
               +dbo.f_ASPX_THERION_AutoCombo('municipio'                                                                                              -- @id_autocombo
                                            ,'INE_CRUDO_MUNICIPIO'                                                                                    -- @tabla_autocombo  
                                            ,'NOMBRE'                                                                                                 -- @campo_busqueda
                                            ,'NOMBRE'                                                                                                 -- @campo_mostrar
                                            ,'1=1'                                                                                                    -- @where
                                            ,'25vw'                                                                                                   -- @width
                                            , null                                                                                                    -- @codigo_seleccionado
                                            ,'Seleccionar Municipio. Empiece a teclear e irán saliendo los registros disponibles'                     -- @title 
                                            , 0                                                                                                       -- @disable  
                                            ,';font-size:0.80vw;vertical-aling:middle;background:transparent
                                              ;font-family:Open Sans;border-radius:0px;-ms-border-radius:0px;-moz-border-radius:0px;-webkit-border-radius:0px;-khtml-border-radius:0px
                                              ;border:solid 1px #000
                                              ;border-bottom-width:2px
                                              ;border-bottom-style:dotted;'                                                    -- @style_adicional  
                                            )
              +'<a class="etiqueta " style="display:inline-block;width:2.5vw;">C.P.:</a><input id="codigopostal" class="datoentrada" type="text" value="" maxlength="8" style="width:4vw;"/>' 
           +'</td>'
        +'</tr>'        
       ----------------------
       -- Datos Registrales
       ----------------------
       set @html+=
    -- +'<tr><td class="eticomp_2" style="padding-left:2vw;"><u>Datos Catastrales y Registrales</u><td></tr>'+char(10)
       +'<tr><td class="eticomp">DATOS DEL INMUEBLE</td></tr>'+char(10)
       +'<tr style="height:2vh">
           <td class="datoencargo">'
              +'<section style="display:none">'
              +'<a class="etiqueta etipri">Superficie Aproximada (m2): </a>'
              +'<input id="superficie" class="datoentrada" type="number" onchange="'+@calculo_tarifa+'" style="text-align:right;width:6vw" min="1" max="80000" step="1" />' 
              +'<p class="separatacam"></p>'
              +'</section>'
              +'<a class="etiqueta etipri" style="padding-right:0px">Reg. Propiedad: </a>'
           --   +'<input id="regpropiedad" class="datoentrada" type="text" value="" maxlength="25" style="width:25vw;"/>'+ 
              +dbo.f_ASPX_THERION_AutoCombo('regpropiedad'                                                                                               -- @id_autocombo
                                           ,'v_vRegPropiedad'                                                                                        -- @tabla_autocombo  
                                           ,'descripcion'                                                                                            -- @campo_busqueda
                                           ,'descripcion'                                                                                            -- @campo_mostrar
                                            ,'1=1'                                                                                                    -- @where
                                            ,'25vw'                                                                                                   -- @width
                                            , null                                                                                                    -- @codigo_seleccionado
                                            ,'Seleccionar Registro de la Propiedad. Empiece a teclear e irán saliendo los registros disponibles'                     -- @title 
                                            , 0                                                                                                       -- @disable  
                                            ,';font-size:0.80vw;vertical-aling:middle;background:transparent
                                              ;font-family:Open Sans;border-radius:0px;-ms-border-radius:0px;-moz-border-radius:0px;-webkit-border-radius:0px;-khtml-border-radius:0px
                                              ;border:solid 1px #000
                                              ;border-bottom-width:2px
                                              ;border-bottom-style:dotted;'                                                    -- @style_adicional  
                                           )
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Nº Finca Registral: </a><input id="fincaregistral" class="datoentrada" type="text" value="" maxlength="10" style="width:11vw;"/>' 
              +'<a class="etiqueta ">Idufir: </a><input id="idufir" class="datoentrada" type="text" value="" maxlength="25" style="width:10.5vw;"/>' 
              +'<p class="separatacam"></p>'
              +'<a class="etiqueta etipri">Ref. Catastral: </a><input id="refcatastral" class="datoentrada" type="text" value="" maxlength="25" style="width:25vw;"/>' 
              +'<hr style="border:solid 1px #000">'
              ---------------------------------
           +'</td>'
        +'</tr>'        

       -----------------------------------
       -- Contacto de gestion (seleccion)
       -----------------------------------
      
      declare @ver_publico varchar(10)='none'

      if @fk_usuario is not null and @chk_externo=0
         begin
           set @ver_publico=''
         end

       set @html+=
   --    +'<tr><td class="eticomp_2" style="padding-left:2vw;display:'+@ver_publico+'"><u>Persona de Contacto para la gestión del trabajo solicitado</u></td></tr>'+char(10)
       +'<tr>'
         +'<td class="eticomp" style="padding-left:2vw;display:none">
             <a class="etiqueta" style="width:2vw;"><u>Persona de Contacto para la gestión del trabajo solicitado</u></a>
             <input type ="radio" 
                    id   ="mismocontactogestion" 
                    name ="contactogestion" 
                    class="datoentrada" 
                    style="vertical-align:middle" 
                    value="M"
                    checked 
                    onchange="sectionotrocontactogestion.style.display=''none'';
                              sectionotrocontactogestionfichero.style.display=''none'';
                              if (otrocontactogestion.checked) {sectionotrocontactogestion.style.display='''';sectionotrocontactogestionfichero.style.display='''';}
                              "
             />
             <a style="display:inline-block;width:0.5vw;">
             <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Solicitante Tasación</a>
             <a style="display:inline-block;width:1vw;"></a>
             <input type ="radio" 
                    id   ="otrocontactogestion" 
                    name ="contactogestion" 
                    class="datoentrada" 
                    style="vertical-align:middle"
                    value="O"
                      onchange="sectionotrocontactogestion.style.display=''none'';
                                sectionotrocontactogestionfichero.style.display=''none'';
                                if (otrocontactogestion.checked) {sectionotrocontactogestion.style.display='''';sectionotrocontactogestionfichero.style.display='''';nombrecontactogestion.focus();}
                            "
                 />
             <a style="display:inline-block;width:1vw;">
             <a style="vertical-align:middle;font-size:0.65vw;font-weight:nomal">Distinto Solicitante Tasación</a>
         </td>'
       +'</tr>'+char(10)
       -----------------------------------
       -- Contacto de gestion (Datos)
       -----------------------------------
          set @html+=
       +'<tr style="height:auto;display:'+@ver_publico+'">
             <td class="datoencargo">'
              +'<section id="sectionotrocontactogestion" style="display:none">'
                          +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Nombre:   </a><input id="nombrecontactogestion" class="datoentrada" type="text" value="" maxlength="40" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Apellidos:</a><input id="apellidoscontactogestion" class="datoentrada" type="text" value="" maxlength="60" style="display:inline-block;width:25vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Dni:      </a><input id="dnicontactogestion" onchange="comprobardni.dataset.dni=this.value;comprobardni.dataset.lbinput=''lbdnicontactogestion'';comprobardni.click();" class="datoentrada" type="text" value="" maxlength="12" style="display:inline-block;width:10vw;"/>' 
                 +'<a id="lbdnicontactogestion" style="vertical-align:middle;display:inline-block;height:2vh;padding-left:1vw;width:15vw;border:solid 1px transparent;font-weight:normal;"></a>'
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Teléfono: </a><input id="telefonocontactogestion" class="datoentrada" type="text" value="" maxlength="12" style="display:inline-block;width:10vw;"/>' 
                 +'<p class="separatacam"></p>'
                 +'<a class="etiqueta etipri">Email:    </a><input id="emailcontactogestion" class="datoentrada" type="text" value="" maxlength="150" style="display:inline-block;width:25vw;"/>' 
                 +'</section>'
            +'</td>'
       +'</tr>'        
       ----------------
       --##############
       --- Ficheros
       --##############
       ----------------

       declare @css_div_ficheros varchar(max)='vertical-align:top;display:inline-block;overflow-y:auto;font-family:Roboto Condensed;font-size:0.65vw;width:14vw;border:solid 1px transparent;height:auto'
       declare @css_pg_ficheros  varchar(max)='overflow-y:auto;font-family:Roboto Condensed;font-size:0.50vw;width:13.5vw;border:solid 1px #eee;height:3vh;'
       
       set @html+=
       +'<tr><td class="eticomp" >'
             ------------------------
             -- Dni del Solicitante
             ------------------------
                                           +'<div style="'+@css_div_ficheros+'" >' 
                  +'<a class="etiqueta">Doc. DNI/Pasaporte Solicitante</a><br>'
                  +'<input type="file" '
                        +' id="fichero_dni"'
                        +' data-panelficheros="PGFiles_dni"'
                        +' value=""'
                        +' style="vertical-align:middle;display:inline-block;font-family:Roboto Condensed;font-size:0.55vw;height:2vh" '
                        +' data-max-size ="5242880" ' -- 15728640
                        +' tabla_asociada="TH_Presupuestos_WEB_'+@semilla_ficheros+'" '
                        +' codigo_tabla_asociada="1" '
                        +' title="Seleccione el fichero correspondiente al DNI/Pasaporte" '         -- CAMPO FICHERO siendo GUID el identificador a grabar en tabla_asociada
                                          +' onchange="Subeficheros_Normalizado(this, document.getElementById(''PGFiles'') );" '  -- EVENTO PARA SUBIR SIENDO primer paramámetro THIS O EL CAMPO FICHERO Y SEGUNDO PARAMETRO EL DIV DONDE SE VAN A MOSTRAR LAS EVOLUCIONES
                                                                                                    -- Genera un registro -> select f.fileName, f.tabla_asociada, f.codigo_tabla_asociada from SISTEMA_ficheros f (nolock) where f.tabla_asociada='TH_Tasadores_'+@semilla_ficheros+'' and codigo_tabla_asociada=@fk_TH_Tasadores
                  +'/><br>' 
                  +'<div id="PGFiles_dni" style="'+@css_pg_ficheros+'"></div>'  -- DIV DONDE VAN LOS NOMBRES DE FICHEROS Y LA PROGRESS BAR
              +'</div>' 
             ------------------------
             -- Nota Simple
             ------------------------
                                            +'<div style="'+@css_div_ficheros+'" >' 
                     +'<a class="etiqueta">Nota Simple(*)</a><br>'
                     +'<input type ="file"'
                           +' id   ="fichero_notasimple"'
                           +' data-panelficheros="PGFiles_notasimple"'
                           +' value=""'
                           +' style="vertical-align:middle;display:inline-block;font-family:Roboto Condensed;font-size:0.55vw;height:2vh" '
                           +' data-max-size        ="5242880" ' -- 15728640
                           +' tabla_asociada       ="TH_Presupuestos_WEB_notasimple_'+@semilla_ficheros+'" '
                           +' codigo_tabla_asociada="1" '
                           +' title="Seleccione el fichero correspondiente a la Nota Simple" '                    -- CAMPO FICHERO siendo GUID el identificador a grabar en tabla_asociada
                                             +' onchange="Subeficheros_Normalizado(this, document.getElementById(''PGFiles_notasimple'') );" '  -- EVENTO PARA SUBIR SIENDO primer paramámetro THIS O EL CAMPO FICHERO Y SEGUNDO PARAMETRO EL DIV DONDE SE VAN A MOSTRAR LAS EVOLUCIONES
                                                                                                                   -- Genera un registro -> select f.fileName, f.tabla_asociada, f.codigo_tabla_asociada from SISTEMA_ficheros f (nolock) where f.tabla_asociada='TH_Tasadores_'+@semilla_ficheros+'' and codigo_tabla_asociada=@fk_TH_Tasadores
                           +'/><br>' 
                     +'<div id="PGFiles_notasimple" style="'+@css_pg_ficheros+'"></div>'  -- DIV DONDE VAN LOS NOMBRES DE FICHEROS Y LA PROGRESS BAR
               +'</div>' 
             -----------------------------------
             -- Justificante de Autorización
             -----------------------------------
                                            +'<div style="'+@css_div_ficheros+'" >' 
                 +'<section id="sectionotrocontactogestionfichero">'
                     +'<a class="etiqueta">Justificante de Autorización</a><br>'
                     +'<input type ="file"'
                           +' id   ="fichero_justificante"'
                           +' data-panelficheros="PGFiles_justificante"'
                           +' value=""'
                           +' style="vertical-align:middle;display:inline-block;font-family:Roboto Condensed;font-size:0.55vw;height:2vh" '
                           +' data-max-size        ="5242880" ' -- 15728640
                           +' tabla_asociada       ="TH_Presupuestos_WEB_justificante_'+@semilla_ficheros+'" '
                           +' codigo_tabla_asociada="1" '
                           +' title="Seleccione el fichero correspondiente al Justificante de Autorización" '       -- CAMPO FICHERO siendo GUID el identificador a grabar en tabla_asociada
                                             +' onchange="Subeficheros_Normalizado(this, document.getElementById(''PGFiles_justificante'') );" '  -- EVENTO PARA SUBIR SIENDO primer paramámetro THIS O EL CAMPO FICHERO Y SEGUNDO PARAMETRO EL DIV DONDE SE VAN A MOSTRAR LAS EVOLUCIONES
                                                                                                                    -- Genera un registro -> select f.fileName, f.tabla_asociada, f.codigo_tabla_asociada from SISTEMA_ficheros f (nolock) where f.tabla_asociada='TH_Tasadores_'+@semilla_ficheros+'' and codigo_tabla_asociada=@fk_TH_Tasadores
                           +'/><br>' 
                     +'<div id="PGFiles_justificante" style="'+@css_pg_ficheros+'"></div>'  -- DIV DONDE VAN LOS NOMBRES DE FICHEROS Y LA PROGRESS BAR
                 +'</section>'
              +'</div>' 
             -----------------------------------
             -- Fichero Otros
             -----------------------------------
                                            +'<div style="'+@css_div_ficheros+'" >' 
                 +'<section id="sectionotrosficheros">'
                     +'<a class="etiqueta">Otros Ficheros</a><br>'
                     +'<input type ="file"'
                           +' id   ="fichero_otrosficheros"'
                           +' data-panelficheros="PGFiles_otrosficheros"'
                           +' value=""'
                           +' style="vertical-align:middle;display:inline-block;font-family:Roboto Condensed;font-size:0.55vw;height:2vh" '
                           +' data-max-size        ="5242880" ' -- 15728640
                           +' tabla_asociada       ="TH_Presupuestos_WEB_otrosficheros_'+@semilla_ficheros+'" '
                           +' codigo_tabla_asociada="1" '
                           +' title="Seleccione el fichero correspondiente a Otros Ficheros" '                      -- CAMPO FICHERO siendo GUID el identificador a grabar en tabla_asociada
                                             +' onchange="Subeficheros_Normalizado(this, document.getElementById(''PGFiles_otrosficheros'') );" ' -- EVENTO PARA SUBIR SIENDO primer paramámetro THIS O EL CAMPO FICHERO Y SEGUNDO PARAMETRO EL DIV DONDE SE VAN A MOSTRAR LAS EVOLUCIONES
                                                                                                                    -- Genera un registro -> select f.fileName, f.tabla_asociada, f.codigo_tabla_asociada from SISTEMA_ficheros f (nolock) where f.tabla_asociada='TH_Tasadores_'+@semilla_ficheros+'' and codigo_tabla_asociada=@fk_TH_Tasadores
                           +'/><br>' 
                     +'<div id="PGFiles_otrosficheros" style="'+@css_pg_ficheros+'"></div>'  -- DIV DONDE VAN LOS NOMBRES DE FICHEROS Y LA PROGRESS BAR
                 +'</section>'
              +'</div>' 
             -----------------------------------
             -- Justificante de Transferencia
             -----------------------------------
                                            +'<div style="'+@css_div_ficheros+';width:22vw;" >' 
                 +'<section id="sectiontransferencia">'
                     +'<a class="etiqueta">Justificante de Transferencia</a><br>'
                     +'<input type ="file"'
                           +' id   ="fichero_transferencia"'
                           +' data-panelficheros="PGFiles_transferencia"'
                           +' value=""'
                           +' style="vertical-align:middle;display:inline-block;font-family:Roboto Condensed;font-size:0.55vw;height:2vh" '
                           +' data-max-size        ="5242880" ' -- 15728640
                           +' tabla_asociada       ="TH_Presupuestos_WEB_transferencia_'+@semilla_ficheros+'" '
                           +' codigo_tabla_asociada="1" '
                           +' title="Seleccione el fichero correspondiente al Justificante de Transferencia" '       -- CAMPO FICHERO siendo GUID el identificador a grabar en tabla_asociada
                                             +' onchange="Subeficheros_Normalizado(this, document.getElementById(''PGFiles_transferencia''));" '   -- EVENTO PARA SUBIR SIENDO primer paramámetro THIS O EL CAMPO FICHERO Y SEGUNDO PARAMETRO EL DIV DONDE SE VAN A MOSTRAR LAS EVOLUCIONES
                                                                                                                     -- Genera un registro -> select f.fileName, f.tabla_asociada, f.codigo_tabla_asociada from SISTEMA_ficheros f (nolock) where f.tabla_asociada='TH_Tasadores_'+@semilla_ficheros+'' and codigo_tabla_asociada=@fk_TH_Tasadores
                           +'/><br>' 
                     +'<div id="PGFiles_transferencia" style="'+@css_pg_ficheros+';width:21.5vw;"></div>' -- DIV DONDE VAN LOS NOMBRES DE FICHEROS Y LA PROGRESS BAR
                 +'</section>'
              +'</div>' 
              -----------------------------------
       +'</tr>'        
       -----------------------------------
       -- Importe Manual (Datos)
       -----------------------------------
          set @html+=
       +'<tr style="height:auto;display:'+@ver_publico+'">
             <td class="datoimporte" style="text-align:left;padding-left:0px">'
              +'<div id="sectionimportemanual" style="display:inline-block;width:53vw;border:solid 1px transparent;vertical-align:bottom;padding:0px>'
                    +'<a class="etiqueta">Importe Presupuesto (sin IVA):</a>
                       <input id="importemanual" readonly class="datoentrada" type="number" value="" maxlength="8" syle="display:inline-block;text-align:right;width:6vw" min="1" max="10000" step="0.1" />

      
                       <a id="codentid"     style="vertical-align:middle;font-size:0.80vw;font-weight:normal;color:black;display:none;width:6vw;border:solid 1px transparent"></a>
                       <a id="codobjet"     style="vertical-align:middle;font-size:0.80vw;font-weight:normal;color:black;display:none;width:6vw;border:solid 1px transparent"></a>
                       <a id="ivaaplicado"  style="vertical-align:middle;font-size:0.80vw;font-weight:normal;color:black;display:inline-block;width:6vw;border:solid 1px transparent"></a>
                       <a id="totalimporte" style="vertical-align:middle;font-size:0.80vw;font-weight:normal;color:black;display:inline-block;width:8vw;border:solid 1px transparent"></a>
                      ' 
              +'</div>'
              ------------------------------------------------
              +'<div id="validacionjustificante" style="display:inline-block;width:24.5vw;border:solid 1px transparent;vertical-align:top;text-align:left;vertical-align:bottom;">'
                     +'<p style="margin-left:1vw;display:inline-block;text-align:right;width:21vw;padding-right:0px">'
                          +'<a class="btn primary"'
                                 +' onclick="if (PGFiles_transferencia.innerHTML=='''') {alert(''No existe Fichero. Incorporar Fichero previamente'');return} else {}
                                             var enc='' '+@peticion+' '';var p=enc; WEncriptHTML_General_Ext(p,1);"'                                
                          +' >Validar Importe Transferencia</a>'
                     +'</p>'
                     +'<p style="margin-left:1vw;margin-top:0.1vh;display:inline-block;text-align:right;width:21vw;padding-right:0px">'
                          +'<a class="etiqueta ">Importe:</a>'
                          +'<input id="importetransferenciavalidado" style="display:inline-block;width:4vw;font-size:0.70vw;text-align:right;" type="number" readonly style="text-align:right;width:5vw" min="1" max="80000" step="1"/>' 
                          +'<span style="display:inline-block;padding-left:3px;width:1vw;font-size:0.70vw;text-align:left;">€</span>'
                          +'<a class="etiqueta">Fecha:</a>'
                          +'<input id="fechatransferenciavalidado" style="display:inline-block;width:6vw;font-size:0.70vw;text-align:right;" type="date" readonly />'
                     +'</p>'
              +'</div>'
            +'</td>'
       +'</tr>'        

       ----------------------------
       -- Aceptación de los datos
       ----------------------------
       if @fk_usuario is null   -- si el usuario NO viene de Therion no se muestra la parte de aceptación de datos.
          begin
             set @html+=
             +'<tr><td class="eticomp">
                       <a style="display:inline-block;width:2vw;"></a>
                       <input type ="checkbox" id="aceptaciondatos" class="datoentrada" style="vertical-align:middle"/>
                       <a style="display:inline-block;width:0.5vw;"></a>
                       <a style="vertical-align:middle;font-size:0.80vw;font-weight:normal;color:black;display:inline-block;width:40vw;">
                           <b><u>Aceptación y Consentimiento de Datos</u></b>. Le informamos que los datos transmitidos serán exclusivamente usados para generar el presupesto solicitado. Por favor, acepte este cometido para poder tramitar el mismo.
                          <br><i><u>Le informamos que esta página no usa cockies propias ni de terceros</u></i>.
                       </a>
                       <br>
                       <br>
                   </td>
              </tr>'+char(10)
              set @html+=
             +'<tr id="seccionverificacion" style="height:7vh;display:;">' 
             +'    <td style="text-align:left">
                   <a class="opensans" style="text-align:justify;vertical-align:middle;font-size:0.80vw;font-weight:normal;color:red;display:inline-block;width:44vw;">
                      Por motivos de seguridad y para registrar su solicitud correctamente le enviaremos un <b><u>código por SMS</u></b> que le permitirá enviarla. Introduzca el Nº de Teléfono para recibir este código y pulse en el siguiente Icono
                   </a>
                   <br>
                   <br>
                   <a class="etiqueta etipri" style="width:20vw">Teléfono para Recibir por SMS el Código Verificación: </a>
                   <select type ="combobox" id="prefijo" class="datoentrada" name ="prefijo" title="#Introduzca Prefijo Internacional Teléfono#"
                      style="vertical-align:middle;width:9vw;height:auto;font-size:0.85vw;background:#fff;padding:2px;border:solid 1px #666;border-bottom-width:1px;text-align:left;"
                      '+@option_prefijos+'
                   ></select>
                   <input id="telefonoverificacion" class="datoentrada" type="text" value="" maxlength="12" style="display:inline-block;width:6vw;"/> 
                   <a style="display:inline-block;width:1vw;"></a>
                   #icono_verificacion#
                   </td>'
             +'</tr>'        
              set @html+=
             +'<tr id="seccionvalidacion" style="height:auto;display:none;">' 
             +'    <td style="text-align:left">
                   <div id="listavalidaciones" style="width:100%"></div> 
                   </td>'
             +'</tr>'        
             set @html+=
             +'<tr><td></td><td><p class="separatasec"></p></td></tr>'      
              set @html+=
             +'<tr id="secciongrabacion" style="height:7vh;display:;">' -- Este id debe ser llamado siempre secciongrabacion ya que el JSTHERION_EXT.js lo pone diplay 
             +' <td style="text-align:left">
                   <a class="etiqueta etipri" style="width:25vw">Introduzca el Código Recibido por SMS, y pulse en Icono enviar:</a>
                   <input id="llaveenvio" type="text" value="" maxlength="12" style="display:inline-block;width:6vw;"/> 
                   #icono_grabacion#
                </td>'
             +'</tr>'        
          end
       --------------------------------------------------------------------------------------------------
       if @fk_usuario is not null   -- si el usuario viene de Therion -- Usuario Interno (Comercial) -- Tasador o Externo 
          begin
              set @html+=
             +'<tr id="seccionvalidacion" style="height:auto;display:none;">' 
             +'    <td style="text-align:left">
                   <div id="listavalidaciones" style="width:100%"></div> 
                   </td>'
             +'</tr>'        
             --set @html+=
             --+'<tr><td></td><td><p class="separatasec"></p></td></tr>'      
             set @html+=
             +'<tr id="secciongrabacion" style="height:7vh;display:;">' -- Este id debe ser llamado siempre secciongrabacion ya que el JSTHERION_EXT.js lo pone diplay 
             +' <td style="text-align:left">
                   #icono_grabacion#
                </td>'
             +'</tr>'        
          end
       ---------------------------------------
       set @html+=
       +'<tr style="height:2vh">
           <td class="datoencargo">'
           +'<span style="font-size:0.60vw;font-weight:normal">(*) La nota simple aportada deberá tener menos de tres (3) meses de antigüedad. Tasaciones Hipotecarias S.A.U. puede solicitar este documento al Registro de la Propiedad. Coste de este servicio por Finca Registral: 20€ + IVA/IGIC/IPSI</span>'
           +'</td>'
        +'</tr>'        

         ----------------------------------------
      ----------------------------------------
      set @html+=
          +'</table>'+char(10)
      set @html+=
      +'</div>'+char(10)
      ----------------------------------------
      ----------------------------------------
      set @html+=
      +'</div>'+char(10)

      -----------------------
      -- Zonas de Disclaimer
      -----------------------

      if @fk_usuario is null
         begin
             set @html+=
              +'<div class="abajo" style="position:absolute;bottom:0.5vh;width:100%;overflow-y:hidden;margin:auto;background:black;vertical-align:top">'+char(10)
                 +'<table style="width:95%;margin:auto;">'+char(10)
                   +'<tr>'+char(10)
                     ----------- Mapa -------------- 
                     +'<td class="etiquetabajo" style="width:15%;text-align:right">'
                          +'<a href="https://goo.gl/maps/5dh9PiEjN9W9sQmN7" style="vertical-align:middle;">'
                          +'<img src="https://tasacioneshipotecarias.com/wp-content/uploads/2023/04/ubicacion-300x152.png" 
                                 style="width:12vw;height:auto;vertical-align:middle;" 
                                 decoding="async" 
                                 loading="lazy" 
                                 >
                            </a>'
                     +'</td>'
                     ----------- Contacto -------------- 
                     +'<td class="etiquetabajo" style="width:25%;vertical-align:top">'
                          +'<a style="text-align:left;font-size:120%;vertical-align:top">Contacto</a>'
                       --   +'<div style="text-align:left;border:solid 2px #92575b;width:5%"></div>'
                          +'<ul>'
                             +'<li class="itemabajo"><a class="itemabajo" >C/de Labastida,9-11 28034 Madrid</a></li>'
                             +'<li class="itemabajo"><a class="itemabajo" href="mailto:atencionalcliente@tasacioneshipotecarias.com">atencionalcliente@tasacioneshipotecarias.com</a></li>'
                             +'<li class="itemabajo"><a class="itemabajo" >+34 914 549 700.</a></li>'
                          +'</ul>'
                     +'</td>'
                     ----------- Legal -------------- 
                     +'<td class="etiquetabajo" style="width:20%;vertical-align:top">'
                          +'<a style="text-align:left;font-size:120%;vertical-align:top">Legal</a>'
                        --  +'<div style="text-align:left;border:solid 2px #92575b;width:5%"></div>'
                          +'<ul>'
                             +'<li class="itemabajo"><a class="itemabajo" href="https://tasacioneshipotecarias.com/terminos-y-condiciones/">Términos y condiciones</a></li>'
                             +'<li class="itemabajo"><a class="itemabajo" href="https://tasacioneshipotecarias.com/politica-de-privacidad/">Política de Privacidad</a></li>'
                             +'<li class="itemabajo"><a class="itemabajo" href="https://tasacioneshipotecarias.com/politica-de-cookies/">Política de Cookies</a></li>'
                          +'</ul>'
                     +'</td>'
                     ----------- Legal -------------- 
                     +'<td class="etiquetabajo" style="width:20%;vertical-align:top">'
                          +'<a style="text-align:left;font-size:120%;vertical-align:top">Legal</a>'
                        --  +'<div style="text-align:left;border:solid 2px #92575b;width:5%"></div>'
                          +'<ul>'
                             +'<li class="itemabajo"><a class="itemabajo" href="https://tasacioneshipotecarias.com/contact/atencion-al-cliente/">Atención al cliente</a></li>'
                             +'<li class="itemabajo"><a class="itemabajo" href="https://tasacioneshipotecarias.com/about/politica-de-calidad/">Política de Calidad</a></li>'
                          +'</ul>'
                     +'</td>'
                     ----------- Grupo -------------- 
                     +'<td class="etiquetabajo" style="width:auto">'
                     --     +'<a style="text-align:left;font-size:120%;vertical-align:top">Grupo ATValor</a>'
                     --     +'<div style="text-align:left;border:solid 2px #92575b;width:5%"></div>'
                         +'<a href="https://tasacioneshipotecarias.com/wp-content/uploads/2021/04/grupo-atvalor-scaled.jpg">
                          <img src="https://tasacioneshipotecarias.com/wp-content/uploads/2021/04/grupo-atvalor-214x300.jpg" 
                               style="width:8vw;height:15vh"
                               decoding="async" 
                               loading="lazy" 
                           >
                           </a>'              
                     +'</td>'
                     ----------- Legal -------------- 
                 +'</tr>'+char(10)
                 +'</table>'+char(10)
             +'</div>'+char(10)
         end

      set @html=replace(@html,'#icono_grabacion#'   ,@ico_grabacion)
      set @html=replace(@html,'#icono_verificacion#',@ico_verificacion)
      set @html=replace(@html,'#icono_validacion#'  ,@ico_validacion)

      ----------------------   
         
      select isnull(@html,'No existen datos')

      ------------------------------------------------------------------------- 
      -- Dar de Alta el registro del Presupuesto (cuando es de un comercial)
      -------------------------------------------------------------------------

      if @fk_usuario is not null
         begin
           declare @cod_TH_Presupuestos_Web int
           insert into TH_Presupuestos_Web 
                 (codigo_presupuesto
                 ,fk_usuarios
                 ,fecha_registro
                 )
           select [codigo_presupuesto]    =@semilla_verificacion
                 ,[fk_usuario]            =@fk_usuario
                 ,[fecha_registro]        =getdate()
           set @cod_TH_Presupuestos_Web=scope_identity()
         end

      ------------------------

      set @paso=space(len(@prbbdd))+' -> Fin'; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fis,getdate())) set @fis=getdate() raiserror(@mess,10,1,0) with nowait
      set @paso=@prbbdd+' ======================================================================='; set @mess=@paso; raiserror(@mess,10,1,0) with nowait
   
end try begin catch
      
    while @@trancount>0 begin rollback end
    select
       '<resultado>KO</resultado><error>'+error_message()+'</error><salida></salida>'

end catch    

end

GO
