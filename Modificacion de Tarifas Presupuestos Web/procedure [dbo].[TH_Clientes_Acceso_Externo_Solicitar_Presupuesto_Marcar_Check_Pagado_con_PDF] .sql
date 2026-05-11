SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

        @cod_TH_Presupuestos_Web int 
       ,@usuario                 int
as
begin	
   begin try

         update l
            set l.chk_conciliada_transferencia  =1
               ,l.fecha_conciliada_transferencia=getdate()
               ,l.usuario_concilia_transferencia=us.descripcion
		       from TH_Presupuestos_Web l
         outer apply(select top 1 us.descripcion from usuarios us (nolock) where us.codigo=@usuario) us
         where l.codigo=@cod_TH_Presupuestos_Web
         
         select 'OK'

    end try
    begin catch
          select 'ERROR: '+error_message()
    end catch

end

*/


ALTER procedure [dbo].[TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Check_Pagado_con_PDF] 
      ( @cod_TH_Presupuestos_Web int 
       ,@usuario                 int
       ,@debug                   bit=0
      )

as 

------------------------------------------
set nocount on
set dateformat dmy
set transaction isolation level read uncommitted
------------------------------------------

begin

declare @prbbdd       varchar(300)=object_name(@@procid)
       ,@paso         char(100)='Sin Iniciar'
       ,@mess         varchar(max)
       ,@npaso        int=0
       ,@fecha_inicio datetime=getdate()
       ,@trancount    int=@@trancount
       ,@traza        varchar(max)

begin try

      set @paso='       '+@prbbdd+' -> Inicio'; set @mess=@paso+' -> '+convert(varchar,datediff(ms,@fecha_inicio,getdate())) set @fecha_inicio=getdate() raiserror (@mess,10,1) with nowait

      ------------------------------------------------------------------      
      -- declare @dfecha_aspx datetime=convert(datetime, @fecha_aspx, 121)
      ------------------------------------------------------------------

      declare @fuentecorportativa varchar(200)='Roboto Condensed'
      declare @radius             varchar(80)='1vw 1vw 1vw 1vw'
             ,@sombra             varchar(80)='0px 1px 10px -5px rgba(0,0,0,1)'
             ,@sombra_des         varchar(80)='0px 10px 30px -15px rgba(255,255,255,1)'
       
      declare @html varchar(max)=''

      ---------------------------------------------------------------------

      --set @html+=
      --+'<style type="text/css">'
      --   +' div.saltopag    {display:block;page-break-before:always;}'
      --   +' td.etiqueta     {width:10% ;color:gray;font-size:0.70vw;font-weight:normal;padding-right:0.5vw;text-align:right;vertical-align:middle;border-bottom:solid 1px #aaa}'
      --   +' td.etiticket    {width:30% ;color:#5555AA;font-size:0.70vw;font-weight:normal;padding-right:0.5vw;text-align:right;vertical-align:middle;border-bottom:solid 0px #aaa}'
      --   +' td.datorejilla  {font-size:0.8vw;font-weight:normal;text-align:left;vertical-align:middle;border:solid 1px #aaa}'
      --   +' th.titulo       {border:solid 1px #fff}'
      --   +' td.cen          {text-align:center}'
      --   +' td.sep          {padding-left:0.5vw;}'
      --   +' td.datoencargo  {width:auto;color:#000000;font-size:1.2vw;font-weight:bold  ;padding-left :0.5vw;text-align:left ;vertical-align:middle;}'
      --   +' input.datoalta, select.datoalta  {display:inline-block;width:7vw;color:#000000;font-size:0.8vw;font-weight:normal;padding-left:0.1vw;text-align:left;vertical-align:middle;background:rgba(255,253,231,0.5)}'
      --   +' input.datoalta, select.datoalta  {display:inline-block;width:7vw;color:#000000;font-size:0.8vw;font-weight:normal;padding-left:0.1vw;text-align:left;vertical-align:middle;}'
      --   +' input.datotime  {display:inline-block;width:5vw;color:#000000;font-size:0.7vw;font-weight:normal;padding-left:0.1vw;text-align:left;vertical-align:middle;}'
      --   +' td.titulo       {width:auto;background:#1B5494;opacity:1;vertical-align:middle;font-size:1.1vw;font-weight:bold;padding-left:2vw;color:white;'
      --                      +';border-radius:'+@radius+';-ms-border-radius:'+@radius+';-moz-border-radius:'+@radius+';-webkit-border-radius:'+@radius+';-khtml-border-radius:'+@radius
      --                      +';box-shadow:'+@sombra+';-webkit-box-shadow:'+@sombra+';-moz-box-shadow:'+@sombra+';-ms-box-shadow:'+@sombra+';-o-box-shadow:'+@sombra+'} div.cita:hover {overflow:auto}'
      --   +'img.icograbar    {cursor:pointer;vertical-align:middle;width:2.5vw;height:auto;transition:500ms;} img.icograbar:hover {transform: scale(1.2);transition:500ms;}'
      --   +'  a.acciones     {cursor:pointer;display:inline-block;width:9vw;height:2vh;vertical-align:middle;font-weight:bold;text-aling:center;border:solid 0px #000;background:#aaa;padding:0px;'
      --                      +';border-radius:'+@radius+';-ms-border-radius:'+@radius+';-moz-border-radius:'+@radius+';-webkit-border-radius:'+@radius+';-khtml-border-radius:'+@radius+'
      --                      }   
      --       a.acciones:hover {transform: scale(1.2);transition:500ms;}'
      --+'</style> '

      ----------------------
      -- Cabecera de Página 
      ----------------------
      
      set @html+=
       +'<div id="Principal" style="font-family:'+@fuentecorportativa+';border:solid 0px #a00;width:100%;overflow-y:auto;margin:auto;">'
      
      --#############################################
      -----------------------------------------------
      -- Panel para Editar
      -----------------------------------------------
      --#############################################

      declare @url_fichero         varchar(max)
      declare @extension           varchar(10)
      declare @importe_presupuesto decimal(19,2)
      declare @obj_fichero         varchar(max)
      declare @fecha_transferencia varchar(10)

      select @url_fichero        ='data:application/'+replace(lower([ext].ext),'jpeg','jpg')+';base64,'+dbo.f_BinaryToBase64(f.fileBynari)
            ,@extension          =replace(lower([ext].ext),'jpeg','jpg')
            ,@importe_presupuesto=l.importe_pago_total
            ,@fecha_transferencia=format(l.fecha_pago_transferencia,'yyyy-MM-dd')
      from TH_Presupuestos_Web l (nolock)
      outer apply (select top 1 [fileId]=a.items from dbo.f_split(l.fichero_transferencia,';') a order by a.i desc ) [jus]
      inner join SISTEMA_ficheros f (nolock) on f.fileId=[jus].fileId
      outer apply (select top 1 [ext]=a.items from dbo.f_split(f.fileName,'.') a order by a.i desc) [ext]
      where l.codigo=@cod_TH_Presupuestos_Web

      if @extension='pdf'
         begin
            set @obj_fichero='<embed style="display:inline-block;width:35vw;height:55vh" src="'+@url_fichero+'" type="application/'+@extension+'"/>'
         end
      else
        begin
           set @obj_fichero='<img style="display:inline-block;width:35vw;height:55vh;object-fit:contain" src="'+@url_fichero+'" />'
        end

      if @obj_fichero is null 
         begin
            set @obj_fichero='<div style="font-size:2vw;display:inline-block;width:35vw;height:55vh;">EL FICHERO DE TRANSFERENCIA NO HA SIDO POSIBLE MOSTRARLO</div>'
         end

      ---------------------------------------------
      
      declare @reponer_capa varchar(max)=
      '  var aCapaLevantada=document.getElementById(imgcontrolcapa.dataset.idcapa);
         if (aCapaLevantada) {
             aCapaLevantada.style.width =imgcontrolcapa.dataset.oldwidth;
             aCapaLevantada.style.height=imgcontrolcapa.dataset.oldheight;
             aCapaLevantada.style.left  =imgcontrolcapa.dataset.oldleft;
             aCapaLevantada.style.top   =imgcontrolcapa.dataset.oldtop;
            };
         var acerrarizquierda=document.getElementById(''cerrarizquierda_''+p_capa_entrada);
         var acerrarderecha  =document.getElementById(''cerrarderecha_''  +p_capa_entrada);
         if (acerrarizquierda) {acerrarizquierda.style.display=''''};
         if (acerrarderecha)   {acerrarderecha.style.display  =''''};
      '

      declare @grabar_importe_pago varchar(max)=
      '  
         var errores = [];
     
         if (importetransferencia.value=='''') errores.push(''Informar del Importe de la transferencia'');
         if(conceptotransferencia.value=='''') errores.push(''Informar del Concepto de la transferencia'');
         
         if (errores.length > 0) { alert(errores.join(''\n'')); return }
        
         var diferencia=importepagar.value-importetransferencia.value;
         var sSQL=''exec TH_Clientes_Acceso_Externo_Solicitar_Presupuesto_Marcar_Check_Pagado_con_importe'
                 +' @cod_TH_Presupuestos_Web='+format(@cod_TH_Presupuestos_Web,'0')+''
                 +',@usuario='+format(@usuario,'0')+''
                 +',@importe=''+importetransferencia.value+'',@conceptotransferencia=·''+conceptotransferencia.value+''·''+'', @fechatranferencia=·''+fechatransferencia.value+''·'';
         //alert(sSQL); 
         WSQL(sSQL); 
         '+@reponer_capa+'
         WCancela_Registro();
      '

      declare @cancelar_importe_pago varchar(max)=
      '  '+@reponer_capa+'
         WCancela_Registro();
      '

      declare @html_panel_datos varchar(max)=''
      set @html_panel_datos+=
      +'<div id="panelacciones" style="border:solid 0px #a00;height:100%;width:90%;overflow-y:auto;margin:auto;text-align:left;vertical-align:top">'
          +isnull(@obj_fichero,'')
          +'<div style="vertical-align:top;display:inline-block;width:10vw;height:45vh;border:solid 1px transparent;padding-left:1vw;">'
            +'<br><br><br>'+'<span style="padding-right:1vw;font-size:1vw;">Importe Presupuesto:</span>'
            +'<br>'+'<input id="importepagar" readonly style="display:inline-block;width:10vw;font-size:1.5vw;text-align:right;padding:10px;" type="number" step="0.01" value="'+format(isnull(@importe_presupuesto,0),'0.00','us-US')+'" />'
            +'<br><br>'+'<span style="padding-right:1vw;font-size:0.7vw;"><i>Para verificar el check de pago, por favor, informa en siguiente campo el importe indicado en el documento y pulsa en OK. Para salir sin confirmar pulsa en Icono Cancelar.</i></span>'
            
            +'<br><br>'+'<span style="padding-right:1vw;font-size:1vw;">Importe Transferencia:</span>'
            +'<br>'+'<input id="importetransferencia" style="display:inline-block;width:10vw;font-size:1.5vw;text-align:right;padding:10px;" type="number" step="0.01" />'
             +'<br><br>'+'<span style="padding-right:1vw;font-size:1vw;">Concepto Transferencia:</span>'
            +'<br>'+'<textarea id="conceptotransferencia" style="display:inline-block;width:10vw;min-width:10vw;min-height:10vh;font-size:0.75vw;text-align:right;padding:10px;" type="text"></textarea>'
            +'<br><br>'+'<span style="padding-right:1vw;font-size:1vw;">Fecha Transferencia:</span>'
            +'<br>'+'<input id="fechatransferencia" style="display:inline-block;width:10vw;font-size:1vw;text-align:right;padding:10px;" type="date" value="'+isnull(@fecha_transferencia,'')+'"/>'

            +'<br><br>'
            +'<span style="display:inline-block;width:2vw"></span>'+'<img class="aumenta" title="Aceptar y Salir" style="cursor:pointer;display:inline-block;width:2vw;height:auto" src="img/ok_transferencia.png" onclick="'+@grabar_importe_pago+'"/>'
            +'<span style="display:inline-block;width:2vw"></span>'+'<img class="aumenta" title="Cancelar" style="cursor:pointer;display:inline-block;width:2vw;height:auto" src="img/ko_transferencia.png" onclick="'+@cancelar_importe_pago+'"/>'
          +'</div>'
      +'</div>'

      set @html+=@html_panel_datos

      ------------------------------------------------------------------
      ------------------------------------------------------------------

      set @html+=
      +'</div>'
      +'<img id="imgcontrolcapa" style="display:none" src="img/aviso_ok.png" data-idcapa="" data-oldwidth="" data-oldheight="" data-oldleft="" data-oldtop=""
             onload="
             //------------------------------
             // Captar última capa levantada
             //------------------------------
             var aCapas=document.getElementsByClassName(''panelcapa'');
             var aCapaLevantada;
             var capalevantada=''_capa''+p_capa_entrada;
             for (var i=0; i< aCapas.length; i++) {
                 var aCapa=aCapas[i];
                 if (aCapa.parentElement.id.indexOf(capalevantada)>0) {
                     aCapaLevantada=document.getElementById(aCapa.parentElement.id);
                    };
             }             
             if (aCapaLevantada) {
                 //------------------------------------------
                 // Guardar los datos de la capa para reponer
                 //------------------------------------------
                 imgcontrolcapa.dataset.idcapa   =aCapaLevantada.id;
                 imgcontrolcapa.dataset.oldwidth =aCapaLevantada.style.width;
                 imgcontrolcapa.dataset.oldheight=aCapaLevantada.style.height;
                 imgcontrolcapa.dataset.oldleft  =aCapaLevantada.style.left;
                 imgcontrolcapa.dataset.oldtop   =aCapaLevantada.style.top;
                 var acerrarizquierda=document.getElementById(''cerrarizquierda_''+p_capa_entrada);
                 var acerrarderecha  =document.getElementById(''cerrarderecha_''  +p_capa_entrada);
                 if (acerrarizquierda) {acerrarizquierda.style.display=''none''}
                 if (acerrarderecha)   {acerrarderecha.style.display  =''none''}
                 //---------------------------------
                 // Poner nuevos valores de posicion
                 //---------------------------------
                 aCapaLevantada.style.width =''55vw'';
                 aCapaLevantada.style.height=''60vh'';
                 aCapaLevantada.style.left  =''22vw'';
                 aCapaLevantada.style.top   =''20vh'';
                 importetransferencia.focus();
                };
             //-----------------------------------------
             " 
       />'

      select 
       '<resultado>OK</resultado>'
      +'<error></error>'
    --+'<cssdiv>background:#ff0;position:absolute;left:25%;top:20%;width:50vw;height:55vh;text-align:center; border:solid 3px #5A99D4; display:table-cell;vertical-align:middle;box-shadow: 0px 0px 15px #5A99D4;</cssdiv>'
      +'<nombre_ventana><a style="color:red;font-weight:bold;font-size:1.50vw;">Check Pago</a></nombre_ventana>'
      +'<salida>'+isnull(@html,'No existen datos')+'</salida>'
   
end try begin catch
    
    while @@trancount>0 begin rollback end

    declare @p_error varchar(2000)
    set @p_error= 'ERROR EN EL SISTEMA DE DATOS.'+char(13)
                 +'IT Recibirá un Correo informando del mismo para solucionar el problema.'+char(13)

    declare @error_email varchar(max)
    set @error_email= 'NºErr: '+isnull(convert(varchar(300),ERROR_NUMBER()),'')+char(13)+char(13)
                     +'Proc.: '+@prbbdd+char(13)+char(13)
                     +'Línea: '+isnull(convert(varchar(300),ERROR_LINE()),'')+char(13)+char(13)
                     +'Error: '+isnull(convert(varchar(300),ERROR_MESSAGE()),'')+char(13)+char(13)

    set @error_email=replace(replace(@error_email,char(13),'<br/>'),char(10),'<br/>')

    --------------------------------------------------------------------
    --------------------------------------------------------------------
    select 'ERROR: '+ERROR_MESSAGE()
    --------------------------------------------------------------------
    --------------------------------------------------------------------
end catch    

end
GO
